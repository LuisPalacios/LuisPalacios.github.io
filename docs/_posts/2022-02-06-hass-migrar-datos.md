---
title: "HASS migrar Grafana e InfluxDB"
date: "2022-02-06"
categories: domótica
tags: linux homeassistant grafana influxdb
excerpt_separator: <!--more-->
---

![Logo Migrar](/assets/img/posts/logo-hass-out-grafana-influxdb.svg){: width="150px" style="float:left; padding-right:25px" } 

He **migrado los servicios InfluxDB/Grafana de mi Home Assistant a un servidor externo**. Sacar el servicio y montarlo en otro servidor no es demasiado difícil, lo que sí que me llevó un rato fue descubrir cómo exportar e importar los datos entre los InfluxDB y cómo adaptar el Dashboard antiguo de Grafana para que use `Flux`. 


<br clear="left"/>
<!--more-->


#### Instalar un nuevo servidor

Antes necesitas un servidor. En mi caso uso Linux y lo tengo documentado en el [apunte: Servidor Grafana, InfluxDB y Telegraf]({% post_url 2022-02-06-grafana-influxdb %}). Debe estar todo funcionando de forma independiente, InfluxDB, Grafana y Telegraf operativos, con un Bucket llamado `telegraf` y otro `home_assistant`, así será más fácil seguir esta guía sin fallos... 

<br/>

### Exportar/Importar datos InfluxDB


#### Conectar HA con el nuevo InfluxDB


- Averigua `Organization ID` del Bucket `home_assistant` en el nuevo InfluxDB: 

```
luis@almacenix:~$ influx bucket list
....    Organization ID		Schema Type
....    8970132987123409	implicit
:
```
- Ten a mano el resto de datos: `URL, token, nombre bucket`


Lo primero que vamos a hacer es que HA deje de guardar datos en su antiguo InfluxDB y pase a guardarlos en el nuevo InfluxDB.


- Modifica el `configuration.yaml`

```
:
influxdb:
  # New InfluxDB @ almacenix.parchis.org
  #
  api_version: 2
  ssl: false
  host: 192.168.100.241
  port: 8086
  token: nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123==
  bucket: home_assistant
  organization: 8970132987123409

  #
  # Old InfluxDB @ localhost
  #host: localhost
  #username: homeassistant
  #password: !secret influxdb_password

  max_retries: 3
  default_measurement: state
```

- Rearranca HA, el nuevo InfluxDB empieza a recibir datos. Puedes comprobarlo entrando en `http://tu-servidor:8086`, Explorar y compruebar el bucket "home_assistant". 

<br/>

#### Exportar datos antiguos

