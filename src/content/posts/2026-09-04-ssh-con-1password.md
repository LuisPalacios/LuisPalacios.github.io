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

Hace unas semanas aparqué mi ["Bitwarden casero"]({{< relref "2025-03-02-bitwarden.md" >}}) y me pasé a 1Password con el plan familiar. Sí, hay que pagar, pero compartir con la familia y la facilidad de uso lo compensan. Al poco de migrar las contraseñas me encontré con la pestaña _Developer_ y su **agente SSH**: las claves privadas viven en la caja fuerte (el vault), se sincronizan solas entre mis máquinas y cada uso se autoriza con la huella o con Windows Hello.

Por cierto, luego descubrí que Bitwarden también tiene agente SSH desde principios de 2025. Todos los días se aprende algo nuevo.

Sonaba demasiado bien, así que me puse a investigar si me valía para mi caso: varios puestos de trabajo (macOS, Windows, Linux), muchos servidores, equipos de red con un SSH de otra época y cada vez más scripts y agentes de IA lanzando `ssh` sin que yo esté delante. En este apunte cuento lo que he aprendido, cómo lo he montado y dónde NO lo uso.

<br clear="left"/>
<!--more-->

## El problema

Llevo usando claves SSH desde el siglo pasado, y con los años el asunto se me ha ido de las manos. Tres máquinas, cada una con su `~/.ssh/config` "equivalente" con docenas de destinos, y en cada una un puñado de claves privadas que en teoría son las mismas pero que sincronizo a mano y de vez en cuando descubro que no lo son.

Los destinos tampoco son pocos: servidores y máquinas virtuales en casa, equipos de red antiguos, algún servidor en Internet, casas de familiares a las que llego por VPN y, de vez en cuando, servidores de clientes donde soy invitado y me imponen su clave.

Y luego está cómo los uso: sesiones interactivas, scripts, y desde hace un tiempo [agentes de IA en la terminal]({{< relref "2026-04-25-modo-ia-en-la-terminal.md" >}}) que llaman al `ssh` del sistema sin que yo teclee nada.

La pregunta era sencilla: ¿el agente SSH de 1Password aguanta todo esto o me va a dejar tirado a la primera de cambio?

Respuesta corta: **sí, aguanta**, y me quedo con él. Para todo lo que hago estando yo delante, incluidos los scripts y los agentes de IA lanzados desde mi terminal, funciona de maravilla. Lo único que dejo fuera es lo que corre solo sin nadie delante (cron, runners de CI), que sigue con claves de fichero bien restringidas.

## Cómo funciona

Un recordatorio rápido. Cuando `ssh` conecta con un servidor, lo primero que hacen es montar un canal cifrado y acordar un **identificador de sesión**, un valor único para esa conexión. Solo entonces empieza la autenticación, que con clave pública son dos rondas: el cliente ofrece una clave pública y pregunta "¿aceptas esta?", y si el servidor dice que sí, el cliente firma el identificador de sesión con la clave privada y manda la firma. El servidor la comprueba con la pública que tiene en `authorized_keys` y abre la sesión.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-01.png" alt="Autenticación SSH con clave pública en cinco pasos: canal cifrado, oferta de clave pública, aceptación, firma del identificador de sesión y apertura de sesión" width="700px" />
  <div class="image-caption">El servidor nunca ve la clave privada: solo comprueba una firma con la pública que tiene en authorized_keys.</div>
</div>

Dos detalles de este baile importan más adelante. Uno: el cliente ofrece claves **en orden**, y cada "no la acepto" cuenta como un intento fallido contra el límite del servidor, que por defecto son seis. Dos: la clave privada solo se usa para firmar, así que un agente que pide confirmación te la pide una sola vez, para la clave que el servidor ya ha aceptado.

Con 1Password lo único que cambia es quién firma. El agente de 1Password habla el protocolo estándar de `ssh-agent`, así que para el cliente OpenSSH no hay nada nuevo: cuando toca firmar, `ssh` se lo pide al agente a través de un socket (o de un _named pipe_ en Windows), 1Password comprueba que está desbloqueado, te pide la huella si ese proceso aún no tenía permiso, firma dentro de su propio proceso y devuelve **solo la firma**.

