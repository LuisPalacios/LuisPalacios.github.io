---
title: "Windows para desarrollo"
date: "2024-08-25"
categories: desarrollo
tags: windows wsl wsl2 linux ubuntu desarrollo visual studio python git cli vscode compilador
excerpt_separator: <!--more-->
---

![logo win desarrollo](/assets/img/posts/logo-win-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo los pasos para preparar un Windows 11 como equipo de desarrollo. Teniendo en cuenta que soy *Unixero* y trabajo en entorno multiplataforma, Linux, MacOS y Windows, veras que este apunte no está orientado a desarrolladores *solo-microsoft* o *solo-windows*, sino que está orientado a los que les gusta la línea de comandos y desarrollan para múltiples plataformas y/o entornos.

Parto de una instalación de Windows limpia, los instalé en modo [dualboot]({% post_url 2024-08-23-dual-linux-win %}) y lo configuré de la forma más [ligera]({% post_url 2024-08-24-win-decente %}) posible. Describo los componentes, cómo los he configurado, instalado y preparado para tener una buena plataforma de desarrollo de Aplicaciones y Servicios.

<br clear="left"/>
<!--more-->

---

## Preparar el equipo

Antes de entrar en herramientas de desarrollo, como Git, VSCode, compiladores, etc. creo que es importante tener el equipo bien preparado y una de las áreas más importantes es el CLI y cómo mejorarlo con WSL2. Esta primera sección la dedico principalmente a ambos.

### CLI

Antes de nada es imprescindible hablar del terminal, es fundamental, tanto si estás acostumbrado a trabajar desde la línea de comandos como si no, los desarrolladores lo valoran mucho.

En mi caso he trabajado en multiples Sistemas Operativos, no estoy obsesionado con ninguno, ni mucho menos me considero un [BOFH](https://es.wikipedia.org/wiki/Bastard_Operator_from_Hell#:~:text=BOFH%20son%20las%20iniciales%20del,como%20Infame%20Administrador%20del%20Demonio), lo que sí que tengo claro y he aprendido durante años es a **elegir lo que me ahorra tiempo**.

Anticipo que mi Consola elegida en Windows es la **Shell de Unix** (`zsh o bash`), junto con **las decenas de herramientas de línea de comandos Open Source existentes para Linux** (`ls, cd, mkdir, cp, tar, sed, awk, nano, vi, etc.`). Todas ellas se hicieron siguiendo la filosofía Unix, que establece que un programa '*debería hacer una cosa y hacerla bien*', y funcionan así de bien desde hace años.

El trabajo de millones de horas de otras personas me van a ahorrar mucho tiempo. Es inteligente invertir unas cuantas horas en aprender la Shell y el subconjunto de las herramientas de línea de comandos más utilizadas.

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-01.svg"
      caption="Escojo bash/tools de linux que ahorran tiempo"
      width="400px"
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

Hasta aquí he listado las cuatro opciones de consola que voy a tener en mi Windows: `command.com`, `powershell.exe`, `pwsh.exe`, `bash (linux)`, pero hay un programa muy interesante que permite ordenar el acceso a ellas, se trata de Windows Terminal.

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

Instalo el Subsistema de Windows para Linux 2, que como decía permite ejecutar un entorno completo de Linux directamente sobre Windows.

Utiliza una máquina virtual ligera con un **kernel completo de Linux real**, tiene un **rendimiento** altísimo, está super **integrado con Windows**, permite que los archivos y scripts de Linux se ejecuten desde el explorador de Windows, y viceversa; y muy importante, tiene **compatibilidad con Docker**, de hecho WSL2 es el backend preferido para [Docker Desktop en Windows](https://www.docker.com/products/docker-desktop/) (que instalaré más adelante).

Mis **dos casos de uso principales** son:

* Tener `bash` con acceso nativo a `C:\` (vía `/mnt/c`), junto con cualquier herramienta o programa existente en Linux.
* Poder instalar Docker Desktop en Windows

Proceso de instalación:

* Abrir **“Características de Windows**” - Pulso Win + R, escribo `optionalfeatures`, pulso enter. En la ventana marco las opciones:
  * Virtual Machine Platform (Plataforma de Máquina Virtual)
  * Windows Subsystem for Linux (Subsistema de Windows para Linux)
  * Hyper-V (recomendado para Docker con WSL2).

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-02.png"
      caption="Activar características VM"
      width="2560px"
      %}

* **Reboot** - rearranco el equipo
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

Opcionalmente puedo añadir un icono a Ubuntu en el Taskbar. Busco en la lista de aplicaciones instaladas: `Start > All > "Ubuntu 24.04"` y con el botón derecho hago un *Pin to taskbar* para tener un acceso rápido a mi `bash` (Ubuntu 24.04 en WSL2).

{% include showImagen.html
      src="/assets/img/posts/2024-08-25-win-desarrollo-03.png"
      caption="bash para Windows :-)"
      width="650px"
      %}

Efectivamente estamos en una máquina virtual con Ubuntu, así que puedo instalar lo que quiera, por ejemplo, si necesito trabajar con scripts que manipulan JSON's, pues añado `jq`.

```bash
luis@kymeraw:~$ sudo apt install -y jq
```

***Actualizar Ubuntu***: Es importante que cuando hayas terminado actualices el Ubuntu de la VM a la última.

```bash
luis@kymeraw:~$ sudo apt update && sudo apt upgrade -y
```

#### WSL 2 - Cambiar HOME

Quiero que al entrar en WSL2 el HOME de mi usuario sea `/mnt/c/Users/luis`, para que `cd` me lleve a mi `C:\Users\luis`. Voy a usar el comando `usermod` de linux, pero debo hacerlo como root, así que estos son los pasos:

* Desde Powershell cambio Ubuntu para que entre con `root`:

```PS
PS C:\Users\luis> ubuntu2024.exe config --default-user root
```

* Arranco Ubuntu, entro como root y cambio el HOME

```bash
usermod --home /mnt/c/Users/luis/ luis
```

* Desde Powershell vuelvo a poner a `luis` como usuario por defecto

```PS
PS C:\Users\luis> ubuntu2024.exe config --default-user luis
```

#### WSL 2 - Permisos de ficheros

Los permisos de los archivos Linux que se crean en el disco NTFS [se intepretan de una forma muy concreta](https://learn.microsoft.com/en-us/windows/wsl/file-permissions). En una instalación por defecto, cada archivo o directorio que se crea en el disco NTFS (por ejemplo `/mnt/c/Users/luis`) se hace con permisos 777.

En general no debería afectar en nada porque "no" voy a usar el Linux de WSL como "plataforma de desarrollo", simplemente como herramienta de apoyo, moverme por los directorios, ver ficheros, etc. Lo que pasa es que si que hay algunas herramientas a las que esto les preocupa.

Un ejemplo es SSH. El cliente de OpenSSH necesita que el directorio y los archivos bajo `~/.ssh` tengan unos permisos específicos. Si no es así da problemas, traducido significa que no podría abrir una sesión `ssh` desde la consola de WSL a ningún sitio.

La solución es activar los ***metadatos*** en la [configuración avanzada de WSL](https://learn.microsoft.com/en-us/windows/wsl/wsl-config). Para ello entro en la consola WSL, cambio a root, edito un fichero, lo salvo y me salgo de WSL. La sección `[boot]` ya estaba, he añadido la sección `[automount]`

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

La shell que viene por defecto en Ubuntu para WSL2 es `bash` pero como expliqué en [¡Adiós Bash, hola Zsh!]({% post_url 2024-04-23-zsh %}), me he cambiado a `zsh`, asi que aquí hago lo mismo. Me paso a `zsh` ([otro apunte donde hablo de esto]({% post_url 2024-07-25-linux-desarrollo %})). Además voy a instalar ["tmux"]({% post_url 2024-04-25-tmux %}), un multiplexor de terminales opcional potentísimo.

Primero instalo `zsh` en mi máquina virtual. Arranco el Terminal y ejecuto lo siguiente

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

Cambio la shell por defecto a `zsh` para mi usuario `luis`

```bash
luis@kymeraw:~$ chsh -s $(which zsh)
Password:
```

Salgo del Terminal y vuelvo a entrar. La primera vez que entras con `zsh` te ofrece ayuda para crear el fichero `.zshrc`. En mi caso ya lo tengo creado porque uso el mismo para MacOS, Linux y ahora Windows. Descargo mi **[~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7)** y lo copio al HOME `/mnt/c/Users/luis`.

Instalo tmux, que lo suelo utilizar:

```bash
apt install tmux
```

También tengo un **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**, que también copio al HOME (`/mnt/c/Users/luis`).

#### WSL 2 - Scripts

Tengo unos scripts que uso habitualmente y que suelo instalar en todos los equipos Linux con los que trabajo.

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

Para poder conectar desde el Terminal WSL2 vía ***SSH*** a equipos remotos, usar GIT desde WSL, etc. tengo que configurar el cliente SSH.

* Creo `/mnt/c/Users/luis/.ssh`, luego creo una clave y aquí es donde estarán `authorization_keys`, `config`, etc.

```zsh
⚡ luis@kymeraw:luis % cd     # Vuelvo a HOME
⚡ luis@kymeraw:luis % pwd
/mnt/c/Users/luis
⚡ luis@kymeraw:luis % mkdir .ssh
⚡ luis@kymeraw:luis % cd .ssh
⚡ luis@kymeraw:luis % ssh-keygen -t ed25519 -a 200 -C "luis@kymeraw" -f ~/.ssh/id_ed25519
```

Tengo varios apuntes sobre SSH [Git y SSH multicuenta]({% post_url 2021-10-09-ssh-git-dual %}), [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %}) por si necesitas ayuda con SSH.

#### WSL 2 - CRLF vs LF

Al trabajar en desarrollo de software, uno de los aspectos más sutiles pero cruciales que debes tener en cuenta es la diferencia entre los finales de línea en archivos de texto entre Windows y Linux. Este pequeño detalle puede generar grandes problemas si no se maneja correctamente, especialmente cuando se trabaja en entornos mixtos.

* **Windows (CRLF):** En sistemas Windows, los finales de línea en los archivos de texto se representan con una secuencia de dos caracteres: `Carriage Return` (`\r`) seguido de `Line Feed` (`\n`). Esto es conocido como `CRLF` (`\r\n`).

* **Linux/MacOS (LF):** En Linux y MacOS, los finales de línea se representan con un solo carácter: `Line Feed` (`\n`). Esto se conoce como `LF` (`\n`).

Estas diferencias surgen de las historias y convenciones de cada sistema operativo. En la práctica, esto significa que los archivos de texto creados en Windows tendrán `CRLF` al final de cada línea, mientras que los creados en Linux o MacOS solo tendrán `LF`.

***Problemas Comunes al Trabajar en Entornos Mixtos***: Cuando trabajas en un entorno donde se utilizan tanto Windows como Linux (por ejemplo, usando WSL2 en Windows), es fundamental estar consciente de estos finales de línea porque:

* **Conflictos en el control de versiones:** Los sistemas de control de versiones como Git pueden interpretar los finales de línea diferentes como cambios en el archivo, generando conflictos innecesarios y diffs confusos.

* **Incompatibilidades en scripts:** Algunos scripts, especialmente aquellos escritos en bash o zsh, pueden fallar si encuentran un `CRLF` en lugar de un `LF`, ya que el `CR` extra puede ser interpretado como parte del comando.

* **Problemas de compilación o ejecución:** Al compilar código o ejecutar scripts en Linux que fueron creados en Windows, el `CRLF` puede causar errores inesperados y difíciles de depurar.

***Herramientas y Estrategias para Manejar CRLF y LF***: Para evitar problemas con los finales de línea, existen varias estrategias y herramientas que puedes utilizar:

* **Que Git lo [gestione](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings):**

  * Puede manejaro automáticamente
    * `git config --global core.autocrlf true`  - Para convertir LF a CRLF al hacer checkout en Windows
    * `git config --global core.autocrlf input` - Para mantener LF en los repositorios y convertir CRLF a LF al hacer commit
  * O de forma más granular
    * Usando el archivo `.gitattributes` en la raiz del repositorio.

* **Editor de texto:**

  * Usa un editor de texto que te permita elegir el tipo de final de línea. Por ejemplo, Visual Studio Code, Sublime Text y otros permiten definir si quieres que el archivo use `LF` o `CRLF`.
    * En VS Code, puedes ver y cambiar el final de línea en la barra de estado en la parte inferior derecha.

* **Conversión manual con `dos2unix` y `unix2dos`:**

  * Puedes convertir archivos de `CRLF` a `LF` y viceversa usando herramientas de línea de comandos como `dos2unix` y `unix2dos`:

    ```zsh
    # Convertir de CRLF a LF
    dos2unix archivo.txt

    # Convertir de LF a CRLF
    unix2dos archivo.txt
    ```

* **WSL2 y Metadata:**

  * Como he cambiado mi HOME a `/mnt/c/Users/...` y tengo activado `metadata` para manejar correctamente los permisos de archivos desde Linux, tengo que ser MUY consciente de este problema CRLF/LF, así que si haces lo mismo, asegúrate también de mantener un **control estricto sobre los finales de línea**. Esto es especialmente importante si tu `$HOME` está en `/mnt/c/Users/...` donde los archivos se crean nativamente con `CRLF`.

### Buenas Prácticas

* **Establece un estándar en tu equipo de desarrollo:** Decide si todos los desarrolladores deben usar `LF` o `CRLF` en los archivos de texto y configuren sus entornos de acuerdo a eso. En mi caso lo tengo claro: `LF`.

* **Revisa los finales de línea antes de los commits:** Configura Git para advertirte si hay inconsistencias en los finales de línea antes de hacer un commit.

* **Mantén el control:** Asegúrate de que tus herramientas, editores y scripts estén configurados correctamente para manejar y respetar el formato de finales de línea acordado en tu proyecto.

### Windows Terminal

Como dije antes, Windows Terminal es una herramienta poderosa y flexible que te permite utilizar múltiples consolas en pestañas separadas, lo que simplifica enórmemente el punto de entrada a la consola. Solo tengo un sitio donde hacer clic, y dentro de él ya elegiré que quiero arrancar. Explico cómo configurarlo y anclarlo al taskbar.

***Instalación de Windows Terminal***, necesitamos ir al Microsoft Store. En mi caso ya la tenía instalada, pero quería actualizarla y el proceso es el mismo.

* Abro la Microsoft Store, Start > busco por "Store"
* Arranco y una vez dentro busco por "Windows Terminal". Instalo o Actualizo

***Configuración inicial*** de Windows Terminal

* Abro Windows Terminal desde el menú de inicio o utilizando la búsqueda en Windows. El App se llama "Terminal" a secas
* Accedo a la configuración
  * Clic **flecha hacia abajo** cerca pestaña activa > "Settings" (Configuración) o `Ctrl + ,`.
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
      src="/assets/img/posts/2024-08-25-win-desarrollo-04.png"
      caption="Por opciones que no sea"
      width="2560px"
      %}

***Configuración `settings.json` y `state.json`***: Gran parte de esta personalización de Windows Terminal se gestiona a través de dos archivos clave: `settings.json` y `state.json`. Juegan roles diferentes pero complementarios en la configuración del terminal.

* El archivo `settings.json` es el núcleo de la personalización. Aquí se definen los perfiles de las consolas, la apariencia, los atajos de teclado, el comportamiento de las pestañas, y mucho más. Es un archivo en formato JSON que puedes editar para ajustar el Terminal a tus preferencias exactas. Ejemplo de ruta donde se guarda el archivo:
  * `C:\Users\luis\AppData\Local\Packages`
  * `+--> Microsoft.WindowsTerminal_...\LocalState\settings.json`
* El archivo `state.json` almacena información sobre el estado actual del Terminal, como la disposición de las pestañas, las ventanas abiertas, y otros detalles de la sesión. A diferencia del `settings.json`, que es para configuraciones permanentes, `state.json` se utiliza para recordar la configuración temporal entre sesiones. Ejemplo de ruta donde se guarda el archivo:
  * `C:\Users\luis\AppData\Local\Packages`
  * `+--> Microsoft.WindowsTerminal_...\LocalState\state.json`

### Modificar el PATH

Unificación del PATH: En Windows, al igual que la Shell de Unix, la variable PATH se usa para localizar ejecutables. En el pantallazo anterior, en las shells de Windows (`command.com, powershell.exe, pwsh.exe`) habrás visto que son distintas, de modo que priorizan donde buscar los ejecutables. Son casi identicas, pero están bien tal cual las instala.

* Directorio personal. Dedico un directorio específicio para mis scripts y ejecutables. Para incluir tu directorio personal en el PATH y asegurar que esté disponible en todos sitios:

  * Editar el PATH Global en Windows
    * `Start > Settings > About > Advance System Settings`
    * `Environment Variables`
    * ***`System variables`*** > la edito
    * Agrego por ejemplo `C:\Users\luis\priv\bin` al final de la lista.

  * Me aseguro que WSL2 Importe el PATH de Windows Correctamente
    * Edito el fichero `~/.bashrc`
    * Añado: `export PATH=$PATH:/mnt/c/Users/luis/Nextcloud/priv/bin`

<br/>

---

## Herramientas de desarrollo

Nota: A partir de aquí todavía estoy documentando y realizaré cambios...

Ahora que tenemos el CLI y WSL listos, voy a pasar a las herramientas recomendadas en el entorno de desarrollo de software en Windows; algunas de las herramientas más populares y útiles. También indicaré cuales son las que yo he instalado.

### Git

Necesita poca presentación, un sistema de control de versiones distribuido, fundamental para cualquier flujo de trabajo de desarrollo moderno. Lo instalo desde el [sitio oficial de Git](https://git-scm.com/). Es opcional **Git Bash** que junto con `GIT`, al instalarlo en Windows, nos ofrece una herramienta que proporciona un emulador de Bash para Windows. Es especialmente útil para desarrolladores que trabajan con Git y necesitan una CLI con comandos Unix. En mi caso solo lo necesitaré si trabajo desde la consola CMD o PowerShell, nunca desde WSL/linux.

La aplicación contiene numerosas utilidades de Unix, como SCP y SSH, así como la ventana de terminal Mintty. Dado que Windows normalmente ejecuta comandos de CMD, se necesita Git Bash para instalar estas utilidades en la carpeta `C:\programas\Git\usr\bin`.

### VSCode

***Visual Studio Code - Terminal Integrado***: Visual Studio Code (VS Code) es un editor de código fuente que incluye un terminal integrado. Puedo abrir diferentes terminales dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL.

Soporta una amplia variedad de lenguajes de programación y una gran cantidad de extensiones para mejorar su funcionalidad. Lo instalo desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/).

### Docker Desktop

Permite la creación y gestión de contenedores, lo que es esencial para el desarrollo y despliegue de aplicaciones en entornos aislados. Muy útil cuando estás desarrollando Servicios (por ejemplo en Go, NodeJS, ...). En mi caso lo necesito, así que lo instalo desde el [sitio oficial de Docker](https://www.docker.com/products/docker-desktop). Su integración con WSL2 es fundamental y el haberlo preparado antes nos ayuda a una instalación fluída.

### Postman

Herramienta para probar y documentar APIs. Es muy útil para desarrolladores que trabajan con servicios web. En mi caso la necesito también y la voy a instalar desde el [sitio oficial de Postman](https://www.postman.com/).

### HTTPie (alternativa a Postman)

Se trata de una herramienta de línea de comandos o GUI para realizar solicitudes HTTP, diseñada para ser simple y fácil de usar, ideal para probar y depurar APIs de manera rápida y eficiente. La descubrí hace poco y me gusta más que Postman, sobre todo por la parte de la línea de comandos. La instalo desde el [sitio oficial de HTTPie](https://httpie.io/).

Por cierto, se puede instalar utilizando Chocolatey con el comando `choco install httpie`.

### Node.js

Entorno de ejecución para JavaScript en el lado del servidor. Es una herramienta imprescindible para desarrolladores de aplicaciones web. Si la necesitas instalar la tienes disponible en el [sitio oficial de Node.js](https://nodejs.org/).

### JDK (Java Development Kit)

Necesario para el desarrollo en Java, que sigue siendo uno de los lenguajes de programación más populares. Disponible en el [sitio oficial de Oracle](https://www.oracle.com/java/technologies/javase-downloads.html).

### SQL Server Management Studio (SSMS)

Una herramienta para gestionar y administrar bases de datos SQL Server. Disponible en el [sitio oficial de Microsoft](https://docs.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms).

<br/>

---

## Conclusión

Hay decenas de apps, utilidades, comandos, entornos de desarrollo y es imposible documentarlos todos. Mi objetivo realmente era romper el hielo si tienes un Windows y vas a desarrollar. Realmente estos apuntes me vienen muy bien para tener una bitácora de mi instalación, por si tengo que repetirla y espero que te vengan bien a ti como ejemplo.

### Aprendizaje continuo

Voy a insistirte sobre la Shell y Linux. Si vienes de Windows, te recomiendo aprender a utilizar la Shell; es una habilidad fundamental para cualquier desarrollador de software. La Shell permite automatizar tareas, ejecutar comandos, y manejar el sistema de una manera más eficiente y rápida que a través de interfaces gráficas. Existen muchos recursos disponibles para aprender a utilizar la Shell, tanto en `bash` como en `zsh`, te dejo algunas referencias

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
