---
title: "Grafana, InfluxDB and Telegraf Server"
date: "2022-02-06"
categories: ["home automation"]
tags: ["linux","homeassistant","grafana","influxdb"]
draft: false
cover:
  image: "/img/posts/logo-grafana-influxdb.svg"
  hidden: true
---

<img src="/img/posts/logo-grafana-influxdb.svg" alt="Grafana and InfluxDB Logo" width="150px" style="float:left; padding-right:25px"  />

I set up these three services on a dedicated server at home to monitor my home automation. InfluxDB is a database super-optimized for working with time series. Grafana lets you create dashboards and graphs from multiple sources, and Telegraf is a lightweight agent that collects, processes, and sends data to our database.

I've decided to install all three on an Ubuntu 20.04 LTS server, on a virtual machine in KVM, so they're consumed by the rest of the home automation elements: the Home Assistant server and other devices that can write to InfluxDB.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-06.jpg" alt="Monitoring Architecture" width="500px" />
  <div class="image-caption">Monitoring Architecture</div>
</div>

| Note: I previously had Grafana/InfluxDB "inside" Home Assistant OS. Once I finished the installation, I proceeded to [migrate the InfluxDB data and Grafana dashboards]({{< relref "2022-02-06-hass-migrar-datos.md" >}}) |

<br/>

### Linux Server Installation

