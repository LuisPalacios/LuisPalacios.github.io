---
title: "Home Assistant SolaX"
date: "2022-02-13"
categories: domótica
tags: linux homeassistant grafana influxdb solax solaxcloud
excerpt_separator: <!--more-->
---

![Logo Solax](/assets/img/posts/logo-hass-solax.svg){: width="150px" style="float:left; padding-right:25px" } 

Describo cómo he integrado en Home Assistant mi instalación Fotovoltaica con paneles Axitec, un Inversor SolaX y un par de baterías Triple Power. Tras probar varias opciones me he decantado por la **integración MODBUS/TCP** que trabaja en local, vía LAN y saca más datos que el resto de opciones.

<br clear="left"/>
<!--more-->


### Instalación

Mi instalación fotovoltaica consta de los siguientes componentes: 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-1.jpg" 
      caption="Arquitectura de Monitorización" 
      width="700px"
      %}


      - 1 x Inversor SolaX Híbrido X1-HYBRID-5.0T Gen-3
      - 23 x Módulos solar Axitec 280W 60 células policristalino
      - 1 x SolaX EPS Box
      - 1 x BMS para baterías Triple Power de SolaX T- BAT MC0500
      - 2 x Batería Triple Power T63 v2.0 SolaX 6,3kWh
      - 1 x Meter Chint DDSU 666
      - 1 x SolaX Pocket WiFi Dongle
  

Tenemos tres opciones de monitorización. 

1. SolaX Cloud (se actualiza automáticamente vía Dongle) y puede ser consultada a través de la App oficial de SolaX o a través de REST/API. 
2. Consulta directa en local al Pocket Wifi/LAN Dongle mediante REST/API.
3. Consulta directa a través de la LAN (puerto Ethernet) mediante MODBUS/TCP

<br/>

### 1. Monitorizar vía SolaX Cloud

Cuando terminan la instalación deben dejarte configurado el Dongle de modo que vaya guardando en la Cloud SolaX para que puedas consultarlas desde un navegador o una aplicación móvil. Las actualizaciones las hace cada 5 minutos. 

- Podemos usar un navegador o el App de SolaX para conectar con SolaX Cloud. En ambos casos estás accediendo a un servicio online con una ventana de 5-min, que aunque no es tiempo real, funciona bastante bien. 


{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-2.jpg" 
      caption="Opciones vía SolaxCloud" 
      width="700px"
      %}

- Puedes consultar a SolaX Cloud a través de REST/API y bajarte a local los datos.

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-3.jpg" 
      caption="Integración REST/API vía SolaxCloud" 
      width="500px"
      %}


**Integración con Home Assistant**

Nunca he integrado vía el REST/API de SolaxCloud, de hecho no lo recomiendo, es mucho mejor la opción de MODBUS que describo más adelante. No obstante, aquí tienes un par de enlaces: 

