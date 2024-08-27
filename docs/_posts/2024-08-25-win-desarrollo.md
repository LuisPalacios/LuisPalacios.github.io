---
title: "Windows para desarrollo"
date: "2024-08-25"
categories: desarrollo
tags: windows wsl wsl2 linux ubuntu desarrollo visual studio python git cli vscode compilador
excerpt_separator: <!--more-->
---

![logo win desarrollo](/assets/img/posts/logo-win-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo los pasos para preparar un Windows 11 como equipo de desarrollo. Teniendo en cuenta que soy *Unixero* y trabajo en entorno multiplataforma, Linux, MacOS y Windows, veras que este apunte no está orientado a desarrolladores *solo-microsoft/windows*, sino a los que les gusta desarrollar en múltiples plataformas y/o entornos.

Parto de una instalación de Windows limpia, aproveché que necesitaba hacer [dualboot]({% post_url 2024-08-23-dual-linux-win %}) y parametricé el sistema de forma [ligera]({% post_url 2024-08-24-win-decente %}). La primera parte la dedico al CLI y WSL2. La segunda es donde instalo las herramientas de desarrollo.

<br clear="left"/>
<!--more-->

---

## Preparar el equipo

Como todos mis apuntes, se trata de la bitácora de mi instalación, es decir, voy ejecutando y documentando a la vez, así me sirve para tener una referencia en el futuro. Empiezo con un Windows que no tiene nada instalado.

### CLI

Es imprescindible hablar de la Consola que vas a usar, tanto si estás acostumbrado a trabajar desde la línea de comandos como si no, los desarrolladores multiplataforma lo valoramos mucho.

En mi caso he trabajado en multiples Sistemas Operativos, no estoy obsesionado con ninguno, ni quiero imponer nada (soy todo lo contrario a un [BOFH](https://es.wikipedia.org/wiki/Bastard_Operator_from_Hell#:~:text=BOFH%20son%20las%20iniciales%20del,como%20Infame%20Administrador%20del%20Demonio)), lo que sí que tengo claro y he aprendido durante años es a **elegir lo que me ahorra tiempo**.

Anticipo que mi Consola elegida en Windows es la **Shell de Unix** (`zsh o bash`), junto con **las decenas de herramientas de línea de comandos Open Source existentes para Linux** (`ls, cd, mkdir, cp, tar, sed, awk, nano, vi, etc.`). Todas ellas se hicieron siguiendo la filosofía Unix, que establece que un programa '*debería hacer una cosa y hacerla bien*', y funcionan así de bien desde hace años.

El trabajo de millones de horas de otras personas me van a ahorrar mucho tiempo. Es inteligente invertir unas cuantas horas en aprender la Shell y el subconjunto de las herramientas de línea de comandos más utilizadas.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-01.svg"
      caption="Siempre Shell+Herramientas Linux"
      width="350px"
      %}

Cuando bajamos a tierra Windows, el entorno CLI ha sido históricamente un desafío. Desde el anticuado `command.com`, la complicada PowerShell, la obsoleta y confusa nomenclatura del sistema de archivos, la gestión de variables de entorno y PATH, y el omnipresente Registro de Windows, todo parece estar diseñado para frustrar al desarrollador.

Afortunadamente hay luz, en los últimos años, Windows ha dado un paso importante, la introducción de WSL-2 (Windows Subsystem for Linux). Gracias a él, **podemos trabajar con la Shell y herramientas Linux** en el ecosistema de Windows, permitiendo una experiencia de desarrollo mucho más fluida y eficiente, combinando lo mejor de ambos mundos.

Pero antes de entrar en WSL2, déjame dar dar un repaso a todas las opciones disponibles en el ámbito del CLI en Windows 11, ya te anticipo que acabo teniendo cuatro (si 4) consolas distintas.

**Command Prompt (`command.com` / CMD)**: la línea de comandos tradicional de Windows. Es uno de los entornos más antiguos y básicos para ejecutar comandos en Windows, sus scripts son los famosos ***`*.BAT`***. No necesita explicación. Trabajar en esta línea de comandos o hacer scripts en BAT es literalmente hacerse el Harakiri.

```PS
C:\> echo Bye bye, World!
```

**PowerShell**: Entorno de scripting y línea de comandos avanzada desarrollada por Microsoft. Es más potente que CMD, permite el uso de comandos más complejos, scripts, y el acceso al framework .NET. ***Los scripts terminan en `*.PS1`***.

Windows 11 trae la versión 5.1 y lo primero que voy a hacer es instalar la versión 7.

* Instalo ***Powershell 7***. Desde [PowerShell Tags](https://github.com/PowerShell/PowerShell/tags) en "Downloads".

Me quedan dos versiones en paralalelo, puedo arrancar la que quiera o ambas.

* PowerShell **5.x** - PowerShell (**powershell.exe**), conocido como "**Desktop**". Funciona **exclusivamente en Windows**.
  1. Basado en el motor PowerShell 5.1.
  2. Totalmente integrado con Windows, soportando todas las características, módulos y cmdlets específicos de Windows.
  3. Corre sobre el .NET Framework.
  4. Ideal para gestionar entornos Windows, incluyendo Active Directory, Exchange y otros servicios específicos de Windows.

* PowerShell **7.x** - PowerShell (**pwsh.exe**), conocido como "**Core**". **Multiplataforma** (Windows, macOS, Linux).
  1. Basado en el motor de PowerShell 6.0+.
  2. Diseñado para ser más modular y liviano, pero puede carecer de algunas características y módulos específicos de Windows.
  3. Corre sobre .NET Core (ahora .NET 5+).
  4. Adecuado para gestionar entornos diversos, incluyendo servicios en la nube y sistemas no Windows.

```PS
PS C:\> $PSVersionTable
:
```

Puede que PowerShell le sea ***útil a desarrolladores que trabajan exclusivamente en .NET, con C#, en entornos solo Microsoft, para automatizaciones***, o si quieres diferenciarte en el mundo DevOps CI en entornos exclusivos Microsoft/Windows, ***debes aprenderla***. Pero para el resto de casos, mi opción es ***ni aprenderlo, ni usarlo***, así que, a no ser que no me quede más remedio, la PS es para mi un mal necesario, que está ahí, instalo, mantengo, uso de vez en cuando, y punto.

***Windows Subsystem for Linux (WSL 2)***: permite ejecutar un entorno Linux directamente en Windows sin la necesidad de una máquina virtual. Puedes instalar distribuciones de Linux (como Ubuntu, Debian, etc.) y usar la Shell que quieras de forma nativa, con altísimo rendimiento, completamente integrado con el File System de Windows (excepto los permisos). ***¡Esto es justo lo que necesito y recomiendo usar!***. En la siguiente sección explico cómo lo he instalado.

```bash
luis@kymeraw:/mnt/c/Users/luis$ ls -al
```

Hasta aquí he listado las cuatro opciones de consola que voy a tener en mi Windows: `command.com`, `powershell.exe`, `pwsh.exe`, `Shell linux`, pero hay un programa muy interesante que permite ordenar el acceso a ellas, se trata de Windows Terminal.

***Windows Terminal***: Una aplicación moderna que permite utilizar múltiples pestañas con diferentes consolas, como `CMD`, `PowerShell`, `WSL` y otras. Es muy personalizable y soporta características avanzadas como temas y configuraciones de fuentes. Más adelante muestro cómo lo he configurado.

***Más CLI's o Terminales***: Las dos primeras las voy a tratar más adelante.

* *Git Bash:* Junto con `GIT`, al instalarlo en Windows, podemos acceder a `Git bash`, una herramienta que proporciona un emulador de Bash para Windows. Es especialmente útil para desarrolladores que trabajan con Git y necesitan una CLI con comandos Unix.
* *Visual Studio Code - Terminal Integrado***: Visual Studio Code (VS Code) es un editor de código fuente que incluye un terminal integrado. Puedo abrir diferentes terminales dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL.
  *[ConEmu](https://conemu.github.io/)*: otro emulador de terminal avanzado que soporta múltiples consolas dentro de la misma ventana. Puedes abrir CMD, PowerShell, Bash, entre otros, en pestañas diferentes.
* *[Cmder](https://cmder.app/)*: es una consola portátil para Windows, basada en ConEmu y extendida con herramientas Unix como Git para Windows, que proporciona una experiencia CLI unificada.

#### Mi estrategia

Mi estrategia es sencilla y simple, que mi Consola ejecute siempre ***Shell y Herramientas Linux***. ¿Cómo?

* Windows: Instalando `WSL 2` > `<Distribución>` >  ***`zsh o bash`***. Me dará acceso nativo al `C:\` vía `/mnt/c`. Tendré una Distribución Linux completa con acceso a **todas las herramientas open source disponibles en Linux**. Como Terminal uso "Windows Terminal" (más adelante lo explico).
* [MacOS]({% post_url 2023-04-15-mac-desarrollo %}): Uso **zsh**, también **bash** (scripts), junto con las herramientas preinstaladas y **Homebrew** para tener acceso a **todas las herramientas open source disponibles en Linux**. Como Terminal uso "iTerm2". En el enlace tienes un apunte.
* [Linux]({% post_url 2024-07-25-linux-desarrollo %}): Uso **zsh**, tamibén **bash** (scripts), junto con **todas las herramientas open source disponibles en Linux**. Como Terminal yo uso "Gnome Terminal". En el enlace tienes un apunte.

En el caso de Windows, que es sobre lo que va este apunte, rara vez y solo cuando no me quede más remedio iré al CLI nativo de Microsoft: `command.com`, `powershell.exe` o `pwsh.exe`.  A la hora de automatizar con scripts y dado que son todos incompatibles entre sí (`.BAT`, `.PS1`, `scripts bash`) estandarizo mis scripts para que usen `bash`. Ahora con WSL2 también van a funcionarme en Windows.

### WSL 2

Utiliza una máquina virtual ligera con un **kernel completo de Linux real**, tiene un **rendimiento** altísimo, está super **integrado con Windows**, permite que los archivos y scripts de Linux se ejecuten desde el explorador de Windows, y viceversa; y muy importante, tiene **compatibilidad con Docker**, de hecho WSL2 es el backend preferido para [Docker Desktop en Windows](https://www.docker.com/products/docker-desktop/) (que instalaré más adelante).

Mis **dos casos de uso principales** son:

* Tener Shell + Herramientas con acceso nativo a `C:\` (vía `/mnt/c`).
* Poder instalar Docker Desktop en Windows

Proceso de instalación:

* Abrir **“Características de Windows**” - Win + R, `optionalfeatures`. Marco:
  * Virtual Machine Platform (Plataforma de Máquina Virtual)
  * Windows Subsystem for Linux (Subsistema de Windows para Linux)
  * Hyper-V (recomendado para Docker con WSL2).

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-02.png"
      caption="Activar características VM"
      width="2560px"
      %}

* **Reboot**
* **Instalo WSL**, desde PowerShell como administrador

  ```PS
  wsl --install
  ```

* **Instalo una distribución**, en mi caso Ubuntu 24.04 (podrías instalar otra como Debian, Kali-Linux, Suse, ...). Abro PowerShell como Administrador

  ```PS
  wsl --install -d Ubuntu-24.04
  ```

  * Durante la instalación requirió actualizar el núcleo de Linux:
    * Descargué el [Paquete de actualización del kernel de Linux en WSL 2 para máquinas x64](https://learn.microsoft.com/es-es/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package)
    * Lo ejecuté e hice un reboot y tuve que volver a lanzar la instalación de la distribución, creé el usuario linux (`luis`) y le puse contraseña.

    ```PS
    wsl --install -d Ubuntu-24.04
    ```

  * Cuando termina lanza la consola con el CLI de `bash`. Me salgo con `exit`, ya volveremos.

* Abro PowerShell como Administrador, muestro que tengo y me aseguro de que siempre sea la versión 2 (en mi caso no hace falta, solo si tienes otra versión)

  ```PS
  wsl --list --verbose
  wsl --set-default-version 2
  ```

* Actualizo

  ```PS
  wsl --update
  ```

Opcionalmente puedo añadir un icono a Ubuntu en el Taskbar. Busco en la lista de aplicaciones instaladas: `Start > All > "Ubuntu 24.04"` y con el botón derecho hago un *Pin to taskbar* para tener un acceso rápido a mi `bash` (Ubuntu 24.04 en WSL2). Nota: Luego lo quité, una vez que instalo "Windows Terminal" más adelante.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-03.png"
      caption="bash para Windows :-)"
      width="650px"
      %}

Efectivamente estamos en una máquina virtual con Ubuntu, así que puedo instalar la herramienta que quiera. Lo siguiente imporante a hacer es actualizala.

```bash
luis@kymeraw:~$ sudo apt update && sudo apt upgrade -y
```

#### WSL 2 - Cambiar HOME

Quiero que al entrar en WSL2 el HOME de mi usuario sea `/mnt/c/Users/luis`, para que `cd` me lleve al mismo HOME que en Windows: `C:\Users\luis`. Voy a usar el comando `usermod` de linux, pero debo hacerlo como root:

* Desde Powershell, pido que WSL arranque como `root`:

```PS
PS C:\Users\luis> ubuntu2024.exe config --default-user root
```

* Abro una nueva Shell y cambio el HOME de `luis`

```bash
usermod --home /mnt/c/Users/luis/ luis
```

* Vuelvo a dejar que el login por defecto lo haga con `luis`

```PS
PS C:\Users\luis> ubuntu2024.exe config --default-user luis
```

#### WSL 2 - Permisos de ficheros

Los permisos de los archivos Linux que se crean en el disco NTFS [se intepretan de una forma muy concreta](https://learn.microsoft.com/en-us/windows/wsl/file-permissions). Los archivos/directorios que se crean en el disco NTFS (debajo de `/mnt/c/Users/luis`) van con permisos 777.

A mi eso no me gusta. Quiero que WSL sea coherente, además hay programas a los que no les gusta tanto permiso, un ejemplo es SSH. El cliente de OpenSSH necesita que el directorio y los archivos bajo `~/.ssh` tengan unos permisos específicos.

La solución es activar los ***metadatos*** en la [configuración avanzada de WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config). Desd WSL, como `root`, edito `/etc/wsl.con`. La sección `[boot]` ya estaba, he añadido la sección `[automount]`

```zsh
luis@kymeraw:~$ sudo su -

root@kymeraw:~# cat /etc/wsl.conf
[automount]
options = "metadata,uid=1000,gid=1000,umask=022,fmask=11,case=off"

[boot]
systemd=true
```

Hay que salir de la Shell y esperar al menos 8 segundos. Puedes verificar si WSL ha terminado del todo con el comando `wsl --list --running` desde una sesión de PowerShell.

#### WSL 2 - Locale

Mi Windows 11 está en inglés y el Ubuntu se ha instalado en Inglés. Tengo que añadir el locale de Español. En la sesión de Ubuntu, cambio a root y ejecuto lo siguiente:

```bash
root@kymeraw:~$ sudo su -
:
root@kymeraw:~# cat > /etc/locale.gen
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
root@kymeraw:~# locale-gen
Generating locales (this might take a while)...
  en_US.UTF-8... done
  es_ES.UTF-8... done
Generation complete.
```

#### WSL 2 - Cambio a ZSH

La shell que viene por defecto en Ubuntu para WSL2 es `bash` pero como expliqué en [¡Adiós Bash, hola Zsh!]({% post_url 2024-04-23-zsh %}), me paso a `zsh` ([un apunte interesante]({% post_url 2024-07-25-linux-desarrollo %})). También me instalo ["tmux"]({% post_url 2024-04-25-tmux %}), un multiplexor de terminales opcional potentísimo.

Primero `zsh`

```bash
luis@kymeraw:~$ sudo apt update && sudo apt upgrade -y
luis@kymeraw:~$ sudo apt install zsh
```

Compruebo las shells disponibles

```bash
luis@kymeraw:~$ cat /etc/shells
:
/bin/zsh
/usr/bin/zsh
```

Cambio la shell por defecto

```bash
luis@kymeraw:~$ chsh -s $(which zsh)
Password:
```

Salgo y vuelvo a entrar. La primera vez que entras con `zsh` te ofrece ayuda para crear el fichero `.zshrc`. En mi caso ya lo tengo creado porque uso el mismo para MacOS, Linux y ahora Windows. Me lo descargo **[~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7)** y lo copio al HOME `/mnt/c/Users/luis`.

Instalo tmux, que lo suelo utilizar:

```bash
apt install tmux
```

También tengo un **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**, que también copio al HOME (`/mnt/c/Users/luis`).

#### WSL 2 - Scripts

Me instalo mis scripts que suelo usar en todos los Linux/MacOS,

* Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e)
* Fichero [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) personalizado para `nano`
  * Creo los directorios de backup (`sudo mkdir /root/.nano` y `mkdir ~/.nano`
* Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat), un cat sin las líneas de comentarios
* Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) para cambiar a root mucho más rápido
  * Añado mi usuario a sudoers
  * `echo 'luis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-mi-usuario`
* Cambiar los permisos:
  * `sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`

#### WSL 2 - Cliente SSH

Para poder conectar desde la Consola WSL2 a equipos remotos.

* Verifico que el cliente de OpenSSH está instalado:

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
```

* Desde WSL creo `/mnt/c/Users/luis/.ssh`, luego creo una clave pública/privada.

```zsh
⚡ luis@kymeraw:luis % cd     # Vuelvo a HOME
⚡ luis@kymeraw:luis % pwd
/mnt/c/Users/luis
⚡ luis@kymeraw:luis % mkdir .ssh
⚡ luis@kymeraw:luis % cd .ssh
⚡ luis@kymeraw:luis % ssh-keygen -t ed25519 -a 200 -C "luis@kymeraw" -f ~/.ssh/id_ed25519
```

Tengo varios apuntes sobre SSH [Git y SSH multicuenta]({% post_url 2021-10-09-ssh-git-dual %}), [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %}) por si lo necesitas.

#### WSL 2 - Servidor SSH

Configuro que los clientes **accedan directamente a la shell de WSL2** cuando se conecten a mi Windows 11. Nota: todos los comandos desde **PowerShell** como Administrador

* Verifico que OpenSSH está instalado:

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
```

* Agrego el Servidor OpenSSH:

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

* Cambio a que la Shell predeterminada sea WSL. Importante, nunca usar los ejecutables bajo `C:\Users\luis\AppData\Local\Microsoft\WindowsApps` o tardará muchos segundos en mostrarte el prompt al conectar desde los clientes.

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\wsl.exe" -PropertyType String -Force
```

* Inicio el Servicio, Compruebo y Configuro que arranque siempre al hacer boot

```powershell
Start-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

* Respecto a los ***Credenciales***, el Server está ejecutándose en Windows (no en Ubuntu), por lo tanto: Mi usuario es `luis` LOCAL (no uso Microsoft Account) y la contraseña es la de Windows.

* Fichero `C:\ProgramData\ssh\sshd_config`. Desactivo usar el fichero `administrators_authorized_keys`. Para `luis` usará `/mnt/c/Users/luis/authorized_keys`

```config
AuthorizedKeysFile	.ssh/authorized_keys
AcceptEnv LANG LC_*
Subsystem	sftp	sftp-server.exe
#Match Group administrators
#       AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

Lo edito y rearranco el servicio

```powershell
notepad C:\ProgramData\ssh\sshd_config
Restart-Service sshd
```

* Edito las claves que acepto en `authorized_keys`

```powershell
notepad C:\ProgramData\ssh\administrators_authorized_keys
```

* Cómo comprobar si el puerto 22 está abierto. Por defecto lo tenía abierto en mi caso

Si necesitas comprobarlo aquí tienes un script [VerificarPuertoFirewall.ps1](https://gist.github.com/LuisPalacios/f1013d3a0cc0d540b94df2d7d42c2f40). Para abrirlo

```powershell
New-NetFirewallRule -DisplayName "Allow SSH Port 22" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
```

* A partir de ahora me puedo conectar perfectamente con mi Windows desde cualquier otro equipo de la red.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-04.png"
      caption="Conexión vía SSH desde un Mac"
      width="550px"
      %}

#### WSL 2 - CRLF vs LF

Al trabajar en desarrollo de software, uno de los aspectos más sutiles pero cruciales que debes tener en cuenta es la diferencia entre los finales de línea en archivos de texto entre Windows y Linux.

Este pequeño detalle puede generar grandes problemas si no se maneja correctamente, especialmente cuando se trabaja en entornos mixtos, **conflictos en el control de versiones** **incompatibilidades en scripts**, **problemas de compilación o ejecución**. Estas son algunas soluciones:

* Que Git lo gestione ([documentación aquí](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings)). Es decir, revisa los finales de línea antes de los commits.
  * Puede hacerse a nivel global
    * `git config --global core.autocrlf true`  - Para convertir LF a CRLF al hacer checkout en Windows
    * `git config --global core.autocrlf input` - Para mantener LF en los repositorios y convertir CRLF a LF al hacer commit
  * Puede hacerse de forma más granular
    * Usando el archivo `.gitattributes` en la raiz del repositorio.
* Usar un editor de texto que te permita elegir el tipo de final de línea. Por ejemplo, Visual Studio Code, Sublime Text, etc
* Conversión manual con `dos2unix` y `unix2dos` (yo los he instalado en mi WSL2 con `apt install -y dos2unix`)
* Sobre todo **mantener el control**, yo me aseguro de que mis ediciones, herramientas, editores y scripts estén configurados correctamente para manejar y respetar el formato de finales de línea.

#### Modificar el PATH

* Yo siempre dedico un directorio personal específicio para mis scripts y ejecutables. Asñu ne asegyri de qye está disponible en todos ordenadores. Dicho directorio lo puedes sincronizar de múltiples formas, en mi caso utilizo un servidor NextCloud:

* PATH Global en Windows para `command.com y PowerShell`
  * `Start > Settings > About > Advance System Settings`
  * `Environment Variables`
  * ***`System variables`***
  * Añado `C:\Users\luis\Nextcloud\priv\bin` al final de la lista.

* PATH Linux (WSL2)
  * Edito el fichero `~/.bashrc` o `.zshrc`
  * Añado: `export PATH=$PATH:/mnt/c/Users/luis/Nextcloud/priv/bin`

### Windows Terminal

Ahora que tengo WSL2 perfectamente operativo, voy a instalarme ***Windows Terminal***, una herramienta que permite utilizar múltiples consolas en pestañas o ventanas separadas, lo que simplifica enórmemente el punto de entrada a la consola. Solo tengo un sitio donde hacer clic, y dentro de él ya elegiré que quiero arrancar.

* Abro la Microsoft Store, `Start` > busco por "Store"
* Busco por "Windows Terminal". Instalo o Actualizo

***Configuración inicial*** de Windows Terminal

* Abro Windows Terminal `Start` busco "Terminal"
* Accedo a la configuración
  * Clic en 'flecha abajo' > `Settings` o `Ctrl + ,`.
* Configurar perfiles de consola:
  * En el panel izquierdo, veo perfiles como `Windows PowerShell`, `Command Prompt`, `Ubuntu`, etc. Aquí puedo personalizar cada uno de ellos.
  * Cambiar el shell predeterminado: Si deseas que siempre se abra un perfil específico al iniciar Windows Terminal, selecciona el perfil en el menú "Startup" bajo "Default profile".
* Personalizar apariencia:
  * Puedes cambiar el tema, fuente, esquema de colores y más para cada perfil.
* Agregar nuevas consolas (opcional)

***Anclar Windows Terminal al Taskbar***, tan sencillo como con otras Apps

* Lo busco y lo abro
* Hago clic derecho en el ícono de Windows Terminal en la barra de tareas.
* "Pin to taskbar" (Anclar al taskbar).

Tendrás acceso rápido a Windows Terminal directamente desde tu taskbar, y podrás abrir rápidamente cualquier consola que necesites con solo un clic.

***Usar múltiples pestañas en Windows Terminal***: Podemos hacer varias cosas

* Abrir nuevas pestañas: ícono `+` o atajo `Ctrl + Shift + T`.
* Cambiar entre pestañas: `Ctrl + Tab`
* Cerrar pestañas: ícono `X` o `Ctrl + Shift + W`.
* Sacar las pestañas como ventanas independientes: Botón derecho sobre la pestaña

Empiezo a trabajar de manera más eficiente y organizada. Tengo la posibilidad de abrir la consola que necesite, por defecto lo he configurado para que WSL (Ubuntu 22.04.3 LTS), he cambiado los colores ligeramente para diferenciar dónde estoy y en el caso de `command.com` he puesto otro tipo de fuente de letra.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-05.png"
      caption="Por opciones que no sea"
      width="2560px"
      %}

***Configuración `settings.json` y `state.json`***: Gran parte de esta personalización de Windows Terminal se gestiona a través de dos archivos clave: `settings.json` (nucleo de la personalización, puedes editarlo desde el propio menú) y `state.json` (estado actual del Terminal).

<br/>

---

## Herramientas de desarrollo

La segunda parte del apunte, la instalación de las herramientas de desarrollo, como hay miles y es inviable documentarlo, espero que las que instalo te sirvan de ejemplo. IMPORTANTE!! verás que la gran mayoría las instalo en Windows 11, lo digo porque quizá alguna merecería la pena instalarlas dentro del WSL2 (por ejemplo `Ruby`?). Mientras que no diga lo contrario instalo siempre en Windows.

### VSCode

![VSCode](/assets/img/posts/logo-vscode.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Lo ***instalo*** desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/). Diría que es el editor de código fuente más potente que he visto nunca, con soporte de cientos de extensiones muy últiles, la posibilidad de abrir diferentes **terminales integrados** dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL. S

Además, soporta una amplia variedad de lenguajes de programación y la posibilidad de trabajar con equipos remotos. El fichero de settings del usuario está en este directorio. Muestro cómo lo suelo configurar yo (ojo que esto ya es muy personal)

* `PS C:\Users\luis\AppData\Roaming\Code\User\settings.json`

```json
{
    "debug.javascript.autoAttachFilter": "always",
    "redhat.telemetry.enabled": false,
    "security.workspace.trust.untrustedFiles": "open",
    "git.openRepositoryInParentFolders": "always",
    "[python]": {
        "editor.formatOnType": true
    },
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.autofetch": true,
    "cmake.configureOnOpen": true,
    "cmake.showOptionsMovedNotification": false,
    "openInDefaultBrowser.run.openWithLocalHttpServer": false,
    "terminal.integrated.enableMultiLinePasteWarning": "never",
    "markdownlint.config": {
        "MD023": false
    },
    "explorer.confirmDelete": false,
    "workbench.colorTheme": "Default Light Modern",
    "editor.accessibilitySupport": "off",
    "search.followSymlinks": false
}
```

### Git

![Git para Windows](/assets/img/posts/2024-08-25-win-desarrollo-06.png){: width="150px" height="150px" style="float:left; padding-right:25px" }

El objetivo principal es tener acceso al ejecutable `git.exe` desde las consolas de Microsoft (`CMD` y `PowerShell`) y aplicaciones de terceros. Selecciono Use external OpenSSH porque ya viene instalado con Windows 11. Selecciono Use the OpenSSL library (para los server certificates). El ejecutable `git` dentro de WSL2 es distinto y también lo usaré, pero quiero tener la opcion de ambos.

***Instalo*** desde el [sitio oficial de Git](https://git-scm.com/). Durante la instalación elijo la opción de "Git from the command line and also from 3rd-party software". No elijo la tercera opción (Use Git and optional Unix tools). Selecciono `Checkout Windows-style, commit Unix-style line endings` (lo mencioné en [CRLF vs LF](#wsl-2---crlf-vs-lf)). Dejo la opción de Use MinTTY, aunque no creo que lo use (no creo que use `git bash`). Selecciono `Fast-forward or merge`, [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager) y "Enable file system caching`.

Se instala en `C:\Program Files\Git`. Importante: Debajo incluye un ejecutable llamado `.\bin\bash.exe` que no usaré porque tengo WSL2 (`C:\Windows\System32\bash.exe`).

### Docker Desktop

![Docker Desktop](/assets/img/posts/logo-docker.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Permite la creación y gestión de contenedores, lo que es esencial para el desarrollo y despliegue de aplicaciones en entornos aislados. Muy útil cuando estás desarrollando Servicios (por ejemplo en `Go`, `NodeJS`).

Mis casos de uso son varios, poder ejecutar procesos contenerizados (por ejemplo una base de datos), dockerizar Servicios desarrollados (por ejemplo en Go o NodeJS), hacer pruebas de CI para DevOps, laboratorios de Microservicios, etc. ***Instalo*** desde el [sitio oficial de Docker](https://www.docker.com/products/docker-desktop). Su integración con WSL2 es fundamental y el haberlo preparado antes nos ayuda a tener una instalación fluída.

Durante el proceso de instalación selecciono usar WSL2 en vez de Hyper-V

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-07.png"
      caption="Opción WSL2"
      width="300px"
      %}

### Postman o HTTPie

![Docker HTTPie](/assets/img/posts/logo-httpie.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

O ambos. Quizá estás más habituado al primero, puedes instalar desde el [sitio oficial de Postman](https://www.postman.com/). Es una herramienta muy conocida para probar y documentar APIs. Es muy útil para desarrolladores que trabajan con servicios web. En mi caso de momento la dejo en la recámara, quizá la instale más adelante.

Hace poco encontré esta otra herramienta, soporta trabajar tanto en la línea de comandos o GUI para realizar solicitudes HTTP, diseñada para ser simple y fácil de usar, ideal para probar y depurar APIs de manera rápida y eficiente. Me gusta más que Postman, sobre todo por la parte de la línea de comandos. La ***instalo*** desde el [sitio oficial de HTTPie](https://httpie.io/).

### Work in Progress

Esta sección la marco como "WiP", porque hay decenas de apps, utilidades, comandos, entornos de desarrollo y es imposible documentarlos todos. Mi objetivo realmente era romper el hielo. Realmente estos apuntes vienen bien para tener una bitácora de mi instalación, por si tengo que repetirla, pero sobre todo porque espero que te venga bien a ti como ejemplo.

Iré documentado/añadiendo lo nuevo que vaya instalando, cosas que tengo en la cabeza: Compilador de C/C++, GoLang, Node.js, JDK de Java, BBDD locales (Si lo hago será con Docker).

<br/>

---

## Aprendizaje continuo

Para terminar, voy a insistir un poco más sobre ***Shell y Linux***. Si vienes de Windows, te recomiendo aprender a utilizar la Shell; es una habilidad fundamental para cualquier desarrollador de software. La Shell permite automatizar tareas, ejecutar comandos, y manejar el sistema de una manera más eficiente y rápida que a través de interfaces gráficas. Existen muchos recursos disponibles para aprender a utilizar la Shell, tanto en `bash` como en `zsh`, te dejo algunas referencias

* **Curso en Español**: [Curso de Introducción a la Terminal y Comandos Básicos](https://platzi.com/cursos/comandos-terminal/)
* **Curso en Inglés**: [Command Line Basics (Udemy)](https://www.udemy.com/course/command-line-bash-for-beginners/)
* **Comandos Bash**: [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html)
* **Comandos Zsh**: [Zsh Users Guide](https://zsh.sourceforge.io/Guide/zshguide.html)

Además te recomiendo que eches un ojo a algún curso sobre la filosofía de trabajo en Unix, fundamental para comprender Linux. Cómo y por qué los comandos y programas de Unix/Linux están diseñados de la manera en que lo están. La idea principal es que un programa ‘debería hacer una cosa y hacerla bien’. Esta filosofía también abarca conceptos clave como la entrada y salida, el sistema de archivos, la estructura de directorios y la idea de que ‘todo es un fichero’ en Unix. Te dejo algunos cursos cortos y didácticos que cubren estos temas:

* **Curso en Español**: [Introducción a Unix y Linux - Filosofía y Conceptos Básicos](https://cursoswebgratis.com/curso-de-linux/), donde se abordan la estructura de directorios, la gestión de ficheros, y la filosofía Unix de diseño de programas.
* **Curso en Inglés**: [The Unix Workbench (Coursera)](https://www.coursera.org/learn/unix), un curso introductorio que explica la filosofía de Unix, incluyendo la entrada y salida, y cómo interactuar con el sistema de archivos.
* **Curso en Inglés**: [Linux Command Line Basics - Learn the Shell, Philosophy, and More (Udemy)](https://www.udemy.com/course/linux-command-line-basics/), un curso que cubre tanto los comandos esenciales como los principios filosóficos de Unix/Linux.
* **Curso en Inglés**: [Understanding the Unix Philosophy (LinkedIn Learning)](https://www.linkedin.com/learning/understanding-the-unix-philosophy), un curso corto que ofrece una visión general sobre la filosofía de Unix y su aplicación práctica.

Por último, he seleccionado 50 comandos (hay muchos más) que deberías conocer como desarrollador de software multiplataforma. Son esenciales para la navegación del sistema de archivos, gestión de procesos, manipulación de texto, y otras tareas comunes en el desarrollo de software. Cada comando incluye un enlace a su respectiva manpage en Ubuntu 24.04.

<style>
table {
    font-size: 0.8em;
}
</style>

| Comando                                         | Descripción                                                      | Comando                                           | Descripción                                                      |
|-------------------------------------------------|------------------------------------------------------------------|---------------------------------------------------|------------------------------------------------------------------|
| **[ls](https://manpages.ubuntu.com/manpages/noble/man1/ls.1.html)**        | Lista los archivos y directorios en el directorio actual.        | **[alias](https://manpages.ubuntu.com/manpages/noble/man1/alias.1.html)**  | Crea un alias para un comando o una serie de comandos.             |
| **[cd](https://manpages.ubuntu.com/manpages/noble/man1/cd.1.html)**        | Cambia el directorio de trabajo actual.                          | **[unalias](https://manpages.ubuntu.com/manpages/noble/man1/unalias.1.html)** | Elimina un alias previamente definido.                             |
| **[pwd](https://manpages.ubuntu.com/manpages/noble/man1/pwd.1.html)**      | Muestra el directorio de trabajo actual.                         | **[history](https://manpages.ubuntu.com/manpages/noble/man1/history.1.html)** | Muestra el historial de comandos utilizados.                       |
| **[cp](https://manpages.ubuntu.com/manpages/noble/man1/cp.1.html)**        | Copia archivos y directorios.                                    | **[env](https://manpages.ubuntu.com/manpages/noble/man1/env.1.html)**      | Muestra o modifica las variables de entorno.                       |
| **[mv](https://manpages.ubuntu.com/manpages/noble/man1/mv.1.html)**        | Mueve o renombra archivos y directorios.                         | **[export](https://manpages.ubuntu.com/manpages/noble/man1/export.1.html)**  | Define variables de entorno para los procesos secundarios.         |
| **[rm](https://manpages.ubuntu.com/manpages/noble/man1/rm.1.html)**        | Elimina archivos y directorios.                                  | **[source](https://manpages.ubuntu.com/manpages/noble/man1/source.1.html)**  | Ejecuta comandos desde un archivo en el contexto de la Shell actual.|
| **[mkdir](https://manpages.ubuntu.com/manpages/noble/man1/mkdir.1.html)**  | Crea nuevos directorios.                                         | **[uname](https://manpages.ubuntu.com/manpages/noble/man1/uname.1.html)**   | Muestra información sobre el sistema operativo.                    |
| **[rmdir](https://manpages.ubuntu.com/manpages/noble/man1/rmdir.1.html)**  | Elimina directorios vacíos.                                      | **[uptime](https://manpages.ubuntu.com/manpages/noble/man1/uptime.1.html)** | Muestra el tiempo que lleva encendido el sistema.                  |
| **[touch](https://manpages.ubuntu.com/manpages/noble/man1/touch.1.html)**  | Cambia las marcas de tiempo de un archivo o crea archivos vacíos.| **[whoami](https://manpages.ubuntu.com/manpages/noble/man1/whoami.1.html)** | Muestra el nombre del usuario actual.                              |
| **[echo](https://manpages.ubuntu.com/manpages/noble/man1/echo.1.html)**    | Muestra una línea de texto o variable.                           | **[which](https://manpages.ubuntu.com/manpages/noble/man1/which.1.html)**   | Localiza un comando y muestra su ruta completa.                    |
| **[cat](https://manpages.ubuntu.com/manpages/noble/man1/cat.1.html)**      | Concatenar y mostrar el contenido de archivos.                   | **[head](https://manpages.ubuntu.com/manpages/noble/man1/head.1.html)**     | Muestra las primeras líneas de un archivo.                         |
| **[grep](https://manpages.ubuntu.com/manpages/noble/man1/grep.1.html)**    | Busca patrones en el contenido de archivos.                      | **[tail](https://manpages.ubuntu.com/manpages/noble/man1/tail.1.html)**     | Muestra las últimas líneas de un archivo.                          |
| **[find](https://manpages.ubuntu.com/manpages/noble/man1/find.1.html)**    | Busca archivos y directorios en una jerarquía de directorios.    | **[sort](https://manpages.ubuntu.com/manpages/noble/man1/sort.1.html)**     | Ordena líneas de texto en un archivo o entrada.                    |
| **[chmod](https://manpages.ubuntu.com/manpages/noble/man1/chmod.1.html)**  | Cambia los permisos de acceso de los archivos.                   | **[uniq](https://manpages.ubuntu.com/manpages/noble/man1/uniq.1.html)**     | Muestra o filtra líneas repetidas consecutivas en un archivo.      |
| **[chown](https://manpages.ubuntu.com/manpages/noble/man1/chown.1.html)**  | Cambia el propietario de archivos y directorios.                 | **[diff](https://manpages.ubuntu.com/manpages/noble/man1/diff.1.html)**     | Compara archivos línea por línea.                                  |
| **[ps](https://manpages.ubuntu.com/manpages/noble/man1/ps.1.html)**        | Muestra el estado de los procesos actuales.                      | **[tee](https://manpages.ubuntu.com/manpages/noble/man1/tee.1.html)**       | Lee de la entrada estándar y escribe en la salida estándar y en archivos.|
| **[kill](https://manpages.ubuntu.com/manpages/noble/man1/kill.1.html)**    | Envía señales a procesos, como detenerlos.                       | **[xargs](https://manpages.ubuntu.com/manpages/noble/man1/xargs.1.html)**   | Construye y ejecuta líneas de comando desde la entrada estándar.   |
| **[top](https://manpages.ubuntu.com/manpages/noble/man1/top.1.html)**      | Muestra los procesos en ejecución y el uso de recursos.          | **[jobs](https://manpages.ubuntu.com/manpages/noble/man1/jobs.1.html)**     | Muestra el estado de los trabajos en segundo plano.                |
| **[df](https://manpages.ubuntu.com/manpages/noble/man1/df.1.html)**        | Muestra el uso del espacio en disco de los sistemas de archivos. | **[bg](https://manpages.ubuntu.com/manpages/noble/man1/bg.1.html)**         | Reanuda un trabajo suspendido en segundo plano.                    |
| **[du](https://manpages.ubuntu.com/manpages/noble/man1/du.1.html)**        | Estima el uso del espacio en disco por archivos y directorios.   | **[fg](https://manpages.ubuntu.com/manpages/noble/man1/fg.1.html)**         | Trae un trabajo suspendido al primer plano.                        |
| **[tar](https://manpages.ubuntu.com/manpages/noble/man1/tar.1.html)**      | Manipula archivos tar.                                           | **[alias](https://manpages.ubuntu.com/manpages/noble/man1/alias.1.html)**   | Crea un alias para un comando o una serie de comandos.             |
| **[zip](https://manpages.ubuntu.com/manpages/noble/man1/zip.1.html)**      | Comprime archivos en formato ZIP.                                | **[unalias](https://manpages.ubuntu.com/manpages/noble/man1/unalias.1.html)**| Elimina un alias previamente definido.                             |
| **[unzip](https://manpages.ubuntu.com/manpages/noble/man1/unzip.1.html)**  | Descomprime archivos en formato ZIP.                             | **[history](https://manpages.ubuntu.com/manpages/noble/man1/history.1.html)**| Muestra el historial de comandos utilizados.                       |
| **[ssh](https://manpages.ubuntu.com/manpages/noble/man1/ssh.1.html)**      | Se conecta a servidores remotos de forma segura a través de SSH. | **[env](https://manpages.ubuntu.com/manpages/noble/man1/env.1.html)**       | Muestra o modifica las variables de entorno.                       |
| **[scp](https://manpages.ubuntu.com/manpages/noble/man1/scp.1.html)**      | Copia archivos entre servidores de forma segura.                 | **[export](https://manpages.ubuntu.com/manpages/noble/man1/export.1.html)** | Define variables de entorno para los procesos secundarios.         |
| **[wget](https://manpages.ubuntu.com/manpages/noble/man1/wget.1.html)**    | Descarga archivos desde la web.                                  | **[source](https://manpages.ubuntu.com/manpages/noble/man1/source.1.html)** | Ejecuta comandos desde un archivo en el contexto de la Shell actual.|
| **[curl](https://manpages.ubuntu.com/manpages/noble/man1/curl.1.html)**    | Transfiere datos desde o hacia un servidor.                      | **[uname](https://manpages.ubuntu.com/manpages/noble/man1/uname.1.html)**   | Muestra información sobre el sistema operativo.                    |
| **[nano](https://manpages.ubuntu.com/manpages/noble/man1/nano.1.html)**    | Editor de texto simple para la terminal.                         | **[uptime](https://manpages.ubuntu.com/manpages/noble/man1/uptime.1.html)** | Muestra el tiempo que lleva encendido el sistema.                  |
|  **[vim](https://manpages.ubuntu.com/manpages/noble/man1/vim.1.html)**      | Editor de texto avanzado en la terminal.                         | **[whoami](https://manpages.ubuntu.com/manpages/noble/man1/whoami.1.html)** | Muestra el nombre del usuario actual.                              |
| **[man](https://manpages.ubuntu.com/manpages/noble/man1/man.1.html)**      | Muestra el manual de usuario de cualquier comando.               | **[which](https://manpages.ubuntu.com/manpages/noble/man1/which.1.html)**   | Localiza un comando y muestra su ruta completa.                    |
