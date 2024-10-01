---
title: "Windows para desarrollo"
date: "2024-08-25"
categories: desarrollo
tags: windows wsl wsl2 linux ubuntu desarrollo visual studio python git cli vscode compilador
excerpt_separator: <!--more-->
---

![logo win desarrollo](/assets/img/posts/logo-win-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo los pasos para preparar un Windows 11 como equipo de desarrollo para un entorno multiplataforma, Linux, MacOS y Windows, es decir que no estará orientado a desarrollo de software *solo-microsoft/windows*, sino a los que les gusta desarrollar en y para múltiples plataformas y/o entornos.

Parto de una instalación de Windows (en inglés), sin nada instalado, aproveché que necesitaba hacer [dualboot]({% post_url 2024-08-23-dual-linux-win %}) y parametricé el sistema operativo de forma [ligera]({% post_url 2024-08-24-win-decente %}). El apunte empieza por el CLI y WSL2 y en la segunda parte entro en las herramientas y los lenguajes de programación.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

| Este apunte pertenece a una serie:<br><br>• Preparo un PC para [Dualboot Linux Windows]({% post_url 2024-08-23-dual-linux-win %}) e instalo Windows 11 Pro.<br>• Configuro [un Windows 11 decente]({% post_url 2024-08-24-win-decente %}), en su esencia, le quito morralla.<br>• Preparo el [Windows para desarrollo]({% post_url 2024-08-25-win-desarrollo %}) de software, CLI, WSL2, herramientas y lenguajes de programación. |

---

## Preparar el equipo

Como todos mis apuntes, se trata de la bitácora de mi instalación, es decir, voy ejecutando y documentando a la vez, así me sirve para tener una referencia en el futuro.

### Nota sobre el PATH

En Linux y MacOS es inmediato, pero en Windows modificar el PATH es distinto, hay un PATH de Usuario y uno de Sistema, que combinados nos dan el PATH completo. Durante el apunte verás que indico que hay que modificar el PATH. Dejo aquí el cómo:

* Para modificar el PATH Global
  * `Start` > `Settings > System > About > Advance System Settings`
  * o bien `Search` > "`Advance System Settings`" o "`Environment Variables`"
* Modificar en ***`System variables`*** y/o ***`User variables`***
* Dejo un ejemplo [de mi PATH final en un Gist](https://gist.github.com/LuisPalacios/d38dd10a92fa1ab6bbaec799e8afe2f3).

### CLI

Es imprescindible hablar de la Consola que vas a usar, tanto si estás acostumbrado a trabajar desde la línea de comandos como si no, los desarrolladores multiplataforma lo valoramos mucho.

Anticipo que voy a usar mucho WSL2, la **Shell de Unix** (`zsh o bash`), junto con **las herramientas de línea de comandos Open Source existentes para Linux** (`ls, cd, mkdir, cp, tar, sed, awk, nano, vi, etc.`), pero tambien usaré el CMD (con retoques para mejorarlo) y PowerShell.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-01.svg"
      caption="La ventaja  de Shell+Herramientas Linux"
      width="350px"
      %}

**CMD (`cmd.exe`))**: La línea de comandos tradicional de Windows. Es uno de los entornos más antiguos y básicos para ejecutar comandos en Windows, sus scripts son los famosos ***`*.BAT, *.CMD`***.

```PS
C:\> echo Bye bye, World!
```

Es lo que es, no necesita mucha explicación, bastante austero; pero si realmente te gusta, he añadido una sección sobre cómo mejorarlo considerablente !

**PowerShell**: Entorno de scripting y línea de comandos avanzada desarrollada por Microsoft. Es más potente que CMD, permite el uso de comandos más complejos, scripts, y el acceso al framework .NET. ***Los scripts terminan en `*.PS1`***.

* Windows 11 trae la PowerShell **5.x** - (**powershell.exe**), conocido como "**Desktop**". Funciona **exclusivamente en Windows**.
  1. Basado en el motor PowerShell 5.1.
  2. Totalmente integrado con Windows, soportando todas las características, módulos y cmdlets específicos de Windows.
  3. Corre sobre el .NET Framework.
  4. Ideal para gestionar entornos Windows, incluyendo Active Directory, Exchange y otros servicios específicos de Windows.

* ***Powershell 7***: (**pwsh.exe**), conocido como "**Core**". **Multiplataforma** (Windows, macOS, Linux).
  1. Basado en el motor de PowerShell 6.0+.
  2. Diseñado para ser más modular y liviano, pero puede carecer de algunas características y módulos específicos de Windows.
  3. Corre sobre .NET Core (ahora .NET 5+).
  4. Adecuado para gestionar entornos diversos, incluyendo servicios en la nube y sistemas no Windows.

Ahora es buen momento para instalarla,