I install Ubuntu on a virtual machine running on KVM. I followed the official documentation, [Ubuntu Installation](https://ubuntu.com/server/docs/installation) and the following ISO image:

```shell
wget https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso
```

From my KVM server I launch `virt-manager` > New virtual machine, I use the ISO above and name the server `almacenix.tudominio.com` (the domain is private, served by my [own DNS Server]({{< relref "2021-06-20-pihole-casero.md" >}}))

<br/>

### Install InfluxDB OSS Server

Once I have Linux operational, I use the reference documentation [for InfluxDB 2.1](https://docs.influxdata.com/influxdb/v2.1/install/?t=Linux), with downloads [here](https://portal.influxdata.com/downloads/) and perform the installation.

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

- I verify the correct version will be installed:

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

- To prevent it from reporting anything or "phoning home", I edit `/usr/lib/influxdb/scripts/influxd-systemd-start.sh`

```shell
/usr/bin/influxd --reporting-disabled &
```

- I modify `/etc/influxdb/config.toml` so it listens on any IP, making it accessible from the home LAN.

```shell
bolt-path = "/var/lib/influxdb/influxd.bolt"
engine-path = "/var/lib/influxdb/engine"
http-bind-address = "0.0.0.0:8086"
```

- I restart the service

```shell
systemctl restart influxdb
```

<br/>

#### InfluxDB Administration

- I connect to [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086) <-- Put your name/address here.
- I create my user (luis), set the password, and name the Organization "tudominio.com" (can be anything)
- I configure and save the `API Token` for my user.

- It's in Data -> API Tokens -> luis Token - It will be something like:

```shell
nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123==
```

| Note: Any client that wants to Read or Write to my InfluxDB will need to know the server URL, the Organization name, the "Bucket" (Database) name, and the API Token! |

- I install the Influx CLI client

```shell
wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.2.0-linux-amd64.tar.gz
tar xvzf influxdb2-client-2.2.0-linux-amd64.tar.gz
mv influxdb2-client-2.2.0-linux-amd64/influx /usr/local/bin
```

- I configure the client so it doesn't ask for the token every time I use it:

```shell

luis@almacenix:~$ influx version
Influx CLI 2.2.0 (git: c3690d8) build_date: 2021-10-21T15:24:59Z

luis@almacenix:~$ influx config create --config-name influxdb-almacenix  --host-url http://<your-url>:8086 --org <your org>  --token <your token> --active

luis@almacenix:~$ cat .influxdbv2/configs
[influxdb-almacenix]
  url = "http://almacenix.tudominio.com:8086"
  token = "nC912345678901234567890M4MFFj-abcdefghijklmnopqrstu123847987sadkjhfklj9832498324908123=="
  org = "tudominio.com"
  active = true

Proof of concept
luis@almacenix:~$ influx user list
ID   Name
08e1234567892000 luis
```

- I configure the InfluxDB client on my MacOS.

```shell
$ brew update
$ brew install influxdb
$ influx config create --config-name influxdb-almacenix  --host-url http://<your-url>:8086 --org <your org>  --token <your token> --active

Proof of concept
$ influx user list
ID   Name
08e1234567892000 luis
```

<br/>

#### Creating my databases

I'm going to use this server to receive data from Telegraf clients and from Home Assistant, so I create a couple of Buckets.

- `telegraf`, with retention `never or infinite`
- `home_assistant`, with retention `never or infinite`

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-07.png" alt="Initial databases" width="500px" />
  <div class="image-caption">Initial databases</div>
</div>

| Note: I use the same name (`home_assistant`) as the one used in Home Assistant's InfluxDB to facilitate the later migration, documented [in this post]({{< relref "2022-02-06-hass-migrar-datos.md" >}}). |

<br/>

#### Installing the Telegraf client on Linux Ubuntu/Debian/Raspbian

I repeat the following on several Linux machines, starting with `almacenix`. I start from the version 2.1 guide

- Reference: [Use Telegraf to write data](https://docs.influxdata.com/influxdb/v2.1/write-data/no-code/use-telegraf/)
- Reference: [Install Telegraf](https://docs.influxdata.com/telegraf/v1.21/introduction/installation/)

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

- From InfluxDB [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086)
- Data > Buckets > Create Bucket > 'telegraf', retention 'never'
- Data > Telegraf > Create Configuration > Bucket 'telegraf' > System > Continue >
  - Create and verify.
- I copy the Token and URL to read the configuration from the InfluxDB server itself
- The configuration is in Data>Telegraf>Telegraf Almacenix>Download

I create a custom version of the telegraf.service, modify it, and start the service

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

#### Installing the Telegraf client on Linux Gentoo

I have a couple of routers based on Gentoo. It's important that Layman is set up before doing the following. Telegraf is not in the portage tree, emerge from overlay:

```shell
Here's someone who maintains it... as an overlay
    - https://github.com/aexoden/gentoo-overlay

Create /etc/portage/repos.conf/gentoo-aexoden.conf
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

- From InfluxDB [http://almacenix.tudominio.com:8086](http://almacenix.tudominio.com:8086)
- Data > Telegraf > Create Configuration > Bucket 'telegraf' > System > Continue >
- Create and verify.
- I copy the Token and URL
- The configuration is in Data>Telegraf>Telegraf Almacenix>Download

I create a custom version of the telegraf.service, modify it, and start the service

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

### Install Grafana OSS Server

- I follow the guide [Install on Debian or Ubuntu](https://grafana.com/docs/grafana/latest/installation/debian/)

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

#### Configure Grafana

From a browser I connect to the new Grafana server and perform the initial configuration.

- I connect to <http://almacenix.tudominio.com:3000> --> admin, admin (I change the password)

- I connect to my two InfluxDB Buckets (`telegraf` and `home_assistant`)

```shell
Data Sources -> Add data source

Name: Flux telegraf
 Query Language: Flux
 URL: http://127.0.0.1:8086
 Access: Server
 Auth: Everything disabled
 InfluxDB Details:
    Organization: tudominio.com (yours)
    Token: <The one you set with your main user>
    Default Bucket: telegraf
 SAVE & TEST -> Ok

Data Sources -> Add data source

Name: Flux home_assistant
 Query Language: Flux
 URL: http://127.0.0.1:8086
 Access: Server
 Auth: Everything disabled
 InfluxDB Details:
    Organization: tudominio.com (yours)
    Token: <The one you set with your main user>
    Default Bucket: home_assistant
 SAVE & TEST -> Ok
```

- The **recommended** language for querying InfluxDB 2.x is `Flux` as opposed to `InfluxQL` (version 1.x). It's a scripting language that allows much more complex queries, advanced programming, etc. It's quite different from the familiar SQL, so it takes some getting used to. Here's an example (you'll find more in the [migration post]({{< relref "2022-02-06-hass-migrar-datos.md" >}}))

- Panel to measure network traffic from a Telegraf client (one of my Linux machines):

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
  <img src="/img/posts/2022-02-06-grafana-influxdb-02.png" alt="Example configuration with Flux." width="800px" />
  <div class="image-caption">Example configuration with Flux.</div>
</div>

<br/>

#### Grafana Tips

**Display an image in a Grafana panel**

- Copy the image to root@your_server:/usr/share/grafana/public/img/
- Reference the file from a **Text type Panel** with **HTML/MD** content, in my case I use HTML to center it:

```
<center>
<img src="/public/img/logo-linux-router.svg" alt="logo-linux-router.svg" width="64"/>
cortafuegix
</center>
```

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-05.png" alt="Example of an image in a text panel." width="400px" />
  <div class="image-caption">Example of an image in a text panel.</div>
</div>

<br/>

**Share Dashboard with a remote Home Assistant**

I like to see Grafana dashboards from Home Assistant as integrated as possible:

- I configure anonymous authentication and the ability to work with iFrames by modifying the file `/etc/grafana/grafana.ini`:

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

- I restart the Grafana server:

```
root@almacenix:~# systemctl restart grafana-server.service
```

- Next I make sure the `org_name` (`grafana.ini`) matches the Organization name. I enter the Grafana web administration and make sure they match:

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-01.png" alt="org_name and the Dashboard organization name must match" width="800px" />
  <div class="image-caption">org_name and the Dashboard organization name must match</div>
</div>

- Finally, we just need to copy the direct link to the Dashboard.
  - From Grafana->Dashboard->Open the dashboard->Click the Share icon!
  - Copy the URL

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-03.png" alt="Copy the URL to remotely access the Dashboard" width="500px" />
  <div class="image-caption">Copy the URL to remotely access the Dashboard</div>
</div>

- In Home Assistant
  - On an existing Dashboard or creating one from Configuration->Dashboards.
  - Edit Dashboard
  - Add view, set a name, Save and Add Card, type **iFrame (Web page Card)**
  - Enter the Code Editor and add the following, editing to taste (change the URL to yours)

```
type: iframe
url: >-
  http://almacenix.tudominio.com:3000/d/123456-nk/servidores?orgId=1&from=now/d&to=now&kiosk=tv&refresh=5s
aspect_ratio: 70%
```

- Save
- Edit the View again (not the Card) and in View Type set "Panel (1 card)"

<div class="image-box">
  <img src="/img/posts/2022-02-06-grafana-influxdb-04.png" alt="External Grafana Dashboard integrated in Home Assistant" width="800px" />
  <div class="image-caption">External Grafana Dashboard integrated in Home Assistant</div>
</div>

<br/>

Remember, here's a post about how to [migrate InfluxDB data and Grafana dashboards]({{< relref "2022-02-06-hass-migrar-datos.md" >}}) from Home Assistant to a new server like the one we just configured.

<br/>

#### InfluxDB Tips

<br/>

**Export all data from a bucket**

I wanted to see how `Telegraf` data was being stored, so I exported it from influx to inspect

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

**Delete specific data**

During testing with Telegraf Plugins I generated a lot of data that I later wanted to delete. Here are some examples:

- Delete everything stored with `_measurement="temporal_size"` between two specific timestamps

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-15T17:00:00Z' --stop '2022-02-15T23:00:00Z' --predicate '_measurement="temporal_size"'
```

<br/>

- Repeat but use "right now" as the end date.

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-16T14:00:00Z' --stop $(date +"%Y-%m-%dT%H:%M:%SZ") --predicate '_measurement="temporal_size"'
```

<br/>

- Delete `_measurement="temporal_size"` completely. Some tests were stored with dates in the past, so I set it to delete everything from the beginning of (digital) time until now...

```
luis@almacenix:~$ influx delete --bucket telegraf --start '1970-01-01T00:00:00Z' --stop $(date +"%Y-%m-%dT%H:%M:%SZ") --predicate '_measurement="temporal_size"'
```

<br/>

- Last example: I ran tests with the `inputs.influxdb` plugin which filled the Telegraf bucket with dozens of `_measurement`s that were useless to me afterward. I took advantage of the fact that *all data points* came with a tag called `url`.

```
luis@almacenix:~$ influx delete --bucket telegraf --start '2022-02-15T01:00:00Z' --stop '2022-02-16T23:00:00Z' --predicate 'url="http://localhost:8086/metrics"'
```

<br/>

### Telegraf Tips

**Monitor the size of InfluxDB server buckets**

- The goal is to determine the size of InfluxDB server buckets, for example to watch if they grow too much and we run out of space. As always, everything can be observed from Grafana

- Gist: [Script compatible with *influx* format for the **input.exec** Plugin](https://gist.github.com/LuisPalacios/9597178db4c4c4b357dd0700d61c1835) to determine the size of InfluxDB server buckets.

<br/>

**Monitor the size of QCOW2 disks on a QEMU/KVM Host**

- The goal is to be able to see the size of QCOW2 disks on a Linux Host with QEMU/KVM.

- Gist: [Script compatible with *influx* format for the **input.exec** Plugin](https://gist.github.com/LuisPalacios/e130f8200132a86a32dafbf2bfd0d1fb) to determine the space used by QCOW2 disks.

----

<br/>
