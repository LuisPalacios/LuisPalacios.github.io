---
title: "Rsync on MacOS"
date: "2006-11-13"
categories: ["tools"]
tags: ["client","server","mac","linux","rsync"]
draft: false
cover:
  image: "/img/posts/logo-rsync.svg"
  hidden: true
---


<img src="/img/posts/logo-rsync.svg" alt="rsync logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

The rsync program comes bundled with Mac OSX, but if you need a more recent version with additional features -- such as metadata preservation, extended character support, or cross-platform character handling -- you'll need to install one of the latest versions.

<br clear="left"/>
<!--more-->

To compile the latest version you'll need:

- To know how to use Terminal.app
- To have the Apple Developer Tools installed

The installation steps are as follows. When I did this it was version 3.1.0 which I compiled on MacOSX 10.8.5 in 64-bit mode. As root:

```shell
# cd /tmp
# curl -O http://rsync.samba.org/ftp/rsync/rsync-3.1.0.tar.gz
# tar -xzvf rsync-3.1.0.tar.gz
# rm rsync-3.1.0.tar.gz
# curl -O http://rsync.samba.org/ftp/rsync/rsync-patches-3.1.0.tar.gz
# tar -xzvf rsync-patches-3.1.0.tar.gz
# rm rsync-patches-3.1.0.tar.gz
# cd rsync-3.1.0
# patch -p1 < patches/fileflags.diff
# patch -p1 < patches/crtimes.diff
# ./prepare-source
# ./configure
# make
# make install
# mv /usr/local/bin/rsync /usr/bin
```

<br/>

## Installing the rsyncd daemon on MacOSX

If you find it necessary, you can update to the latest version of rsync as described above. In any case, what I describe below works for both the latest version and older versions.

In this section we'll see how to configure MacOSX to start "rsync" in daemon mode, meaning to run the command `rsync --daemon` in the background.

To run a "daemon" on the Mac and have it start on each boot you need to use "launchd" and "launchdctl" to load an XML file that describes which process you want to run in daemon mode. The XML file is a "PLIST or property list" file that is installed as root in /Library/LaunchDaemon.

So here we go. Create the file `org.samba.rsync.plist`

```xml
{% raw %}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>Disabled</key>
        <false/>
        <key>Label</key>
        <string>org.samba.rsync</string>
        <key>Program</key>
        <string>/usr/bin/rsync</string>
        <key>ProgramArguments</key>
        <array>
                <string>/usr/bin/rsync</string>
                <string>--daemon</string>
                <string>--config=/etc/rsyncd.conf</string>
        </array>
        <key>inetdCompatibility</key>
        <dict>
                <key>Wait</key>
                <false/>
        </dict>
                <key>Sockets</key>
                <dict>
                        <key>Listeners</key>
                        <dict>
                                <key>SockServiceName</key>
                                <string>rsync</string>
                                <key>SockType</key>
                                <string>stream</string>
                        </dict>
                </dict>
</dict>
</plist>
{% endraw %}
```

From Terminal.app and as root, I copy the file to /Library/LaunchDaemons

```shell
# cp org.samba.rsync.plist /Library/LaunchDaemons/
```

I create the file /etc/rsyncd.conf

```conf
pid file = /var/run/rsyncd.pid
use chroot = yes
read only = yes
charset = utf-8

\[Datos\]
 path=/Volumes/Datos
 comment = Luis's Repository
 uid = luis
 gid = luis
 list = yes
 read only = false
 auth users = luis
 secrets file = /etc/rsync/rsyncd.secrets
```

Secrets file /etc/rsync/rsyncd.secrets. Use the same (plain text) password that the client will use.

```conf
luis:PASSWORD
```

```shell
# chmod 400 rsyncd.secrets
```

I load the plist into the launchd registry. The "rsync --daemon" process doesn't start immediately -- what we're doing is registering the service so that when a request arrives on port 873, the launchd process will take care of starting "rsync --daemon".

```shell
# netstat -na|grep 873
```

```shell
:
# launchctl load -w /Library/LaunchDaemons/org.samba.rsync.plist
# netstat -na|grep 873
tcp6 0 0 \*.873 \*.\* LISTEN
tcp4 0 0 \*.873 \*.\* LISTEN
```

From a client we can verify it's working

```shell
$ rsync --stats luis@myserver.mydomain.com::Datos
Password:
:
sent 58 bytes received 618 bytes 193.14 bytes/sec
total size is 24580 speedup is 36.36
```
