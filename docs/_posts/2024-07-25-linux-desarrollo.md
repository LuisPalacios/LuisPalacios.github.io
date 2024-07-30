---
title: "Linux para desarrollo"
date: "2024-07-25"
categories: desarrollo
tags: linux ubuntu desarrollo python git gem ruby ror iterm ohmyzsh zsh vscode
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-linux-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo mi bitácora de configuración de un Linux (Ubuntu) como equipo de desarrollo. Instalo varias aplicaciones gráficas y de línea de comando que para mí son fundamentales para trabajar con el equipo.

Partiendo de una instalación nueva de Ubuntu, el orden de instalación puede variarse, pero te recomiendo (si tu Ubuntu está recién instalado) que sigas el mismo orden para ver los mismos resultados.

<br clear="left"/>
<!--more-->

## Primeros pasos

Antes de empezar, utilizo el terminal predeterminado de Ubuntu, aunque a veces me da por usar otro (Terminator, Xfce Terminal, Konsole, ...).

### Ficheros y scripts que uso habitualmente

- Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e)
- Fichero [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) personalizado para `nano`
  - Creo los directorios de backup (`sudo mkdir /root/.nano` y `mkdir ~/.nano`
- Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat), un cat sin las líneas de comentarios
- Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) para cambiar a root mucho más rápido
  - Normalmente añado mi usuario a `echo 'luis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-mi-usuario`
- Cambiar los permisos: `sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`

### Instalación de software

Actualizo Ubuntu a la última, incluidos `flatpak` y `snap`.

```zsh
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo flatpak udpate
sudo snap refresh
```

Esenciales

```zsh
sudo apt install -y vim git libfuse2
```

Desarrollo en C/C++

```zsh
sudo apt install -y build-essential cmake autotools-dev automake \
               libevent-dev libncurses5-dev bison flex
```

Python (nota, python3 venía preinstalado)

```zsh
sudo apt install -y python3-pip pipenv
```

Recomendados

```zsh
sudo apt-get install xscreensaver xscreensaver-data-extra xscreensaver-gl-extra
```

## Shell

La shell que viene por defecto en Ubuntu es `bash` pero tal como cuento en [¡Adiós Bash, hola Zsh!]({% post_url 2024-04-23-zsh %}), hace ya un tiempo que me he cambiado a `zsh`.

Además de `Zsh`, opcionalmente Oh My Zsh (aunque yo he dejado de usarlo), te recomiendo que le eches un ojo a ["Terminales con tmux"]({% post_url 2024-04-25-tmux %}), un multiplexor de terminales opcional potentísimo.

Aquí las referencias a mis ficheros, importante que las revises y adaptes a tu caso.

- **[~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7)**. Mi fichero de configuración de `zsh`
- **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**. Mi fichero de configuración de `tmux`.
- **[t](https://gist.github.com/LuisPalacios/860b689687bc239ab9f3549be67df499)**. Script para lanar `tmux`

## Chrome

No necesita mucha presentación. En Ubuntu lo instalo desde la página de [Google Chrome](https://www.google.com/intl/es_es/chrome/), descargo el `.deb` y botón derecho > Abrir con Instalación de Software.

## VSCode

Visual Studio Code es un editor de código fuente para Windows, Linux, macOS y Web con un soporte increible de extensioens, características, plugins y lenguajes soportados. Sigo las indicaciones de [Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux), **descargo el .deb** y al instalo (también añade el repositorio apt para luego hacer los updates automáticos mediante el gestor de paquetes del sistema).

```zsh
apt update && apt upgrade -y && apt full-upgrade -y
apt install ./code_1.91.1-1720564633_amd64.deb
```

Un tip: para poder arrancarlo cómodamente desde el terminal he añadido el alias **`e`** a mi `.zshrc`

```text
# Alias para llamar a VSCode desde CLI con "e"
echo 'alias e="code"' >> ~/.zshrc
source ~/.zshrc
```

### Consejos sobre VSCode

- [Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync) - sincroniza settings, snippets, temas, iconos, extensiones, usando tu cuenta de GitHub o Microsoft
- Con VSCode puedes hacerlo todo desde el teclado. Ya trae un subconjunto de comandos mapeado a [Atajos de teclado](https://code.visualstudio.com/docs/getstarted/keybindings). Si quieres aprender estos atajos por defecto, imprime el PDF para [Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf), [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) o [Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) y déjalo cerca.

## Git

Ya realicé la instalación arriba, en cualquier caso:

```zsh
sudo apt update
sudo apt install git -y
```

Creo mis ficheros [~/.gitconfig](https://gist.github.com/LuisPalacios/0ee871ee236485d4a064179b16ada400) y [~/.gitignore_global](https://gist.github.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c), que te puedes bajar

```zsh
curl -s -O https://gist.githubusercontent.com/LuisPalacios/0ee871ee236485d4a064179b16ada400/raw/348a8a448095a460756f85ef0362521b886b0a2e/.gitconfig
curl -s -O https://gist.githubusercontent.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c/raw/65d0ed6acba83ece4db78228821589212b9f9f4b/.gitignore_global
```

Como cliente GUI uso [GitKraken](https://www.gitkraken.com). Tienes más información sobre git en esta [chuleta sobre GIT]({% post_url 2021-10-10-git-cheatsheet %}) y [GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}).

## SSH

Ahora es buen momento para configurar tu pareja de claves pública/privada para conectar con Hosts remotos y/o usarlo con servidor(es) Git. La clave pública-privada SSH es un sistema de autenticación y encriptación utilizado para la conexión entre un cliente y un servidor. Se utilizan un par de claves: una clave pública y una clave privada. Los dos casos de uso más típicos son:

Tengo un apunte que te va a ser muy útil para conseguirlo, se trata de ["Git y SSH multicuenta"]({% post_url 2021-10-09-ssh-git-dual %}) y un par más [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %}). Un resumen,

```zsh
➜  ~ ssh-keygen -t ed25519 -a 200 -C "luis@kymerax" -f ~/.ssh/id_ed25519
```

El contenido de tu pública se comparte:

- En equipo remotos con los que quiero conectar: añadiéndolo al final del fichero `~/.ssh/authorized_keys`
- En Servidores GIT, a través de su GUI, en la propiedades de mi cuenta.

## AppImageLauncher

Vas a encontrar muchas aplicaciones en formato .AppImage y para instalarlas y gestionarlas te recomiendo que te instales el [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher/releases). Te recomiendo leer [AppImageLauncher, integra las aplicaciones AppImages al lanzador de aplicaciones](https://ubunlog.com/appimagelauncher-integra-appimges-en-ubuntu/) donde explican muy bien cómo instalarlo.