<div class="image-box">
  <img src="/img/posts/2026-09-04-ssh-con-1password-02.png" alt="Flujo de una autenticación SSH con el agente de 1Password: el servidor pide la firma, el cliente la delega por el socket del agente y 1Password devuelve solo la firma" width="800px" />
  <div class="image-caption">El cliente ssh habla con 1Password por socket o named pipe; la clave privada nunca sale del proceso de 1Password.</div>
</div>

La clave privada nunca sale de 1Password: no está en disco sin cifrar, no se carga en la memoria de `ssh` ni de tu shell, y con el vault bloqueado el agente ni siquiera la tiene en memoria.

### Comparado con lo de siempre

El **`ssh-agent` de toda la vida** carga la clave descifrada en memoria una vez y no vuelve a preguntar. Cómodo, pero la clave sigue viviendo en un fichero de cada máquina y la sincronización es cosa tuya. **gpg-agent** hace algo parecido con mucha más ceremonia; lo usé años y no lo echo de menos. Las **llaves hardware** (YubiKey y compañía) son las que mejor aíslan la clave, pero cada dispositivo es una clave distinta y hay que tocar la llave en cada operación. Los **certificados SSH** con una CA son la solución "de empresa", y para un homelab es matar moscas a cañonazos.

1Password se queda en un punto intermedio muy razonable: aislamiento, autorización biométrica por uso, sincronización automática y cero ficheros privados en disco. A cambio, necesita la aplicación de escritorio abierta y desbloqueada. Y ahí está la pega.

## Dónde lo uso y dónde no

No es "todo o nada". El agente de 1Password se queda con:

- Las **sesiones interactivas** a cualquier destino.
- El **scripting desde el puesto de trabajo**, incluidos los heredocs y los pipes con `tar`.
- Los **agentes de IA** que lanzo desde una sesión de escritorio desbloqueada.
- Todo lo que sea **Git** por SSH.

Y las claves de fichero clásicas se quedan con todo lo que no tiene a nadie delante de una pantalla: cron, timers de systemd, runners de CI y scripts que corren en un servidor sin sesión de usuario. Para esos casos la clave vive en disco y, sobre todo, se restringe en el `authorized_keys` del destino con `command="..."` y sin shell, sin reenvío de puertos ni de agente. Una clave sin persona detrás que solo puede ejecutar un script concreto es un riesgo asumible; una con shell completa no lo es.

Esto no es una limitación exótica de 1Password: cualquier agente que pida autorización a una persona falla exactamente igual cuando no hay persona.

## ¿Cuántas claves?

Hay cuatro estrategias razonables. **Una para todo** es la más cómoda y la peor idea: si se compromete, hay que cambiarla en todos los servidores el mismo día. **Una por host** es el extremo opuesto: revocar es trivial, pero con docenas de destinos el mantenimiento es un infierno. **Una por máquina** es lo que tenía antes, y con 1Password pierde el sentido, porque la clave ya no está atada a la máquina. Y **una por propósito**: agrupar destinos por dominio de confianza, de forma que si cae una clave el daño se queda dentro de ese grupo.

Me quedo con la última. Acabé con seis:

| Clave            | Tipo    | Destinos                                            |
| ---------------- | ------- | --------------------------------------------------- |
| `Homelab`        | ed25519 | Servidores, VMs y contenedores de casa              |
| `Network`        | ed25519 | Equipos de red con firmware actual                  |
| `Network Legacy` | RSA     | Switch antiguo que solo entiende `ssh-rsa`          |
| `VPS`            | ed25519 | Máquinas virtuales en la nube                       |
| `Clientes`       | ed25519 | Casas de familiares y clientes que aceptan mi clave |
| `Git`            | ed25519 | Forgejo y GitHub (y firmar commits, si quieres)     |

Pocas claves tiene además una ventaja práctica: no chocar con el límite de seis intentos del servidor. Me pasó el primer día: ocho claves en el agente, la buena al final, y un `Too many authentication failures`. Diez segundos de susto y una lección bien aprendida.

Lo evito de dos formas, y uso las dos. **Desde el cliente**, con `IdentitiesOnly yes` en cada `Host` y un `IdentityFile` que apunta a la **clave pública** (`.pub`) descargada de 1Password y guardada en `~/.ssh/keys/`. OpenSSH admite indicar solo la pública para usar la privada correspondiente del agente, así que `ssh` pide esa clave y ninguna más. **Desde el agente**, con el fichero `agent.toml`, donde el orden de los bloques es el orden en que se ofrecen las claves:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/agent.toml" lang="toml" title="agent.toml — orden y visibilidad de las claves" >}}

