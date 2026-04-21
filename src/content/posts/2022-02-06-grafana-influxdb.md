---
title: "Servidor Grafana, InfluxDB y Telegraf"
date: "2022-02-06"
categories: ["domótica"]
tags: ["linux","homeassistant","grafana","influxdb"]
draft: false
cover:
  image: "/img/posts/logo-grafana-influxdb.svg"
  hidden: true
---

<img src="/img/posts/logo-grafana-influxdb.svg" alt="Logo Grafana e InfluxDB" width="150px" style="float:left; padding-right:25px"  />

Monto estos tres servicios en un servidor dedicado en mi casa para poder monitorizar la Domótica. InfluxDB es una base de datos super optimizada para trabajar con series de tiempo. Grafana permite crear cuadros de mando y gráficos a partir de múltiples fuentes y Telegraf es un agente ligero que permite recolectar, procesar y enviar datos a nuestra base de datos.

He decidido instalar los tres en un servidor Ubuntu 20.04 LTS, sobre máquina virtual en KVM, de modo que son consumidos por el resto de elementos de la Domótica: servidor Home Assistant y resto de `cacharros` que puedan escribir en InfluxDB.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-06.jpg" alt="Arquitectura de Monitorización" width="500px" />
  <div class="image-caption">Arquitectura de Monitorización</div>
</div>

| Nota: Antes tenía Grafana/InfluxDB "dentro" de Home Assistant OS. Una vez que terminé la instalación pasé a [migrar los datos de InfluxDB y los dashboards Grafana]({{< relref "2022-02-06-hass-migrar-datos.md" >}}) |

<br/>

### Instalación del Servidor Linux

