---
title: "Conectar HASS con Node-RED"
date: "2022-10-02"
categories: ["domótica"]
tags: ["linux","homeassistant","grafana","flujos","nodered","iot","influxdb","solax","solaxcloud","docker"]
draft: false
cover:
  image: "/img/posts/logo-nodered-hass.svg"
  hidden: true
---

<img src="/img/posts/logo-nodered-hass.svg" alt="Logo nodered" width="150px" style="float:left; padding-right:25px"  />

Explico como he conectado Node-RED con mi Home Assistant (HASS), teniendo en cuenta que se ejecutan en servidores independientes. Están desplegados en máquinas virtuales distintas, para poder realizar mantenimientos de forma independiente y mejorar su rendimiento.

Para tu información he creado otro apunte [aquí]({{< relref "2022-10-01-nodered-docker.md" >}}) donde describo la instalación de Node-RED utilizando Alpine y Docker por debajo, corriendo como máquina virtual sobre mi servidor KVM.

<br clear="left"/>
<!--more-->

### Configuración en Home Assistant

Voy a suponer que tienes ambos instalados y que puedes acceder a sus respectivas interfaces web aunque estén en máquinas diferentes, o en lugares distintos, como es mi caso. Para conectar ambos vamos a empezar por Home Assistant.

En la pantala de administración voy al icono de usuario en la parte inferior izquierda de la pantalla.

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-03.png" alt="Parámetros de usuario" width="200px" />
  <div class="image-caption">Parámetros de usuario</div>
</div>

A continuación, bajo al final de la página hasta llegar a los tokens de acceso de larga duración. Creo un token y copio el string que me presenta. IMPORTANTE: Copia el texto entero porque una vez creado la primera vez ya no será posible volver a enseñar la cadena de texto. Así que cópialo, ya que lo necesitaremos más adelante. Si te equivocas, no pasa nada, bórralo y crea otro. Puedes incluso generar un QR para imprimirlo y poder acceder en el futuro a la cadena de texto. Te muestro aquí un ejemplo de la secuencia

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-04.png" alt="Creación del Token" width="500px" />
  <div class="image-caption">Creación del Token</div>
</div>

<br/>

### Configuración en Node-RED

A continuación me voy a mi instancia de Node-red y hago clic en el icono de la hamburguesa para que aparezca el menú desplegable. Selecciono Gestionar Paleta

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-05.png" alt="Opción Manage Palette" width="250px" />
  <div class="image-caption">Opción Manage Palette</div>
</div>

Hago click en la pestaña "Instalar" y escribe "Home Assistant". Aparecen varios nodos diferentes. Me interesa el que se titula "node-red-contrib-home-assistant-websocket" (más información [aquí](https://flows.nodered.org/node/node-red-contrib-home-assistant-websocket))

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-06.png" alt="Paleta Home-Assistant Node-RED" width="400px" />
  <div class="image-caption">Paleta Home-Assistant Node-RED</div>
</div>

Una vez que termina la instalación (tras unos instantes) verás que aparece una nueva paleta. Por cierto, si haces clic en la pestaña de la izquierda (Nodos) verás los que ya tienes instalados. Yo lo compruebo regularmente aquí porque a menudo habrá actualizaciones que hay que instalar manualmente

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-07.png" alt="Nuevas paletas Home-Assistant" width="150px" />
  <div class="image-caption">Nuevas paletas Home-Assistant</div>
</div>

Una vez que vemos la nueva paleta en la parte izquierda el siguiente paso consiste en **configurar la paleta para que se vincule a mi servidor Home Assistant**. Arrastre cualquier nodo de esta lista (por ejemplo `events: state`) y hago doble clic en él para configurarlo. Aquí tenemos que ir al campo "servidor" y añadir un servidor, o hacer clic en el icono del lápiz.

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-08.png" alt="Edito el servidor Home-Assistant" width="600px" />
  <div class="image-caption">Edito el servidor Home-Assistant</div>
</div>

Añado la URL base (requiere http:// y el número de puerto), pego el Token que creé en Home-Assistant. Dejo el resto tal cual y pulso en ADD, DONE y DEPLOY.

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-09.png" alt="Datos del servidor Home-Assistant" width="500px" />
  <div class="image-caption">Datos del servidor Home-Assistant</div>
</div>

Si todo ha ido bien debería ver un icono verde bajo el nodo de cambio de estado y si entro en el nodo y hago clic en el campo de la entidad veo una lista de mis entidades de mi Home Assistant, que reconozco perfectamente...

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-10.png" alt="Conexión activa" width="300px" />
  <div class="image-caption">Conexión activa</div>
</div>
<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-11.png" alt="Acceso a las entidades de HASS" width="500px" />
  <div class="image-caption">Acceso a las entidades de HASS</div>
</div>

A partir de aquí ya se pueden crear flujos dado que ambos están perfectamente conectados. De hecho podría conectar a varios servidores Home Assistant si es que los tuviese.

La ventaja de ejecutar Node-RED en un servidor independiente, como decía al principio, radica en separar modularmente los servicios. Ahora no hay dependencias entre ellos y podré ejecutar funciones de Domótica desde Node-RED independientemente de Home Assistant.

<br/>

### Apple HomeKit

Ahora que tenemos Node-RED instalado podemos añadir otros nodos adicionales desde la librería, como HomeKit.He instalado el proyecto [node-red-contrib-homekit-bridged](https://flows.nodered.org/node/node-red-contrib-homekit-bridged), que integra HomeKit con Node-RED. Ya se que podría haberlo integrado directamente con HASS, pero prefiero tener a Node-RED como intermediario entre ambos (HASS y HomeKit).

- Desde el menú de Node-RED (arriba a la derecha) en el interfaz web -> `Manage Palette` -> `Install`, buscar e instalar `node-red-contrib-homekit-bridged`.

<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-01.png" alt="Instalación de node-red-contrib-homekit-bridged" width="500px" />
  <div class="image-caption">Instalación de node-red-contrib-homekit-bridged</div>
</div>
* Se instalan los nodos siguientes:
<div class="image-box">
  <img src="/img/posts/2022-10-02-nodered-hass-02.png" alt="Nodos instalados" width="250px" />
  <div class="image-caption">Nodos instalados</div>
</div>

Un par de enlaces para hacer flujos con este nodo:

- [Ejemplos](https://nrchkb.github.io/wiki/examples/). Se pueden importar desde la "hamburguesa" de Node-RED.
- [Documentación](https://nrchkb.github.io/wiki/introduction/quick-start/), información sobre cómo trabaja y ejemplos.

---
