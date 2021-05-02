---
title: "Previsualizar Markdown en MacOS"
date: "2021-04-24"
categories: herramientas
tags: macos
excerpt_separator: <!--more-->
---

![logo md](/assets/img/post/logo-markdown.svg){: width="150px" style="float:left; padding-right:10px" } 

Con MacOS no se incluye una opción en FINDER para poder pre-visualizar archivos Markdown (.md). Existen varias opciones pero una de las más rápidas y sencillas consiste en instalar `qlmarkdown`

<br clear="left"/>
<!--more-->

Ante la pregunta ¿cómo puedo hacer que "Quick Look" muestre vistas previas de archivos Markdown (.md)?, la respuesta es que existe un proyecto [qlmarkdown](https://github.com/toland/qlmarkdown) que puede instalarse con homebrew y que soluciona el problema. 


```zsh
brew install --cask qlmarkdown
```

A partir de ese momento se establece la asociación entre los archivos `.md` y el visor 

```zsh
➜  ~ qlmanage -m | grep "md"
  com.unknown.md -> /Users/luis/Library/QuickLook/QLMarkdown.qlgenerator (1.3.5)
➜  ~
```

Nota: En mi caso tuve que reiniciar el sistema para que esto funcionase; para que me permitiese validar su ejecuión.