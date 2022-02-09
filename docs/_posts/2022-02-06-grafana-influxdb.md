---
title: "Servidor Grafana, InfluxDB y Telegraf"
date: "2022-02-06"
categories: domótica
tags: linux homeassistant grafana influxdb
excerpt_separator: <!--more-->
---

![Logo Grafana](/assets/img/posts/logo-grafana-influxdb.svg){: width="150px" style="float:left; padding-right:25px" } 

Monto estos tres servicios en un servidor dedicado en mi casa para poder monitorizar la Domótica. InfluxDB es una base de datos super optimizada para trabajar con series de tiempo. Grafana permite crear cuadros de mando y gráficos a partir de múltiples fuentes y Telegraf es un agente ligero que permite recolectar, procesar y enviar datos a nuestra base de datos. 

He decidido instalar los tres en un servidor Ubuntu 20.04 LTS, sobre máquina virtual en KVM, de modo que son consumidos por el resto de elementos de la Domótica: servidor Home Assistant y resto de `cacharros` que puedan escribir en InfluxDB.

<br clear="left"/>
<!--more-->

{% include showImagen.html 
      src="/assets/img/posts/hass-monitoring.jpg" 
      caption="Arquitectura de Monitorización" 
      width="500px"
      %}

| Nota: Antes tenía Grafana/InfluxDB "dentro" de Home Assistant OS. Una vez que terminé la instalación pasé a [migrar los datos de InfluxDB y los dashboards Grafana]({% post_url 2022-02-06-hass-migrar-datos %}) |

<br/>


### Instalación del Servidor Linux

