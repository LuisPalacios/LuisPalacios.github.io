---
title: "SSH con 1Password"
date: "2026-09-04"
categories: ["administración"]
tags:
  [
    "1password",
    "ssh",
    "ssh-agent",
    "git",
    "homelab",
    "seguridad",
    "windows",
    "wsl",
    "macos",
    "linux",
  ]
draft: true
cover:
  image: "/img/posts/logo-1password-ssh.svg"
  hidden: true
---

<img src="/img/posts/logo-1password-ssh.svg" alt="Logo SSH con 1Password" width="150px" height="150px" style="float:left; padding-right:25px" />

Hace unas semanas aparqué mi ["Bitwarden casero"]({{< relref "2025-03-02-bitwarden.md" >}}) y me pasé a 1Password con el plan familiar. Sí, hay que pagar, pero compartir con la familia y la facilidad de uso lo compensan. Al poco de migrar las contraseñas me encontré con la pestaña _Developer_ y su **agente SSH**: las claves privadas viven en la caja fuerte (el vault), se sincronizan solas entre mis tres máquinas y cada uso se autoriza con la huella o con Windows Hello.

Por cierto, luego descubrí que Bitwarden también tiene agente SSH desde principios de 2025. Todos los días se aprende algo nuevo.

Sonaba demasiado bien, así que me puse a investigar en serio si me valía para mi caso: puestos de trabajo multiplataforma (macOS, Windows, Linux), acceso a muchos servidores, switches con un SSH de otra época, y cada vez más scripts y agentes de IA lanzando `ssh` sin que yo esté delante. En este apunte cuento lo que he aprendido, cómo lo he configurado y dónde NO lo uso.

<br clear="left"/>
<!--more-->

## El problema

Llevo usando claves SSH desde el siglo pasado, y con los años el asunto se me ha ido de las manos. Lo empleo desde varias máquinas: Linux, Windows (con Git Bash, PowerShell y WSL) y un Mac. Todas con su `~/.ssh/config` "equivalente" con docenas de `Host`, y en cada una hay un puñado de ficheros `id_*` que en teoría son los mismos pero que en la práctica sincronizo a mano y de vez en cuando descubro que no lo son.

Los destinos tampoco son pocos: servidores y máquinas virtuales en casa, equipos de red con un SSH de otra época, algún servidor en Internet, máquinas de familiares a las que llego por VPN y, de vez en cuando, servidores de clientes donde soy invitado y me imponen su clave.

Y luego está cómo los uso. Sesiones interactivas y desde hace un tiempo, doy permiso y hago scripting desde [caparazones IA en la terminal]({{< relref "2026-04-25-modo-ia-en-la-terminal.md" >}}), llamando al `ssh` del sistema sin TTY y con `BatchMode=yes`.

La pregunta era sencilla: ¿el agente SSH de 1Password aguanta todo esto o me va a dejar tirado a la primera de cambio?

Respuesta corta: **sí, aguanta**, y me quedo con él. Para todo lo que hago estando yo delante, incluidos los scripts y los agentes de IA lanzados desde mi terminal, funciona de maravilla. Lo único que dejo fuera es lo que corre solo sin nadie delante (cron, runners), que sigue con claves de fichero bien restringidas.

## Cómo funciona SSH

Un pequeño recordatorio sobre cómo habla `ssh` con el servidor SSH. Al conectar, cliente y servidor negocian algoritmos, intercambian claves y el servidor se identifica con su clave de host. De ahí salen dos cosas: un **canal cifrado** y un **identificador de sesión**, un valor único para esa conexión que conocen los dos extremos y nadie más. Solo entonces empieza la autenticación del usuario.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-01.png" alt="Autenticación SSH con clave pública en cinco pasos: canal cifrado, oferta de clave pública, aceptación, firma del identificador de sesión y apertura de sesión" width="700px" />
  <div class="image-caption">El servidor nunca ve la clave privada: solo comprueba una firma con la pública que tiene en authorized_keys.</div>
</div>

Con la conexión ya cifrada, la autenticación con clave pública son dos rondas:

1. **Sondeo.** El cliente le manda al servidor una clave pública y le pregunta, sin firmar nada, "¿aceptarías esta clave para este usuario?". El servidor mira su `authorized_keys` y contesta sí o no. Si es no, el cliente prueba con la siguiente clave que tenga.
2. **Prueba.** Si es sí, el cliente firma el identificador de sesión con la clave privada y le manda la firma. El servidor la comprueba con la clave pública que tiene guardada y, si cuadra, abre la sesión. Si no cuadra, es un intento fallido más y el cliente pasa a la siguiente clave.

No hay ningún desafío enviado por el servidor. Lo que se firma es el identificador de sesión, que cumple la misma función: es único por conexión, así que una firma capturada no sirve para otra.

Dos detalles de este baile importan más adelante:

- **El cliente ofrece claves en orden** (paso ②), y cada "no la acepto" cuenta como un intento fallido contra el límite del servidor, `MaxAuthTries`, que por defecto es 6. Con muchas claves y la buena al final, te comes un `Too many authentication failures` antes de llegar a ella.
- **La clave privada solo se usa en el paso ④.** Preguntar "¿aceptas esta clave?" (paso ②) no necesita firmar nada, así que un agente que pide confirmación solo te la pide una vez: para la clave que el servidor ya ha aceptado, aunque antes haya ofrecido cinco.

Todo esto se ve con `ssh -v`:

```text
debug1: Offering public key: SSH Homelab ED25519 SHA256:... agent
debug1: Server accepts key: SSH Homelab ED25519 SHA256:... agent
debug1: Authentication succeeded (publickey).
```

## Cómo funciona con el agente

El agente de 1Password implementa el protocolo estándar de `ssh-agent`, así que para el cliente OpenSSH no hay nada nuevo. El baile con el servidor es el de la sección anterior; lo que cambia es la segunda ronda: cuando toca firmar el identificador de sesión, `ssh` no tiene la clave privada. Se la pide a un agente y recibe la firma de vuelta. Lo único que cambia con 1Password (o Bitwarden) es quién es ese agente y dónde vive la clave.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-02.png" alt="Flujo de una autenticación SSH con el agente de 1Password: el servidor pide la firma, el cliente la delega por el socket del agente y 1Password devuelve solo la firma" width="800px" />
  <div class="image-caption">El cliente ssh habla con 1Password por Socket/Named pipe; la clave privada nunca sale del proceso de 1Password.</div>
