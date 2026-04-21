---
title: "Move KVM guest"
date: "2016-07-07"
categories: ["virtualization"]
tags: ["backup","iscsi","kvm","linux"]
draft: false
cover:
  image: "/img/posts/logo-move.svg"
  hidden: true
---

<img src="/img/posts/logo-move.svg" alt="Move logo" width="150px" style="float:left; padding-right:25px"  />

I recently had to move a virtual machine from one of my servers to another on the same network. As always I relied on Google, although it's a straightforward operation I do almost everything from the shell, so here's the process for future reference...

<br clear="left"/>
<!--more-->

To move a KVM Guest to a new Host:

- Copy the VM disk from the source server to the destination.

```shell
# scp /home/luis/aplicacionix.qcow2 nuevo.tudominio.com:/home/luis
```

- On the Source, export the configuration file and copy it to the destination

```shell
# virsh dumpxml aplicacionix > dom_aplicacionix.xml
# scp dom_aplicacionix.xml nuevo.tudominio.com:/home/luis
```

- On the destination, import and add the XML file

```shell
# virsh define dom_aplicacionix.xml
```

- Start the new VM manually or from virt-manager
