---
title: "Chuleta sobre GIT"
date: "2021-10-10"
categories: desarrollo
tags: git
excerpt_separator: <!--more-->
---

![Logo GIT Cheatsheet](/assets/img/posts/logo-git-cheatsheet.svg){: width="150px" style="float:left; padding-right:25px" } 

Este apunte contiene **mi ficha de ayuda sobre GIT**: Es mi hoja recordatorio que utilizo como programador, donde tengo las comando que más utilizo. Viene bien por ejemplo cuando borro accidentalmente un fichero, quiero consultar una versión anterior de código o quiero ignorar una modificación en un archivo concreto.

<br clear="left"/>
<!--more-->

| **Importante**: Este apunte lo uso como *referencia*, por lo tanto asume que conoces GIT. Si necesitas saber más te recomiendo este otro [apunte sobre GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}) |


**Básico**

```zsh
$ git config --global user.name "Don Quijote"
$ git config --global user.email "donquijote@email.com"

$ mkdir -p /home/proyectos/miproyecto
$ cd /home/proyectos/miproyecto
$ git init

$ cd /home/proyectos
$ git clone https://github.com/LuisPalacios/LuisPalacios.github.io

$ cd /home/proyectos/miproyecto
$ git status
```

<br/>

**Tags**

```zsh
$ git log --pretty=oneline
a7a05..d9114 (HEAD -> master, origin/master, origin/HEAD) Nueva versión
:
3f64b..37101 Versión terminada
ce5d4..1e621 Primer commit
$ git tag 1.0 3f64b           <== Aplicada al commit con hash 3f64b
$ git tag -d 1.0              <== La borro para añadirla de nuvo con anotación
$ git tag -a 1.0 -m "Primera versión operativa" 3f64b
$ git tag 2.0                 <== Aplica al último commit
$ git push origin 1.0         <== Envío tag o tags al origen.
$ git push origin --tags
```

<br/>

**Alias**

```zsh
$ git config --global alias.lo '!git --no-pager log --graph --decorate --pretty=oneline --abbrev-commit'
$ git config --global alias.lg '!git lg1'
$ git config --global alias.lg1 '!git lg1-specific --all'
$ git config --global alias.lg1-specific "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %s - %an %C(blue)%d%C(reset)'"
```

```zsh
$ git lo
$ git lg
```

<br/>

**Deshacer**.

Técnicamente consiste en *Volver a la versión anterior de un archivo de la working copy*. Muy útil cuando hemos borrado o  modificado un archivo por error y queremos deshacer por completo y volver a su versión anterior (la del último commit).  Ojo que es destructivo, vuelve a dejar el contenido anterior del fichero y lo que hayamos modificado se pierde... 

```zsh
$ git restore Capstone/dataset/0.dataclean/datos.ipynb
```

<br/>

---