</div>

El flujo, paso a paso:

1. El cliente `ssh` (o `git`, `scp`, lo que sea) se conecta al servidor `sshd` y le va ofreciendo claves públicas. Cuando el servidor acepta una de su `authorized_keys`, toca demostrar que se tiene la privada: **firmar el identificador de sesión**.
2. El cliente no tiene esa clave privada. Se conecta al agente a través de un **socket Unix** en macOS y Linux, o de un **named pipe** en Windows, y le pide que firme ese identificador con ella.
3. 1Password comprueba si está desbloqueado (si no, te pide desbloquear), mira si ese proceso ya tiene autorización para esa clave y, si no, te pide **autorización biométrica**: Touch ID en el Mac, Windows Hello en Windows, PolKit o PAM en Linux.
4. Firma dentro de su propio proceso y devuelve **solo la firma**.
5. `ssh` reenvía esa firma al servidor, que la comprueba con la clave pública de `authorized_keys` y si coincide abre la sesión.

¿Y de dónde saca el cliente las claves públicas que ofrece en el paso 1? Se las pide al agente nada más arrancar, y 1Password contesta con las que tiene disponibles en el vault. Por eso importa el orden en que las ofrece, como veremos.

Lo importante es que la clave privada nunca sale de 1Password: no está en disco sin cifrar, no se carga en la memoria de `ssh` ni de tu shell, y con el vault bloqueado el agente ni siquiera la tiene en memoria. Las claves públicas sí se guardan en disco para poder mostrarte el prompt de autorización aunque 1Password esté bloqueado.

### Qué claves ve el agente

Por defecto el agente ofrece **todas** las claves SSH que tengas en el vault Personal (o Private, o Employee, según el tipo de cuenta). Las de otros vaults no se ofrecen. Si quieres cambiar eso, o controlar el **orden** en que se ofrecen, existe el fichero `agent.toml`. Lo veremos en detalle más adelante, porque el orden importa más de lo que parece.

### Y comparado con lo de siempre

Dicho de otra forma, ¿qué gano frente a las alternativas que ya conocía?

El **`ssh-agent` de toda la vida** carga la clave descifrada en memoria una vez y no vuelve a preguntar. Cómodo, pero la clave sigue viviendo en un fichero de cada máquina y la sincronización es cosa tuya. **gpg-agent** con subclaves de autenticación hace algo parecido con mucha más ceremonia; lo usé años y no lo echo de menos. Las **llaves hardware** (YubiKey, claves `sk-*` FIDO2) son las que mejor aíslan la clave, pero exigen tocar la llave en cada operación y cada dispositivo es una clave distinta, así que la sincronización entre tres máquinas se convierte en tres llaves. Los **certificados SSH** con una CA son la solución "de empresa": credenciales de corta duración y nada de `authorized_keys`, pero montar y mantener la CA para un homelab es matar moscas a cañonazos, y mis switches ni los entienden.

1Password se queda en un punto intermedio muy razonable: aislamiento del proceso, autorización biométrica por uso, sincronización automática y cero ficheros privados en disco. A cambio, necesita la aplicación de escritorio abierta y desbloqueada. Y ahí está la pega.

## El veredicto: modelo híbrido

Después de darle vueltas, mi conclusión es que no es "todo o nada". El agente de 1Password se queda con:

- Las **sesiones interactivas** a cualquier destino.
- El **scripting desde el workstation**, incluidos órdenes de tipo heredoc como `sudo -n bash -s` y los pipes con `tar`.
- Los **agentes de IA** (Claude Code y compañía) que lanzo desde una sesión de escritorio desbloqueada.
- Todo lo que sea **Git** por SSH: Forgejo, GitHub y la firma de commits.

Y las claves de fichero clásicas se quedan con todo lo que no tiene a nadie delante de una pantalla:

- **Cron y timers de systemd** que corren en los servidores (backups, sincronizaciones entre máquinas).
- Los **runners de Forgejo Actions** y cualquier CI.
- Scripts que corren en servidor tipo Proxmox o en la VM router, sin sesión de usuario.

Para esos casos la clave vive en disco con `chmod 600` y, sobre todo, se restringe en el `authorized_keys` del destino: `command="..."`, `no-port-forwarding`, `no-agent-forwarding`, `no-pty`. Una clave headless que solo puede ejecutar un script concreto es un riesgo asumible; una clave headless con shell completa no lo es.

Ojo: esto no es una limitación exótica de 1Password. Cualquier agente que pida autorización a una persona falla exactamente igual cuando no hay persona.

## ¿Cuántas claves?

Hay cuatro estrategias razonables:

- **Una clave para todo.** La más cómoda y la peor idea: si se compromete, tienes que cambiarla en todos los `authorized_keys` del mundo el mismo día. Y en los logs de los servidores no distingues nada.
- **Una clave por host.** El extremo opuesto. Revocar es trivial, pero con docenas de destinos el mantenimiento es un infierno y, como veremos ahora, empiezas a chocar con `MaxAuthTries`.
- **Una clave por workstation.** Tres claves, tres máquinas. Es lo que tenía antes y tiene su lógica: si me roban el portátil, revoco una clave. Pero con 1Password pierde el sentido, porque la clave ya no está atada a la máquina.
- **Una clave por propósito.** Agrupar destinos por "dominio de confianza": si cae uno, el radio de la explosión se queda dentro de ese grupo.

Me quedo con la última. Empecé con cinco claves y acabé con seis, porque el switch antiguo necesita su propia clave RSA y no quería arrastrar RSA al resto de la red:

| Clave            | Tipo    | Destinos                                                        |
| ---------------- | ------- | --------------------------------------------------------------- |
| `Homelab`        | ed25519 | Servidores, VMs y contenedores de casa                          |
| `Network`        | ed25519 | Controlador wireless y equipos de red con firmware actual       |
| `Network Legacy` | RSA     | Switch principal con firmware antiguo (solo entiende `ssh-rsa`) |
| `VPS`            | ed25519 | Máquinas virtuales en la nube (AWS, GCP, OVHcloud...)           |
| `Clientes`       | ed25519 | Casas de familiares y clientes que aceptan mi clave             |
| `Git`            | ed25519 | Forgejo y GitHub (y firmar commits, si quieres)                 |

