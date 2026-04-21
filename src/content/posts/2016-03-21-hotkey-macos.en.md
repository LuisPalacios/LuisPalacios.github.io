---
title: "Hotkey for MacOS Apps"
date: "2016-03-21"
categories: ["tools"]
tags: ["finder","hotkey","macos","osx","pathfinder"]
draft: false
cover:
  image: "/img/posts/logo-hotkey.svg"
  hidden: true
---



<img src="/img/posts/logo-hotkey.svg" alt="hotkey logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

I need to be able to open a program by pressing a HotKey, regardless of which application has focus. Applications typically don't come with this option but there are cases where it could be useful.

<br clear="left"/>
<!--more-->

I'm going to use the PathFinder application as an example. My goal is to have this application open as soon as I press a specific key combination. To configure a HotKey for launching an application, we simply need to use Automator and the system's Keyboard Preferences. Launch the `Automator` program.

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-01.png" alt="Automator program" width="800px" />
  <div class="image-caption">Automator program</div>
</div>

- Create a new Service,

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-02.png" alt="Create a new service" width="800px" />
  <div class="image-caption">Create a new service</div>
</div>

We associate a keypress with an App.

- Automator: New Document
- Select the conditions: no data input, in any application
- Drag *Open Application* and select the application to open
- Save the Service as "Launch Path Finder"

<div class="image-box">
  <img src="/img/posts/2016-03-21-hotkey-macos-03.png" alt="Associate the key" width="600px" />
  <div class="image-caption">Associate the key</div>
</div>
