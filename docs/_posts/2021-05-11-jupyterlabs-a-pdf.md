---
title: "Convertir cuadernos JupyterLabs a PDF"
date: "2021-05-11"
categories: desarrollo
tags: macos python jupyter
excerpt_separator: <!--more-->
---

![logo jupyter impresión](/assets/img/posts/logo-jupyterprint.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


En este apunte describo cómo he conseguido, desde un MacOS, convertir a PDF correctamente los ejercicios de Jupyter Labs en diferentes entornos. No es fácil convertir los cuadernos de Jupyter Labs a PDF debido a las múltiples variantes (imágenes, enlaces) que puede contener. He probado exportaciones intermedias, `pandoc`, apps, sin demasiado éxito.

<br clear="left"/>
<!--more-->

## Convertir cuadernos a PDF

Lo descrito lo probé con un cuaderno con `neo4J` y `py2neo` cuando realizaba el ejercicio del **acertijo de Einstein: ¿quién es el propietario del pez?** en pythong con neo4j. En teoría debe funcionar con otro tipo de cuadernos, con imágenes embebidas. 

El proceso en resumen:

| 1 | JupyterLabs > **exportar a HTML** local en mi Mac |
| 2 | JupyterLabs > **exportar archivos adicionales** referenciados desde el HTML |
| 3 | En el Mac > **"Chrome" > Imprimir a PDF con tamaño de papel personalizado** |
| 4 | En el Mac > Vista Previa > **Recortar el PDF** para eliminar la zona en blanco sobrante |

<br/>

### Paso 1 - Exportar a HTML. 

Aunque no es estrictamente necesario te recomiendo usar Chrome para este paso, en ciertos casos vas a tener que descargar varios archivos adicionales (imágenes) desde JupyterLabs y Chrome lo hace bastante cómodo. 

Desde Jupyter Labs vamos a **exportar el cuaderno a HTML**:

* File > "export notebook as HTML > `/Users/luis/Downloads`"

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-1.png" 
      caption="Exportar notebook como HTML" 
      width="500px"
      %}

<br/>

### Paso 2 - Exportar archivos adicionales (OPCIONAL)

Esto hazo solo si tu cuaderno referencia archivos adicionales como imágenes u otros HTML que por ejemplo contengan scripts. En mi cuaderno en cuestion uso un submódulo que crea debajo del directorio `figures` varios archivos `graph*.html` que contienen `javascript embebido` para mostrar los grafos. 

* Descargo los `graph*.html`. Entro en `figures`, seleccionar todos, Botón derecho > Download > `/Users/luis/Downloads`

* En local, en mi directorio `Downloads` creo un sub directorio `figures` y muevo los ficheros. 

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-3.png" 
      caption="Muevo los graph*.html a `figures`" 
      width="300px"
      %}

<br/>

### Paso 3 - Imprimir HTML local a PDF

Ya tengo el HTML en mi ordenador (junto con ficheros de apoyo). 

* Abro con **Chrome** (ahora sí que es importante usarlo), el archivo `Luis-Acertijo-Einstein.html`. Navego por el documento hasta el final (en mi caso obligatorio para que carge todos los scripts y salgan las imágenes en el PDF)

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-4.png" 
      caption="Abro el fichero en local" 
      width="500px"
      %}

| Nota: Al imprimir a PDF añade **saltos de página muy molestos**. El truco para quitarlos (algo que hago siempre) consiste en parametrizar un tamaño de papel muy largo, en el ejemplo **"portrait" con ancho 370mm por 4000mm de largo**. Quizá demasiado, pero queda bastante bien (en este cuaderno), en tu caso ajusta a lo que necesites. |


* Imprimo a PDF desde Chrome usando el `System’s Dialog`

  *	CMD-ALT-P: (o bien CMD-P > More Settings > Print Using System Dialog)
```config
	Show Details -> Pager Size > Manage Custom Sizes > Create new one with: 
		Paper Size: Width 370mm, Height 4000mm
		Non Printable: User Defined. Top, Left, Right, Bottom > all with 5mm
	Dejo el todo el resto por defecto: Orientation: Portrait. Copies: 1. Pages: All. Scale: 100%, ...
	
      PDF > Save as PDF
```

{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-5.jpg" 
      caption="Tamaño personalizado de papel" 
      width="730px"
      %}

<br/>

### Paso 4 - Recortar el PDF

Como decía, en el ejemplo he usado un tamaño de página **"portrait" 370mm ancho x 4000mm largo**, por lo que me va a sobrar al final mucho espacio en blanco. Bueno, pues aquí tienes el último truco para quitarlo. 

* Abro el PDF con Vista Previa (disponible en el Mac)
  * **Visualización > Una Página (CMD-2)**
  * **Herramientas > Selección Rectangular**
  * Selecciono el rectángulo que quiero que quede (excluyo zonas en blanco al final)
  * Selecciono **Herramientas > Recortar (CMD-K)**
  * Selecciono **Archivo > Guardar (CMD-S)**


{% include showImagen.html 
      src="/assets/img/posts/jupyterprint-6.jpg" 
      caption="Fichero PDF una vez recortado" 
      width="500px"
      %}


