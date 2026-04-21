---
title: "Self-Hosted Bitwarden"
date: "2025-03-02"
categories: ["administration"]
tags: ["security","password","manager","credentials","authenticator","linux","pve","proxmox","lxc"]
draft: false
cover:
  image: "/img/posts/logo-bitvaultwarden.svg"
  hidden: true
---

<img src="/img/posts/logo-bitvaultwarden.svg" alt="Bit and Vault warden Logo" width="150px" style="float:left; padding-right:25px"  />

In this post I describe the process of installing a "Bitwarden" server. I've been using their Cloud service for several years, but I've decided to go with an on-premise home installation.

While researching I discover with surprise that I have two options, the first is to use the official **Bitwarden self-hosted** (which consumes quite a few resources and seems complex) or go with a lightweight **Vaultwarden**, a clone of the former, which apparently installs quickly and is simple.

<br clear="left"/>
<!--more-->

## Introduction

[Bitwarden](https://bitwarden.com/es-la/open-source/) is a free and open-source password manager that stores sensitive information -- such as website credentials -- in an encrypted vault. The service is available as a web interface, desktop applications, browser extensions, mobile applications and command-line interface. Bitwarden offers a cloud-hosted service (the one I use) and you can also install it "at home":

- Option 1: Install the [Bitwarden Server](https://github.com/bitwarden/server) using the official [Bitwarden self-hosted](https://bitwarden.com/help/install-on-premise-linux/) version. You need Docker and a configuration that apparently has some complexity.
- Option 2: Install [Vaultwarden](https://github.com/dani-garcia/vaultwarden), an alternative implementation written in `Rust` that supports the Bitwarden client API and is compatible with the [official Bitwarden clients](https://bitwarden.com/download/) ([disclaimer](https://github.com/dani-garcia/vaultwarden#disclaimer)).

To keep things simple, I'll go with the second option and if it covers what I need I'll probably stick with it.

## Installation

These are the two options I have.

- In an LXC container with a [Proxmox VE Helper-Scripts](https://community-scripts.github.io/ProxmoxVE/scripts) > *Authentication & Security* > *Vaultwarden*.
- On a Raspberry Pi 5 that I have dedicated to NextCloud, which is always on.

In both cases it's mandatory to have an [Nginx Proxy Manager](https://nginxproxymanager.com) at home. I already had one, and I documented it in my post about [Home Automation and Networking]({{< relref "2023-04-08-networking-avanzado.md" >}}), look for the *Reverse Proxy* section.

**Vaultwarden on Pi5:**

I decide to go with the Pi5, where the first thing is to install Docker. First as root I update to the latest:

```shell
apt update && apt upgrade -y && apt full-upgrade -y
apt full-upgrade -y && apt autoremove -y --purge
```

From my user I install Docker:

```shell
curl -fsSL https://get.docker.com -o install-docker.sh
cat install-docker.sh                                    # (verify the script)
sh install-docker.sh --dry-run                           # a dry-run doesn't hurt
sudo sh install-docker.sh
```

I give permissions to my user

```shell
sudo usermod -aG docker $USER
```

I reboot the machine and verify

```shell
reboot
:
docker ps -a

luis@cloud:~ $ docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

luis@cloud:~ $ docker info
Client: Docker Engine - Community
 Version:    28.0.1
:
```

I create a directory, prepare the `compose.yaml` to (download and) start *Vaultwarden*

```shell
luis@cloud:~ $ mkdir vaultwarden
luis@cloud:~ $ cd vaultwarden/
luis@cloud:~/vaultwarden $ mkdir vw-data
luis@cloud:~/vaultwarden $ nano compose.yaml
luis@cloud:~/vaultwarden $ tree .
.
├── compose.yaml
└── vw-data
```

Contents of `compose.yaml`:

```yaml
#
# Compose for the on-premise vaultwarden service
#
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      DOMAIN: "https://bitwarden.tld.com"
    volumes:
      - ./vw-data/:/data/
    ports:
      - 8080:80
```

More or less it looks like this -- you'll have your NGINX in between, with your domain, all requests that arrive on the https port get redirected to internal server X.Y on port 8080.

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-01.svg" alt="Final configuration" width="300px" />
  <div class="image-caption">Final configuration</div>
</div>

I start the container and watch its log

```shell
luis@cloud:~/vaultwarden $ docker compose up -d
luis@cloud:~/vaultwarden $ docker compose logs
```

I configure my DNS, create a new entry in NGINX and connect to my new server at `https://bitwarden.tld.com` (use your domain)

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-02.png" alt="Initial connection to the server" width="400px" />
  <div class="image-caption">Initial connection to the server</div>
</div>

From here, time to configure Vaultwarden...

## Configuration

I click on *Create Account*, enter my personal email and the required data

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-03.png" alt="Creating my user" width="400px" />
  <div class="image-caption">Creating my user</div>
</div>

I log in again and now have access to my Vaultwarden (Bitwarden) server.

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-04.png" alt="Access to the local server" width="400px" />
  <div class="image-caption">Access to the local server</div>
</div>

Once the installation is complete I can see the data and reconfigure the clients with the local server address.

### Export

The next thing I did was go to my [Bitwarden](https://vault.bitwarden.com/#/login) account, in the cloud, log in with my usual user and went to `Vault > export`. I exported in encrypted JSON format with a password. It created a file like `bitwarden_encrypted_export_20250302162516.json` and I downloaded it to my computer.

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-05.png" alt="Export" width="400px" />
  <div class="image-caption">Export</div>
</div>

### Import

Next I connect from the browser to my local server, log in and click on `Import Data`.

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-06.png" alt="Import" width="400px" />
  <div class="image-caption">Import</div>
</div>

Once the data was imported I changed all clients to point to the local server and went to my cloud Bitwarden account to delete it. So far it looks very good -- as you can see, the Raspberry Pi5 (8GB) is more than capable in terms of resources, running NextCloud and Vaultwarden simultaneously.

<div class="image-box">
  <img src="/img/posts/2025-03-02-bitwarden-07.png" alt="Pi5 running NextCloud and Vaultwarden" width="400px" />
  <div class="image-caption">Pi5 running NextCloud and Vaultwarden</div>
</div>
