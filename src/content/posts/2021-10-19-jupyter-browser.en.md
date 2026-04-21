---
title: "Jupyter Lab with Chrome on Mac"
date: "2021-10-19"
categories: ["development"]
tags: ["macos","python","jupyter"]
draft: false
cover:
  image: "/img/posts/logo-jupyterchrome.svg"
  hidden: true
---

<img src="/img/posts/logo-jupyterchrome.svg" alt="Jupyter Chrome Logo" width="150px" style="float:left; padding-right:25px"  />

I describe how to change the default browser for Jupyter Lab on a Mac. If we don't do anything and launch jupyter lab from the command line, the system's default browser (Safari) will be invoked. If you want to change it to Chrome, follow the steps below.

<br clear="left"/>
<!--more-->

The process is fairly simple. I assume you have Jupyter installed. Open the terminal:

```
cd ~/.jupyter
```

If you have the file ```jupyter_notebook_config.py```, open it with your preferred editor. If it doesn't exist, create it with the following command:

```
$ jupyter notebook --generate-config
Writing default config to: /Users/luis/.jupyter/jupyter_notebook_config.py
```

Open the file with your preferred editor

```
e jupyter_notebook_config.py
```

Change the following line

```
c.NotebookApp.browser = 'open -a /Applications/Google\ Chrome.app %s'
```

Go back to your project and launch Jupyter Lab from the command line — you'll see that the new browser is now invoked.

```
pipenv run jupyter lab
```

----

<br/>