- Entro en modo debugging en el Linux que aloja a HASS OS ([más info](https://developers.home-assistant.io/docs/operating-system/debugging/#ssh-access-to-the-host), [otra referencia](https://developers.home-assistant.io/docs/operating-system/debugging/) y [otra referencia](https://github.com/home-assistant/operating-system/blob/rel-1/Documentation/configuration.md#automatic)

  - Formateo USB como FAT o EXT4 y muy importante, le pongo el nombre: "CONFIG"
  - Creo en su raiz un fichero "autorhized_keys" con mi clave pública
  - Inserto la usb en un puerto libre del servidor HA
  - De forma casi instantánea activa SSHD escuchando en el puerto 22222
  - Ejecuto desde un cliente donde tenga la clave privada:

```
ssh root@tu-servidor-hass -p 22222  (también ssh root@homeassistant.local -p 22222)
```

  - Una vez dentro del HASS OS, averiguo el nombre del container de InfluxDB y entro en una shell interactiva con él, exporto los datos y los saco de nuevo al Linux (host de HASS OS) y de ahí a mi Mac.

```
# docker ps -a
:
# docker exec -it addon_XXXXXXX_influxdb /bin/bash
:
root@XXXXXXX-influxdb:/# influx_inspect export -database home_assistant -datadir /data/influxdb/data -waldir /data/influxdb/wal -lponly -compress -out home_assistant.line.gz
:

root@XXXXXXX-influxdb:~# ls -al h*
-rw-r--r-- 1 root root 75503542 Feb  6 21:46 home_assistant.line.gz
root@XXXXXXX-influxdb:~# exit
:
# docker cp addon_XXXXXXX_influxdb:/root/home_assistant.line.gz /mnt/data/
# scp /mnt/data/home_assistant.line.gz luis@idefix.parchis.org:Desktop/
:
```

<br/>

#### Importar en el nuevo InfluxDB

Envío el fichero al nuevo servidor, lo descomprimo y cargo los datos en el Bucket `home_assistant`

```shell
~/Desktop > scp home_assistant.line.gz luis@almacenix.parchis.org:.

luis@almacenix:~$ gunzip home_assistant.line.gz

luis@almacenix:~$ influx write --bucket home_assistant --file ./home_assistant.line
```

<br/>

### Exportar/Importar dashboard Grafana

#### Exportar dashboard Grafana de Home Assistant

- HA > Grafana > "Tu Dashboard" > Share Dashboard > Export
	- Export for Sharing Externally (X)
	- Save to File (JSON)

<br/>

#### Importar en el nuevo servidor Grafana

- Seleccionar Tu Dashboard - xxxxxxxx.json”
  - Name: Tu Dashboard
  - Folder: General.
  - InfluxDB: **Flux home_assistant**  <== El nombre de tu conexión a InfluxDB

<br/>

#### Adaptar Grafana para que use `Flux`

El nuevo InfluxDB 2.x prefiere el uso de `Flux` antes que `InfluxQL`, tal como pasaba en la versión anterior 1.x (la utilizada en la versión embebida en HA).

Por desgracia Grafana no trae todavía una ayuda gráfica para escribir las queries en dicho lenguaje de Script. Dejo aquí múltiples ejemplos de queries que he utilizado con varios de mis sensores: 


<br/>

**Linux con Telegraf**

Ejemplo de networking:

```html
from(bucket: "telegraf")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["host"] == "cortafuegix")
  |> filter(fn: (r) => r._measurement == "net")
  |> filter(fn: (r) => r["interface"] == "ppp0")
  |> filter(fn: (r) => r._field == "bytes_recv" or r._field == "bytes_sent")
  |> aggregateWindow(every: v.windowPeriod, fn: last, createEmpty: false)
  |> derivative(unit: 1s, nonNegative: false)
  |> yield(name: "derivative")
```

Consumo de CPU total (todos los cores):

```html
data = from(bucket: "telegraf")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["host"] == "cortafuegix")
  |> filter(fn: (r) => r._measurement == "cpu")
  |> filter(fn: (r) => r._field == "usage_idle")
  |> filter(fn: (r) => r.cpu == "cpu-total")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> map(fn: (r) => ({ r with _value: (r._value * -1.0)+100.0 }))
  |> yield(name: "mean")

```

Ocupación del Disco:

```html
from(bucket: "telegraf")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["host"] == "cortafuegix")
  |> filter(fn: (r) => r["_measurement"] == "disk")
  |> filter(fn: (r) => r["_field"] == "used_percent")
  |> filter(fn: (r) => r["device"] == "vda4")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

Memoria:

```html
from(bucket: v.bucket)
  |> range(start: v.timeRangeStart)
  |> filter(fn: (r) => r["host"] == "cortafuegix")
  |> filter(fn: (r) => r._measurement == "mem")
  |> filter(fn: (r) => r._field == "used_percent" or r._field == "used")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

<br/>

**Sensores en home_assistant**

Estados:

```html
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "state")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "binary_sensor")
  |> filter(fn: (r) => r["entity_id"] == "cocina_puerta")
  |> yield()
```

Baterías:

```html
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solax_numserie_battery_power")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

Consumos de potencia:

```html
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "aerotermia_power")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")
```

Agregado temp media:

```
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "°C")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "buhardilla_sensor" 
                    or r["entity_id"] == "principal_sensor" 
                    or r["entity_id"] == "cuarto1_sensor" 
                    or r["entity_id"] == "cuarto2_sensor" 
                    or r["entity_id"] == "salon_sensor")
  |> drop(columns: ["entity_id"])
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> mean()
  |> yield(name: "mean")
```

----

<br/>





