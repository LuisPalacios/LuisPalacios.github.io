---
title: "Putting a Disk to Sleep on MacOSX"
date: "2013-12-10"
categories: ["tools"]
tags: ["disk","macosx","sleep"]
draft: false
cover:
  image: "/img/posts/2013-12-10-dormir-disco-macos-01.png"
  hidden: true
---

<img src="/img/posts/2013-12-10-dormir-disco-macos-01.png" alt="Sleep logo" width="150px" style="float:left; padding-right:25px"  />

I need to increase the time MacOSX waits before putting an external Thunderbolt hard drive to sleep. The default is ten minutes. The command to view the current configuration is:

<br clear="left"/>
<!--more-->

```shell
obelix:~ luis$ sudo pmset -g
Active Profiles:
AC Power 2*
Currently in use:
 standby 1
 Sleep On Power Button 1
 womp 1
 halfdim 1
 hibernatefile /var/vm/sleepimage
 darkwakes 1
 autorestart 0
 networkoversleep 0
 disksleep 10   <=========== !!!!!!
 sleep 1
 autopoweroffdelay 14400
 hibernatemode 0
 autopoweroff 1
 ttyskeepawake 1
 displaysleep 10
 standbydelay 10800
```

To increase it to 20 minutes, simply run the following:

```shell
obelix:~ luis$ sudo pmset -a disksleep 20
Warning: Idle sleep timings for "AC Power" may not behave as expected.
- Display sleep should have a lower timeout than system sleep.
```
