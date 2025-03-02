---
title: "Bitwarden casero"
date: "2025-03-02"
categories: administración
tags: seguridad password manager claves authenticator linux pve proxmox lxc
excerpt_separator: <!--more-->
---

![Logo Bit y Vault warden](/assets/img/posts/logo-bitvaultwarden.svg){: width="150px" style="float:left; padding-right:25px" }

En este apunte describo el proceso de instalacion de un servidor "Bitwarden". Llevo ya varios años usándolo con su servicio Cloud, pero he decidido optar por hacer una instalación "on-premise" casera.

Al investigar descubro con sorpresa que tengo dos opciones, la primera es usar el **Bitwarden self-hosted** oficial (que consume bastantes recursos y parece complejo) o bien optar por un ligero **Vaultwarden**, un clone del primero, que por lo visto se instala rápido y es sencillo.

<br clear="left"/>
<!--more-->

## Introducción

[Bitwarden](https://bitwarden.com/es-la/open-source/) es un gestor de contraseñas libre y de código abierto que almacena información sensible —como credenciales de sitios web— en una caja fuerte encriptada. El servicio está disponible en interfaz web, aplicaciones de escritorio, complementos para navegador, aplicaciones móviles e interfaz de línea de comandos. Bitwarden ofrece un servicio alojado en la nube (el que yo uso) y también puedes instalártelo "en casa":

- Opción 1: Instalar el [Bitwarden Server](https://github.com/bitwarden/server) usando la version oficial de [Bitwarden self-hosted](https://bitwarden.com/help/install-on-premise-linux/). Necesitas docker y hacer una configuracion que por lo visto tiene algo de complejidad.
- Opción 2: Instalarte [Vaultwarden](https://github.com/dani-garcia/vaultwarden), una implementación alternativa escrita en `rust` que soporta la API de cliente de Bitwarden y es compatible con los [clientes oficiales de Bitwarden](https://bitwarden.com/download/) ([disclaimer](https://github.com/dani-garcia/vaultwarden#disclaimer)).

Por no complicarme mucho la vida, voy a ir por la segunda opción y si cubre lo que necesito probablemente me quede con ella.

## Instalación

Estas son las dos opciones que tengo.

- En contenedor LXC en Proxmox con el [script](https://community-scripts.github.io/ProxmoxVE/scripts) *Authentication & Security* > *Vaultwarden*.
- En Raspberry Pi 5 que tengo dedicada a NextCloud, siempre está encendida.

En ambos casos es obligatorio tener en tu casa un [Nginx Proxy Manager](https://nginxproxymanager.com). Yo ya lo tenía, y lo documenté en mi apunte sobre [Domótica y Networking]({% post_url 2023-04-08-networking-avanzado %}), busca la sección *Proxy Inverso*.

**Vaultwarden en Pi5**

Decido ir por la Pi5, donde lo primero es instalar Docker. Primero como root actualizo a la última:

```bash
apt update && apt upgrade -y && apt full-upgrade -y
apt full-upgrade -y && apt autoremove -y --purge
```

Desde mi usuario instalo docker:

```bash
curl -fsSL https://get.docker.com -o install-docker.sh
cat install-docker.sh                                    # (verifico el script)
sh install-docker.sh --dry-run                           # un dry-run no viene mal
sudo sh install-docker.sh
```

Le doy permisos a mi usuario

```bash
sudo usermod -aG docker $USER
```

Rearranco el equipo y compruebo

```bash
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

Creo un directorio, preparo el `compose.yaml` para que (descarge y) arranque *Vaultwarden*

```bash
luis@cloud:~ $ mkdir vaultwarden
luis@cloud:~ $ cd vaultwarden/
luis@cloud:~/vaultwarden $ mkdir vw-data
luis@cloud:~/vaultwarden $ nano compose.yaml
luis@cloud:~/vaultwarden $ tree .
.
├── compose.yaml
└── vw-data
```

Contenido de `compose.yaml`:

```yaml
#
# Compose para el servicio vaultwarden on premise
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

Más o menos queda asi, tendrás tu NGINX en medio, con tu dominio, todas las peticiones que le llegan por el puerto https las redirige al servidor interno X.Y en el puerto 8080.

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-01.svg"
      caption="Configuración final"
      width="300px"
      %}

Arranco el contenedor y me quedo viendo su log

```bash
luis@cloud:~/vaultwarden $ docker compose up -d
luis@cloud:~/vaultwarden $ docker compose logs
```

Configuro mi DNS, doy de alta una nueva entrada en el NGNIX y conecto con mi nuevo servidor en `https://bitwarden.tld.com` (usa tu dominio)

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-02.png"
      caption="Conexión inicial con el servidor"
      width="400px"
      %}

A partir de aquí a configurar Vaultwarden...

## Configuración

Pulso en *Create Account*, introduzco mi correo personal y los datos que pide

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-03.png"
      caption="Creación de mi usuario"
      width="400px"
      %}

Vuelvo a hacer login y ya tengo acceso a mi servidor Vaultwarden (Bitwarden).

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-04.png"
      caption="Acceso al servidor local"
      width="400px"
      %}

Una vez que termina la instalación ya puedo ver los datos y reconfigurar los clientes con la dirección local del servidor.

### Exportar

Lo siguiente que hice fue irme a mi cuenta de [Bitwarden](https://vault.bitwarden.com/#/login), en la nube, login con mi usuario de siempre y entré en `Vault > export`. Exporté en formato JSON encriptado con una contraseña. Creó un fichero del tipo `bitwarden_encrypted_export_20250302162516.json` y lo descargo en mi ordenador.

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-05.png"
      caption="Exportación"
      width="400px"
      %}

### Importar

A continuación conecto desde el navegador con mi servidor local, hago login y click en `Import Data`.

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-06.png"
      caption="Importación"
      width="400px"
      %}

Una vez importados los datos he cambiado todos los clientes para que apunten al servidor local y me fui a mi cuenta en la nube de Bitwarden para borrarla. De momento tiene muy buena pinta, como se puede observar, de recursos la Raspberry Pi5 (8GB) va sobradísima, ejecutando NextCloud y Vaultwarden simultáneamente.

{% include showImagen.html
      src="/assets/img/posts/2025-03-02-bitwarden-07.png"
      caption="Pi5 ejecutando NextCloud y Vaultwarden"
      width="400px"
      %}