Dos avisos sobre este fichero. En cuanto existe, solo se ofrecen las claves listadas. Y es un fichero por máquina: no viaja con el vault, hay que copiarlo a cada equipo.

## Puesta en marcha en cada máquina

En todas empieza igual: _Settings > Developer > Use the SSH Agent_. Nada más activarlo, 1Password pregunta si puede guardar los nombres de las claves en disco; yo digo que sí, porque el nombre de un item no es un secreto y así el prompt de autorización dice "SSH Homelab" en vez de una huella recortada. Y en _Settings > General_, en las tres plataformas, dejo 1Password en la barra de menús o bandeja y arrancando al iniciar sesión: si cierras la app, el agente muere con ella.

Lo que cambia por sistema es dónde escucha el agente y qué cliente SSH le habla.

**macOS.** El agente escucha en un socket dentro de la carpeta de 1Password, y la app te ofrece editar `~/.ssh/config` para apuntar a él. Mi recomendación: **no le dejes**. Copia el extracto y ponlo en un fichero aparte que se incluya al final del config, por una razón que explico en la siguiente sección. Y si usas `ControlMaster`, recuerda que las conexiones ya abiertas no vuelven a autenticar: para probar de verdad, `ssh -o ControlPath=none host`.

**Linux.** El socket es `~/.1password/agent.sock`. Dos avisos: el agente **no funciona con las instalaciones de Flatpak ni de Snap**, así que instala 1Password desde su repositorio, como cuento en [Linux para desarrollo]({{< relref "2024-07-25-linux-desarrollo.md" >}}); y si usas GNOME, su keyring ya exporta un `SSH_AUTH_SOCK` que puede pisar al de 1Password. Por eso prefiero `IdentityAgent` en el config a pelearme con variables de entorno.

**Windows 11.** Aquí no hay socket: 1Password escucha en el mismo _named pipe_ que usa el OpenSSH nativo de Microsoft. Por eso hay que **deshabilitar el servicio "OpenSSH Authentication Agent"** antes de activar el de 1Password (la propia app te lo pregunta), y por eso el `ssh.exe` de Windows usa el agente de 1Password para todos los hosts sin configurar nada. Lo instalé en su día tal y como cuento en [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}}).

Git Bash es otra historia: su `ssh` no sabe hablar con named pipes. La solución es usar el de Microsoft también desde ahí, con `core.sshCommand` en Git apuntando a la ruta completa de `C:/Windows/System32/OpenSSH/ssh.exe` y anteponiendo ese directorio al `PATH` en `~/.bashrc`, porque Git for Windows pone sus propios directorios por delante al arrancar.

**WSL.** La vía oficial es delegar en el `ssh.exe` de Windows con unos alias, con dos consecuencias: se usa el `~/.ssh/config` de Windows, no el de WSL, y cada pestaña nueva vuelve a pedir aprobación. La alternativa que uso yo es un puente con `socat` y `npiperelay` que crea el socket en `~/.1password/agent.sock`, el mismo sitio que en Linux, para que el mismo config sirva en los dos:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/1password-agent-relay.sh" lang="bash" title="~/.local/bin/1password-agent-relay.sh — puente WSL → 1Password" >}}

Para comprobar que el agente responde, en cualquiera de las plataformas, `ssh-add -l` debe listar las claves del vault.

## Un config para las tres máquinas

Mi objetivo era tener **un solo** `~/.ssh/config` idéntico en las tres máquinas y que lo único que cambie por plataforma sea la ruta del agente. La solución es un fichero base más un `Include config.d/*.conf`, donde en cada máquina solo existe su fichero de plataforma.

{{< codefile path="snippets/2026-09-04-ssh-con-1password/config" lang="bash" title="~/.ssh/config — base idéntico en las tres máquinas" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/macos.conf" lang="bash" title="~/.ssh/config.d/macos.conf" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/linux.conf" lang="bash" title="~/.ssh/config.d/linux.conf (también en WSL con el puente)" >}}

{{< codefile path="snippets/2026-09-04-ssh-con-1password/windows.conf" lang="bash" title="~/.ssh/config.d/windows.conf" >}}

