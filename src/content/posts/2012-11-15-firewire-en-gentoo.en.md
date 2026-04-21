---
title: "FireWire on Linux on Mac"
date: "2012-11-15"
categories: ["linux"]
tags: ["firewire","gentoo","linux","disks"]
draft: false
cover:
  image: "/img/posts/logo-firewire.svg"
  hidden: true
---

<img src="/img/posts/logo-firewire.svg" alt="firewire" width="150px" height="150px"  style="float:left; padding-right:25px"  />

IEEE 1394 (FireWire) is a type of connection for various platforms, designed for high-speed serial data input and output. It is commonly used for connecting digital devices such as digital cameras and camcorders. Apple implemented it for connecting hard drives.

<br clear="left"/>
<!--more-->

In this post I describe how to configure a FireWire disk to connect it to my Mac Mini running `Gentoo Linux`. First, the Linux Kernel needs to be prepared to support the FireWire driver.

```text
 Device Drivers --->
   IEEE 1394 (FireWire) support --->
      <*> FireWire driver stack
      <*> OHCI-1394 controllers
      <*> Storage devices (SBP-2 protocol)

 Device Drivers --->
   SCSI device support --->
      <*> SCSI device support
      <*> SCSI disk support
```

Compile and install the new kernel, reboot the machine, and then prepare the `/etc/make.conf` file. Portage has a global `USE` flag `ieee1394` that enables FireWire support in other software packages. By activating it, the library `sys-libs/libraw1394` will be installed.

```text
USE="... ieee1394 ..."
````

With the new USE flag active, we recompile the system:

```zsh
# emerge -DuvNp system world
```

From this point on you can connect the FireWire disk to the Mac -- it should recognize it as just another disk. During boot, this is what you see in "dmesg":

```log
[ 8.967388] firewire_core 0000:05:00.0: created device fw1: GUID 00d0b802e0009568, S800
[ 9.199443] firewire_sbp2 fw1.0: logged in to LUN 0000 (0 retries)
[ 9.205079] scsi 3:0:0:0: Direct-Access External RAID 0 PQ: 0 ANSI: 4
[ 9.205249] sd 3:0:0:0: Attached scsi generic sg2 type 0
[ 9.209223] sd 3:0:0:0: [sdc] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[ 9.212173] sd 3:0:0:0: [sdc] Write Protect is off
[ 9.212180] sd 3:0:0:0: [sdc] Mode Sense: 10 00 00 00
[ 9.214408] sd 3:0:0:0: [sdc] Cache data unavailable
[ 9.214414] sd 3:0:0:0: [sdc] Assuming drive cache: write through
[ 9.224797] sd 3:0:0:0: [sdc] Cache data unavailable
[ 9.224806] sd 3:0:0:0: [sdc] Assuming drive cache: write through
[ 9.227352] sdc: [mac] sdc1 sdc2 sdc3 sdc4
[ 9.237568] sd 3:0:0:0: [sdc] Cache data unavailable
[ 9.237578] sd 3:0:0:0: [sdc] Assuming drive cache: write through
[ 9.239442] sd 3:0:0:0: [sdc] Attached SCSI disk
```

<br/>

In my case I'm going to use this disk to access an [HFS+ partition from my Mac Mini]({{< relref "2012-12-15-HFS en Linux.md" >}}) that I had created some time ago.
