---
title: "Preview Notebooks on MacOS"
date: "2021-05-08"
categories: ["tools"]
tags: ["macos"]
draft: false
cover:
  image: "/img/posts/logo-jupyterview.svg"
  hidden: true
---

<img src="/img/posts/logo-jupyterview.svg" alt="jupyter view logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

MacOS doesn't include an option in Finder to preview Jupyter Lab notebooks (.ipynb). There are several options but one of the quickest and simplest is to install `ipynb-quicklook`

<br clear="left"/>
<!--more-->

To be able to Quick Look `.ipynb` files, there's a project called [ipynb-quicklook](https://github.com/tuxu/ipynb-quicklook) that you can install to solve the problem.

- Download ipynb-quicklook.qlgenerator ([from here](https://github.com/tuxu/ipynb-quicklook/releases))
- Decompress and move the ipynb-quicklook.qlgenerator directory to ~/Library/QuickLook.
- Run `qlmanage -r` to reset Quick Look
- From now on, pressing space on an `.ipynb` file will show its content

```shell
➜  ~ qlmanage -m|grep "ipynb"
  org.jupyter.ipynb -> /Users/lpalacio/Library/QuickLook/ipynb-quicklook.qlgenerator (1)
  ➜  ~
```

Note: In my case I had to restart the system for this to work.