- Proyecto en GitHUb para hacer la **[SolaxCloud integration for Home Assistant](https://github.com/thomascys/solaxcloud)**.
- Un buen hilo de discusión [aquí](https://community.home-assistant.io/t/pv-solax-inverter-cloud-sensors-via-api/277874/65), encontrarás muchos comentarios sobre esta y otras opciones... 

<br/>

### 2. Monitorizar vía red local (WiFi/LAN Dongle)

En mi caso tengo el Dongle WiFi (de hecho intenté comprar el LAN sin éxito). La monitorización se consigue mediante consultas REST API directas al dongle.

<br/> 

**Integración con Home Assistant**

La integración con Home Assistant la tienes disponible en: **[// SolaX Power](https://www.home-assistant.io/integrations/solax/)**, implementa el **[🌞 Solax Inverter API Wrapper](https://github.com/squishykid/solax)** del mismo autor.

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-4.png" 
      caption="Integración Solax Power con Wifi Dongle" 
      width="400px"
      %}

Mis observaciones y algunos retos: 

- Lo he usado durante más de un año y funciona relativamente bien, sin demasiados problemas. Expone las métricas más habituales, aunque no todas. 
- El Dongle WiFi se conecta como cliente a tu red WiFi para llegar a SolaxCloud pero también expone una nueva red Wifi. 
- Mi primera sorpresa fue este nuevo SSID (WiFi_SWXXXXXXXX) **sin clave** donde usa una IP fija (5.8.8.8) y descubrir que solo escucha a las peticiones API REST por esta IP. 
  - Eso supone, en la mayoría de los casos, tener que montar un proxy en tu casa. Por ejemplo una raspberry conectada a tu LAN y a esta WiFi. Montar un `nginx` que haga de proxy. 
  - Por suerto encontré [este proyecto](https://blog.chrisoft.io/2021/02/14/firmwares-modificados-para-solax-pocket-wifi-v2/) donde puedes bajarte Firmwares modificados para Solax Pocket WIFI V2, que básicamente habilita el escuchar por la IP que recibe en tu casa. 
- Otro reto es su estabilidad, "a veces" dejaba de actualizar, sin motivo aparente. 
  - Se solucionaba desenchufando/enchufando el dongle (USB).
- El tercer reto es que la integración [Solax Power](https://www.home-assistant.io/integrations/solax/) solo funciona con la versión de firmware **V2.033.20**, por lo que no podía actualizar a su última versión **V2.034.06**


{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-5.png" 
      caption="Integración REST API vía red local" 
      width="500px"
      %}


<br/>

### 3. Monitorizar vía red local (MODBUS/TCP)

Consultar al Inversor mediante el protocolo MODBUS/TCP es la mejor opción. Por suerte mi inversor X1-HYBRID-G3 soporta recibir consultas por el puerto 502 (puerto de por defecto para el protocolo modbus/tcp). Necesitas poner un cable Ethernet en el puerto LAN de tu inversor conectado a la red local de tu casa. En mi caso le asigno una dirección IP fija desde mi DHCP server a través de su MAC.

<br/> 

**Integración con Home Assistant**

Existe una *Integración* muy buena, lee muchos más datos y con más frecuencia que el resto de opciones que he probado, [homsassistant-solax-modbus](https://github.com/wills106/homsassistant-solax-modbus). El autor,

- Publicó en este [hilo](https://community.home-assistant.io/t/solax-inverter-by-modbus-no-pocket-wifi-now-a-custom-component/140143/10) su trabajo, merece la pena recorrerlo. 
- Tiene otro repositorio, [Home Assistant Configuration](https://github.com/wills106/homeassistant-config) muy interesante. 


| Nota: En mi caso empecé con una versión antigua (instalación manual). Antes de instalar la última eliminé el directorio `/config/custom_components/solax_modbus` y borré la integración desde *Configuration > Integrations*, Tras el reboot de rigor pude  seguir con el siguiente punto. |

<br/>

**Instalación con HACS (0.4.5)**

Desde la versión 0.4.5 ya es posible hacer la instalación desde [HACS](https://hacs.xyz), el Community Store de Home Assistant.

- HACS > Integrations > Explore & Download Repositories > busco por "modbus"

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-6.png" 
      caption="Instalo Homsassistant Solax Modbus" 
      width="500px"
      %}

Selecciono la última versión


{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-7.png" 
      caption="Selecciono la última versión" 
      width="500px"
      %}


**Rearranco** Home Assistant desde Configuration > Settings > Restart

Entro en **Configuration** > **Device & Services** > **Add Integration** > **Setup a new Integration**, busco por `solax` y selecciono *SolaX Inverter Modbus*. La llamo `SolaXM`(la M la pongo por Modbus), pongo su IP, selecciono MI MODELO y establezco la frecuencia en 15s, más que suficiente... 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-10.jpg" 
      caption="Doy de alta la nueva integración" 
      width="600px"
      %}

Aparece ya en Configuration > Devices & Services > Integrations. Entro en el **device** la añado a Lovelace UI.

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-11.png" 
      caption="A partir de ahora ya podemos verlo en Lovelace" 
      width="800px"
      %}


<br/>

**Migración de 0.4.x a 0.5.3a**

Cuando se liberó la versión 0.5.x el autor recomendaba eliminar la integración (0.4.x) y volver a crearla con la nueva (0.5.x) **manteniendo el mismo nombre del dispositivo**, para que todo el resto de tu configuración se mantenga al instalar la nueva versión. 

- Confirmo el nombre de mi dispositivo, en mi caso le había puesto **`SolaXM`**
  - *Configuration > Devices & Services > SolaXM (SolaX Inverter Modbus) > "..." > Rename* 
- Elimino el dispositivo Solax modbus
  - *Configuration > Devices & Services > SolaXM (SolaX Inverter Modbus) > "..." > Delete*
- Rearranco HA
  - Configuration > Settings > Server Control > Home Assistant > Restart

- Elimino la integración Solax modbus en HACS
  - HACS > Integrations > SolaX Inverter Modbus > "..." > Remove
- Reinstalo la nueva versión 0.5.3a
  - HACS > Integrations > Explore & Download Repositories > busco por "modbus"
  - SolaX INverter Modbus > Download this repository > Selecciono la última (0.5.3a) > Download
- Rearranco Home Assistant
  - Configuration > Settings > Server Control > Home Assistant > Restart
- Doy de alta de nuevo el dispositivo
  - Configuration > Device & Services > Add Integration > Setup a new Integration
  - Busco por `solax` > *SolaX Inverter Modbus* > lo llamo **`SolaXM`** 
  - Pongo su IP y resto de parámetros. 

| Nota: En esta ocasión no necesito definir el modelo porque compartí el inicio de mi número de serie con el Autor (ver el link del hilo de desarrollo de arriba) para que lo detecte |

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-21.png" 
      caption="Nueva versión 0.5.3a" 
      width="600px"
      %}


<br/>


**Exportar los datos a InfluxDB**

Para exportar los datos voy a usar mi Servidor Externo con InfluxDB 2.x y Grafana ([un apunte sobre eso]({% post_url 2022-02-06-grafana-influxdb %})). Por cierto, lo migré de InfluxDB 1.x (embebido en HASS) a esta versión externa ([aquí los pasos]({% post_url 2022-02-06-hass-migrar-datos %})).

Configuro `/config/configuration.yaml` para mandar la información de mi Inversor al servidor InfluxDB. Si tu inversor es distinto tendrás datos parecidos pero no iguales.

```
:
influxdb:
  # New InfluxDB 2.x
  api_version: 2
  ssl: false
  host: 192.168.X.Y
  port: 8086
  token: EL-TOKEN-DE-MI-USUARIO (influxdb>LoadData>API Token)
  bucket: home_assistant
  organization: MI-ORGANIZATION-ID (influxdb>Icono Usuario>About)
  max_retries: 3
  default_measurement: state
  include:
    entities:
     :
      # Poner aquí los sensor.solaxm
      - sensor.solaxm_bms_connect_state
      - sensor.solaxm_backup_charge_end
      - sensor.solaxm_backup_charge_start
      - sensor.solaxm_backup_gridcharge
      - sensor.solaxm_battery_capacity
      - sensor.solaxm_battery_current_charge
      - sensor.solaxm_battery_input_energy_today
      - sensor.solaxm_battery_output_energy_today
      - sensor.solaxm_battery_power_charge
      - sensor.solaxm_battery_temperature
      - sensor.solaxm_battery_voltage_charge
      - sensor.solaxm_charger_end_time_1
      - sensor.solaxm_charger_end_time_2
      - sensor.solaxm_charger_start_time_1
      - sensor.solaxm_charger_start_time_2
      - sensor.solaxm_grid_export
      - sensor.solaxm_grid_import
      - sensor.solaxm_house_load
      - sensor.solaxm_inverter_current
      - sensor.solaxm_inverter_frequency
      - sensor.solaxm_inverter_power
      - sensor.solaxm_inverter_temperature
      - sensor.solaxm_inverter_voltage
      - sensor.solaxm_measured_power
      - sensor.solaxm_pv_current_1
      - sensor.solaxm_pv_current_2
      - sensor.solaxm_pv_power_1
      - sensor.solaxm_pv_power_2
      - sensor.solaxm_pv_total_power
      - sensor.solaxm_pv_voltage_1
      - sensor.solaxm_pv_voltage_2
      - sensor.solaxm_run_mode
      - sensor.solaxm_today_s_export_energy
      - sensor.solaxm_today_s_import_energy
      - sensor.solaxm_today_s_solar_energy
      - sensor.solaxm_today_s_yield 
```

<br/>

**Configuración de Grafana para visualizar los consumos**

El siguiente paso es configurar un Dashboard en Grafana para representar algunos de esos datos. 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-12.png" 
      caption="Ejemplo de configuración en Grafana" 
      width="800px"
      %}

Te dejo aquí las Query's con el nuevo Flux Script... 

```
// 🏠 Consumo total casa 
// vía Solax Modbus 
//
from(bucket: "home_assistant")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "W")
|> filter(fn: (r) => r["_field"] == "value")
|> filter(fn: (r) => r["domain"] == "sensor")
|> filter(fn: (r) => r["entity_id"] == "solaxm_house_load")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")

// 🔌 Consumo Iberdrola
// vía Solax Modbus 
//
from(bucket: "home_assistant")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "W")
|> filter(fn: (r) => r["_field"] == "value")
|> filter(fn: (r) => r["domain"] == "sensor")
|> filter(fn: (r) => r["entity_id"] == "solaxm_grid_import")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> map(fn: (r) => ({ r with _value: (r._value * -1.0) }))
|> yield(name: "mean")

// 🌞 Prod. Fotovoltaica 1&2
// Potencia (W) total generada por los Paneles:
// vía SolaX Modbus
//
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solaxm_pv_power_1" or r["entity_id"] == "solaxm_pv_power_2")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")

// Baterías: ➕⚡️Carga   /  ➖🔋 Descarga
// Carga y Consumo de las baterías
// vía SolaX Modbus
//
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solaxm_battery_power_charge")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")

// 🔩 Prod. hacia Casa/Red
// Inversor: Potencia en Watios AC que entrega el Inversor 
// desde los paneles FV hacia la casa (para cubrir la demanda solicitada)
// vía SolaX Modbus
//
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solaxm_inverter_power")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

<br/>

**Temas Pendientes**

- Tengo pendiente de estudio la [configuración que utiliza el autor de la Integración](https://github.com/wills106/homeassistant-config/blob/master/packages/solax_x1_hybrid_g3_triplepower.yaml). 

- Tengo pendiente ver qué otras opciones son interesantes para monitorizar, además de investigar la posibilidad de programar el Inversor desde Home Assistant, aunque eso me da bastante respeto de momento... 


<br/>

### Integración con Energy Dashboard

Con la versión 2021.8 Home Assistant liberó el Tablero de control de la energía

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-13.png" 
      caption="Ejemplo de configuración en Grafana" 
      width="250px"
      %}


Su objetivo es facilitar a los usuarios el conocimiento de su consumo energético, permite ver de un vistazo rápido cómo lo estás haciendo hoy, con la opción de desglosar también por horas para ver qué ha pasado . También incluye indicadores que ayudan a identificar tu dependencia de la red y si añadir almacenamiento de energía ayudaría. 

Existe una forma de compatibilizar los datos de esta integración para que me aparezcan en dicho Dashboard... 

<br/>

#### Configuración inicial. 

En este [enlace](https://www.home-assistant.io/blog/2021/08/04/home-energy-management/) está la documentación para configurar la pantalla de Energía. 

| Nota: Si ya has hecho una configuración y no consigues editarla desde el Dashboard `Energy` es porque solo puedes editarla desde **Configuration > Dashboard > Energy**. Por cierto, a nivel informativo, la configuración se guarda en el fichero: `config/.storage/energy` |


{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-14.png" 
      caption="Configuration > Dashboard > Energy" 
      width="600px"
      %}

{% include showImagen2.html 
      src="/assets/img/posts/2022-02-13-hass-solax-16.jpg" 
      src2="/assets/img/posts/2022-02-13-hass-solax-17.jpg" 
      caption="Detalle de los datos configurados, click para ampliar" 
      width="250px"
      %}

| Nota1: Para el CO2 Signal basta con visitar el sitio y darse de alta, te envía tu token |

| Nota2: En la ventana donde defino el grid consumption (SolaXM Today's Import Energy) he añadido un entity que hace el tracking the los costes totales, pero es una prueba, no hace falta ponerlo |

El resultado final es el Dashboard de Energía 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-15.png" 
      caption="Dashboard de Energía integrado en HA" 
      width="800px"
      %}


Comparación con lo que vemos en un Dashboard Grafana personalizado... 

{% include showImagen.html 
      src="/assets/img/posts/2022-02-13-hass-solax-20.png" 
      caption="Detalle de consumos en un Dashboard Grafana" 
      width="800px"
      %}

<br/>
