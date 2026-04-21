---
title: "Linux on MacBook Air 2015"
date: "2023-08-06"
categories: ["infrastructure"]
tags: ["linux","mac","macbook","air","efi","dualboot"]
draft: false
cover:
  image: "/img/posts/logo-linux-macbook.svg"
  hidden: true
---

<img src="/img/posts/logo-linux-macbook.svg" alt="linux macbook logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

In this post I describe how to repurpose an old MacBook Air (2015) by installing Linux on it and extending its useful life. Over time, these Macs become nearly useless machines, painfully slow and with insufficient memory.

Why not take advantage of them with Linux? A 2015 MacBook Air with 8GB of RAM and a 128GB drive can become a very useful machine.

<br clear="left"/>
<!--more-->

### Installation

I chose Ubuntu Desktop for the installation. These are the steps I followed:

- Download the ISO from [Ubuntu 22.04.2 LTS Desktop](https://ubuntu.com/download/desktop)
- Flash the ISO onto a USB drive with [balenaEtcher](https://etcher.balena.io) from another Mac.
- Insert the USB into the MacBook Air and boot **while holding down the ALT key**
- Double-click on **EFI BOOT**

<div class="image-box">
  <img src="/img/posts/2023-08-06-linux-macbook-01.jpg" alt="Selecting the EFI Boot option" width="200px" />
  <div class="image-caption">Selecting the EFI Boot option</div>
</div>

- Select **Try or Install Ubuntu**

<div class="image-box">
  <img src="/img/posts/2023-08-06-linux-macbook-02.jpg" alt="After a few seconds it starts booting" width="400px" />
  <div class="image-caption">After a few seconds it starts booting</div>
</div>
<div class="image-box">
  <img src="/img/posts/2023-08-06-linux-macbook-03.jpg" alt="Selecting the Install Ubuntu option" width="400px" />
  <div class="image-caption">Selecting the Install Ubuntu option</div>
</div>

- Select **Spanish** (or your preferred language)
- Select the **minimal installation** option and also **Install third-party software**

<div class="image-box">
  <img src="/img/posts/2023-08-06-linux-macbook-04.png" alt="Minimal installation" width="600px" />
  <div class="image-caption">Minimal installation</div>
</div>
<div class="image-box">
  <img src="/img/posts/2023-08-06-linux-macbook-05.png" alt="Option to install third-party software" width="600px" />
  <div class="image-caption">Option to install third-party software</div>
</div>

- Select **erase disk and install Ubuntu**
- My time zone.
- My user details
- Installation begins -- it will take a while.
- When finished, **remove the USB and restart the system**

If you don't want a GUI, from here you only need to disable it.

- How to disable the Ubuntu GUI

```shell
sudo systemctl set-default multi-user
```

- That's it, a fully operational Ubuntu on a solid machine. Reboot.

```shell
reboot
```
