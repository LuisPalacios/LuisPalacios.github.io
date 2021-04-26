---
title: "Mi primer blog"
date: "2002-11-11"
categories: apuntes gentoo linux
---

![nimble image](/assets/img/original/nimble.jpg){: width="150px" style="float:left; padding-right:10px" } 

Este fué mi primer post en mi blog original con Nibbleblog, no con wordpress, ni recientemente con Jekyll, asi que lo dejo tal cual.

Mi primer apunte lo hice con Nibbleblog En el 2002 instalé [NibbleBlog](http://www.nibbleblog.com), un motor muy sencillo para la creación y manipulación de mi bitácora, basado en archivos XML.

La verdad es que esta gente ha hecho un excelente trabajo, sencillo, rápido y productivo. Qué más decir que lo recomiendo. Más adelante en el tiempo me pasé a WordPress, pero dejo aquí unas nociones la instalación de Nibbleblog a modo de referencia.

Requisitos para su instalación en Gentoo El orden es sencillo: Instala Apache y PHP (USE: simplexml). Se acabó. ## Instalación Descargar de forma manual el ZIP de NibbleBlog desde su [página de descargas](http://www.nibbleblog.com/download/en/). Descomprimirlo y copiar todo su contenido a un directorio accesible por apache. Aquí pongo un ejemplo en mi caso:


```bash
cd /data/www
unzip /home/luis/Desktop/nibbleblogv11_editor.zip
mv nibbleblog\ v1.1\ +\ editor/ blog.luispa.com
```

Creo un nuevo vhost que apunta al nuevo directorio:

```bash
cd /data/www/blog.luispa.com
find . -exec chown apache:apache {} \;
/etc/init.d/apache graceful
```

<br/>

# Configuración

Conecta con tu blog, en la página de admin (algo parecido a [http://tu.servidor.com/admin](http://tu.servidor.com/admin)) Las preguntas son muy simples, si algo te salió mal, simplemente borra el contenido bajo el subdirectorio "content" y vuelve a intentarlo. Acceso al blog:

* Como "lector" http://tublog.tudominio.com 
* Como "admin" http://tublog.tudominio.com/admin
* El resto es tan intuitivo que no merece la pena explicarlo

# Búsqueda en NibbleBlog

Vaya sorpresa que me he llevado. Al instalar NibbleBlog y estar un rato jugando con él me he dado cuenta que no trae un "buscador".

La solución ha sido sencilla, en [http://www.freefind.com](http://www.freefind.com) tiene un servicio gratuito (apoyado en publicidad) que básicamente consiste en que ellos tienen el buscador e indexan tus páginas. En cinco minutos lo tienes funcionando. Solo hay que darse de de alta, activar el Plugin de inserción de "HTML" en NibbleBlog y marchando. Por cierto, en Noviembre de 2014 me pasé a WordPress que sí incluye un Buscador :-)