Tres decisiones que merecen explicación:

**El `Include` va al final.** Es lo contrario de lo que verás en casi todos los ejemplos, pero en `ssh_config` gana el **primer** valor que se encuentra para cada opción. Si el `IdentityAgent` global estuviera arriba, el `IdentityAgent none` de los clientes nunca se aplicaría. Lo específico arriba, lo general abajo. Y ojo: un `Include` que va detrás de un bloque `Host` pertenece a ese bloque, por eso el `Host *` de los valores por defecto va justo antes. Si `ssh -G destino` no te enseña `identityagent`, es esto.

**Claves que no están en 1Password.** Para los clientes que me imponen su clave, el bloque lleva `IdentityAgent none` y un `IdentityFile` a la clave de fichero. `ssh` ni le pregunta al agente. Funciona en las tres plataformas, Windows incluido.

**ForwardAgent apagado.** Reenviar el agente deja un socket en el host intermedio que cualquiera con root allí puede usar mientras dure tu sesión. Con 1Password el daño se limita a lo que autorices en ese momento, pero prefiero `ForwardAgent no` y, cuando hay que saltar por un intermedio, `ProxyJump`, que abre una segunda conexión desde mi máquina sin exponer nada en el salto.

Los equipos de red antiguos tienen su propio bloque que reactiva `ssh-rsa`, y lo cuento en la sección de servidores.

## Git

Con SSH resuelto, Git sale casi gratis: los `Host` de GitHub y de mi Forgejo usan la clave `Git` con `IdentitiesOnly yes`. Si tienes varias cuentas, el truco de los alias de host que conté en [Git multicuenta]({{< relref "2024-09-21-git-multicuenta.md" >}}) sigue siendo válido, cada alias con su `.pub`.

Y si quieres firmar commits, desde Git 2.34 se puede hacer con claves SSH en vez de GPG, y 1Password trae su propio firmador. El `.gitconfig` común queda así, sacando a un fichero local lo que cambia por sistema, que es la ruta del firmador:

{{< codefile path="snippets/2026-09-04-ssh-con-1password/gitconfig" lang="ini" title="~/.gitconfig — común a las tres máquinas" >}}

Fíjate en que `user.signingkey` es la **clave pública completa**, no una ruta. Lo más fiable para la parte local es abrir el item de la clave en la app, pulsar _Configure Commit Signing_ y copiar el snippet que te genera para tu sistema. Yo, por cierto, no firmo commits: lo dejo aquí por si a ti te interesa.

## Scripts y agentes de IA

Aquí es donde me jugaba la decisión. Lo que manda son dos ajustes de _Settings > Developer_: **cuándo pregunta** (por defecto, una vez por aplicación y clave, y "aplicación" incluye sus subprocesos, así que autorizar la terminal vale para el `ssh` que lance un agente de IA desde dentro) y **cuánto recuerda** (por defecto, hasta que 1Password se bloquea; se puede alargar a un número de horas).

Y una cosa que hay que tener clara: `BatchMode=yes` desactiva los prompts **del propio ssh**, no el diálogo de 1Password, que es otra aplicación. Así que hay tres escenarios:

1. **1Password desbloqueado y la terminal ya autorizada.** Todo funciona sin ningún prompt. Es el caso normal.
2. **1Password bloqueado.** El agente lanza un prompt de desbloqueo y `ssh` se queda esperando. El script, o el agente de IA, parece colgado hasta que desbloqueas.
3. **Petición desde una app que no está en primer plano.** 1Password no te molesta con el prompt y deja la petición en espera; lo ves como _SSH request waiting_ en el icono de la bandeja. Este es el que más veces me ha hecho pensar que el agente de IA se había colgado.

Mi checklist para que no se cuelgue nada:

- 1Password abierto y **desbloqueado**.
- Antes de soltar al agente de IA, un `ssh` a mano desde esa misma terminal para autorizar la aplicación y la clave.
- Para sesiones largas, alargar lo que recuerda la aprobación.
- Si un comando SSH lleva más de unos segundos sin salida, mirar el icono de 1Password antes de matar nada.
- `IdentitiesOnly yes` en todos los `Host`: un solo prompt por conexión, no cinco.
- Nada de esto vale para cron ni runners. Eso va con clave de fichero y `command=`.

## Lado servidor

