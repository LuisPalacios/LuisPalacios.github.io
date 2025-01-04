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

### Scripts

Que uso habitualmente

- Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e)
- Fichero [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) personalizado para `nano`
  - Creo los directorios de backup (`sudo mkdir /root/.nano` y `mkdir ~/.nano`
- Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat), un cat sin las líneas de comentarios
- Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) para cambiar a root mucho más rápido
  - Añado mi usuario a sudoers
  - `echo 'luis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-mi-usuario`
- Cambiar los permisos:
  - `sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`

No olvides ***SSH***, tengo varios apuntes al respecto: [Git multicuenta]({% post_url 2024-09-21-git-multicuenta %}), [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %}). Un resumen,

```zsh
ssh-keygen -t ed25519 -a 200 -C "luis@kymerax" -f ~/.ssh/id_ed25519
```

Añade el contenido de la pública al `~/.ssh/authorized_keys` de tus servidores o estaciones remotas.

### Locales

Por si lo necesitas. Para reconfigurar los locales. Yo trabajo con los locales en Español, aunque instale Linux en inglés, de hecho suelo configurar ambos.

- `/etc/locale.gen`

```conf
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
```

- Ejecutar `locale-gen`

```bash
locale-gen
```

- La configuración más completa es con:

```bash
dpkg-reconfigure locales
```

### Instalación de software

**Actualizar** el sistema

```zsh
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo flatpak update
sudo snap refresh
```

**Esenciales** para empeza

```zsh
sudo apt install -y vim libfuse2
```

**GIT**, sin comentarios

```zsh
sudo apt install -y git gh
```

**C/C++** aunque no programes en estos lenguajes

```zsh
sudo apt install -y build-essential cmake autotools-dev automake \
               libevent-dev libncurses5-dev bison flex
```

**Python, pip, pipenv** (nota, python3 venía preinstalado)

```zsh
sudo apt install -y python3-pip pipenv
```

**Golang** (el lenguaje de programación más famoso del mundo)

