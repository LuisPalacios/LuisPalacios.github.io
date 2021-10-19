---
title: "Jupyter Lab con Chrome en Mac"
date: "2021-10-19"
categories: desarrollo
tags: macos python jupyter
excerpt_separator: <!--more-->
---

![Logo GIT](/assets/img/posts/logo-jupyterchrome.svg){: width="150px" style="float:left; padding-right:25px" } 

Describo cómo cambiar el navegador de por defecto para Jupyter Lab en un Mac. Si no hacemos nada y arrancamos jupyter lab desde la línea de comandos veremos cómo se invoca al navegador de por defecto del sistema (Safari). Si quieres cambiarlo a Chrome sigue los pasos siguientes. 

<br clear="left"/>
<!--more-->


El proceso es bastante sencillo, asumo que tienes Jupyter instalado, abrimos el terminal:

```
$ cd ~/.jupyter
```

Si tienes el fichero ```jupyter_notebook_config.py``` ábrelo con tu editor preferido. Si no existe, créalo con el comando siguiente: 

```
$ jupyter notebook --generate-config
Writing default config to: /Users/luis/.jupyter/jupyter_notebook_config.py
```

Abrimos el fichero con el editor preferido

```
$ e jupyter_notebook_config.py
```

Cambia la línea siguiente

```
c.NotebookApp.browser = 'open -a /Applications/Google\ Chrome.app %s'
```

Vuelve a tu proyecto y arranca Jupyter Lab desde la línea de comandos, verás que ahora se invoca al nuevo navegador. 

```
$ pipenv run jupyter lab
```


----

<br/>
