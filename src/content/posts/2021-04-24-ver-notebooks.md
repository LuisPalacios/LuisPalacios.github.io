---
title: "Previsualizar Cuadernos en MacOS"
date: "2021-05-08"
categories: ["herramientas"]
tags: ["macos"]
draft: false
cover:
  image: "/img/posts/logo-jupyterview.svg"
  hidden: true
---

<img src="/img/posts/logo-jupyterview.svg" alt="logo jupyter view" width="150px" height="150px" style="float:left; padding-right:25px"  />

Con MacOS no se incluye una opción en Finder para poder pre-visualizar cuaderos de Jupyter Labs (.ipynb). Existen varias opciones pero una de las más rápidas y sencillas consiste en instalar `ipynb-quicklook`

<br clear="left"/>
<!--more-->

Para poder previsulalizar ("Quick Look") de archivos `.ipynb` existe un proyecto [ipynb-quicklook](https://github.com/tuxu/ipynb-quicklook) que puedes instalartese y soluciona el problema.

- Descargar ipynb-quicklook.qlgenerator ([desde aquí](https://github.com/tuxu/ipynb-quicklook/releases))
- Descomprimir y mover el directorio ipynb-quicklook.qlgenerator a ~/Library/QuickLook.
- Ejecuta `qlmanage -r` para resetear Quick Look
- A partir de ahora pulsando espacio sobre fichero `.ipynb` mostrará su contenido 👍

```shell
➜  ~ qlmanage -m|grep "ipynb"
  org.jupyter.ipynb -> /Users/lpalacio/Library/QuickLook/ipynb-quicklook.qlgenerator (1)
  ➜  ~
```

Nota: En mi caso tuve que reiniciar el sistema para que esto funcionase.
