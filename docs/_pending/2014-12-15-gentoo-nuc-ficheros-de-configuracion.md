---
title: "Gentoo en NUC: Ficheros de configuración"
date: "2014-12-15"
categories: gentoo
tags: linux nuc
excerpt_separator: <!--more-->
---

{% include showImagen.html
    src="/assets/img/original/?p=7"
    caption="instalación de Gentoo GNU/Linux en un Intel® NUC D54250WYK"
    width="600px"
    %}

{% include showImagen.html
    src="/assets/img/original/conf.png"
    caption="conf"
    width="600px"
    %}

/dev/sda2 /boot ext2 noauto,noatime 1 2
/dev/sda3 none swap sw 0 0
/dev/sda4 / ext4 noatime 0 1
proc /proc proc defaults 0 0
tmpfs /dev/shm tmpfs nodev,nosuid,noexec 0 0

CFLAGS="-O2 -pipe -march=native"
CHOST="x86_64-pc-linux-gnu"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j5 -l10"
EMERGE_DEFAULT_OPTS="--nospinner --keep-going --jobs=5 --load-average=10"
USE="-cups X alsa apache2 avahi cleartype corefonts esd exif ffmpeg fontconfig fuse gtk gtk2 imagemagick imap jpeg lm_sensors maildir mysql ogg oggvorbis opengl png pulseaudio samba sasl snmp spell tiff truetype type1 udev vhosts vorbis x264 xcb xml xulrunner xv xvmc zeroconf"
LINGUAS="es en"
APACHE2_MODULES="actions alias auth_basic auth_digest authn_anon authn_dbd authn_dbm authn_default authn_file authz_dbm authz_default authz_groupfile authz_host authz_owner authz_user autoindex cache dav dav_fs dav_lock dbd deflate dir disk_cache env expires ext_filter file_cache filter headers ident imagemap include info log_config logio mem_cache mime mime_magic negotiation proxy proxy_ajp proxy_balancer proxy_connect proxy_http rewrite setenvif so speling status unique_id userdir usertrack vhost_alias"
ACCEPT_LICENSE="*"
PORTDIR="/usr/portage"
DISTDIR="${PORTDIR}/distfiles"
PKGDIR="${PORTDIR}/packages"
GENTOO_MIRRORS="http://gentoo-euetib.upc.es/mirror/gentoo/"
VIDEO_CARDS="vesa"
INPUT_DEVICES="evdev keyboard mouse"

sys-apps/systemd
sys-fs/udev

media-gfx/splashutils fbcondecor
>=dev-libs/libxml2-2.7.8-r5 python
x11-libs/libdrm libkms video_cards_radeon
sys-auth/consolekit policykit
net-dns/avahi dbus gtk3
app-text/poppler cairo
dev-lang/python sqlite
sys-auth/pambase consolekit
media-gfx/splashutils fbcondecor gpm mng png truetype -hardened
media-libs/lcms static-libs
media-libs/libjpeg-turbo static-libs
app-arch/bzip2 static-libs
media-libs/libpng static-libs
virtual/jpeg static-libs
media-libs/libmng static-libs
media-libs/freetype static-libs
sys-boot/grub -nls
net-dns/bind berkdb dlz ipv6 -mysql ssl xml
www-servers/apache threads ssl sni
dev-lang/php apache2 spell berkdb bzip2 cli crypt ctype curl exif filter ftp gd gdbm iconv imap ipv6 json mysql ncurses nls pcre posix readline reflection session snmp spl ssl threads truetype unicode xml xsl zlib mysqli sockets tokenizer xmlrpc sqlite simplexml pdo postgres pcre xmlreader
net-misc/ntp ipv6 ssl zeroconf caps
net-dns/avahi mdnsresponder-compat
net-analyzer/net-snmp perl
mail-filter/amavisd-new mysql razor spamassassin
media-libs/libpng apng
dev-vcs/git tk
net-analyzer/net-snmp perl
media-libs/mesa xvmc g3dvl
sys-libs/zlib static-libs
media-sound/easytag mp3
net-fs/cifs-utils ads
net-fs/samba winbind
sys-libs/talloc python
app-admin/ulogd mysql nfct nflog dbi nfacct pcap sqlite
sys-process/lsof rpc
sys-libs/gpm static-libs
media-libs/sdl-image gif
net-libs/libmicrohttpd messages
mail-client/cone -ipv6
media-libs/mesa gbm
dev-libs/apr-util nss
net-misc/strongswan caps constraints mysql non-root openssl pam dhcp

net-misc/udpxy                ~amd64
=net-misc/xupnpd-9999         **
=app-emulation/docker-1.3.1   ~amd6

LC_ALL="es_ES.UTF-8"
LC_COLLATE="es_ES.UTF-8"
LC_CTYPE="es_ES.UTF-8"
LC_MESSAGES="es_ES.UTF-8"
LC_MONETARY="es_ES.UTF-8"
LC_NUMERIC="es_ES.UTF-8"
LC_PAPER="es_ES.UTF-8"
LANG="es_ES.UTF-8"

#
# Ojo!!!: Utilizo MTU 8704 que es lo máximo que me permite la tarjeta de Intel.
# Para que funcione debes asegurarte de que tu Switch lo soporta y tener 
# configurado y activo Jumbo Frames. Notarás mucha mejora si tienes una NAS
# (también debe terner activo jumbo frames) a la que accedes vía NFS
#

# Instalacion de TOTOBO
#
#

# Ethernet NIC
config_eth0="null"
mtu_eth0="8704"

#
# VLAN (802.1q support) (( emerge net-misc/vconfig ))
#
vlans_eth0="100"
vlan100_name="vlan100"

config_vlan100="192.168.1.245/24"
routes_vlan100="default via 192.168.1.1"
