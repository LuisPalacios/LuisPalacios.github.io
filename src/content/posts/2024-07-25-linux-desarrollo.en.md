---
title: "Linux for Development"
date: "2024-07-25"
categories: ["development"]
tags: ["linux","ubuntu","development","python","git","gem","ruby","ror","iterm","ohmyzsh","zsh","vscode"]
draft: false
cover:
  image: "/img/posts/logo-linux-desarrollo.svg"
  hidden: true
---

<img src="/img/posts/logo-linux-desarrollo.svg" alt="linux development logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

In this post I describe my configuration log for setting up a Linux (Ubuntu) machine as a development workstation. I install several graphical and command-line applications that are essential for my workflow.

Starting from a fresh Ubuntu installation, the installation order can be varied, but I recommend (if your Ubuntu is freshly installed) that you follow the same order to see the same results.

<br clear="left"/>
<!--more-->

> Note: My notes for setting up each OS for software development: [macOS]({{< relref "2023-04-15-mac-desarrollo.md" >}}), [linux]({{< relref "2024-07-25-linux-desarrollo.md" >}}) and [Windows]({{< relref "2024-08-25-win-desarrollo.md" >}}).

## First Steps

Before starting, I use Ubuntu's default terminal, although sometimes I switch to another one (Terminator, Xfce Terminal, Konsole, ...).

### Scripts

That I use regularly