Lo describo más adelante en la sección [Golang](#golang).

**Recomendados** que vendrán bien

```zsh
sudo apt install -y xscreensaver xscreensaver-data-extra xscreensaver-gl-extra
sudo apt install -y ca-certificates curl wget
```

**Docker** (más en [Docker](#docker))

```zsh
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instalo la última verión
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Añado mi usuario al grupo de Docker (salir y volver a hacer login tras este comando)
sudo usermod -aG docker $USER

# Compruebo que funciona. Si recibes un error de permisos, haz un reboot del equipo
docker run hello-world
```

**[Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux)** para la gestión de contenedores.

```zsh
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
https://localhost:9443   (Asigno contraseña al administrador)
```

**`tmux`** desde los fuentes

```zsh
# Preparo el entorno, módulos adicionales
sudo apt-get update
sudo apt install pkg-config autoconf-archive build-essential autoconf libtool libssl-dev python3-pkgconfig libcurl4-gnutls-dev

# Descargo y compilo tmux
cd ~/ && git clone https://github.com/tmux/tmux.git && cd tmux && ./autogen.sh && ./configure
make && sudo make install
```

**Networking**, varias herramientas útiles

```zsh
apt install -y net-tools iputils-ping tcpdump ppp
```

## Shell

La shell que viene por defecto en Ubuntu es `bash` pero tal como cuento en [¡Adiós Bash, hola Zsh!]({% post_url 2024-04-23-zsh %}), hace ya un tiempo que me he cambiado a `zsh`.

Además de `Zsh`, opcionalmente Oh My Zsh (aunque yo he dejado de usarlo), te recomiendo que le eches un ojo a ["Terminales con tmux"]({% post_url 2024-04-25-tmux %}), un multiplexor de terminales opcional potentísimo.

## Git

Ya realicé la instalación arriba, en cualquier caso, lo repito:

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

Dejo aquí enlaces a mis apuntes sobre Git

- [Chuleta sobre GIT]({% post_url 2021-10-10-git-cheatsheet %}), donde recomiendo instalar `gh` en tu cuenta Personal o Multicuenta.
- [Git multicuenta]({% post_url 2024-09-21-git-multicuenta %}), donde trato más en detalle cómo trabajar con varias cuentas en GitHub
- [GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}), para profundizar en Git y entenderlo de una vez por todas, ojo que es muy técnico.

## Chrome

No necesita mucha presentación. En Ubuntu lo instalo desde la página de [Google Chrome](https://www.google.com/intl/es_es/chrome/), descargo el `.deb` y botón derecho > Abrir con Instalación de Software.

## VSCode

Visual Studio Code es un editor de código fuente para Windows, Linux, macOS y Web con un soporte increible de extensioens, características, plugins y lenguajes soportados. Sigo las indicaciones de [Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux), **descargo el .deb** y al instalo (también añade el repositorio apt para luego hacer los updates automáticos mediante el gestor de paquetes del sistema).

```zsh
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt install ./<file>.deb
```

### Consejos sobre VSCode

- Consulta mi apunte sobre [Personalizar VSCode]({% post_url 2023-06-20-vscode %}).
- [Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync) - sincroniza settings, snippets, temas, iconos, extensiones, usando tu cuenta de GitHub o Microsoft
- Con VSCode puedes hacerlo todo desde el teclado. Ya trae un subconjunto de comandos mapeado a [Atajos de teclado](https://code.visualstudio.com/docs/getstarted/keybindings). Si quieres aprender estos atajos por defecto, imprime el PDF para [Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf), [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) o [Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) y déjalo cerca.

## AppImageLauncher

Vas a encontrar muchas aplicaciones en formato .AppImage y para instalarlas y gestionarlas te recomiendo que te instales el [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher/releases). Te recomiendo leer [AppImageLauncher, integra las aplicaciones AppImages al lanzador de aplicaciones](https://ubunlog.com/appimagelauncher-integra-appimges-en-ubuntu/) donde explican muy bien cómo instalarlo.

## Docker

Si vas a hacer desarrollos de backend, servicios, middleware, es muy probable que necesites Docker. Tienes dos opciones, la primera es [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) y la segunda usar [Docker Desktop para Linux](https://docs.docker.com/desktop/install/linux-install/), o incluso podrías montar ambos en el mismo equipo. Si tienes dudas mira las [diferencias](https://docs.docker.com/desktop/faqs/linuxfaqs/#what-is-the-difference-between-docker-desktop-for-linux-and-docker-engine).

En mi caso prefiero usar **[Docker Engine](https://docs.docker.com/engine/install/ubuntu/)** y leventar un contenedor con [Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux) para hacer la gestión.

## HTTPie

Recomiendo la herramienta [HTTPie](https://httpie.io/) si vas a trabajar con API's. Te ayuda a trabajar con tus API's de forma sencilla e intuitiva. Tienen una versión gráfica y otra CLI.

El proceso para instalarlo en mi linux es el siguiente:

- Desde la página de [Descargas](https://httpie.io/download) accedo a Download for Linux
- Desde la página de [Descargas CLI](https://httpie.io/cli) sigo las instrucciones para instalarme la versión CLI, `snap install httpie`

Ejemplos:

- Hola Mundo
  - `https httpie.io/hello`
- Método HTTP personalizado, encabezados HTTP y datos JSON
  - `http PUT pie.dev/put X-API-Token:123 name=John`
- Envío de formularios
  - `http -f POST pie.dev/post hello=World`
- Ver la solicitud que se está enviando utilizando una de las opciones de salida
  - `http -v pie.dev/get`
- Construir e imprimir una solicitud sin enviarla utilizando el modo offline
  - `http --offline pie.dev/post hello=offline`
- Usar la API de Github para publicar un comentario en un issue con autenticación
  - `http -a USERNAME POST https://api.github.com/repos/httpie/cli/issues/83/comments body=HTTPie is awesome! :heart:`
- Subir un archivo utilizando entrada redirigida
  - `http pie.dev/post < files/data.json`
- Descargar un archivo y guardarlo mediante salida redirigida
  - `http pie.dev/image/png > image.png`
- Descargar un archivo al estilo wget
  - `http --download pie.dev/image/png`
- Usar sesiones nombradas para hacer persistentes ciertos aspectos de la comunicación entre solicitudes al mismo host
  - `http --session=logged-in -a username:password pie.dev/get API-Key:123`
  - `http --session=logged-in pie.dev/headers`
- Establecer un encabezado de host personalizado para evitar la falta de registros DNS
  - `http localhost:8000 Host:example.com`

## Golang

Hago la instalación manual desde su sitio en internet. Primero elimino el golang de mi Ubuntu

Veo que tenía una versión que se instaló en el pasado usando `apt`

```zsh
sudo dpkg -l | grep -i golang
# Me enseña que tengo la 1.22
sudo apt-cache policy golang-go golang-src
# Me muestra su detalle
```

Las borro

```zsh
sudo apt-get remove golang-go
sudo apt-get remove --auto-remove golang-go
sudo dpkg -l | grep -i golang
# No muestra nada
```

Instalo desde el sitio de Go la [última versión disponible](https://go.dev/doc/install)

```zsh
# Desde root
wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
```

Me aseguro de tener `/usr/local/go/bin` en mi PATH (mi [~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7) lo tiene configurado).

```zsh
% go version
go version go1.22.5 linux/amd64
```

Si no has programado nunca en Go, ya estás tardando 😂, sigue el manual [https://go.dev/doc/](https://go.dev/doc/).