* Instalo [PowerShell 7](https://github.com/PowerShell/PowerShell/tags) > "Downloads".

```PS
PS C:\> $PSVersionTable
:
```

* Modifico el script que se ejecuta al iniciar una sesión de PS7
  * Añado lo siguiente al final de `C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1` (PS7)

```PS
# Quito el alias de por defecto 'where' para evitar conflictos con el 'where.exe' que instalo desde Git para Windows
Remove-Item alias:\where -Force
```

PowerShell es muy ***útil para desarrolladores que trabajan exclusivamente en .NET, con C#, en entornos solo Microsoft***, para automatizaciones, para el mundo DevOps CI en entornos Windows/Azure.

***Windows Subsystem for Linux (WSL 2)***: permite ejecutar un entorno Linux directamente en Windows sin la necesidad de una máquina virtual. Puedes instalar distribuciones de Linux (como Ubuntu, Debian, etc.) y usar la Shell que quieras de forma nativa, con altísimo rendimiento, completamente integrado con el File System de Windows (excepto los permisos).

```bash
luis@kymeraw:/mnt/c/Users/luis$ ls -al
```

***Windows Terminal***: Una aplicación moderna que permite utilizar múltiples pestañas con diferentes consolas, como `CMD`, `PowerShell`, `WSL`, `Git Bash`, ... Es muy personalizable y soporta características avanzadas como temas y configuraciones de fuentes.  Entro en detalle más adelante.

***Git for Windows:*** Se trata del importantísimo **`git.exe`** para trabajar desde la línea de comandos que además incluye **Git Bash**, una herramienta que proporciona un emulador de Bash para Windows. Otro terminal más, algo parecido a lo que vemos en un terminal WSL2 de Ubuntu, pero usando un emulador de terminal y ejecutables nativos de Windows. Lo veremos.

***Visual Studio Code - Terminal Integrado***: Visual Studio Code (VS Code) es un editor de código fuente que incluye un terminal integrado. Puedo abrir diferentes terminales dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL.

#### Mi estrategia

Mi estrategia consiste en usar lo que mejor encaje en cada momento. Instalo y configuro todas las opciones anteriores, [mejoro el cmd](#cmd-mejorado) e instalo [Windows Terminal](#windows-terminal) como "lanzador unificado" del CLI que necesite en cada momento.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-08.png"
      caption="Uso el terminal que quiero según el caso de uso"
      width="450px"
      %}

### CMD Mejorado

Hoy en día, sobre todo para los que venimos de Unix/Linux/MacOS, se puede mejorar muchísimo, tanto he acabado usándolo bastante.

**Clink**: Lo primero que hay que hacer es instalar [Clink](https://github.com/chrisant996/clink/). Súper recomendado; le añade todo lo que le falta, la readline (de linux), múltiples funcionalidades, colores, historia, Scriptable Prompt.

Es importante que leas la sección de [instalación y uso](https://github.com/chrisant996/clink?tab=readme-ov-file#installation) para configurarlo de forma adecuada y sobre todo para inyectarlo en el CMD, de tal forma que arranque automáticamente al arrancar `cmd.exe`. Básicamente mete la siguiente entrada en el Registry:

```conf
  Computer\HKEY_CURRENT_USER\Software\Microsoft\Command Processor
    |
    +--> AutoRun   "C:\Program Files (x86)\clink\clink.bat" inject --autorun
```

Tiene un potencia enorme porque soporta [Scriptable Prompt]( https://chrisant996.github.io/clink/clink.html#customizing-the-prompt), que significa que puedas modificar el PROMPT usando scripts LUA en tiempo real, por ejemplo para el **estado de Git**. Lee la [documentación](https://chrisant996.github.io/clink/clink.html#extending-clink-with-lua).

Creo mi script LUA ([prompt_filters.lua](https://gist.githubusercontent.com/LuisPalacios/f0f86aa9ed476bd8286b4d058cc8a34c/raw/prompt_filters.lua)) en `C:\Users\luis\AppData\Local\clink`:

```cmd
clink-reload

C:\Users\luis>clink info | findstr scripts
scripts : C:\Program Files (x86)\clink ; C:\Users\luis\AppData\Local\clink

C:\Users\luis>notepad C:\Users\luis\AppData\Local\clink\prompt_filters.lua
```

**Startship.rs**: Lo siguiente que instalo es [startship.rs](https://starship.rs/), que se vende como "un Prompt para cualquier Shell, mínimo, super-rápido, y altamente personalizable". Starship aprovecha símbolos y caracteres especiales que no están presentes en las fuentes predeterminadas. Para que el prompt se vea correctamente, es necesario instalar una **Nerd Font**.

* Lo primero es instalarme una Nerd Font, desde su [repositorio oficial](https://www.nerdfonts.com/) > `Downloads`. Busco y descargo `Fira Code` (puede ser cualquiera). Unzip del fichero, selecciono todos los `.ttf` > botón derecho > `Install`. Lo configuro como fuente por defecto en [Windows Terminal](#windows-terminal), Settings -> Profiles -> Defaults -> Appearance -> Font Face `FiraCode`

* El siguiente paso es instalar la última versión con: `winget install starship`

* Añado el script de inicio a la Shell
  * Powershell: Añado lo siguiente al final de `C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1` (PS7)
    * `Invoke-Expression (&starship init powershell)`
  * CMD: Necesito tener Clink instalado y operativo
    * Creo el archivo `C:\Users\luis\AppData\Local\clink\starship.lua` con este contenido
    * `load(io.popen('starship init cmd'):read("*a"))()`
    * Elimino el fichero que creé en el paso anterior (Clink): `C:\Users\luis\AppData\Local\clink\prompt_filters.lua`

**Cmder**: puedes ir un paso más allá e instalarte *[Cmder](https://cmder.app/)*: una consola muy potente que incluye el emulador *[ConEmu](https://conemu.github.io/)* (emulador de terminal) y [Clink](https://github.com/chrisant996/clink/) y si has instalado Git for Windows, se integra perfecto, con acceso en el PATH a todas las herramientas.

Yo lo he instalado para probarlo, pero si soy sincero no lo estoy usando, me parecen ya demasiadasa opciones.

### WSL 2

WSL2 utiliza una máquina virtual ligera con un **kernel real completo de Linux**, tiene un **rendimiento** altísimo, está super **integrado con Windows**, permite que los archivos y scripts de Linux se ejecuten desde el explorador de Windows, y viceversa; y muy importante, tiene **compatibilidad con Docker**, de hecho WSL2 es el backend preferido para [Docker Desktop en Windows](https://www.docker.com/products/docker-desktop/) (que instalaré más adelante).

> ***Aviso:*** Solo le he encontrado un pero. Ten cuidado al acceder desde WSL2 a un directorio de `/mnt/c (C:)` del que cuelgan cientos o miles de archivos. Un ejemplo es un repositorio GIT grande. Irá lento, bastante lento. En esos casos es mejor "atacar" dichos directorios dessde el CMD o Powershell.

Mis **casos de uso de WSL2**:

* Tener Shell + Herramientas con acceso nativo a `C:\` (vía `/mnt/c`). Tendré una Distribución Linux completa con acceso a **todas las herramientas open source disponibles en Linux**. Llego al terminal WSL2 vía **Windows Terminal**
* Equipararme a lo que uso en [MacOS]({% post_url 2023-04-15-mac-desarrollo %}) o [Linux]({% post_url 2024-07-25-linux-desarrollo %}) para desarrollo de software.
* Poder instalar Docker Desktop en Windows

Proceso de instalación:

* Abrir **“Características de Windows**” - Win + R, `optionalfeatures`. Marco las opciones:
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

* Miro las distribuciones disponibles

  ```PS
  wsl --list --online
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

#### WSL 2 - Cambiar HOME a /mnt/c/Users

El único propósito por el que me gustaría cambiarlo es que al ejecutar "cd" me lleve a /mnt/c/Users/<usuario>, unificando el HOME en sesiones CMD, PowerShell y WSL2. Bueno, pues muy **IMPORTANTE, no lo recomiendo !!!**. Se puede hacer, que en vez de apuntar a `/home/<usuario>`, apunte a `/mnt/c/Users/<usuario>`, pero lo dicho, es algo que no recomiendo.

¿Por qué no lo recomiendp?: Algunas aplicaciones y herramientas, como Docker Desktop, se rompen. Hay Apps que tienen *hard-coded* el que el $HOME esté en su sitio (/home/<usuario>) dentro de WSL2 y cambiarlo hará que no funcionen correctamente o incluso que tengas errores inesperados.

Por lo tanto, recomiendo dejar tu WSL2 tal cual y una alternativa para ir rápido al HOME de Windows es un alias en `.bashrc` o `.zshrc`: `alias c="cd /mnt/c/Users/<usuario>`.

De todas formas, si necesitas cambiarlo, se haría así:

* Desde Powershell, pido que WSL arranque como `root`:

```PS
PS C:\Users\luis> ubuntu2404.exe config --default-user root
```

* Abro una nueva Shell y cambio el HOME de `luis`

```bash
C:\Users\luis> ubuntu2404.exe
root@kymeraw:~# usermod --home /mnt/c/Users/luis/ luis
```

* Vuelvo a dejar que el login por defecto lo haga con `luis`

```PS
PS C:\Users\luis> ubuntu2404.exe config --default-user luis
```

#### WSL 2 - Fichero /etc/wsl.conf

Lo menciono en varias partes de este apunte, dejo aquí la copia final que utilizo en mi ordenador, hay que editarla en WSL2 como root.

```zsh
[boot]
systemd=true
[automount]
options = "metadata,uid=1000,gid=1000,umask=022,fmask=11,case=off"
[interop]
enabled=true
appendWindowsPath=false
```

Importante: Cuando modificas este fichero hay que salirse de WSL y pararlo, esperar a que nos diga que no hay nada ejecutándose y volver a ejecutarlo. Veamos un ejemplo, donde estoy en una sesíón WSL2 en la shell como root.

```PS
root@kymeraw:~# exit
logout
luis@kymeraw:~$ exit
logout
PS C:\Users\luis> wsl --shutdown
:
PS C:\Users\luis> wsl --list --running
There are no running distributions.
```

La línea `options` bajo `[automount]` sirve para establecer bien los permisos de los ficheros. Ten en cuenta que los permisos de los archivos Linux que se crean en el disco NTFS [se intepretan de una forma muy concreta](https://learn.microsoft.com/en-us/windows/wsl/file-permissions). Los archivos/directorios que se crean en el disco NTFS (debajo de `/mnt/c/Users/<usuario>`) van con permisos 777.

A mi eso no me gusta. Quiero que WSL sea coherente, además hay programas a los que no les gusta tanto permiso, un ejemplo es SSH. El cliente de OpenSSH necesita que el directorio y los archivos bajo `~/.ssh` tengan unos permisos específicos.

La solución es activar los ***metadatos*** en la [configuración avanzada de WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config), en el fichero `/etc/wsl.conf` en la sección `[automount]`.

Cuando vuelvo a entrar en la Shell me aseguro de que mis archivos son míos (si has cambiado de distribución podría ocurrirte que pertenecen a otro usuario, por ejemplo `ubuntu:lxd`).

```PS
PS C:\Users\luis>  ubuntu2404.exe
luis@kymeraw:~$ pwd
/mnt/c/Users/luis
luis@kymeraw:~$ sudo chown -R luis:luis /mnt/c/Users/luis
[sudo] password for luis:
```

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
sudo apt install tmux
```

Aquí tengo un **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**, que también copio al HOME (`/mnt/c/Users/luis`).

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
* Crear el directorio `mkdir ~/.nano` tanto para root como para mi usuario

#### WSL 2 - Cliente SSH

Para poder conectar desde la Consola WSL2 a equipos remotos.

* Verifico que el cliente de OpenSSH está instalado (Esta sesión de Powershell como Administrador)

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
```

* Creo el par pública/privada en el directorio HOME de windows. El motivo es que normalmente voy a usar el cliente SSH de Windows.

```PS
PowerShell 7.4.5
C:\Users\luis> ssh-keygen.exe -t ed25519 -a 200 -C "luis@kymeraw" -f $env:USERPROFILE\.ssh\id_ed25519_luispa

PowerShell 7.4.5
C:\Users\luis> ssh-keygen.exe -t ed25519 -a 200 -C "luis@kymeraw" -f %USERPROFILE%\.ssh\id_ed25519_luispa

WSL2
C:\Users\luis> ssh-keygen -t ed25519 -a 200 -C "luis@kymeraw" -f /mnt/c/Users/luis/.ssh/id_ed25519_luispa
```

Te dejo un enlace a otro apunte muy interesante, [Git multicuenta]({% post_url 2024-09-21-git-multicuenta %}), donde trato el tema de SSH como alternativa.

#### WSL 2 - Servidor SSH

Veamos el proceso de activación del servidor SSH. Lo primero es verifico si OpenSSH está instalado. A continuación agrego el Servidor OpenSSH:

```powershell
Get-WindowsCapability -Online | ? Name -like 'OpenSSH*'
:
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

Inicio el Servicio, compruebo y configuro que arranque siempre al hacer boot

```powershell
Start-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

El Servidor SSH se ejecuta en Windows (no en WSL2/Ubuntu), por lo tanto los ***Credenciales*** son los de windows, mi usuaario LOCAL `luis` (no uso Microsoft Account) y su contraseña es la de Windows. El fichero **sshd_config** se encuentra en `C:\ProgramData\ssh\sshd_config`.

En mi caso desactivo usar el fichero `administrators_authorized_keys` porque prefiero que use el del HOME de mi usuario `luis` que está en `C:\Users\luis\.ssh\authorized_keys`

```config
AuthorizedKeysFile .ssh/authorized_keys
AcceptEnv LANG LC_*
Subsystem sftp sftp-server.exe
#Match Group administrators
# AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

Lo edito y rearranco el servicio

```powershell
notepad C:\ProgramData\ssh\sshd_config
Restart-Service sshd
```

Edito las claves que acepto en `authorized_keys`

```powershell
notepad C:\ProgramData\ssh\administrators_authorized_keys
```

Compruebo si el puerto 22 está abierto. Si necesitas comprobarlo aquí tienes un script [VerificarPuertoFirewall.ps1](https://gist.github.com/LuisPalacios/f1013d3a0cc0d540b94df2d7d42c2f40). En mi caso estaba ya abierto; si necesitas abrir el puerto en el firewall usa el comando siguietne.

```powershell
New-NetFirewallRule -DisplayName "Allow SSH Port 22" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
```

A partir de ahora me puedo conectar perfectamente con mi Windows desde cualquier otro equipo de la red. Si te fijas me conectó directamente con WSL2, sigue leyendo...

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-04.png"
      caption="Conexión vía SSH desde un Mac"
      width="550px"
      %}

***Opcional***: Por defecto, si activamos el Servidor SSH en Windows, cuando conectemos con él nos redirigirá a una sesión de `cmd.exe`, pero puedes cambiarlo para que los clientes **accedan directamente a la shell de WSL2**. Importante, nunca usar los ejecutables de wsl que también están bajo `C:\Users\luis\AppData\Local\Microsoft\WindowsApps` o tardará muchos segundos en mostrarte el prompt. Ejecuto desde Powershell como administrador.

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\wsl.exe" -PropertyType String -Force
```

#### WSL 2 - CRLF vs LF

Al trabajar en desarrollo de software, uno de los aspectos más sutiles pero cruciales que debes tener en cuenta es la diferencia entre los finales de línea en archivos de texto entre Windows y Linux.

En este apunte [CRLF vs LF]({% post_url 2024-09-28-crlf-vs-lf %}) puedes encontrar cómo manejo este tema.

#### WSL 2 - Starship

Hablé de **startship** en la sección de [CMD mejorado](#cmd-mejorado), aquí explico cómo lo añado a mi WSL2. En este ejemplo he seleccionado descargar las NerdFonts FiraCode (que son las mismas que instalé a nivel Windows para CMD y Powershell).

Abro una sesión de WSL2:

```bash
sudo apt install fontconfig unzip
mkdir -p ~/.fonts
cd .fonts
curl -LJs -o FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
unzip FiraCode.zip && rm FiraCode.zip
fc-cache -fv
```

Instalo la última versión de **startship** en WSL2:

```bash
curl -sS https://starship.rs/install.sh | sh
```

El siguiente paso es configurar el `.zshrc` (mira la sección anterior [WSL 2 - Cambio a ZSH](#wsl-2---cambio-a-zsh) donde tengo un enlace al que utilizo yo.

#### WSL 2 - Cambiar UID/GID

Durante la instalación tube un problema, la primera vez me instaló Ubuntu22.04 y puso a mi usuario `luis` el UID/GID 1000:1000, activé metada como mencionaba antes para la gestión de permisos y todo bajo `/mnt/c` pasó a ser propiedad de 1000:1000. Hasta ahí todo bien.

El problema vino al instalar Ubuntu24.04 y eliminar la 22.04. Observé que crea por defecto el usuario `ubuntu y el grupo lxc` con UID/GID 1000, y al usuario `luis` le asignó el `1002`. Eso provocó un líó de permisos enorme.

Esto es lo que hice para arreglarlo:

``` bash
PS > wsl --install Ubuntu24-04
PS > ubuntu2404.exe config --default-user root
PS > wsl --shutdown
PS > ubuntu2404.exe

nano /etc/group cambié los gid
lxc 1000 -> 1001
ubuntu 1001 -> 1002
luis 1002 -> 1000

nano /etc/passwd cambié los uid
ubuntu 1000 -> 1002
luis 1002 -> 1000

cd /home
chown -R luis:luis luis
chown -R ubuntu:ubuntu ubuntu
```

Reviso el fichero de configuración. Aquí tienes una copia: [/etc/wsl.conf](#wsl-2---fichero-etcwslconf).

```Powershell
PS > ubuntu2404.exe config --default-user luis
PS > wsl --shutdown
PS > ubuntu2404.exe
```

Nota: Para hacer búsquedas de los permisos y que no se eternice entrando en `/mnt/c` uso el comando siguiente:

```bash
cd /
find . -not \( -path "./mnt*" -type d -prune \) -user ubuntu
```

#### Modificar el PATH

**PATH de Windows (para `CMD`, `PowerShell`)**:

Consulta la [nota sobre el PATH](#nota-sobre-el-path) que puse al principio de este apunte.

**WSL2**:

En mi caso prefiero que WSL2 no me añada todos las entradas del PATH de Windows al de Linux, modifico `/etc/wsl.conf` y añado la sección:

```conf
[interop]
appendWindowsPath=false
```

Aquí tienes una copia: [/etc/wsl.conf](#wsl-2---fichero-etcwslconf).

* Salgo de WSL, lo apago (`wsl --shutdown`), vuelvo a entrar y edito `~/.bashrc` o `.zshrc`. Este es un ejemplo de cómo queda (soy selectivo en qué quiero del PATH de windows en mi sesión WSL2).

```bash
⚡ luis@kymeraw:~ % echo $PATH
/mnt/c/Users/luis/.gems/bin:.:/mnt/c/Users/luis/Nextcloud/priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/wsl/lib:/mnt/c/Windows/System32:/mnt/c/Windows:/mnt/c/Windows/System32/wbem:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Program Files/PowerShell/7
```

### Windows Terminal

Ahora que tengo WSL2 perfectamente operativo, voy a instalarme ***Windows Terminal***, una herramienta que permite configurar y arrancar múltiples consolas en pestañas o ventanas separadas, lo que simplifica enórmemente el punto de entrada. Solo tengo un sitio desde donde configurar y hacer clic.

* Abro la Microsoft Store, `Start` > busco por "Store"
* Busco por "Windows Terminal". Instalo o Actualizo

***Configuración inicial*** de Windows Terminal

* Abro Windows Terminal `Start` busco "Terminal"
* Accedo a la configuración
  * Clic en 'flecha abajo' > `Settings` o `Ctrl + ,`.
* Configurar perfiles de consola:
  * En el panel izquierdo, veo perfiles como `Windows PowerShell`, `CMD`, `Ubuntu`, etc. Aquí puedo personalizar cada uno de ellos.
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

Empiezo a trabajar de manera más eficiente y organizada. Tengo la posibilidad de abrir la consola que necesite, por defecto lo he configurado para que WSL (Ubuntu 24.04.3 LTS), he cambiado los colores ligeramente para diferenciar dónde estoy y en el caso de `cmd.exe` he puesto otro tipo de fuente de letra.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-05.png"
      caption="Por opciones que no sea"
      width="2560px"
      %}


***Configuración `settings.json` y `state.json`***: Gran parte de esta personalización de Windows Terminal se gestiona a través de dos archivos clave: `settings.json` (nucleo de la personalización, puedes editarlo desde el propio menú) y `state.json` (estado actual del Terminal).

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-08.png"
      caption="Uso el terminal que necesito según el caso de uso"
      width="450px"
      %}

Aquí tienes el [mi fichero de configuración settings.json](https://gist.github.com/LuisPalacios/ba989c7d8f2f65cd49308402754df82e) que utilizo en mi ordenador. Nota: los `uuid` del mismo serán distintos en tu caso. No lo copies/pegues tal cual o no te funcionará.

<br/>

---

<br/>

A partir de aquí empieza la segunda parte del apunte, la instalación de las herramientas y lenguajes de programación. Las instalo todas en Windows 11 (lo digo porque quizá alguna merecería la pena instalarlas dentro del WSL2, por ejemplo `Ruby`).

Un aviso respecto a **.NET**, lo dejo para el final, empiezo por las herramientas multiplataforma, porque considero hay que instalarlas en todo equipo de desarrollo (tanto en Windows como Linux o Mac), continúo con los lenguajes que he elegido para mi Windows y dejo para el final .NET y Visual Studio.

## Herramientas multiplataforma

### VSCode

![VSCode](/assets/img/posts/logo-vscode.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Lo ***instalo*** desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/). Diría que es el editor de código fuente más potente que he visto nunca, con soporte de cientos de extensiones muy útiles, la posibilidad de abrir diferentes **terminales integrados** dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL. S

Además, soporta una amplia variedad de lenguajes de programación y la posibilidad de trabajar con equipos remotos.

***Settigs y Sincronización***: Echa un ojo al apunte [VSCode settings y extensiones]({% post_url 2023-06-20-vscode %}) donde mantengo cómo lo gestiono y mi configuración.

Creo una especie de ***alias***, en linux y en Mac me gusta crear un alias que llamo "***e***" (de **e**ditor), para llamar a mi editor preferido. Desde una sesión de Administrador edito el script `c:\windows\e.cmd`. Ya tengo mi alias, será válido para cmd y powershell

```cmd
@echo off
"C:\Users\luis\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd" %*
```

### Git for Windows

![Git para Windows](/assets/img/posts/2024-08-25-win-desarrollo-06.png){: width="150px" height="150px" style="float:left; padding-right:25px" }

El objetivo principal es tener acceso a `git.exe` desde las consolas nativas `CMD`, `PowerShell` y aplicaciones de terceros.

***Instalo*** desde el [sitio oficial de Git](https://git-scm.com/). Se instala en `C:\Program Files\Git`. Nota: incluye el ejecutable `.\bin\bash.exe`, tienes otro bajo WSL2 `C:\Windows\System32\bash.exe`, tenlo en cuenta (el orden en el PATH, mira la [nota sobre el PATH](#nota-sobre-el-path)).

Decisiones que he tomado durante la instalación:

* Bundled `ssh` & `openssl`: Selecciono **Use the bundled OpenSSH (voids W11 issue) and bundle OpenSSL**. Cuando preparé este apunte la versión de SSH de Windows 11 tiene problemas con repositorios grandes de Git.
* Handling of CRLF: Selecciono siempre **Checkout as-is, commit Unix-style line endings**. Ver la sección [sobre crlf](#wsl-2---crlf-vs-lf).
* PATH (related to Git Bash): Yo no uso Git Bash, por lo que selecciono **Git from the command line and also from 3rd-party software**. Aunque luego añado dicho PATH manualmente al sistema.

Usé la versión `Git-2.46.0-64-bit.exe`:

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-09.png"
      caption="Proceso de instalaicón de Git for Windows"
      width="1024px"
      %}

Decía que no Git Bash, pero si que me aprovecho de todo lo que trae, es una pasada, tengo a mi disposición un montón de ejecutables "estilo linux" pero en CMD/PowerShell, por lo tanto añado manualmente al PATH un par de directorios, `C:\Program Files\Git\mingw64\bin` y `C:\Program Files\Git\usr\bin`, al PATH del sistema para tener acceso a estos regalos:

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-10.png"
      caption="Aprovecho los ejecutables que trae Git for Windows"
      width="1024px"
      %}

Git for Windows además te instala MinGW-w64, una bifurcación de MinGW (Minimalist GNU for Windows) que proporciona un conjunto de herramientas y un entorno de desarrollo para compilar y ejecutar aplicaciones de código abierto, principalmente en C y C++, en sistemas Windows. Es crucial si compilas aplicaciones para Windows usando herramientas y entornos tradicionales de GNU/Linux.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-11.png"
      caption="Y además los que instala del proyecto mingw64"
      width="1024px"
      %}

Por cierto, cuando no sepas dónde está el ejecutable...

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-12.png"
      caption="¿De dónde va a cargar el ejecutable?"
      width="1024px"
      %}

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

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-13.png"
      caption="Consola de Docker"
      width="600px"
      %}

#### Integración con WSL2

La integración con WSL2 es inmediata, no tienes que hacer nada. Bueno, casi nada. Hay un tema importante "El contexto".

Al entrar en una sesión de WSL2 es importante estar en el Contexto adecuado de Docker. Si no tienes el correcto puedes encontrarte con el error `Failed to initialize: protocol not available`.

```bash
PS > ubuntu2404.exe

$ docker ps -a
Failed to initialize: protocol not available

$ docker context ls
NAME              DESCRIPTION                               DOCKER ENDPOINT                             ERROR
default           Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux *   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine
```

En este caso estamos en el contexto `desktop-linux` lo que provocará que WSL2 no se pueda comunicar correctamente con Docker. Puedes cambiar de contexto con el comando `docker context use default` pero no será permanente. Lo mejor es editar el fichero `~/.docker/config.json`

```bash
nano ~/.docker/config.json
:
        "currentContext": "default",
:
```

A partir de este momento funcionará correctamente

```bash
PS > ubuntu2404.exe

$ docker context ls
NAME            DESCRIPTION                               DOCKER ENDPOINT                             ERROR
default *       Current DOCKER_HOST based configuration   unix:///var/run/docker.sock
desktop-linux   Docker Desktop                            npipe:////./pipe/dockerDesktopLinuxEngine

$ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
:
```

| |
| -- |
| **CUIDADO!!** si has cambiado el HOME de WSL 2 a `/mnt/c/Users/<usuario>` (ver [aquí](#wsl-2---cambiar-home)) cada vez que arranques Docker sobreescribe el fichero `C:\Users\<usuario>\.docker\config.json` por lo que es inútil editarlo. La solución consiste en eñadir `docker context use default` al final de tu `.bashrc/.zshrc` |
| |

### Postman

Puedes instalar desde el [sitio oficial de Postman](https://www.postman.com/). Es una herramienta muy conocida para probar y documentar APIs. Es muy útil para desarrolladores que trabajan con servicios web. En mi caso de momento la dejo en la recámara, quizá la instale más adelante.

### HTTPie

![Docker HTTPie](/assets/img/posts/logo-httpie.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Muy en la línea de Postman, hace poco encontré esta otra herramienta, soporta trabajar tanto en la línea de comandos o GUI para realizar solicitudes HTTP, diseñada para ser simple y fácil de usar, ideal para probar y depurar APIs de manera rápida y eficiente. Me gusta más que Postman, sobre todo por la parte de la línea de comandos. La ***instalo*** desde el [sitio oficial de HTTPie](https://httpie.io/).

Necesitas instalar [Chocolatey](https://chocolatey.org/), un gestor de paquetes potentísimo para Windows. Yo lo he [instalado](https://chocolatey.org/install) para instalarme `httpie`, pero de momento no lo estoy usando para nada más, reconozco que tengo que investigarlo.

## Lenguajes de programación

### Python, Pip y PipEnv

![logo python](/assets/img/posts/logo-python.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

**[Python](https://www.python.org)** es un lenguaje de programación interpretado, versátil y fácil de aprender, lo que más me gusta es que es muy legible y soporta múltiples paradigmas como la programación orientada a objetos, funcional e imperativa. Hay mucha herramienta que lo necesita y tiene muchos casos de uso. Aunque en mi caso no lo uso casi nunca, siempre lo instalo.

**[Pip](https://pypi.org/project/pip/)** es una herramienta fundamental para gestionar paquetes de Python. Es el sistema utilizado para instalar y manejar librerías de terceros desde el [Python Package Index (PyPI)](https://pypi.org), el repositorio oficial de Python.

**[PipEnv](https://pipenv.pypa.io/en/latest/)** es otra herramienta imprescindible para gestionar entornos virtuales. Cuando se desarrollan aplicaciones en Python, es necesario utilizar varias librerías externas que pueden entrar en conflicto entre proyectos. Con **`PipEnv`**, podemos gestionar un entorno virtual donde todos los paquetes se instalan sin afectar al sistema principal. Existen alternativas como [Virtualenv](https://virtualenv.pypa.io/en/latest/) y [Conda](https://docs.conda.io/projects/conda/en/latest/index.html), pero en mi caso siempre uso **`PipEnv`**.

1. **Instalar Python** desde [python.org](https://www.python.org/downloads/windows/). Descargo la última versión.

Antes de ejecutar el instalador: **Importante quitar los alias que Windows 11 trae por defecto a `python.exe` o `python3.exe`**. Ejecuta desde `Search` > "`Manage app execution aliases`". Desactiva los dos alias "python" and "python3".

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-15.png"
      caption="Desactivar los dos alias a python/python3"
      width="450px"
      %}

Durante la instalación selecciono las siguientes opciones, para tener disponible `py.exe`, `python.exe` desde cualquier terminal.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-16.png"
      caption="Opciones durante la instalación"
      width="2048px"
      %}

Además creo un ***alias*** a `python3`, creo el script `c:\windows\python3.cmd`.

```cmd
@echo off
"C:\Program Files\Python312\python.exe" %*
```

1. **Instalar PipEnv**. Una vez tengas Python y Pip instalados, abre una terminal de Windows (cmd o PowerShell) y ejecuta:

```powershell
pip install --user pipenv
```

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-17.png"
      caption="Log de la instalación de pipenv"
      width="650px"
      %}

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-18.png"
      caption="Versiones de python, pip y pipenv"
      width="600px"
      %}

**Importante**, añadir el directorio de los scripts al PATH, tal como se recomienda durante la instalación de `pipenv`:

  `C:\Users\<usuario>\AppData\Roaming\Python\Python312\Scripts`

Siempre que instalo hago una **prueba de concepto**, con un mini proyecto, un único fuente llamado `main.py` bajo el entorno virtual `pipenv`, con una única librería `requests`.

```cmd
mkdir tmp
cd tmp
pipenv install requests
pipenv lock
```

Creo el fuente con `notepad main.py`

```python
import requests
response = requests.get('https://httpbin.org/ip')
print('Tu dirección IP es: {0}'.format(response.json()['origin']))
```

Ejecuto la prueba de concepto con `pipenv run python main.py`

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-19.png"
      caption="Ejecuto desde el entorno seguro `pipenv` y funciona."
      width="500px"
      %}

### C/C++

![LLVM](/assets/img/posts/logo-llvm.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Como este es un apunte multiplataforma, para trabajar en C/C++ elijo **CLang V17, estándar C++20**. El compilador CLang pertenece al proyecto `LLVM`, acrónimo de "Low-Level Virtual Machine", que se convirtió en algo mucho más grande con el tiempo. Clang es un compilador de C, C++, y Objective-C, modular, rápido y definitivamente multiplataforma.

Para saber cómo instalarlo en Windows mejor consulta este ejemplo que tengo en GitHub, [`git-repo-eol-analyzer`](https://github.com/LuisPalacios/git-repo-eol-analyzer), que demuestra el trabajo multiplataforma, funciona en Windows, Linux y MacOS y explica todos los pasos para preparar el entorno: instalar Clang, CMake, Clang-format e incluso la integración con VSCode.

Si quieres un acceso rápido a la instalación en Windows: - Descarga e instala ***CLANG 17.0.1*** desde el sitio de las [Releases oficiales](https://github.com/llvm/llvm-project/releases) (link directo a [LLVM 64bits 17.0.1 para Windows)](https://github.com/llvm/llvm-project/releases/download/llvmorg-17.0.1/LLVM-17.0.1-win64.exe).

#### CMake

![CMake](/assets/img/posts/logo-cmake.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Muy vinculado a C/C++, CMake es una herramienta de código abierto que gestiona la configuración y generación de scripts de compilación para proyectos multiplataforma. Permite abstraer las configuraciones específicas de cada plataforma, simplificando la creación de archivos de construcción (Makefiles, proyectos de Visual Studio, etc.). En proyectos C++ en Windows, CMake se integra perfectamente con VSCode, permite generar de forma automática los proyectos, etc.

Para instalarlo en Windows: desde el [sitio oficial](https://cmake.org/download/), me bajo el *Windows x64 Installer*. También te recomiendo instalar **Ninja (Generador)** desde [su repositorio oficial](https://github.com/ninja-build/ninja/releases) y guardarlo en un directorio que ya tengas en el PATH.

El proceso básico de CMake consta de dos pasos:

1. **Configurar (Configure)**: Analiza el archivo `CMakeLists.txt`, crea todos los scripts y ficheros específicos para que el sistema luego pueda generar (compilar) el código. El resultado de la configuración se realiza en el subdirectorio **./build**.

2. **Generar (Build)**: A partir del paso anterior, CMake compila para el entorno de desarrollo y sistema en el que estemos, por ejemplo un proyecto con un `Makefile` o cosas más complejas.

CMake sigue un enfoque declarativo, se define lo que el proyecto necesita (fuentes, bibliotecas, dependencias) en el archivo `CMakeLists.txt`. Repasa el que he creado en el proyecto que mencionaba antes: [`git-repo-eol-analyzer`](https://github.com/LuisPalacios/git-repo-eol-analyzer).

### Golang

![Golang](/assets/img/posts/logo-golang.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

Golang es un lenguaje que combina la simplicidad y eficiencia de lenguajes antiguos como C, con las características modernas necesarias para el desarrollo de software concurrente y de alto rendimiento. Es especialmente popular en el desarrollo de sistemas distribuidos, servicios en la nube y herramientas de red, gracias a su enfoque en la concurrencia y la escalabilidad.

* Para ***instalarlo en Windows***, ve a la página de [descargas de Go](https://go.dev/dl/) me bajo la útima versión del MSI para windows-amd64, lo instala por defecto con `C:\Program Files\Go\bin` que añade al PATH.
* Para ***integrarlo con VSCode*** instalo la extensión [`golang.go`](https://marketplace.visualstudio.com/items?itemName=golang.Go).

Algunas variables críticas para un entorno de desarrollo eficiente en Go:

* `$GOROOT`: Ruta de instalación (por defecto `C:\Program Files\Go`).
* `$GOPATH`: Directorio de trabajo por defecto `C:\Users\<usuario>\go`.
* La instalación añade al PATH `$GOROOT\bin` y `$GOPATH\bin`.

A partir de Go 1.11, se introdujo el sistema de módulos **Go Modules** que gestiona dependencias de manera más eficiente. Lo habilito con `go env -w GO111MODULE=on` y hago un pequeño programa para comprobar que todo está bien.

Inicializo el módulo del proyecto:

```bash
go mod init hola
```

Creo el archivo `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hola, mundo")
}
```

Compilo y ejecuto y luego compilo el binario `hola.exe`

```bash
go run main.go

go build
```

## .NET

Hablar de `.NET` lia un poco a no ser que hayas vivido y experimentado toda su evolución. Ha fecha de hoy tenemos:

* ***.NET Framework***: Solo está disponible en Windows y se mantendrá en su versión 4.8, principalmente para soportar aplicaciones que lo necesitan.
* ***.NET (5 y versiones posteriores)***: Es multiplataforma, más moderno y la evolución natural de .NET Core, no de .NET Framework.

### .NET Framework

El .NET Framework es una plataforma de desarrollo creada por Microsoft para construir y ejecutar aplicaciones en Windows. Incluye muchas bibliotecas de clases para hacer Apps de escritorio, servicios web, aplicaciones web, etc. Se usa mucho en todo tipo de Apps que corren en Windows.

Lo **vas a instalar sí o sí**, aunque el futuro sea .NET (core .5), me da igual si acabas teniendo el Runtime como si acabas teniendo el Developer Pack (incluye el Runtime, necesario para desarrollar). Yo no voy a necesitar el .NET 3.5 (incluye .NET 2.0) porque no creo que instale Apps antiguas que requieran dicho Framework, pero el que sí que voy a necesitar es el .NET 4.8 porque es el último y seguro que algún app me lo pide. Por ejemplo, [HTTPie](#httpie) necesita que tengas el Runtime.

Puedes instalarlo desde la **Programas y características** del panel de control o desde la Web de microsoft). Si uso el primer método, verifico antes qué tengo y luego instalo.

1. Abro **Control Panel** > **Programs** > **Programs and Features** > **Turn Windows features on or off**.
2. Aquí se puede ver la versión de .NET Framework instaladas.
3. En la lista de características, busca las versiones de .NET Framework disponibles (por ejemplo, .NET Framework 3.5 o .NET Framework 4.8).
4. Marca la casilla junto a la versión que deseas instalar.
5. Haz clic en **Aceptar** y espera a que Windows complete la instalación.

Si la versión no está en la lista, puedo ir a la Web de microsoft, ([ejemplo para la 4.8.1](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481)

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-14.png"
      caption="Opción de instalar .NET desde la Web"
      width="640px"
      %}

### .NET 5 / Core

Pendiente de documentar

## Work in Progress

Esta sección la marco como "Trabajo en curso (WiP en inglés)", porque hay decenas de apps, utilidades, comandos, entornos de desarrollo y es imposible documentarlos todos. Mi objetivo realmente era romper el hielo. Realmente estos apuntes vienen bien para tener una bitácora de mi instalación, por si tengo que repetirla, pero sobre todo porque espero que te venga bien a ti como ejemplo.

Iré documentado/añadiendo lo nuevo que vaya instalando, cosas que tengo en la cabeza: Compilador de C/C++, Node.js, JDK de Java, BBDD locales (Si lo hago será con Docker).

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