Instalo Ubuntu en una máquina virtual corriendo en KVM. He seguido la documentación oficial, [Insalación de Ubuntu](https://ubuntu.com/server/docs/installation) y la siguiente imagen ISO:   
```shell
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso
```
Desde mi servidor con KVM lanzo `virt-manager` → Nueva máquina virtual, uso el ISO anterior y llamo al servidor `almacenix.parchis.org` (el dominio es privado, servido por mi propio DNS Server)

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

- Conecto con [http://almacenix.parchis.org:8086](http://almacenix.parchis.org:8086) <-- Pon aquí tu nombre/dirección. 
- Creo mi usuario (luis), establezco la contraseña y llamo a la Organización "parchis.org" (puede ser cualquiera)
- Configuro y me guardo el `API Token` de mi usuario. 

* Está en Data -> API Tokens -> luis Token - Será del tipo:
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
  url = "http://almacenix.parchis.org:8086"
  token = "nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123=="
  org = "parchis.org"
  active = true

Prueba de concepto
luis@almacenix:~$ influx user list
ID			Name
08e1234567892000	luis
```

- Configuro el cliente InfluxDB en mi MacOS.

```shell
$ brew update
$ brew install influxdb
$ influx config create --config-name influxdb-almacenix  --host-url http://<tu-url>:8086 --org <tu org>  --token <tu token> --active

Prueba de concepto
$ influx user list 
ID			Name
08e1234567892000	luis
```

<br/>

#### Creo mis Bases de datos

Voy a usar este servidor para recibir datos desde clientes Telegraf y desde Home Assistant, así que creo un par de Buckets. 

- `telegraf`, con retention `never o infinita`
- `home_assistant`, con retention `never o infinita`

{% include showImagen.html 
      src="/assets/img/posts/influxdb-buckets.png" 
      caption="Bases de datos iniciales" 
      width="500px"
      %}

| Nota: Uso el mismo nombre (`home_assistant`) que el que se usa en el InfluxDB de Home Assistant para facilitar la migración posterior, documentada [en este apunte]({% post_url 2022-02-06-hass-migrar-datos %}). |


<br/>

#### Instalación del cliente Telegraf en Linux Ubuntu/Debian/Raspbian

Repito lo siguiente en varios equipos Linux, empezando por `almacenix`. Parto de la guía de la versión 2.1

* Referencia: [Use Telegraf to write data](https://docs.influxdata.com/influxdb/v2.1/write-data/no-code/use-telegraf/)
* Referencia: [Install Telegraf](https://docs.influxdata.com/telegraf/v1.21/introduction/installation/)


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
- Desde InfluxDB [http://almacenix.parchis.org:8086](http://almacenix.parchis.org:8086)
- Data > Buckets > Create Bucket > ‘telegraf’, retention ‘never’
- Data > Telegraf > Create Configuration > Bucket ‘telegraf’ > System > Continue >
   - Create and verify.
- Copio el Token y el URL para leer la configuración desde el propio servidor InfluxDB
- La configuración está en Data>Telegraf>Telegraf Alamcenix>Download

Me creo una versión personalizada del telegraf.service, lo modifico y arranco el servicio

```shell
cp /lib/systemd/system/telegraf.service /etc/systemd/system/
nano telegraf.service
   ExecStart=/usr/bin/telegraf --config http://almacenix.parchis.org:8086/api/v2/telegrafs/XXXXXXXX $TELEGRAF_OPTS
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

- Desde InfluxDB [http://almacenix.parchis.org:8086](http://almacenix.parchis.org:8086)
- Data > Telegraf > Create Configuration > Bucket ‘telegraf’ > System > Continue >
- Create and verify.
- Copio el Token y el URL
- La configuración está en Data>Telegraf>Telegraf Alamcenix>Download

Me creo una versión personalizada del telegraf.service, lo modifico y arranco el servicio

```shell
cp /lib/systemd/system/telegraf.service /etc/systemd/system/
nano telegraf.service
	EnvironmentFile=-/etc/conf.d/telegraf
	ExecStart=/usr/bin/telegraf --config http://almacenix.parchis.org:8086/api/v2/telegrafs/XXXXXXXXX $TELEGRAF_OPTS
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

- Conecto con http://almacenix.parchis.org:3000 —> admin, admin (cambio la contraseña)

- Conecto con mis dos Bucket's en InfluxDB (`telegraf` y `home_assistant`)

```shell
Data Sources -> Add data source

Name: Flux telegraf
 Query Language: Flux
 URL: http://127.0.0.1:8086
 Access: Server
 Auth: Todo desactivado
 InfluxDB Details: 
    Organization: parchis.org (la tuya)
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
    Organization: parchis.org (la tuya)
    Token: <El que pusiste con tu usuario principal>
    Default Bucket: home_assistant
 SAVE & TEST -> Ok 
```

- El lenguaje **recomendado** para interrogar a InfluxDB 2.x es `Flux` a diferencia de `InfluxQL` (versiones 1.x). Es un lenguaje de script que permite hacer consultas mucho más complejas, programación avanzada, etc. Se aleja bastante del conocido SQL, así que cuesta al princpio, mira un ejemplo (tienes más en el [apunte de la migración]({% post_url 2022-02-06-hass-migrar-datos %})) 
  
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

{% include showImagen.html 
      src="/assets/img/posts/grafana-config-1.png" 
      caption="Ejemplo de configuración con Flux." 
      width="800px"
      %}

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

{% include showImagen.html 
      src="/assets/img/posts/grafana-panel-imagen.png" 
      caption="Ejemplo de imagen en un panel de texto." 
      width="400px"
      %}

<br/>


**Compartir Dashboard con un Home Assistant remoto**

Me gusta ver los dashboards de Grafana desde Home Assistant lo más integrado posible:

En el equipo donde tengo Grafana aActivo la autenticación anónima y el poder trabajar desde iFrames en /etc/grafana/grafana.ini

```yaml
[auth.anonymous]
enabled = true
org_name = parchis.org
org_role = Viewer
hide_version = true

[security]
cookie_samesite = none
allow_embedding = true
```

Rearranco el servidor

```
root@almacenix:~# systemctl restart grafana-server.service
```

 - Copiar el link directo al Dashboard.
   -  Desde Grafana->Dasboard->Abre el dashboard->Click en el icono de Compartir !!
   -  Copiar la URL

{% include showImagen.html 
      src="/assets/img/posts/grafana-hass-1.png" 
      caption="Copia la URL para acceder remotamente al Dashboard" 
      width="500px"
      %}


- En el Home Assistant
  - En un Dashboard existente o creando uno desde Configuración->Dashboards. 
  - Edit Dashboard
  - Add view, poner nombre, Save y Add Card, tipo **iFrame (Web page Card)** 
  - Entrar en Code Editor y poner lo siguiente, editando a gusto (cambiar la URL por la tuya

```
type: iframe
url: >-
  http://almacenix.parchis.org:3000/d/123456-nk/servidores?orgId=1&from=now/d&to=now&kiosk=tv&refresh=5s
aspect_ratio: 70%
```

  - Save
  - Editar el View de nuevo (no la Card) y en View Type pon "Panel (1 card) 


{% include showImagen.html 
      src="/assets/img/posts/grafana-hass-2.png" 
      caption="Dashboard Grafana externo integrado en Home Assistant" 
      width="800px"
      %}


<br/>

Recuerda aquí tienes un apunte sobre como [migrar los datos de InfluxDB y los dashboards Grafana]({% post_url 2022-02-06-hass-migrar-datos %}) desde Home Assistant a un servidor nuevo como el que acabamos de configurar. 

----

<br/>