- Script [/usr/bin/e](https://gist.githubusercontent.com/LuisPalacios/14b0198abc35c26ab081df531a856971/raw/8b6e278b4e89f105b2d573ebc79c67e915e6ab47/e)
- Custom [/etc/nanorc](https://gist.githubusercontent.com/LuisPalacios/4e07adf45ec1ba074939317b59d616a4/raw/b50efd22130a0129e408bca10fc7b8dbab7e03ff/nanorc) file for `nano`
  - Create the backup directories (`sudo mkdir /root/.nano` and `mkdir ~/.nano`
- Script [/usr/bin/confcat](https://gist.githubusercontent.com/LuisPalacios/d646638f7571d6e74c20502b3033cf07/raw/f0f015d9b1d806919ec0295a22f3710b4f3096e0/confcat), a cat without comment lines
- Script [/usr/bin/s](https://gist.githubusercontent.com/LuisPalacios/8e334583ad28e681326c65b665457eaa/raw/201a2ace950dcbb14b341b31ae70c9fffde29540/s) to switch to root much faster
  - Add my user to sudoers
  - `echo 'luis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-mi-usuario`
- Change permissions:
  - `sudo chmod 755 /usr/bin/e /usr/bin/confcat /usr/bin/s`

Don't forget ***SSH***, I have several posts about it: [Git multi-account]({{< relref "2024-09-21-git-multicuenta.md" >}}), [SSH and X11]({{< relref "2017-02-11-x11-desde-root.md" >}}) and [SSH on Linux]({{< relref "2009-02-01-ssh.md" >}}). A summary,

```zsh
ssh-keygen -t ed25519 -a 200 -C "luis@kymerax" -f ~/.ssh/id_ed25519
```

Add the public key contents to `~/.ssh/authorized_keys` on your remote servers or workstations.

### Locales

In case you need it. To reconfigure locales. I work with Spanish locales, even if I install Linux in English; in fact, I usually configure both.

- `/etc/locale.gen`

```conf
en_US.UTF-8 UTF-8
es_ES.UTF-8 UTF-8
```

- Run `locale-gen`

```shell
locale-gen
```

- The most complete configuration is with:

```shell
dpkg-reconfigure locales
```

### Software Installation

**Update** the system

```zsh
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo flatpak update
sudo snap refresh
```

**Essentials** to get started

```zsh
sudo apt install -y vim libfuse2
```

**GIT**, no comment needed

```zsh
sudo apt install -y git gh
```

**C/C++** even if you don't program in these languages

```zsh
sudo apt install -y build-essential cmake ninja-build autotools-dev automake libevent-dev libncurses5-dev bison flex
```

**C/C++ LLVM** is the one I use ([source](https://apt.llvm.org/))

```zsh
# Install the latest version:
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# Install a specific version
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh <version number>
```

**Python, pip, pipenv** (note, python3 came preinstalled)

```zsh
sudo apt install -y python3-pip pipenv
```

**Golang** (the most famous programming language in the world)

I describe it later in the [Golang](#golang) section.

**Recommended** packages that will come in handy

```zsh
sudo apt install -y xscreensaver xscreensaver-data-extra xscreensaver-gl-extra
sudo apt install -y ca-certificates curl wget
```

**Docker** (more in [Docker](#docker))

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

# Install the latest version
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add my user to the Docker group (log out and back in after this command)
sudo usermod -aG docker $USER

# Verify it works. If you get a permissions error, reboot the machine
docker run hello-world
```

**[Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux)** for container management.

```zsh
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
https://localhost:9443   (Set administrator password)
```

**`tmux`** from source

```zsh
# Prepare the environment, additional modules
sudo apt-get update
sudo apt install pkg-config autoconf-archive build-essential autoconf libtool libssl-dev python3-pkgconfig libcurl4-gnutls-dev

# Download and compile tmux
cd ~/ && git clone https://github.com/tmux/tmux.git && cd tmux && ./autogen.sh && ./configure
make && sudo make install
```

**Networking**, various useful tools

```zsh
apt install -y net-tools iputils-ping tcpdump ppp
```

## Shell

The default shell in Ubuntu is `bash` but as I explain in [Goodbye Bash, hello Zsh!]({{< relref "2024-04-23-zsh.md" >}}), I switched to `zsh` a while ago.

In addition to `Zsh`, optionally Oh My Zsh (although I've stopped using it), I recommend you check out ["Terminals with tmux"]({{< relref "2024-04-25-tmux.md" >}}), a very powerful optional terminal multiplexer.

## Git

I already installed it above, in any case, here it is again:

```zsh
sudo apt update
sudo apt install git -y
```

I create my [~/.gitconfig](https://gist.github.com/LuisPalacios/0ee871ee236485d4a064179b16ada400) and [~/.gitignore_global](https://gist.github.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c) files, which you can download

```zsh
curl -s -O https://gist.githubusercontent.com/LuisPalacios/0ee871ee236485d4a064179b16ada400/raw/348a8a448095a460756f85ef0362521b886b0a2e/.gitconfig
curl -s -O https://gist.githubusercontent.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c/raw/65d0ed6acba83ece4db78228821589212b9f9f4b/.gitignore_global
```

As a GUI client I use [GitKraken](https://www.gitkraken.com). You can find more information about git in this [GIT cheat sheet]({{< relref "2021-10-10-git-cheatsheet.md" >}}) and [GIT in detail]({{< relref "2021-04-17-git-en-detalle.md" >}}).

Here are links to my posts about Git

- [GIT cheat sheet]({{< relref "2021-10-10-git-cheatsheet.md" >}}), where I recommend installing `gh` for your Personal or Multi-account setup.
- [Git multi-account]({{< relref "2024-09-21-git-multicuenta.md" >}}), where I go into more detail about how to work with multiple GitHub accounts
- [GIT in detail]({{< relref "2021-04-17-git-en-detalle.md" >}}), to dive deep into Git and understand it once and for all - beware, it's very technical.

## Chrome

Needs no introduction. On Ubuntu I install it from the [Google Chrome](https://www.google.com/intl/es_es/chrome/) page, download the `.deb` and right-click > Open with Software Install.

## VSCode

Visual Studio Code is a source code editor for Windows, Linux, macOS and Web with incredible support for extensions, features, plugins and supported languages. I follow the instructions at [Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux), **download the .deb** and install it (it also adds the apt repository for automatic updates through the system package manager).

```zsh
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
sudo apt install ./<file>.deb
```

### VSCode Tips

- Check my post about [Customizing VSCode]({{< relref "2023-06-20-vscode.md" >}}).
- [Settings Sync](https://code.visualstudio.com/docs/editor/settings-sync) - sync settings, snippets, themes, icons, extensions, using your GitHub or Microsoft account
- With VSCode you can do everything from the keyboard. It already comes with a subset of commands mapped to [Keyboard Shortcuts](https://code.visualstudio.com/docs/getstarted/keybindings). If you want to learn these default shortcuts, print the PDF for [Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf), [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) or [Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) and keep it nearby.

## AppImageLauncher

You'll find many applications in .AppImage format and to install and manage them I recommend you install [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher/releases). I recommend reading [AppImageLauncher, integrate AppImage applications into the application launcher](https://ubunlog.com/appimagelauncher-integra-appimges-en-ubuntu/) where they explain very well how to install it.

## Docker

If you're going to do backend, services, or middleware development, you'll very likely need Docker. You have two options, the first is [Docker Engine](https://docs.docker.com/engine/install/ubuntu/) and the second is [Docker Desktop for Linux](https://docs.docker.com/desktop/install/linux-install/), or you could even set up both on the same machine. If in doubt check the [differences](https://docs.docker.com/desktop/faqs/linuxfaqs/#what-is-the-difference-between-docker-desktop-for-linux-and-docker-engine).

In my case I prefer to use **[Docker Engine](https://docs.docker.com/engine/install/ubuntu/)** and run a container with [Portainer CE](https://docs.portainer.io/start/install-ce/server/docker/linux) for management.

## HTTPie

I recommend the [HTTPie](https://httpie.io/) tool if you're going to work with APIs. It helps you work with your APIs in a simple and intuitive way. They have a GUI version and a CLI version.

The process to install it on my linux is as follows:

- From the [Downloads](https://httpie.io/download) page I go to Download for Linux
- From the [CLI Downloads](https://httpie.io/cli) page I follow the instructions to install the CLI version, `snap install httpie`

Examples:

- Hello World
  - `https httpie.io/hello`
- Custom HTTP method, HTTP headers and JSON data
  - `http PUT pie.dev/put X-API-Token:123 name=John`
- Form submission
  - `http -f POST pie.dev/post hello=World`
- View the request being sent using one of the output options
  - `http -v pie.dev/get`
- Build and print a request without sending it using offline mode
  - `http --offline pie.dev/post hello=offline`
- Use the GitHub API to post a comment on an issue with authentication
  - `http -a USERNAME POST https://api.github.com/repos/httpie/cli/issues/83/comments body=HTTPie is awesome! :heart:`
- Upload a file using redirected input
  - `http pie.dev/post < files/data.json`
- Download a file and save it via redirected output
  - `http pie.dev/image/png > image.png`
- Download a file wget-style
  - `http --download pie.dev/image/png`
- Use named sessions to persist certain aspects of communication between requests to the same host
  - `http --session=logged-in -a username:password pie.dev/get API-Key:123`
  - `http --session=logged-in pie.dev/headers`
- Set a custom host header to work around missing DNS records
  - `http localhost:8000 Host:example.com`

## Golang

I do a manual installation from its website. First I remove golang from my Ubuntu

I see that I had a version that was installed in the past using `apt`

```zsh
sudo dpkg -l | grep -i golang
# Shows me that I have version 1.22
sudo apt-cache policy golang-go golang-src
# Shows its details
```

I remove them

```zsh
sudo apt-get remove golang-go
sudo apt-get remove --auto-remove golang-go
sudo dpkg -l | grep -i golang
# Shows nothing
```

I install from the Go website the [latest available version](https://go.dev/doc/install)

```zsh
# As root
wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
```

I make sure to have `/usr/local/go/bin` in my PATH (my [~/.zshrc](https://gist.github.com/LuisPalacios/7507ce0b84adcad067320e9631648fd7) has it configured).

```zsh
% go version
go version go1.22.5 linux/amd64
```

If you've never programmed in Go, what are you waiting for? Follow the manual at [https://go.dev/doc/](https://go.dev/doc/).
