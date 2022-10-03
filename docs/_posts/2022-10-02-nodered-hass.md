---
title: "Conectar HASS con Node-RED"
date: "2022-10-02"
categories: domótica
tags: linux homeassistant grafana flujos nodered iot influxdb solax solaxcloud docker
excerpt_separator: <!--more-->
---

![Logo nodered](/assets/img/posts/logo-nodered-hass.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte como conectar Node-RED y HASS cuando se ejecutan en instancias separadas. Tengo un servidor que ejecuta Home-Assistant y otro Node-red, están en máquinas virtuales separadas.  Lo bueno de esto es que cuando necesito reiniciar Home-Assistant no afecta a Node-RED y viceversa.

Aquí tienes cómo instalé mi [servicio Node-RED]({% post_url 2022-10-01-nodered-docker %}) utilizando Alpine y Docker por debajo, corriendo como máquina virtual sobre mi servidor KVM.

<br clear="left"/>
<!--more-->

### Configuración en HASS

Voy a suponer que tienes ambos instalados y que puedes acceder a sus respectivas interfaces web aunque estén en máquinas diferentes, o en lugares distintos, como es mi caso.

En Home Asssitant voy al icono de usuario en la parte inferior izquierda de la pantalla.

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-1.png" 
      caption="Parámetros de usuario" 
      width="200px"
      %}

A continuación, bajo al final de la página hasta llegar a los tokens de acceso de larga duración. Creo un token y coio el string que me presenta. IMPORTANTE: Copia el texto entero porque una vez creado la primera vez ya no será posible volver a enseñar la cadena de texto. Así que cópialo, ya que lo necesitaremos más adelante. Si te equivocas, no pasa nada, bórralo y crea otro. Puedes incluso generar un QR para imprimirlo y poder acceder en el futuro a la cadena de texto. Te muestro aquí un ejemplo de la secuencia

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-2.png" 
      caption="Creación del Token" 
      width="500px"
      %}


<br/>


### Configuración en Node-RED

A continuación me voy a mi instancia de Node-red y hago clic en el icono de la hamburguesa para que aparezca el menú desplegable. Selecciono Gestionar Paleta


{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-3.png" 
      caption="Opción Manage Palette" 
      width="250px"
      %}

Hago click en la pestaña "Instalar" y escribe "Home Assistant". Aparecen varios nodos diferentes. Me interesa el que se titula "node-red-contrib-home-assistant-websocket" (más información [aquí](https://flows.nodered.org/node/node-red-contrib-home-assistant-websocket))

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-4.png" 
      caption="Paleta Home-Assistant Node-RED" 
      width="400px"
      %}

Una vez que termina la instalación (tras unos instantes) verás que aparece una nueva paleta. Por cierto, si haces clic en la pestaña de la izquierda (Nodos) verás los que ya tienes instalados. Yo lo compruebo regularmente aquí porque a menudo habrá actualizaciones que hay que instalar manualmente

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-5.png" 
      caption="Nuevas paletas Home-Assistant" 
      width="150px"
      %}


Una vez que vemos la nueva paleta en la parte izquierda el siguiente paso consiste en **configurar la paleta para que se vincule a mi servidor Home Assistant**. Arrastre cualquier nodo de esta lista (por ejemplo `events: state`) y hago doble clic en él para configurarlo. Aquí tenemos que ir al campo "servidor" y añadir un servidor, o hacer clic en el icono del lápiz.

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-6.png" 
      caption="Edito el servidor Home-Assistant" 
      width="600px"
      %}


Añado la URL base (requiere http:// y el número de puerto), pego el Token que creé en Home-Assistant. Dejo el resto tal cual y pulso en ADD, DONE y DEPLOY. 


{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-7.png" 
      caption="Datos del servidor Home-Assistant" 
      width="500px"
      %}


Si todo ha ido bien debería ver un icono verde bajo el nodo de cambio de estado y si entro en el nodo y hago clic en el campo de la entidad veo una lista de mis entidades de mi HASS, que reconozco perfectamente... 

{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-8.png" 
      caption="Conexión activa" 
      width="300px"
      %}
{% include showImagen.html 
      src="/assets/img/posts/2022-10-02-nodered-hass-9.png" 
      caption="Acceso a las entidades de HASS" 
      width="500px"
      %}

A partir de aquí ya se pueden crear flujos dado que ambos están perfectamente conectados. De hecho podría conectar a varios servidores HASS si es que los tuviese. 

La ventaja de ejecutar Node-RED en un servidor independiente, como decía al principio, radica en separar modularmente los servicios. Ahora no hay dependencias entre ellos y podré ejecutar funciones de Domótica desde Node-RED independientemente de HASS.


---