Pocas claves también tiene una ventaja práctica: quedarse por debajo del límite de intentos del servidor. Cuando te conectas, el agente va ofreciendo claves públicas una a una hasta que el servidor reconoce una. Cada clave rechazada cuenta como un intento fallido aunque el servidor nunca haya pedido una firma. El `sshd` de OpenSSH trae `MaxAuthTries 6` por defecto, así que con siete claves en el agente y mala suerte en el orden te encuentras con esto:

```text
Received disconnect from 192.168.1.10 port 22:2: Too many authentication failures
```

Me pasó el primer día de la migración: un host que aún no tenía `IdentitiesOnly`, ocho claves en el agente y la buena al final. Diez segundos de susto y una lección bien aprendida.

Hay dos formas de evitarlo, y yo uso las dos:

**Desde el cliente**, con `IdentitiesOnly yes` en cada `Host` y un `IdentityFile` que apunta a la **clave pública** (`.pub`) descargada de 1Password. OpenSSH admite explícitamente indicar solo la pública para usar la privada correspondiente del agente. Así `ssh` solo pide esa clave y no hay ronda de pruebas. Las descargo desde la app (botón _Download_ en el campo _Public key_ del item) y las guardo en `~/.ssh/keys/`.

**Desde el agente**, con `agent.toml`: el orden de los bloques `[[ssh-keys]]` es el orden en que se ofrecen las claves. Las de uso más frecuente, arriba.

{{< codefile path="snippets/2026-09-04-ssh-con-1password/agent.toml" lang="toml" title="agent.toml — orden y visibilidad de las claves" >}}

Dos avisos sobre este fichero. Uno: en cuanto existe, aunque esté vacío, anula la regla por defecto y solo se ofrecen las claves listadas. Dos: un error de sintaxis para el agente entero, y te enteras en _Settings > Developer_. No hace falta reiniciar nada al editarlo, pero la primera vez que lo creas puede que tengas que bloquear y desbloquear 1Password. Y tres detalles que aprendí montándolo: el campo `vault` es opcional, y si el nombre del vault no coincide exactamente el agente se queda sin claves, así que yo lo omito. El agente relee el fichero en cuanto lo guardas, sin reiniciar nada, y lo compruebas con `ssh-add -l`. Y es un fichero por máquina: no viaja con el vault, hay que copiarlo a cada equipo.

## Configuración por plataforma

Vamos a ver la puesta en marcha en cada máquina. En todas empieza igual: _Settings > Developer > Use the SSH Agent_. Lo distinto es dónde escucha el agente y qué cliente SSH le habla.

Nada más activarlo, y esto es igual en macOS, Windows y Linux, 1Password pregunta si puede **guardar los nombres de las claves SSH en disco**, con dos botones: _Use key names_ (el que viene marcado) o _Use key fingerprints only_. Lo que guarda en claro son los títulos de los items, no las claves, y sirve para que el prompt de autorización te diga "SSH Homelab" en vez de un fingerprint recortado cuando 1Password está bloqueado. Yo dejo el valor por defecto (_Use key names_): el nombre de un item no es un secreto y me ahorra descifrar hashes a las tantas. Se cambia luego en _Settings > Developer_, casilla _Display key names when authorizing connections_.

### macOS

Tras contestar lo de los nombres, 1Password abre la ventana _Configure SSH agent_ con un extracto para `~/.ssh/config` y dos botones: _Edit Automatically_ o _Copy snippet_. El extracto es este:

