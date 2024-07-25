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

## Guía rápida

Dejo más adelante detalles sobre los paquetes y opciones instaladas, pero si tienes prisa por levantar tu estación de trabajo de desarrollo, ahí va:

Actualiza el SO.

```zsh
apt update && apt upgrade -y && apt full-upgrade -y

apt install -y vim git build-essential cmake g++ autotools-dev automake \
               libevent-dev libncurses5-dev bison flex
```

## Instalación

Empezamos con la instalación, si estás buscando cómo **actualizar o reparar**, ve al final del apunte.

### Terminal

Utilizaremos el terminal predeterminado de Ubuntu o cualquier otro de tu preferencia como GNOME Terminal, Konsole, etc.

### Zsh, Oh My Zsh, Tmux

![logo linux oh my zsh](/assets/img/posts/logo-ohmyzsh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[oh-my-zsh](https://ohmyz.sh) es un entorno de trabajo en línea de comando mucho más bonito para trabajar junto con **Zsh**. Viene con miles de funciones útiles, ayudantes, plugins, temas. Trae varios plugins que hacen la vida más fácil. [Lo mejor de Oh My Zsh son sus temas](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes).

En este apunte no voy a cubrir en detalle mi parametrización de `Oh my Zsh` porque es un tema muy personal. Dejo aquí una referencia.

```zsh
sudo apt update
sudo apt install zsh -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Además de `Zsh`, Oh My Zsh, te recomiendo que le eches un ojo a `tmux`, un multiplexor de terminales opcional pero potentísimo.

Echa un ojo a mis apuntes ["¡Adiós Bash, hola Zsh!"]({% post_url 2024-04-23-zsh %}) y a ["Terminales con tmux"]({% post_url 2024-04-25-tmux %}).

Aquí las referencias a mis ficheros, importante que las revises y adaptes a tu caso.

- **[~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7)**. Mi fichero de configuración de `zsh`
- **[~/.tmux.conf](https://gist.github.com/LuisPalacios/065f4f0491d472d65ef62f67f1f418a1)**. Mi fichero de configuración de `tmux`.
- **[t](https://gist.github.com/LuisPalacios/860b689687bc239ab9f3549be67df499)**. Script to launch `tmux`

### VSCode

![logo vscode](/assets/img/posts/logo-vscode.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Visual Studio Code es un editor de código fuente desarrollado por Microsoft para Windows, Linux, macOS y Web. Incluye soporte de tantas cosas que es imposible explicarlo aquí.

Con la inmensa diversidad de características, plugins y lenguajes soportados puedes usarlo como IDE para cualquier proyecto.

```zsh
sudo apt update
sudo apt install software-properties-common apt-transport-https wget -y
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install code -y
```

Un tip: para poder arrancarlo cómodamente desde el terminal añade un alias a tu `.zshrc`

```text
# Alias para llamar a VSCode desde CLI con "e"
echo 'alias e="code"' >> ~/.zshrc
source ~/.zshrc
```

#### Consejos sobre VSCode

- Con VSCode puedes hacerlo todo desde el teclado. Ya trae un subconjunto de comandos mapeado a [Atajos de teclado](https://code.visualstudio.com/docs/getstarted/keybindings). Si quieres aprender estos atajos por defecto, imprime el PDF para [Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf), [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) o [Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) y déjalo cerca.

### Git

![logo git](/assets/img/posts/logo-git.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[Git](https://git-scm.com) es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia. Existen varias opciones de Instalación del cliente para la línea de comandos ([fuente original](https://git-scm.com/download/mac)), en mi caso utilizo la de Homebrew.

Instalación:

```zsh
sudo apt update
sudo apt install git -y
```

Creo mis ficheros [~/.gitconfig](https://gist.github.com/LuisPalacios/0ee871ee236485d4a064179b16ada400) y [~/.gitignore_global](https://gist.github.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c), que te puedes bajar así:

```zsh
curl -s -O https://gist.githubusercontent.com/LuisPalacios/0ee871ee236485d4a064179b16ada400/raw/348a8a448095a460756f85ef0362521b886b0a2e/.gitconfig
curl -s -O https://gist.githubusercontent.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c/raw/65d0ed6acba83ece4db78228821589212b9f9f4b/.gitignore_global

# Edítalo para adaptarlo
e .gitconfig
```

Como cliente GUI uso [GitKraken](https://www.gitkraken.com). Tienes más información sobre git en esta [chuleta sobre GIT]({% post_url 2021-10-10-git-cheatsheet %}) y [GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}).

<br/>

### SSH clave pública-privada

![logo ssh](/assets/img/posts/logo-ssh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Ahora es buen momento para configurar tu pareja de claves pública/privada para conectar con Hosts remotos y/o usarlo con servidor(es) Git. La clave pública-privada SSH es un sistema de autenticación y encriptación utilizado para la conexión entre un cliente y un servidor. Se utilizan un par de claves: una clave pública y una clave privada. Los dos casos de uso más típicos son:

Tengo un apunte que te va a ser muy útil para conseguirlo, se trata de ["Git y SSH multicuenta"]({% post_url 2021-10-09-ssh-git-dual %}). Un resumen:

Creo mi clave pública-privada, crea dos archivos de texto bajo `~/.ssh`.

```zsh
➜  ~ ssh-keygen -t ed25519 -a 200 -C "luis@mihost" -f ~/.ssh/id_ed25519
:
Enter passphrase (empty for no passphrase):            <=== Pon una contraseña que usarás durante las futuras conexiones
Your identification has been saved in /Users/luis/.ssh/id_ed25519   <== Clave PRIVADA. NUNCA LO COMPARTAS
Your public key has been saved in /Users/luis/.ssh/id_ed25519.pub   <== Clave PÚBLICA. Este contenido es el que compartes !!
:
```

El contenido del fichero con la clave pública lo compartes con el servidor remoto (`github` o un linux para terminal remoto), mientras que la clave privada se mantiene en local. Simplificándolo muchísimo, mi clave *pública* que le paso a Github la va a usar para encriptar información que solo yo, que poseo la *privada equivalente*, puedo descifrar y así comunicarnos.

En el caso de Github se puede usar este método (SSH pública-privada) para acceso directo a tu cuenta y modificar repositorios de forma segura, sin necesidad de hacer login (https con usuario y contraseña). Es importante destacar que debes mantener tu clave privada segura, ya que si alguien más la tiene, puede acceder a tu cuenta y repositorios.

El contenido de tu pública se comparte:

- En equipo remotos con los que quiero conectar: añadiéndolo al final del fichero `~/.ssh/authorized_keys`
- En Servidores GIT, a través de su GUI, en la propiedades de mi cuenta.

Además del apunte anterior, tienes otros dos, [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %}).

</br>