Buena noticia: en los servidores Linux no hay que cambiar nada, porque las firmas que produce 1Password son firmas OpenSSH normales. Lo único que hago es aprovechar para poner orden en los `authorized_keys`: un comentario en cada línea que diga de qué clave viene, borrar las claves de máquinas que ya no existen y asegurarme de que el servidor no deja entrar por contraseña.

Tres casos especiales:

**Máquinas virtuales en la nube.** El `authorized_keys` no es del todo tuyo: lo escribe el agente del proveedor a partir de los metadatos de la instancia o del proyecto, y lo que añadas a mano desaparece en la siguiente sincronización. La clave nueva se añade donde viven las demás, con la herramienta del proveedor.

**Windows como servidor.** Si el usuario es administrador, las claves no van en su `authorized_keys` sino en `C:\ProgramData\ssh\administrators_authorized_keys`. Mira el `sshd_config` antes de pegar la clave en el sitio equivocado. Y una cosa más: desde una sesión SSH a ese Windows, el agente de 1Password **no está disponible**, porque solo atiende a procesos de tu sesión de escritorio. Para saltar de ahí a otro sitio, hay que estar delante.

**Equipos de red antiguos.** Mi switch principal lleva un firmware de hace más de una década y como clave de usuario solo entiende `ssh-rsa`. Por eso la clave `Network Legacy` es RSA (1Password importa claves RSA sin problema) y por eso su bloque en el config reactiva `ssh-rsa` y un intercambio de claves antiguo, que OpenSSH desactivó por defecto hace años. En el switch, la clave se registra por su huella MD5, que se calcula con `ssh-keygen -l -E md5` sobre la `.pub` descargada. Un aviso: el agente firma con SHA-1 dejando una queja en su log, y ha habido versiones de 1Password en las que dejó de hacerlo. Si un día tus equipos viejos dejan de entrar justo después de una actualización, ya sabes por dónde empezar.

El controlador wireless, con firmware actual, es otro mundo: acepta ed25519 y cifrados modernos, así que usa la clave `Network` normal y no necesita ninguna excepción.

## Seguridad

Antes de fiarme quise entender de qué me protege y de qué no. Un **proceso local malicioso** puede escribir en el socket, y la protección es el prompt: 1Password te dice qué proceso pide qué clave y tú apruebas o deniegas. Si aparece uno que no esperabas, _Deny_ y a investigar. **Alguien con root en mi máquina**, con claves de fichero, se las lleva y punto; con 1Password no hay nada en disco que llevarse, y tendría que esperar a que yo desbloquee y apruebe. No es invulnerable, pero el listón sube mucho. Y un **host intermedio comprometido** con el agente reenviado puede usarlo mientras dure la sesión, por eso `ForwardAgent no` y `ProxyJump`.

Mi checklist de hardening:

- Autorización biométrica activada.
- Bloqueo automático de 1Password a los pocos minutos de inactividad y al bloquear la pantalla.
- Aprobaciones que se olvidan al bloquear, salvo sesiones largas con agentes de IA.
- `ForwardAgent no` e `IdentitiesOnly yes` en todos los `Host`.
- `agent.toml` para que el agente solo ofrezca lo que tiene que ofrecer.
- Revisar de vez en cuando la pestaña _Activity_ del agente en la app.

## Migración desde ficheros

Lo hice en cuatro pasos, sin prisa y sin borrar nada hasta el final.

**Inventario.** En cada máquina, qué claves privadas hay y qué `Host` del config las usa. Con eso monté una tabla: fichero, máquina, destinos.

**Regenerar o importar.** Para todo lo moderno generé claves **nuevas** ed25519 dentro de 1Password, así la privada nunca ha existido en un disco. Para el switch antiguo importé la RSA que ya tenía. Para los clientes, cada uno según sus normas.

**Pruebas en paralelo.** Descargué las `.pub` a `~/.ssh/keys/` y, host a host, siempre la misma receta: subir la pública nueva usando la clave vieja; entrar forzando solo la nueva con `ssh -o IdentitiesOnly=yes -i ~/.ssh/keys/homelab.pub host`; si entra, quitar la vieja del `authorized_keys` dejando una copia; apuntar el bloque del config a la `.pub` nueva; y por último `ssh host` sin forzar nada. Cinco minutos por host y ningún susto.

