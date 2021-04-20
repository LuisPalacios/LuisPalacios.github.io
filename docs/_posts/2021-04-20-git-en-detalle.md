---
title: "GIT en detalle"
date: "2021-04-20"
categories: apuntes git linux
---

![GIT Logo](/assets/img/Git-Logo-1788C-300x125.png){: width="150px" style="float:left; padding-right:20px" } 

En pocas palabras, [GIT] es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia.

No depende de un repositorio central, múltiples usuarios pueden instalarse GIT y comunicarse entre ellos sin necesidad de conectar con un servidor central. Lo que pasa es que sería inmanejable, así que los "servidores o repositorios centrales (remotos)" son muy útiles y necesarios. 

Podrías montarte el tuyo propio con [Gitolite] por ejemplo, o mejor todavía con [GitLab] (auto-gestionado). Ahora bien, **lo más sensato es usar los que están disponibles en internet como los famosos [GitHub] o [GitLab]**. 

[Git]: https://git-scm.com
[GitHub]: https://www.github.com
[GitLab]: https://www.gitlab.com
[Gitolite]: https://gitolite.com

<br/>

## Introducción

Empezamos por algunos enlaces. Muy útil, la [Cheatsheet en Español](https://training.github.com/downloads/es_ES/github-git-cheat-sheet/) o la [Visual Git Cheat Sheet](https://ndpsoftware.com/git-cheatsheet.html) o este pequeño [Guía burros](https://rogerdudler.github.io/git-guide/index.es.html) o si quieres algo más oficial, tienes la [documentación oficial](https://git-scm.com/doc) o si te vas a cualqueir buscador en internet vas a encontrar cientos de videos, tutoriales, documentos, etc. 

¿Porqué mola GIT?. Hay muchos motivos, como su velocidad, que lo hizo Linus Torvals, que es libre, que nos permite movernos, como si tuviéramos un puntero en el tiempo, por todas las revisiones de código y desplazarnos una manera muy ágil.

Tiene un sistema de trabajo con ramas (branches) que lo hace especialmente potente. Están destinadas a provocar proyectos divergentes de un proyecto principal, para hacer experimentos o para probar nuevas funcionalidades.

Antes de entrar en harina, tenemos dos formas de trabajar con Git. Una es con el cliente (programa) `git` para la línea de comandos. La otra es usar un cliente gráfico, muchísimo más sencillo y agradable. Aún así te recomiendo empezar por `git` y cuando entiendas cuatro cosillas importantes te pases a entorno gráfico. Te recomiendo los primeros de esta lista, ojo que hay muchísimos.

* Cliente `git`, programa para línea de comandos
* Cliente GUI [GitKraken](https://www.gitkraken.com) <- Este es el que uso yo 🤗
* Cliente GUI [GitHub Desktop](https://desktop.github.com) desarrollado por GitHub.
* Cliente GUI [SourceTree](https://www.sourcetreeapp.com)
* Aquí tienes más.. [clientes GUI](https://git-scm.com/downloads/guis)

<br/>

### Instalación de Git

Te voy a pedir que instales tanto el programa `git` de línea de comandos como que **elijas uno de los clientes anteriores (el que más te guste)**, lo descargues y lo instales en tu ordenador. 

* Aquí tienes una pequeña guía para [instalar](https://git-scm.com/book/es/v2/Inicio---Sobre-el-Control-de-Versiones-Instalación-de-Git) `git` en línea de comandos en Linux, Windows y Mac.

Una vez que lo tengas instalado deberías funcionarte al menos lo siguiente: 


```
➜  ~ > git
usage: git [--version] [--help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           <command> [<args>]
           :
➜  ~ > git --version
git version 2.24.3 (Apple Git-128)
```
<br/>

## GIT desde el interior

Uno de los mejores artículos técnicos **con detalle** que me encontré en el pasado para aprender GIT fue [Git from the inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out). De hecho me gustó tanto que me he tomado la libertad de traducirlo y crear esta versión a medida con mis propias palabras. Por supuesto todo el crédito va para su Autora [Mary Rose Cook](https://maryrosecook.com), muchas gracias desde aquí!.