Instalo Ubuntu en una máquina virtual corriendo en KVM. He seguido la documentación oficial, [Insalación de Ubuntu](https://ubuntu.com/server/docs/installation) y la siguiente imagen ISO:

```shell
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso
```

Desde mi servidor con KVM lanzo `virt-manager` → Nueva máquina virtual, uso el ISO anterior y llamo al servidor `almacenix.tudominio.com` (el dominio es privado, servido por mi [propio DNS Server]({{< relref "2021-06-20-pihole-casero.md" >}}))

<br/>

### Instalar el Servidor Influxdb OSS

Una vez que tengo el Linux operativo uso la documentación de referencia [de InfluxDB 2.1](https://docs.influxdata.com/influxdb/v2.1/install/?t=Linux), con las descargas [aquí](https://portal.influxdata.com/downloads/) y realizo la instalación.

```shell
wget -qO- https://repos.influxdata.com/influxdb.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdb.gpg > /dev/null
export DISTRIB_ID=$(lsb_release -si); export DISTRIB_CODENAME=$(lsb_release -sc)
echo "deb [signed-by=/etc/apt/trusted.gpg.d/influxdb.gpg] https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list > /dev/null
apt update && apt upgrade -y
apt full-upgrade -y
apt autoremove -y
apt clean
journalctl --vacuum-time=2d
journalctl --vacuum-size=500M
systemctl reboot -f
```

- Verifico que se va a instalar la versión correcta:

```shell
apt-cache policy influxdb2
influxdb2:
  Instalados: (ninguno)
  Candidato:  2.1.1
  Tabla de versión:
     2.1.1 500
        500 https://repos.influxdata.com/ubuntu focal/stable amd64 Packages
apt install influxdb2
```

- Para que no reporte nada "ni llame a casa", edito `/usr/lib/influxdb/scripts/influxd-systemd-start.sh`

```shell
/usr/bin/influxd --reporting-disabled &
```

- Modifico `/etc/influxdb/config.toml` para que escuche en cualquier IP, que pueda ser accesible desde la LAN casera.

```shell
bolt-path = "/var/lib/influxdb/influxd.bolt"
engine-path = "/var/lib/influxdb/engine"
http-bind-address = "0.0.0.0:8086"
```

- Rearranco el servicio

```shell
systemctl restart influxdb
```

<br/>

#### Administración de InfluxDB

- Conecto con [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086) <-- Pon aquí tu nombre/dirección.
- Creo mi usuario (luis), establezco la contraseña y llamo a la Organización "tudominio.com" (puede ser cualquiera)
- Configuro y me guardo el `API Token` de mi usuario.

- Está en Data -> API Tokens -> luis Token - Será del tipo:

```shell
nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123==
```

| Nota: Cualquier cliente que quiera Leer o Escribir en mi InfluxDB va a necesitar conocer la URL del servidor, el nombre de la Organización, el nombre del "Bucket" (Base de datos) y el API Token ! |

- Instalo el cliente CLI de Influx

```shell
wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.2.0-linux-amd64.tar.gz
tar xvzf influxdb2-client-2.2.0-linux-amd64.tar.gz
mv influxdb2-client-2.2.0-linux-amd64/influx /usr/local/bin
```

- Configuro el cliente para que no me pregunte el token cada vez que lo use:

```shell

luis@almacenix:~$ influx version
Influx CLI 2.2.0 (git: c3690d8) build_date: 2021-10-21T15:24:59Z

luis@almacenix:~$ influx config create --config-name influxdb-almacenix  --host-url http://<tu-url>:8086 --org <tu org>  --token <tu token> --active

luis@almacenix:~$ cat .influxdbv2/configs
[influxdb-almacenix]
  url = "http://almacenix.tudominio.com:8086"
  token = "nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123=="
  org = "tudominio.com"
  active = true

Prueba de concepto
luis@almacenix:~$ influx user list
ID   Name
08e1234567892000 luis
```

- Configuro el cliente InfluxDB en mi MacOS.

```shell
$ brew update
$ brew install influxdb
$ influx config create --config-name influxdb-almacenix  --host-url http://<tu-url>:8086 --org <tu org>  --token <tu token> --active

Prueba de concepto
$ influx user list
ID   Name
08e1234567892000 luis
```

<br/>

#### Creo mis Bases de datos

Voy a usar este servidor para recibir datos desde clientes Telegraf y desde Home Assistant, así que creo un par de Buckets.

- `telegraf`, con retention `never o infinita`
- `home_assistant`, con retention `never o infinita`

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-07.png" alt="Bases de datos iniciales" width="500px" />
  <div class="image-caption">Bases de datos iniciales</div>
</div>

| Nota: Uso el mismo nombre (`home_assistant`) que el que se usa en el InfluxDB de Home Assistant para facilitar la migración posterior, documentada [en este apunte]({{< relref "2022-02-06-hass-migrar-datos.md" >}}). |

<br/>

#### Instalación del cliente Telegraf en Linux Ubuntu/Debian/Raspbian

Repito lo siguiente en varios equipos Linux, empezando por `almacenix`. Parto de la guía de la versión 2.1

- Referencia: [Use Telegraf to write data](https://docs.influxdata.com/influxdb/v2.1/write-data/no-code/use-telegraf/)
- Referencia: [Install Telegraf](https://docs.influxdata.com/telegraf/v1.21/introduction/installation/)

```shell
root@almacenix:~# apt-cache policy telegraf
telegraf:
  Instalados: (ninguno)
  Candidato:  1.21.3-1
  Tabla de versión:
     1.21.3-1 500
        500 https://repos.influxdata.com/ubuntu focal/stable amd64 Packages
root@almacenix:~# apt install telegraf

systemctl stop telegraf

```

- Desde InfluxDB [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086)
- Data > Buckets > Create Bucket > ‘telegraf’, retention ‘never’
- Data > Telegraf > Create Configuration > Bucket ‘telegraf’ > System > Continue >
  - Create and verify.
- Copio el Token y el URL para leer la configuración desde el propio servidor InfluxDB
- La configuración está en Data>Telegraf>Telegraf Alamcenix>Download

Me creo una versión personalizada del telegraf.service, lo modifico y arranco el servicio

```shell
cp /lib/systemd/system/telegraf.service /etc/systemd/system/
nano telegraf.service
   ExecStart=/usr/bin/telegraf --config http://almacenix.tudominio.com:8086/api/v2/telegrafs/XXXXXXXX $TELEGRAF_OPTS
systemctl daemon-reload
nano /etc/defaults/telegraf
  INFLUX_TOKEN=XXXXXXXXX==
systemctl daemon-reload
systemctl start telegraf
```

<br/>

#### Instalación del cliente Telegraf en Linux Gentoo

Tengo un par de routers basados en Gentoo, importante que Layman esté montando antes de hacer lo siguiente. Telegraf no está en el tree de portage, emerge desde overlay:

```shell
Aquí hay un tipo que lo mantiene… como overlay
    - https://github.com/aexoden/gentoo-overlay

Creo /etc/portage/repos.conf/gentoo-aexoden.conf
[gentoo-extras-overlay]
location = /var/db/repos/gentoo-extras-overlay
sync-type = git
sync-uri = https://github.com/aexoden/gentoo-overlay.git
clone-depth = 0
auto-sync = yes

emerge --sync
cat >> /etc/portage/package.accept_keywords
net-analyzer/telegraf ~amd64

emerge -v telegraf
```

- Desde InfluxDB [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086)
- Data > Telegraf > Create Configuration > Bucket ‘telegraf’ > System > Continue >
- Create and verify.
- Copio el Token y el URL
- La configuración está en Data>Telegraf>Telegraf Alamcenix>Download

Me creo una versión personalizada del telegraf.service, lo modifico y arranco el servicio

```shell
cp /lib/systemd/system/telegraf.service /etc/systemd/system/
nano telegraf.service
 EnvironmentFile=-/etc/conf.d/telegraf
 ExecStart=/usr/bin/telegraf --config http://almacenix.tudominio.com:8086/api/v2/telegrafs/XXXXXXXXX $TELEGRAF_OPTS
systemctl daemon-reload
nano /etc/conf.d/telegraf
 INFLUX_TOKEN=XXXXXXX==
systemctl daemon-reload
systemctl start telegraf
```

<br/>

### Instalar el Servidor Grafana OSS

- Sigo la guía [Install on Debian or Ubuntu](https://grafana.com/docs/grafana/latest/installation/debian/)

```shell
apt install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt update
apt install grafana
systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server
systemctl enable grafana-server
```

<br/>

#### Configurar Grafana

Desde un navegador conecto con el nuevo servidor grafana y realizo la primera configuración.

- Conecto con <http://almacenix.tudominio.com:3000> —> admin, admin (cambio la contraseña)

- Conecto con mis dos Bucket's en InfluxDB (`telegraf` y `home_assistant`)

```shell
Data Sources -> Add data source

Name: Flux telegraf
 Query Language: Flux
 URL: http://127.0.0.1:8086
 Access: Server
 Auth: Todo desactivado
 InfluxDB Details:
    Organization: tudominio.com (la tuya)
    Token: <El que pusiste con tu usuario principal>
    Default Bucket: telegraf
 SAVE & TEST -> Ok

Data Sources -> Add data source

Name: Flux home_assistant
 Query Language: Flux
 URL: http://127.0.0.1:8086
 Access: Server
 Auth: Todo desactivado
 InfluxDB Details:
    Organization: tudominio.com (la tuya)
    Token: <El que pusiste con tu usuario principal>
    Default Bucket: home_assistant
 SAVE & TEST -> Ok
```

- El lenguaje **recomendado** para interrogar a InfluxDB 2.x es `Flux` a diferencia de `InfluxQL` (versiones 1.x). Es un lenguaje de script que permite hacer consultas mucho más complejas, programación avanzada, etc. Se aleja bastante del conocido SQL, así que cuesta al princpio, mira un ejemplo (tienes más en el [apunte de la migración]({{< relref "2022-02-06-hass-migrar-datos.md" >}}))

- Panel para medir el tráfico de red de un cliente Telegraf (uno de mis equipos Linux):

```
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

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-02.png" alt="Ejemplo de configuración con Flux." width="800px" />
  <div class="image-caption">Ejemplo de configuración con Flux.</div>
</div>

<br/>

#### Tips para Grafana

**Mostrar una imagen en un panel de Grafana**

- Copia la imagen en root@tu_servidor:/usr/share/grafana/public/img/
- Referencia el fichero desde un **Panel de tipo Text** con contenido **HTML/MD**, en mi caso uso HTML para centrarlo:

```
<center>
<img src="/public/img/logo-linux-router.svg" alt="logo-linux-router.svg" width="64"/>
cortafuegix
</center>
```

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-05.png" alt="Ejemplo de imagen en un panel de texto." width="400px" />
  <div class="image-caption">Ejemplo de imagen en un panel de texto.</div>
</div>

<br/>

**Compartir Dashboard con un Home Assistant remoto**

Me gusta ver los dashboards de Grafana desde Home Assistant lo más integrados posible:

- Configuro autenticación anónima y poder trabajar con iFrames modificando el fichero `/etc/grafana/grafana.ini`:

```yaml
[auth.anonymous]
enabled = true
org_name = tudominio.com
org_role = Viewer
hide_version = true

[security]
cookie_samesite = none
allow_embedding = true
```

- Rearranco el servidor Grafana:

```
root@almacenix:~# systemctl restart grafana-server.service
```

- A continuación me aseguro de que coincida el `org_name` (`grafana.ini`) con el nombre de la Organización, entro en la administración de Grafana vía Web y me aseguro de que coincidan:

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-01.png" alt="org_name y el nombre de la organización del Dashboard deben coincidir" width="800px" />
  <div class="image-caption">org_name y el nombre de la organización del Dashboard deben coincidir</div>
</div>

- Por último ya solo nos queda copiar el link directo al Dashboard.
  - Desde Grafana->Dasboard->Abre el dashboard->Click en el icono de Compartir !!
  - Copiar la URL

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-03.png" alt="Copia la URL para acceder remotamente al Dashboard" width="500px" />
  <div class="image-caption">Copia la URL para acceder remotamente al Dashboard</div>
</div>

- En el Home Assistant
  - En un Dashboard existente o creando uno desde Configuración->Dashboards.
  - Edit Dashboard
  - Add view, poner nombre, Save y Add Card, tipo **iFrame (Web page Card)**
  - Entrar en Code Editor y poner lo siguiente, editando a gusto (cambiar la URL por la tuya

```
type: iframe
url: >-
  http://almacenix.tudominio.com:3000/d/123456-nk/servidores?orgId=1&from=now/d&to=now&kiosk=tv&refresh=5s
aspect_ratio: 70%
```

- Save
- Editar el View de nuevo (no la Card) y en View Type pon "Panel (1 card)

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-04.png" alt="Dashboard Grafana externo integrado en Home Assistant" width="800px" />
  <div class="image-caption">Dashboard Grafana externo integrado en Home Assistant</div>
</div>

<br/>

Recuerda aquí tienes un apunte sobre como [migrar los datos de InfluxDB y los dashboards Grafana]({{< relref "2022-02-06-hass-migrar-datos.md" >}}) desde Home Assistant a un servidor nuevo como el que acabamos de configurar.

<br/>

#### Tips para InfluxDB

<br/>

**Exportar todos los datos de un bucket**

Quería ver cómo se estaban guardando los datos de `Telegraf` así que los saqué de influx para verlos 🤗

```
luis@almacenix:~$ influx bucket list
ID   Name  Retention Shard group duration Organization ID  Schema Type
:
1234584375938475 telegraf infinite 168h0m0s  8975ef952db592e6 implicit
:
luis@almacenix:~$ sudo influxd inspect export-lp --bucket-id 1234584375938475 --engine-path /var/lib/influxdb/engine --output-path /home/luis/telegraf.lp
:
luis@almacenix:~$ more telegraf.lp
cpu,cpu=cpu-total,host=almacenix usage_guest=0 1644238720000000000
cpu,cpu=cpu-total,host=almacenix usage_guest=0 1644238730000000000
cpu,cpu=cpu-total,host=almacenix usage_guest=0 1644238740000000000
cpu,cpu=cpu-total,host=almacenix usage_guest=0 1644238750000000000
:
```

<br/>

**Borrar datos específicos**

Durante pruebas con Plugins de Telegraf generé muchos datos que más tarde quise borrar, aquí dejo algunos ejemplos:

- Borrar todo lo que he guardado con el `_measurement="temporal_size"` entre dos timestamps concretos

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-15T17:00:00Z' --stop '2022-02-15T23:00:00Z' --predicate '_measurement="temporal_size"'
```

<br/>

- Repito pero pongo "ahora mismo" como fecha de fin.

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-16T14:00:00Z' --stop $(date +"%Y-%m-%dT%H:%M:%SZ") --predicate '_measurement="temporal_size"'
```

<br/>

- Borra el `_measurement="temporal_size"` por completo, algunas pruebas se guardaron con fechas en el pasado así que establezco que lo borre entero, desde el inicio de los tiempos (digitales) hasta ahora mismo...

```
luis@almacenix:~$ influx delete --bucket telegraf --start '1970-01-01T00:00:00Z' --stop $(date +"%Y-%m-%dT%H:%M:%SZ") --predicate '_measurement="temporal_size"'
```

<br/>

- El último ejemplo, hice pruebas con el plugin `inputs.influxdb` que me llenó el bucket de Telegraf de un montón de `_measurement's` (decenas) que luego no me servían para nada. Aprovheché que *todos los data points* venían con un tag llamado `url`.

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-15T01:00:00Z' --stop '2022-02-16T23:00:00Z' --predicate 'url="http://localhost:8086/metrics"'
```

<br/>

### Tips para Telegraf

**Monitorizar el tamaño de los buckets de un Servidor InfluxDB**

- El objetivo es averiguar el tamaño de los buckets de un servidor InfluxDB, por ejemplo para observar si crecen mucho y nos quedamos sin espacio. Como siempre se puede observar todo desde Grafana

- Gist: [Script compatible con formato *influx* para el Plugin **input.exec**](https://gist.github.com/LuisPalacios/9597178db4c4c4b357dd0700d61c1835) para averiguar el tamaño de los buckets de un servidor InfluxDB.

<br/>

**Monitorizar el tamaño de los discos QCOW2 de un Host QEMU/KVM**

- El objetivo es que podamos ver el tamaño de los discos QCOW2 de un linux Host con QEMU/KVM.

- Gist: [Script compatible con formato *influx* para el Plugin **input.exec**](https://gist.github.com/LuisPalacios/e130f8200132a86a32dafbf2bfd0d1fb) para averiguar la ocupación de los discos QCOW2.

----

<br/>