**Retirar y borrar.** Antes de borrar nada, aparté las privadas que ya no referenciaba ningún `Host` en un directorio `~/.ssh/retired/` y les di unos días de margen. También aproveché para sacar del config las contraseñas que tenía apuntadas en comentarios; ahora viven en 1Password, que es donde debían estar. Después, fuera. Lo que de verdad protege es que los tres discos van cifrados.

## Problemas típicos

| Error                                                      | Causa                                                                                   | Solución                                                         |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `Could not open a connection to your authentication agent` | `IdentityAgent` apunta a un socket que no existe, o 1Password no está corriendo         | Comprobar el socket y que el agente está activado en _Developer_ |
| `invalid format` sobre un `.pub`, y luego pide contraseña  | 1Password está cerrado: sin agente, `ssh` intenta leer el `.pub` como privada           | Abrir 1Password; el aviso desaparece solo                        |
| `Too many authentication failures`                         | El agente ofrece más de seis claves                                                     | `IdentitiesOnly yes` con el `.pub`, y ordenar `agent.toml`       |
| `agent refused operation`                                  | 1Password no quiso firmar: petición denegada, vault bloqueado o regresión con `ssh-rsa` | Mirar el prompt, actualizar 1Password                            |
| `no matching key exchange method found`                    | El destino solo ofrece algoritmos antiguos                                              | Reactivarlos solo para ese `Host`                                |
| `Permission denied (publickey)` con `IdentitiesOnly`       | El `.pub` no coincide con ninguna clave del agente, o esa clave no está en `agent.toml` | `ssh-add -l` y comparar huellas                                  |
| `ssh` colgado sin salida desde un script o agente de IA    | 1Password bloqueado o prompt suprimido por estar en segundo plano                       | Desbloquear y mirar _SSH request waiting_ en el icono            |
| En Git Bash nada funciona                                  | Está usando su propio `ssh`, que no habla con el pipe                                   | `core.sshCommand` y `PATH` al `ssh.exe` de Windows               |

## Conclusión

Mola. La sensación de abrir cualquiera de las tres máquinas, escribir `ssh pve`, poner el dedo y estar dentro, sin haber copiado un solo fichero, es de las que no vuelves atrás. Y el prompt que te dice _quién_ pide _qué_ clave es un control que con `ssh-agent` no tenía.

Pero es importante tener claro el límite: el agente de 1Password es para personas. Todo lo que corre solo, sin nadie delante, sigue con claves de fichero bien restringidas. Y los agentes de IA están en medio: funcionan de maravilla mientras tú estés ahí con el vault desbloqueado, y se quedan mirando al infinito en cuanto no lo estás.

## Referencias

Consultadas el 4 de septiembre de 2026. Lo que no aparece aquí y he afirmado en el apunte, dalo por experiencia u opinión mía.

| Tipo      | Enlaces                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1Password | [Get started with the SSH agent](https://developer.1password.com/docs/ssh/get-started/), [SSH agent config file](https://developer.1password.com/docs/ssh/agent/config/), [Advanced use cases](https://developer.1password.com/docs/ssh/agent/advanced/), [Security](https://developer.1password.com/docs/ssh/agent/security/), [Agent forwarding](https://developer.1password.com/docs/ssh/agent/forwarding/), [Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/) |
| 1Password | [Use the SSH agent with WSL](https://developer.1password.com/docs/ssh/integrations/wsl/), [Sign Git commits with SSH](https://developer.1password.com/docs/ssh/git-commit-signing/), [Manage SSH keys](https://developer.1password.com/docs/ssh/manage-keys/)                                                                                                                                                                                                                                  |
| OpenSSH   | [ssh_config(5)](https://man.openbsd.org/ssh_config), [sshd_config(5)](https://man.openbsd.org/sshd_config), [Release notes 8.8](https://www.openssh.com/txt/release-8.8)                                                                                                                                                                                                                                                                                                                       |
| Windows   | [OpenSSH key management (Microsoft)](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_keymanagement), [npiperelay (fork de albertony)](https://github.com/albertony/npiperelay)                                                                                                                                                                                                                                                                                 |
| Comunidad | [Git Bash and 1Password SSH not working](https://www.1password.community/discussions/developers/git-bash-and-1password-ssh-not-working/142552), [Notas de versión de 1Password](https://releases.1password.com/mac/stable/)                                                                                                                                                                                                                                                                    |
