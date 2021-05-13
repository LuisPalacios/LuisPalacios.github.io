---
title: "Previsualizar Markdown en MacOS"
date: "2021-04-24"
categories: herramientas
tags: macos
excerpt_separator: <!--more-->
---

![logo md](/assets/img/posts/logo-markdown.svg){: width="150px" height="88px" style="float:left; padding-right:25px" } 

Con MacOS no se incluye una opción en el **Finder**, para poder pre-visualizar archivos Markdown (.md). Existen varias opciones para resolverlo, una de las más rápidas y sencillas consiste en instalar `qlmarkdown`

<br clear="left"/>
<!--more-->

Ante la pregunta ¿cómo puedo hacer que "Quick Look" muestre vistas previas de archivos Markdown (.md)?, la respuesta es que existe un proyecto [qlmarkdown](https://github.com/toland/qlmarkdown) que puede instalarse con homebrew y que soluciona el problema. 


```console
brew install --cask qlmarkdown
```

A partir de ese momento se establece la asociación entre los archivos `.md` y el visor 

```console
➜  ~ qlmanage -m | grep "md"
  com.unknown.md -> /Users/luis/Library/QuickLook/QLMarkdown.qlgenerator (1.3.5)
➜  ~
```

Nota: En mi caso tuve que reiniciar el sistema para que esto funcionase; para que me permitiese validar su ejecuión.