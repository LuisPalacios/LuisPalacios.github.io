---
title: "Remote WireShark"
date: "2016-06-05"
categories: ["linux"]
tags: ["networking","traffic","capture"]
draft: false
cover:
  image: "/img/posts/logo-wireshark.svg"
  hidden: true
---

<img src="/img/posts/logo-wireshark.svg" alt="Wireshark logo" width="150px" style="float:left; padding-right:25px"  />

In this post I explain how I launch a network traffic capture (`tcpdump`) on a remote Linux machine ([Pi2 with Gentoo]({{< relref "2015-05-17-gentoo-pi2.md" >}})) and have it forwarded to **Wireshark** running on my computer (Mac). We'll get tcpdump's output to become Wireshark's input. It seems like magic but you'll see it's extremely simple. You'll need to know `ssh` and `sudo`, a couple of prerequisites for making this so easy.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2016-06-05-wireshark-remoto-01.jpg" alt="wireshark-remote" width="600px" />
  <div class="image-caption">wireshark-remote</div>
</div>

<br/>

- Option with mkfifo

I'll start with a slightly more complicated option (the next one is simpler), but it will help us better understand the idea...

We run two sessions in a terminal (`Terminal.app`, `iTerm2`, etc.). In my case I run them on my iMac. In one session I run WireShark on my computer. In the other I request remote execution of tcpdump via SSH on a Linux machine. I connect both processes through an intermediate FIFO file.

Session 1:

```shell
mkfifo /tmp/remote
wireshark -k -i /tmp/remote
```

Session 2:

```shell
ssh luis@gentoopi.tudominio.com "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" > /tmp/remote
```

<br/>

- Direct option without mkfifo (Preferred)

The above can be reduced to a single line in a single Terminal session:

Single session, in this case I run Wireshark on my MacOS:

```shell
ssh luis@gentoopi.tudominio.com "sudo tcpdump -s 0 -U -n -w - -i eth0 not port 22" | /Applications/Wireshark.app/Contents/MacOS/Wireshark -k -i -
```
