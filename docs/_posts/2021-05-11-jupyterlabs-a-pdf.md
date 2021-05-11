---
title: "Convertir cuadernos JupyterLabs a PDF"
date: "2021-05-11"
categories: desarrollo
tags: macos python jupyter
excerpt_separator: <!--more-->
---

![logo jupyter impresión](/assets/img/posts/logo-jupyterprint.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


En este apunte describo cómo he conseguido, desde un MacOS, convertir a PDF correctamente los ejercicios de Jupyter Labs con diferentes entornos. He observador que no es fácil convertir a PDF los cuadernos de Jupyter Labs. He probado varias opciones de exportación a Tex, HTML, PDF, etc. sin demasiado éxito. Al final he encontrado una solución aceptable. 

<br clear="left"/>
<!--more-->

## Imprimir cuadernos "a PDF"

Lo que describo está probado con cuadernos con `neo4J` y `py2neo` cuando realizaba el ejercicio del **acertijo de Einstein: ¿quién es el propietario del pez?** en pythong con neo4j (fuente [aquí](https://github.com/LuisPalacios/Master-DS/tree/main/3-Exploratory/4-NoSQL))...

Probablemente funcione con otro tipo de cuadernos e imágenes. He encontrado una forma bastante adecuada de imprimirlos a PDF. El proceso general consiste en **exportar a HTML** en local e **imprimir a PDF** desde el Mac.

<br/>

### Paso 1 - Exportar a HTML. 

Aunque no es estrictamente necesario te recomiendo usar Chrome para este paso, en ciertos casos vas a tener que descargar varios ficheros adicionales (imágenes) desde JupyterLabs y Chrome lo hace bastante cómodo. 

Desde Jupyter Labs Exporta a HTML y baja también las figuras que tengas asociadas al cuaderno. En mi caso, al tratarse de un proyecto con `py2neo`, crea un subdirectorio `figures`, donde deja los `.html` con referencias a scripts para mostrar las imágenes. 

En la imagen siguiente se puede ver cómo he exportado mi cuaderno siguiendo estos pasos: 

* File > export notebook as HTML > /Users/luis/Downloads

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-1.png" 
      caption="Exportar notebook como HTML" 
      width="500px"
      %}


* Entrar en `figures`, seleccionar todas: Botón derecho > Download > /Users/luis/Downloads

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-1.png" 
      caption="Descargar las figuras py2neo" 
      width="500px"
      %}

* En local, en mi directorio `Downloads` creo un sub directorio `figures`y muevo dentro los ficheros graph*.html.

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-3.png" 
      caption="Muevo los graph*.html a `figures`" 
      width="300px"
      %}

<br/>

### Paso 2 - Imprimir HTML local desde Chrome

Ahora sí que es importante usar Chrome, con Safari no he conseguido que me funcione bien. 

* Por lo tanto, abro con Chrome el archivo local `Luis-Acertijo-Einstein.html`. Es recomendable bajar por todo el documento (rápidamente) de modo que se carguen todas las imágenes (de lo contrario podrían no salir en el PDF)

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-4.png" 
      caption="Abro el fichero en local" 
      width="500px"
      %}

* Imprimo a PDF desde Chrome (siempre usando el System’s Dialog, en vez de la opción propia). Voy a mandarlo a imprimir a PDF cambiando sólo el *tamaño del papel*
  *	CMD-ALT-P: (o bien CMD-P > More Settings > Print Using System Dialog)
```config
	Show Details -> Pager Size > Manage Custom Sizes > Create new one with: 
		Paper Size: Width 370mm, Height 4000mm
		Non Printable: User Defined. Top, Left, Right, Bottom > all with 5mm
	Orientation: Portrait
	Copies: 1
	Pages: All
	Scale: 100%
	Resto todo por defecto.
	PDF > Save as PDF
```

| Nota: Aquí tienes uno de los trucos más importantes. Como no me gusta **paginar** el PDF porque desbarta el documento, así que pido que se utilice un tamaño de papel que englobe todo el PDF... en este caso **empiezo probando con un ancho de 370mm y un largo de 4000mm**. Al final volví a imprimir con un largo de 4700mm en mi caso para que me cabiese entero en una sola página. |

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-5.jpg" 
      caption="Fichero PDF" 
      width="500px"
      %}
