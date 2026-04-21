---
title: "HASS migrate Grafana and InfluxDB"
date: "2022-02-06"
categories: ["home automation"]
tags: ["linux","homeassistant","grafana","influxdb"]
draft: false
cover:
  image: "/img/posts/logo-hass-out-grafana-influxdb.svg"
  hidden: true
---

<img src="/img/posts/logo-hass-out-grafana-influxdb.svg" alt="Migration Logo" width="150px" style="float:left; padding-right:25px"  />

I've **migrated the InfluxDB/Grafana services from my Home Assistant to an external server**. Moving the service and setting it up on another server isn't too difficult. What did take me a while was figuring out how to export and import data between the InfluxDB instances and how to adapt the old Grafana Dashboard to use `Flux`.

<br clear="left"/>
<!--more-->

#### Install a new server

First you need a server. In my case I use Linux and have it documented in the [post: Grafana, InfluxDB and Telegraf Server]({{< relref "2022-02-06-grafana-influxdb.md" >}}). Everything should be working independently — InfluxDB, Grafana, and Telegraf operational, with a Bucket called `telegraf` and another `home_assistant`. This will make it easier to follow this guide without errors...

<br/>

### Export/Import InfluxDB data

#### Connect HA to the new InfluxDB

- Find the `Organization ID` of the `home_assistant` Bucket in the new InfluxDB:

```
luis@almacenix:~$ influx bucket list
....    Organization ID  Schema Type
....    8970132987123409 implicit
:
```

- Have the rest of the data handy: `URL, token, bucket name`

The first thing we'll do is have HA stop storing data in its old InfluxDB and start storing them in the new InfluxDB.

- Modify the `configuration.yaml`

```
:
influxdb:
  # New InfluxDB @ almacenix.tudominio.com
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

- Restart HA, the new InfluxDB starts receiving data. You can verify by going to `http://your-server:8086`, Explore, and checking the "home_assistant" bucket.

<br/>

#### Export old data

- I enter debug mode on the Linux hosting HASS OS ([more info](https://developers.home-assistant.io/docs/operating-system/debugging/#ssh-access-to-the-host), [another reference](https://developers.home-assistant.io/docs/operating-system/debugging/) and [another reference](https://github.com/home-assistant/operating-system/blob/rel-1/Documentation/configuration.md#automatic))

  - I format a USB drive as FAT or EXT4, and very importantly, I name it: "CONFIG"
  - I create an "authorized_keys" file at its root with my public key
  - I insert the USB into a free port on the HA server
  - Almost instantly it activates SSHD listening on port 22222
  - I run from a client where I have the private key:

```
ssh root@your-hass-server -p 22222  (also ssh root@homeassistant.local -p 22222)
```

- Once inside HASS OS, I find the InfluxDB container name and enter an interactive shell with it, export the data, and bring it back to the Linux host (HASS OS host) and from there to my Mac.

```
# docker ps -a
:
# docker exec -it addon_XXXXXXX_influxdb /bin/bash
:
root@XXXXXXX-influxdb:/# influx_inspect export -database home_assistant -datadir /data/influxdb/data -waldir /data/influxdb/wal -lponly -compress -out home_assistant.line.gz
:

root@XXXXXXX-influxdb:~# ls -al h*
-rw-r--r-- 1 root root 75503542 Feb  6 21:46 home_assistant.line.gz
root@XXXXXXX-influxdb:~# exit
:
# docker cp addon_XXXXXXX_influxdb:/root/home_assistant.line.gz /mnt/data/
# scp /mnt/data/home_assistant.line.gz luis@idefix.tudominio.com:Desktop/
:
```

<br/>

#### Import into the new InfluxDB

I send the file to the new server, decompress it, and load the data into the `home_assistant` Bucket

```shell
~/Desktop > scp home_assistant.line.gz luis@almacenix.tudominio.com:.

luis@almacenix:~$ gunzip home_assistant.line.gz

luis@almacenix:~$ influx write --bucket home_assistant --file ./home_assistant.line
```

<br/>

### Export/Import Grafana dashboard

#### Export Grafana dashboard from Home Assistant

- HA > Grafana > "Your Dashboard" > Share Dashboard > Export
  - Export for Sharing Externally (X)
  - Save to File (JSON)

<br/>

#### Import into the new Grafana server

- Select Your Dashboard - xxxxxxxx.json"
  - Name: Your Dashboard
  - Folder: General.
  - InfluxDB: **Flux home_assistant**  <== The name of your InfluxDB connection

<br/>

#### Adapt Grafana to use `Flux`

The new InfluxDB 2.x prefers the use of `Flux` over `InfluxQL`, as was the case with the previous version 1.x (used in the embedded version in HA).

Unfortunately, Grafana doesn't yet have a graphical helper for writing queries in this scripting language. I'll leave here multiple examples of queries I've used with several of my sensors:

<br/>

**Linux with Telegraf**

Networking example:

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

Total CPU usage (all cores):

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

Disk usage:

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

Memory:

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

**Sensors in home_assistant**

States:

```html
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "state")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "binary_sensor")
  |> filter(fn: (r) => r["entity_id"] == "cocina_puerta")
  |> yield()
```

Batteries:

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

Power consumption:

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

Average temperature aggregate:

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
