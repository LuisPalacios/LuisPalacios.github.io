---
title: "Plex Media Server"
date: "2014-04-23"
categories: ["tv"]
tags: ["linux","gentoo","plex"]
draft: false
cover:
  image: "/img/posts/logo-pms.png"
  hidden: true
---


<img src="/img/posts/logo-pms.png" alt="Plex logo" width="150px" style="float:left; padding-right:25px"  />

Plex Media Server lets you transform your computer into a multimedia center. It uses the digital content and sources you have available, such as media files or other multimedia sources. It organizes content into different sections to serve them to clients.

<br clear="left"/>
<!--more-->

## Installation

Below is the installation process

```
# layman -a fouxlay
# emerge -v plex-media-server
:
[ebuild N ~] media-tv/plex-media-server-0.9.9.7::fouxlay 68,137 kB
```

Once it finishes it shows the message `Plex Media Server is now fully installed...` and you can connect to it through a browser: `http://<ip>:32400/web/`

The installation process creates the "plex" user and its HOME directory is at `/var/lib/plexmediaserver`

## Configuration

In my case I left the default configuration

```shell
# default script for Plex Media Server
# the number of plugins that can run at the same time
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS=6
# ulimit -s $PLEX_MEDIA_SERVER_MAX_STACK_SIZE
PLEX_MEDIA_SERVER_MAX_STACK_SIZE=3000
# where the mediaserver should store the transcodes
PLEX_MEDIA_SERVER_TMPDIR=/tmp
# uncomment to set it to something else
# PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="${HOME}/Library/Application\ Support"
# the user that PMS should run as, defaults to 'plex'
# note that if you change this you might need to move
# the Application Support directory to not lose your
# media library
PLEX_MEDIA_SERVER_USER=plex
```

I configure the machine so the service starts at boot

```shell
# rd-update add pled-media-server default
```

The startup process is simple — we run the script left in init.d:

```shell
# /etc/init.d/plex-media-server start
:
___ PROCESSES ___
plex 15833 1 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15839 15833 0 13:02 ? 00:00:00 /bin/sh /usr/sbin/start_pms
plex 15840 15839 49 13:02 ? 00:00:07 ./Plex Media Server
plex 15856 15840 85 13:02 ? 00:00:00 Plex Plug-in [com.plexapp.system] /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/Framework.bundle/Contents/Resources/Versions/2/Python/bootstrap.py --server-version 0.9.9.7.429-f80a8d6 /var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Plug-ins/System.bundle
```

From here on, PMS management is done through a Web interface. Next, you just need to set up your library.