```text
Host *
  IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Mi recomendación: **no dejes que lo edite**. Ese `Host *` es, línea por línea, el contenido de `~/.ssh/config.d/macos.conf` (ver más abajo), y quiero que viva ahí, incluido al final del fichero base, para que no pise el `IdentityAgent none` de los clientes. Pulsa _Copy snippet_, si quieres pégalo en `~/.ssh/config.d/macos.conf` y cierra la ventana; no pregunta nada más. Si ya le diste a _Edit Automatically_, abre `~/.ssh/config`, corta el bloque `Host *` que ha añadido y muévelo a `macos.conf`.

Ese extracto es también la pista de dónde está el socket, que en macOS vive en un sitio poco amigable. 1Password sugiere un enlace simbólico opcional para tener algo más corto:

```bash
mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
```

Yo no lo uso: la ruta larga va en `macos.conf` y no toco `SSH_AUTH_SOCK`.

Si usas `ControlMaster` en el Mac, ten en cuenta que las conexiones ya abiertas no vuelven a autenticar: un cambio de clave no se nota hasta que caduca el socket, y puedes creer que algo funciona cuando no. Para probar de verdad, `ssh -o ControlPath=none host`.

Además, en _Settings > General_ dejo activados _Keep 1Password in the menu bar_ y _Start at login_: si cierras la app, el agente muere con ella. Con eso, tras un reinicio no hace falta ni abrir 1Password: el primer `ssh` te pide la huella, y ese mismo gesto desbloquea el vault y firma.

### Linux

Aquí el socket es `~/.1password/agent.sock` y hay dos avisos importantes. El primero: **el agente no funciona con las instalaciones de Flatpak ni de Snap**. Instala 1Password desde su repositorio `.deb` o `.rpm`; lo cuento en [Linux para desarrollo]({{< relref "2024-07-25-linux-desarrollo.md" >}}). El segundo: si usas GNOME, su keyring ya exporta un `SSH_AUTH_SOCK` (`/run/user/1000/keyring/ssh`) que puede pisar al de 1Password. Por eso prefiero `IdentityAgent` en el `config` a pelearme con variables de entorno.

El segundo aviso es el mismo que en el Mac: al activar el agente aparece la ventana _Configure SSH agent_ con su `Host *` e `IdentityAgent ~/.1password/agent.sock`. Tampoco aquí dejo que edite `~/.ssh/config`: ese bloque es `~/.ssh/config.d/linux.conf` y va incluido al final. En Windows esta ventana no sale porque el pipe es fijo y no hay nada que configurar.

Verifico que el socket existe y que el agente responde:

```bash
ls -la ~/.1password/agent.sock
SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -l
```

Y en _Settings > General_, _Keep 1Password in the system tray_.

### Windows 11

En Windows no hay socket: 1Password se pone a escuchar en el named pipe `\\.\pipe\openssh-ssh-agent`, que es exactamente el que usa el OpenSSH nativo de Microsoft. Eso tiene dos consecuencias.

La primera es que hay que **deshabilitar el servicio "OpenSSH Authentication Agent"** si está instalado, porque si no los dos pelean por el mismo pipe. 1Password lo sabe: al activar el agente en Windows, en vez de la ventana del extracto para `~/.ssh/config` te pregunta _Have you disabled OpenSSH?_ y te enlaza a sus instrucciones. No pulses "sí" hasta haberlo hecho. Desde PowerShell como administrador:

```powershell
Stop-Service ssh-agent -ErrorAction SilentlyContinue
Set-Service ssh-agent -StartupType Disabled
```

Si prefieres la vía gráfica, que es la que documenta 1Password: `Win + R`, `services.msc`, doble clic en _OpenSSH Authentication Agent_, _Startup type_ en _Disabled_, _Stop_ si está en marcha, y _Apply_. Para comprobar que ha quedado bien y que ya contesta 1Password:

```powershell
Get-Service ssh-agent          # Status: Stopped, StartType: Disabled
ssh-add -l                     # debe listar las claves del vault, no "error fetching identities"
```

Si `ssh-add -l` sigue devolviendo error, lo habitual es que 1Password esté bloqueado o que el agente no esté activado en _Developer_.
La segunda es que el `ssh.exe` de Windows usa ese pipe siempre. No admite `IdentityAgent`, así que el agente de 1Password se aplica a todos los hosts. La única excepción que sigue funcionando es `IdentityAgent none` para un `Host` concreto, que es lo que uso con los clientes.

**PowerShell** y `cmd` funcionan sin más: el `ssh.exe` de `C:\Windows\System32\OpenSSH` ya está en el PATH. Lo instalé en su día tal y como cuento en [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}}).

**Git Bash** es otra historia. El `ssh` que trae Git for Windows es el de MSYS2, que emula los sockets Unix con TCP y no sabe hablar con named pipes. 1Password no menciona Git Bash en su documentación; lo que documenta es configurar Git para que use el `ssh.exe` de Microsoft:

```bash
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
```

Y para el `ssh` interactivo desde Git Bash hay una trampa: aunque en el PATH de Windows el de Microsoft vaya antes, Git for Windows antepone sus propios directorios al arrancar la shell, así que `ssh` a secas es siempre el de MSYS2. La solución es anteponer tú también el de Windows, en `~/.bashrc`:

```bash
export PATH="/c/Windows/System32/OpenSSH:$PATH"
```

Con eso `ssh`, `scp` y `ssh-add` desde Git Bash son los de Windows, y `ssh-add -l` lista las claves de 1Password. Por la misma razón, en `core.sshCommand` no vale `ssh.exe` a secas: hay que poner la ruta completa, como arriba.

Como en las otras dos, en _Settings > General_ activo _Keep 1Password in the notification area_.

### WSL

Aquí hay dos caminos, y solo uno está documentado por 1Password.

**Opción A, la oficial: delegar en `ssh.exe`.** En lugar de reenviar el agente, WSL delega la conexión SSH entera en el `ssh.exe` de Windows a través del interop. Para Git:

```bash
git config --global core.sshCommand ssh.exe
```

Y para uso interactivo, unos alias en `~/.bashrc`:

```bash
alias ssh='ssh.exe'
alias ssh-add='ssh-add.exe'
```

Tiene una consecuencia que hay que tener clara: el `~/.ssh/config` que se usa es el de **Windows** (`%USERPROFILE%\.ssh\config`), no el de WSL. Y una limitación documentada: la autorización en WSL es **por sesión**, así que cada pestaña nueva de WSL vuelve a pedir aprobación. Para probarlo:

```bash
ssh-add.exe -l
ssh.exe -T git@github.com
```

**Opción B, la de siempre: un puente con npiperelay y socat.** 1Password solo la menciona de pasada ("existen workarounds con npiperelay y socat"), pero es la que permite usar el `ssh` nativo de Linux dentro de WSL con su propio `~/.ssh/config`. Se instala `socat` en WSL, se descarga `npiperelay.exe` (yo uso el [fork de albertony](https://github.com/albertony/npiperelay), que es el mantenido) y se deja en una ruta fija de Windows. Este script, cargado desde `~/.bashrc`, levanta el puente si no existe:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/1password-agent-relay.sh" lang="bash" title="~/.local/bin/1password-agent-relay.sh — puente WSL → 1Password" >}}

El detalle que me gusta de este script es que crea el socket en `~/.1password/agent.sock`, el mismo sitio que en Linux. Así el `config.d/linux.conf` del que hablo ahora sirve en WSL sin cambiar una coma. Ojo, en el informe que usé de base aparecía `sudo apt install -y socat wsl`; ese paquete `wsl` no existe, solo hace falta `socat`.

## Un config para las tres máquinas

Mi objetivo era tener **un solo** `~/.ssh/config` en las tres máquinas, versionado, y que lo único que cambie por plataforma sea la ruta del agente. La solución es un fichero base idéntico más un `Include config.d/*.conf`, donde en cada máquina solo existe su fichero.

{{< codefile path="snippets/2026-09-04-ssh-con-1password/config" lang="bash" title="~/.ssh/config — base idéntico en las tres máquinas" >}}

Y los tres ficheros de plataforma, de los que en cada máquina solo existe uno:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/macos.conf" lang="bash" title="~/.ssh/config.d/macos.conf" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/linux.conf" lang="bash" title="~/.ssh/config.d/linux.conf (también en WSL con la opción B)" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/windows.conf" lang="bash" title="~/.ssh/config.d/windows.conf" >}}

Varias decisiones que merecen explicación:

**El `Include` va al final.** Es lo contrario de lo que verás en casi todos los ejemplos, pero tiene un motivo: en `ssh_config` gana el **primer** valor que se encuentra para cada opción. Si el `Include` con `Host *` e `IdentityAgent` estuviera arriba, el `IdentityAgent none` del bloque de clientes nunca se aplicaría. Lo específico arriba, lo general abajo. Una trampa que me costó un rato: un `Include` que va detrás de un bloque `Host` **pertenece a ese bloque**, y lo incluido solo aplica a ese host. Por eso el `Host *` de los valores por defecto va justo antes del `Include`: lo saca del último bloque y lo hace global. Si `ssh -G destino` no te enseña `identityagent`, es esto.

**Coexistencia con claves que no están en 1Password.** Para los clientes que me imponen su clave, el bloque lleva `IdentityAgent none` y un `IdentityFile` a la clave privada de fichero. `ssh` ni le pregunta al agente. Funciona en las tres plataformas, Windows incluido.

**ProxyJump y puertos raros.** Los servidores de familiares van por túnel OpenVPN a IPs `10.8.x.x` y puertos como el 1443. Cuando hay que saltar por el VPS uso `ProxyJump`, que abre una segunda conexión SSH desde mi máquina a través del intermedio **sin** dejar el agente expuesto en él.

**ForwardAgent apagado por defecto.** Cuando reenvías el agente (`ForwardAgent yes` o `ssh -A`), en el host intermedio aparece un socket en `/tmp/ssh-XXXX/agent.XXXX`. Cualquiera con root en esa máquina puede usarlo para autenticarse contra tus otros servidores mientras la sesión está abierta. Con 1Password el daño se limita a lo que autorices en ese momento, pero prefiero no jugármela: `ForwardAgent no` en `Host *` y, si un día lo necesito, `ssh -A` a mano para ese host y esa sesión. Si quieres algo automático pero limitado a sesiones interactivas, OpenSSH permite un bloque `Match` independiente (nunca anidado dentro de un `Host`, eso no existe):

```bash
Match host pve exec "test -t 0"
    ForwardAgent yes
```

**Switches con crypto de otra época.** El bloque `Host sw-core sw-planta* ap-*` reactiva `ssh-rsa` como algoritmo de clave de host y de usuario, que OpenSSH 8.8 desactivó por defecto por usar SHA-1. Lo explico en la sección de servidores.

## Git

Con SSH resuelto, Git sale casi gratis. Los dos `Host` de Git (`github.com` y mi Forgejo detrás de Nginx Proxy Manager, puerto 22) usan la clave `Git` con `IdentitiesOnly yes`. Si tienes varias cuentas en GitHub, el truco de los alias de host que conté en [Git multicuenta]({{< relref "2024-09-21-git-multicuenta.md" >}}) sigue siendo válido: un `Host github-personal` y un `Host github-trabajo`, cada uno con su `.pub`.

### Firmar commits

Desde Git 2.34 se pueden firmar commits con claves SSH en vez de GPG, y 1Password trae un binario, `op-ssh-sign`, que hace de firmador. Mi `.gitconfig` común a las tres máquinas queda así:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/gitconfig" lang="ini" title="~/.gitconfig — común a las tres máquinas" >}}

Fíjate en que `user.signingkey` es la **clave pública completa**, no una ruta. Y en que la ruta de `op-ssh-sign` la saco a un `~/.gitconfig.local` porque cambia por sistema. En el Mac:

```ini
[gpg "ssh"]
    program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
```

En Linux:

```ini
[gpg "ssh"]
    program = /opt/1Password/op-ssh-sign
```

Y en Windows, además, el `ssh.exe` de Microsoft:

```ini
[core]
    sshCommand = C:/Windows/System32/OpenSSH/ssh.exe
[gpg "ssh"]
    program = C:/Users/luis/AppData/Local/1Password/app/8/op-ssh-sign.exe
```

Nota: de esas tres rutas, 1Password solo documenta la de macOS. Las de Linux y Windows son las que me encuentro yo en mis instalaciones, y la de Windows cambió con el instalador MSIX de la versión 8.11.18. Lo más fiable es abrir el item de la clave en la app, pulsar _Configure Commit Signing_ y copiar el snippet que te genera para tu sistema.

Para WSL hay un binario aparte. En 1Password 8.11.18 o posterior está en `/mnt/c/Users/<usuario>/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe`; en versiones anteriores estaba en `.../AppData/Local/1Password/app/8/op-ssh-sign-wsl`. Y un aviso documentado: la firma de commits desde WSL **no funciona en Windows ARM**.

### Verificar firmas

Para que `git log --show-signature` diga "Good signature" hace falta un fichero de firmantes permitidos:

```bash
echo "luis@luispa.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..." >> ~/.ssh/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Ese fichero se puede compartir e incluso versionar en el repo, como un `CODEOWNERS`. Y en Forgejo y GitHub, la misma clave pública se sube como _signing key_ para que marquen los commits como verificados.

## Scripts y agentes de IA

Aquí es donde me jugaba la decisión, así que le dediqué tiempo. Primero, los ajustes que mandan, en _Settings > Developer_:

**Cuándo pregunta** (_Ask approval_):

- _For each new application_ (por defecto): autoriza una vez por aplicación y clave. "Aplicación" incluye sus subprocesos, así que autorizar WezTerm vale para el `ssh` que lance Claude Code desde dentro.
- _For each new application and terminal session_: además, por cada pestaña o ventana de terminal. Más seguro, mucho más pesado.

**Cuánto recuerda** (_Remember approval_):

- _Until 1Password locks_ (por defecto): al bloquearse, se olvidan las aprobaciones.
- _Until 1Password quits_: sobreviven al bloqueo, mueren al cerrar la app.
- _For a set amount of time_ (4, 12 o 24 horas): sobreviven al bloqueo, pero para firmar sigue haciendo falta desbloquear.

Además, en el propio prompt hay una casilla, _Approve for all applications_, que autoriza esa clave para cualquier proceso de tu usuario durante la sesión del agente. Y otro ajuste útil, _Display key names when authorizing connections_, para que el prompt diga "SSH Homelab" en vez de una huella truncada (a cambio guarda los títulos en disco sin cifrar).

### Qué pasa con BatchMode=yes

`BatchMode=yes` desactiva los prompts **del propio ssh**: contraseñas y confirmación de claves de host. No tiene nada que ver con el prompt de 1Password, que es un diálogo gráfico de otra aplicación. Así que hay tres escenarios, y esto es experiencia mía, no documentación:

1. **1Password desbloqueado y la terminal ya autorizada.** Todo funciona sin ningún prompt. Los heredocs, los pipes con `tar`, el `sudo -n`, Claude Code. Es el caso normal.
2. **1Password bloqueado.** El agente sigue corriendo y lanza un prompt de desbloqueo. `ssh` se queda esperando la respuesta del agente y el script (o el agente de IA) parece colgado hasta que desbloqueas. `ConnectTimeout` no ayuda, porque la conexión TCP ya está hecha; el que espera es el agente.
3. **Petición desde una app que no está en primer plano.** 1Password suprime el prompt para no molestarte y deja la petición en espera; verás _SSH request waiting_ al pulsar el icono de la barra de menús o de la bandeja. Este es el caso que más veces me ha hecho pensar que Claude Code se había colgado: yo mirando otra ventana y la petición esperando en silencio.

### Checklist para que Claude Code no se cuelgue

- 1Password abierto, **desbloqueado** y en la barra de menús o bandeja.
- Antes de soltar al agente de IA, un `ssh -T pve` a mano desde esa misma terminal para autorizar la aplicación y la clave.
- Para sesiones largas, valorar _Remember approval > For a set amount of time_; el bloqueo automático de 1Password seguirá pidiendo desbloquear, pero no volverá a pedir aprobación por clave.
- Si un comando SSH lleva más de unos segundos sin salida, mirar el icono de 1Password antes de matar nada.
- `IdentitiesOnly yes` en todos los `Host`: así cada conexión pide una sola clave y hay un solo prompt, no cinco.
- Nada de esto vale para cron ni runners. Eso va con clave de fichero y `command=`.

## Lado servidor

### Linux

Buena noticia: en los servidores no hay que cambiar nada. Las firmas que produce 1Password son firmas OpenSSH normales. Lo único que hago es aprovechar para poner orden en los `authorized_keys`: un comentario al final de cada línea que diga de qué clave viene (`luis@1password-homelab`), borrar las claves de máquinas que ya no existen y asegurarme de que el `sshd_config` no deja entrar por contraseña:

```text
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
```

Y para las claves headless de cron, la restricción de la que hablaba antes:

```text
command="/usr/local/bin/backup-pull.sh",no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty ssh-ed25519 AAAA... backup@pve
```

**VMs en la nube.** En GCP, AWS o Azure el `authorized_keys` no es del todo tuyo: lo escribe el agente del proveedor a partir de los metadatos de la instancia o del proyecto, y lo que añadas a mano desaparece en la siguiente sincronización. Se reconoce porque cada línea lleva un comentario del estilo `# Added by Google`. La pública nueva se añade donde viven las demás, con la herramienta del proveedor (en GCP, una línea `usuario:clave pública` en el metadato `ssh-keys`), y en unos segundos el agente la pone en el `authorized_keys`.

**Windows como servidor.** El OpenSSH de Microsoft lee `~/.ssh/authorized_keys` como el de Linux, con una excepción: si el usuario es administrador y en `sshd_config` está activo el bloque `Match Group administrators`, las claves van en `C:\ProgramData\ssh\administrators_authorized_keys`. Mira el `sshd_config` antes de pegar la clave en el sitio equivocado.

Dos tropiezos más con Windows como servidor, los dos de un portátil recién encendido. Uno: el `sshd` escuchaba y en local respondía, pero desde fuera el puerto 22 estaba cerrado, porque la regla del firewall que crea la instalación solo aplica al perfil _Private_ y la wifi de casa había quedado como _Public_; se arregla con `Set-NetConnectionProfile -InterfaceAlias 'Wi-Fi' -NetworkCategory Private`. Dos: en un Windows en español el grupo no se llama `Administrators`, así que cualquier receta de Internet con `net localgroup Administrators` falla; usa el identificador del grupo, `S-1-5-32-544`, que es el mismo en todos los idiomas.

Y una última cosa sobre entrar por SSH en un Windows que también es cliente de 1Password: desde esa sesión remota el agente de 1Password **no está disponible**. Su pipe solo atiende a procesos de tu sesión de escritorio, así que `ssh-add -l` falla aunque en la pantalla del PC funcione. Es el mismo caso "headless" de los agentes de IA: para saltar de ese Windows a otro sitio, hay que estar delante. También conviene saber qué shell te da ese `sshd`: si tienes Git for Windows, puede ser Git Bash en vez de PowerShell, y los comandos que le mandes se interpretan como bash.

### Switch principal

Aquí es donde toca mancharse las manos. Mi switch principal lleva un firmware de hace más de una década, y su SSH es de otra época. Según la guía de configuración de esa versión del firmware, como algoritmo de clave de host y de clave pública de usuario solo entiende `ssh-rsa` (y su variante `x509v3-ssh-rsa`). Nada de ed25519, nada de ECDSA, nada de `rsa-sha2-256`. Por eso la clave `Network` es RSA y no ed25519.

El choque viene con el cliente: OpenSSH 8.8 desactivó por defecto las firmas `ssh-rsa` (RSA con SHA-1) tanto para la clave de host como para la del usuario. De ahí el bloque de mi `config`:

```bash
Host sw-core sw-planta* ap-*
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
    KexAlgorithms +diffie-hellman-group14-sha1
```

Sobre el `KexAlgorithms`: los hilos de la comunidad del fabricante dicen que esa versión solo ofrece `diffie-hellman-group-exchange-sha1` y `diffie-hellman-group14-sha1`, y OpenSSH 8.2 sacó el segundo de sus valores por defecto. No lo he encontrado en documentación primaria del fabricante, así que dalo por **no confirmado** y compruébalo en tu switch con `show ip ssh`. Si `ssh -v` te suelta `no matching key exchange method found`, es esto.

En ese switch la clave del usuario se registra por su hash MD5. Lo calculo desde la clave pública descargada de 1Password:

```bash
ssh-keygen -l -E md5 -f ~/.ssh/keys/network.pub
# 4096 MD5:27:0c:78:ad:8f:b0:0f:d9:8f:ed:f0:0c:0e:8f:4d:35 luis (RSA)
```

Y en el switch, quitando el prefijo `MD5:` y los dos puntos:

```text
conf t
 ip ssh version 2
 ip ssh pubkey-chain
  username admin
   key-hash ssh-rsa 270C78AD8FB00FD98FEDF00C0E8F4D35
  exit
 exit
end
```

Un aviso sobre 1Password y SHA-1: el agente firma `ssh-rsa` (dejando en su log un "signing with ssh-rsa; SHA-1 may be insecure"), pero ha habido varias versiones en las que dejó de hacerlo y el síntoma era `agent refused operation`. Las notas de versión mencionan arreglos en la 8.10.21, la 8.10.56 y la 8.11.6. Si un día tus switches viejos dejan de entrar justo después de actualizar 1Password, ya sabes por dónde empezar.

Y sobre el exponente RSA: 1Password no importa claves RSA con exponente público menor de 65537 (lo puedes comprobar con `openssl rsa -text -in clave | grep publicExponent`). Si generas la clave en 1Password, no hay nada que mirar.

### Controlador wireless

El controlador wireless lleva un firmware actual y es otro mundo: firma con `rsa-sha2-256` y `rsa-sha2-512`, cifrados modernos, KEX de curva elíptica y, comprobado en mi versión, `ssh-ed25519` para la clave del usuario (`show ip ssh` te lista los algoritmos de clave pública que acepta). Así que aquí uso la clave `Network` ed25519, y la RSA se queda solo para el switch antiguo. La clave del usuario se registra igual que en el switch, por su hash MD5, pero con el tipo `ssh-ed25519`:

```text
ip ssh pubkey-chain
 username admin
  key-hash ssh-ed25519 5D41402ABC4B2A76B9719D911017C592
```

Y además lo endurezco del lado del servidor:

```text
ip ssh version 2
ip ssh server algorithm hostkey rsa-sha2-512 rsa-sha2-256
ip ssh server algorithm publickey rsa-sha2-512 rsa-sha2-256 ssh-ed25519
ip ssh server algorithm kex curve25519-sha256@libssh.org ecdh-sha2-nistp521 ecdh-sha2-nistp384 ecdh-sha2-nistp256 diffie-hellman-group14-sha256
ip ssh server algorithm encryption aes256-gcm@openssh.com aes128-gcm@openssh.com chacha20-poly1305@openssh.com aes256-ctr
ip ssh server algorithm mac hmac-sha2-512-etm@openssh.com hmac-sha2-256-etm@openssh.com hmac-sha2-512 hmac-sha2-256
```

Con eso el bloque `Host wlc` de mi `config` no necesita ninguna excepción de crypto.

## Seguridad

Antes de fiarme quise entender de qué me protege y de qué no. Tres escenarios:

**Un proceso local malicioso intenta usar el agente.** Cualquier proceso de mi usuario puede escribir en el socket; la protección son los permisos del socket y, sobre todo, el prompt: 1Password te dice qué proceso pide qué clave y tú apruebas o deniegas. Si aparece un prompt que no esperabas, la respuesta es _Deny_ y a investigar. Por eso no me gusta _Approve for all applications_ salvo en momentos muy concretos.

**Alguien con root en mi workstation.** Con claves de fichero, se las lleva y punto (cifradas con passphrase, con suerte). Con 1Password no hay nada en disco que llevarse; tendría que esperar a que yo desbloquee y a que apruebe, o intentar un volcado de memoria del proceso desbloqueado. No es invulnerable, pero el listón sube mucho. Esto es opinión mía, 1Password no lo documenta en estos términos.

**Un host intermedio comprometido con el agente reenviado.** Ya lo he contado: un root en el salto puede usar tu agente mientras dure la sesión. Con 1Password además tendrá que pasar por tu prompt si la clave no estaba ya autorizada, pero la mitigación de verdad es `ForwardAgent no` y `ProxyJump`.

Mi checklist de hardening:

- Autorización biométrica activada (Touch ID, Windows Hello, PolKit).
- Bloqueo automático de 1Password a los 10 o 15 minutos de inactividad y al bloquear la pantalla.
- _Remember approval_ en _Until 1Password locks_, salvo sesiones largas de agentes de IA.
- `ForwardAgent no` en `Host *`.
- `IdentitiesOnly yes` en todos los `Host`.
- `agent.toml` para que el agente solo ofrezca lo que tiene que ofrecer.
- Revisar de vez en cuando la pestaña _Activity_ del agente en la app (hay que activar _Record and display activity_).

## Migración desde ficheros

Lo hice en cuatro pasos, sin prisa y sin borrar nada hasta el final.

**Inventario.** En cada máquina, qué claves privadas hay y quién las usa:

```bash
find ~/.ssh -type f -exec grep -l "PRIVATE KEY" {} +
grep -h IdentityFile ~/.ssh/config | sort | uniq -c
```

Con eso monté una tabla: fichero, máquina, destinos, y si el destino era "moderno" o no.

**Regenerar o importar.** Para todo lo que es Linux, VPS y Git, generé claves **nuevas** ed25519 dentro de 1Password. Así la clave privada nunca ha existido en un disco. Para el switch antiguo importé la RSA que ya tenía (item nuevo > SSH Key > _Import a key file_), previa comprobación del exponente. Para los clientes, cada uno según sus normas: los que aceptan mi clave, ed25519 nueva en 1Password; los que imponen la suya, fichero e `IdentityAgent none`.

**Pruebas en paralelo.** Descargué las `.pub` a `~/.ssh/keys/` (con `chmod 600`: un `.pub` es público por definición y 644 sería lo normal, pero estos solo los lee `ssh`, y con 600 el día que 1Password esté cerrado verás una línea de "invalid format" en vez del cartel de "UNPROTECTED PRIVATE KEY FILE"), añadí cada clave nueva al `authorized_keys` de su grupo **sin quitar la vieja**, y fui probando destino a destino con `ssh -v`, buscando la línea que confirma que la firma vino del agente:

```text
debug1: Offering public key: ... agent
debug1: Server accepts key: ...
Authenticated to pve ([192.168.1.10]:22) using "publickey".
```

Cuando todo entraba con la clave nueva, quité las viejas de los `authorized_keys`.

Al final lo convertí en una receta por host, siempre la misma: subir la pública nueva usando la clave vieja; entrar forzando solo la nueva con `ssh -o IdentitiesOnly=yes -i ~/.ssh/keys/homelab.pub host`; si entra, quitar la vieja del `authorized_keys` dejando una copia; apuntar el bloque del `config` a la `.pub` nueva (`ssh -G host` te enseña la configuración efectiva sin conectar, por si dudas); y por último `ssh host` sin forzar nada. Cinco minutos por host y ningún susto.

**Borrado.** Antes de borrar nada, las aparté: un directorio `~/.ssh/retired/` con cada privada que ningún `IdentityFile` del `config` referencia ya, y unos días de margen por si algo se queja. También aproveché para sacar del `config` las contraseñas que tenía apuntadas en comentarios; ahora viven en 1Password, que es donde debían estar. Después, las privadas de fichero, fuera. En Linux `shred -u`, en macOS `rm -P`, en Windows `Remove-Item -Force`. Sé que en SSD y sistemas de ficheros modernos el borrado seguro es más una ilusión que otra cosa; lo que de verdad protege es que los tres discos van cifrados (LUKS, FileVault, BitLocker).

## Problemas típicos

| Error                                                                                               | Causa                                                                                                      | Solución                                                                                             |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `Could not open a connection to your authentication agent`                                          | `SSH_AUTH_SOCK` o `IdentityAgent` apuntan a un socket que no existe, o 1Password no está corriendo         | Comprobar `ls -la` del socket y que el agente está activado en _Developer_                           |
| `WARNING: UNPROTECTED PRIVATE KEY FILE` o `invalid format` sobre un `.pub`, y luego pide contraseña | 1Password está cerrado: sin agente, `ssh` intenta leer el `.pub` como clave privada y lo descarta          | Abrir 1Password; el aviso desaparece solo (con `chmod 600` en los `.pub` el mensaje es más discreto) |
| `Too many authentication failures`                                                                  | El agente ofrece más de seis claves                                                                        | `IdentitiesOnly yes` con el `.pub`, y ordenar `agent.toml`                                           |
| `agent refused operation` al firmar con RSA                                                         | 1Password no quiso firmar: petición denegada, vault bloqueado, o regresión con `ssh-rsa` SHA-1             | Mirar el prompt, actualizar 1Password, revisar `+ssh-rsa`                                            |
| `no matching key exchange method found`                                                             | El destino solo ofrece KEX antiguos                                                                        | `KexAlgorithms +diffie-hellman-group14-sha1` solo para ese `Host`                                    |
| `no matching host key type found. Their offer: ssh-rsa`                                             | Clave de host RSA con SHA-1                                                                                | `HostKeyAlgorithms +ssh-rsa` solo para ese `Host`                                                    |
| `Permission denied (publickey)` con `IdentitiesOnly`                                                | El `.pub` del `IdentityFile` no coincide con ninguna clave del agente, o esa clave no está en `agent.toml` | `ssh-add -l` y comparar huellas                                                                      |
| `ssh` colgado sin salida desde un script o Claude Code                                              | 1Password bloqueado o prompt suprimido por estar en segundo plano                                          | Desbloquear y mirar _SSH request waiting_ en el icono                                                |
| `fatal: cannot run .../op-ssh-sign-wsl: No such file or directory`                                  | Ruta del firmador antigua (cambió en 8.11.18)                                                              | Regenerar el snippet con _Configure Commit Signing_ > WSL                                            |
| En Git Bash nada funciona                                                                           | Está usando el `ssh` de MSYS2, que no habla con el pipe                                                    | `core.sshCommand` al `ssh.exe` de Windows                                                            |
| En WSL pide aprobación en cada pestaña                                                              | Comportamiento documentado de la opción A                                                                  | Aceptarlo, o pasar a la opción B                                                                     |

## Conclusión

Mola. La sensación de abrir cualquiera de las tres máquinas, escribir `ssh pve`, poner el dedo y estar dentro, sin haber copiado un solo fichero, es de las que no vuelves atrás. Y el prompt que te dice _quién_ pide _qué_ clave es un control que con `ssh-agent` no tenía.

Pero es importante tener claro el límite: el agente de 1Password es para personas. Todo lo que corre solo, sin nadie delante, sigue con claves de fichero bien restringidas. Y los agentes de IA están en medio: funcionan de maravilla mientras tú estés ahí con el vault desbloqueado, y se quedan mirando al infinito en cuanto no lo estás.

## Referencias

Consultadas el 4 de septiembre de 2026. Lo que no aparece aquí y he afirmado en el apunte, dalo por experiencia u opinión mía.

| Tipo      | Enlaces                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1Password | [Get started with the SSH agent](https://developer.1password.com/docs/ssh/get-started/), [SSH agent config file](https://developer.1password.com/docs/ssh/agent/config/), [Advanced use cases](https://developer.1password.com/docs/ssh/agent/advanced/), [Security](https://developer.1password.com/docs/ssh/agent/security/), [Agent forwarding](https://developer.1password.com/docs/ssh/agent/forwarding/), [Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/)                                                                                                                               |
| 1Password | [Use the SSH agent with WSL](https://developer.1password.com/docs/ssh/integrations/wsl/), [Sign Git commits with SSH](https://developer.1password.com/docs/ssh/git-commit-signing/), [Manage SSH keys](https://developer.1password.com/docs/ssh/manage-keys/)                                                                                                                                                                                                                                                                                                                                                                |
| OpenSSH   | [ssh_config(5)](https://man.openbsd.org/ssh_config), [sshd_config(5)](https://man.openbsd.org/sshd_config), [Release notes 8.2](https://www.openssh.com/txt/release-8.2), [Release notes 8.5](https://www.openssh.com/txt/release-8.5), [Release notes 8.8](https://www.openssh.com/txt/release-8.8)                                                                                                                                                                                                                                                                                                                         |
| Switches  | [Guía de configuración del switch: SSH](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst2960cx_3650cx/software/release/15-2_7_e/configuration_guide/b_1527e_consolidated_3560cx_2960cx_cg/b_1527e_consolidated_3560cx_2960cx_cg_chapter_0111010.html), [Controlador: SSH algorithms for Common Criteria](https://www.cisco.com/c/en/us/td/docs/switches/lan/catalyst9500/software/release/17-18/configuration_guide/sec/b_1718_sec_9500_cg/ssh_algorithms_for_common_criteria_certification.html), [SSH best practices en el controlador (mrn-cciew)](https://mrncciew.com/2023/08/28/ios-xe-ssh-best-practices/) |
| Windows   | [OpenSSH key management (Microsoft)](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement), [npiperelay (fork de albertony)](https://github.com/albertony/npiperelay)                                                                                                                                                                                                                                                                                                                                                                                                               |
| Comunidad | [SSH agent errors on older network devices](https://www.1password.community/developers-69/ssh-agent-errors-on-older-cisco-devices-20467), [Git Bash and 1Password SSH not working](https://www.1password.community/discussions/developers/git-bash-and-1password-ssh-not-working/142552), [Notas de versión de 1Password](https://releases.1password.com/mac/stable/)                                                                                                                                                                                                                                                        |
