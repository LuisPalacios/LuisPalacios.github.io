---
title: "Home Assistant SolaX"
date: "2022-02-13"
categories: ["home automation"]
tags: ["linux","homeassistant","grafana","influxdb","solax","solaxcloud"]
draft: false
cover:
  image: "/img/posts/logo-hass-solax.svg"
  hidden: true
---

<img src="/img/posts/logo-hass-solax.svg" alt="Solax Logo" width="150px" style="float:left; padding-right:25px"  />

I describe how I integrated my photovoltaic installation into Home Assistant, featuring Axitec panels, a SolaX Inverter, and a pair of Triple Power batteries. After trying several options, I settled on the **MODBUS/TCP integration** which works locally via LAN and exposes more data than the other options.

<br clear="left"/>
<!--more-->

### Installation

My photovoltaic installation consists of the following components:

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-09.jpg" alt="Monitoring Architecture" width="700px" />
  <div class="image-caption">Monitoring Architecture</div>
</div>

      - 1 x SolaX Hybrid Inverter X1-HYBRID-5.0T Gen-3
      - 23 x Axitec 280W 60-cell polycrystalline solar modules
      - 1 x SolaX EPS Box
      - 1 x BMS for SolaX Triple Power batteries T-BAT MC0500
      - 2 x Triple Power T63 v2.0 SolaX 6.3kWh Battery
      - 1 x Chint DDSU 666 Meter
      - 1 x SolaX Pocket WiFi Dongle
  
We have three monitoring options:

1. SolaX Cloud (automatically updated via the Dongle), which can be queried through the official SolaX App or via REST/API.
2. Direct local query to the Pocket WiFi/LAN Dongle via REST/API.
3. Direct query over LAN (Ethernet port) via MODBUS/TCP.

<br/>

### 1. Monitoring via SolaX Cloud

When the installation is complete, the Dongle should be configured to upload data to SolaX Cloud so you can check it from a browser or mobile app. Updates happen every 5 minutes.

- You can use a browser or the SolaX App to connect to SolaX Cloud. In both cases you're accessing an online service with a 5-minute window, which, although not real-time, works quite well.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-12.jpg" alt="Options via SolaxCloud" width="700px" />
  <div class="image-caption">Options via SolaxCloud</div>
</div>

- You can query SolaX Cloud through REST/API and download the data locally.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-13.jpg" alt="REST/API Integration via SolaxCloud" width="500px" />
  <div class="image-caption">REST/API Integration via SolaxCloud</div>
</div>

**Home Assistant Integration**

I have never integrated via the SolaxCloud REST/API; in fact I don't recommend it — the MODBUS option described below is much better. However, here are a couple of links:

- GitHub project for the **[SolaxCloud integration for Home Assistant](https://github.com/thomascys/solaxcloud)**.
- A good discussion thread [here](https://community.home-assistant.io/t/pv-solax-inverter-cloud-sensors-via-api/277874/65), where you'll find many comments about this and other options...

<br/>

### 2. Monitoring via Local Network (WiFi/LAN Dongle)

In my case I have the WiFi Dongle (I actually tried to buy the LAN one without success). Monitoring is achieved through direct REST API queries to the dongle.

<br/>

**Home Assistant Integration**

The Home Assistant integration is available at: **[// SolaX Power](https://www.home-assistant.io/integrations/solax/)**, which implements the **[🌞 Solax Inverter API Wrapper](https://github.com/squishykid/solax)** by the same author.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-14.png" alt="Solax Power Integration with WiFi Dongle" width="400px" />
  <div class="image-caption">Solax Power Integration with WiFi Dongle</div>
</div>

My observations and some challenges:

- I used it for over a year and it works relatively well, without too many issues. It exposes the most common metrics, though not all of them.
- The WiFi Dongle connects as a client to your WiFi network to reach SolaxCloud, but it also exposes a new WiFi network.
- My first surprise was this new SSID (WiFi_SWXXXXXXXX) **without a password**, using a fixed IP (5.8.8.8), and discovering that it only listens for REST API requests on this IP.
  - In most cases, this means you need to set up a proxy at home. For example, a Raspberry Pi connected to your LAN and to this WiFi, running `nginx` as a proxy.
  - Fortunately, I found [this project](https://blog.chrisoft.io/2021/02/14/firmwares-modificados-para-solax-pocket-wifi-v2/) with modified firmware for the Solax Pocket WiFi V2, which basically enables listening on the IP assigned by your home network.
- Another challenge is stability — "sometimes" it would stop updating, for no apparent reason.
  - The solution was unplugging/plugging the dongle (USB).
- The third challenge is that the [Solax Power](https://www.home-assistant.io/integrations/solax/) integration only works with firmware version **V2.033.20**, so I couldn't update to the latest version **V2.034.06**.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-15.png" alt="REST API Integration via Local Network" width="500px" />
  <div class="image-caption">REST API Integration via Local Network</div>
</div>

<br/>

### 3. Monitoring via Local Network (MODBUS/TCP)

Querying the inverter via the MODBUS/TCP protocol is the best option. Fortunately, my X1-HYBRID-G3 inverter supports receiving queries on port 502 (the default port for the MODBUS/TCP protocol). You need to connect an Ethernet cable from the LAN port on your inverter to your home local network. In my case, I assign a fixed IP address from my DHCP server using its MAC address.

<br/>

**Home Assistant Integration**

There's a very good *Integration* that reads far more data and at a higher frequency than the other options I've tried: [homsassistant-solax-modbus](https://github.com/wills106/homsassistant-solax-modbus). The author:

- Published his work in this [thread](https://community.home-assistant.io/t/solax-inverter-by-modbus-no-pocket-wifi-now-a-custom-component/140143/10), which is worth reading through.
- Has another very interesting repository, [Home Assistant Configuration](https://github.com/wills106/homeassistant-config).

| Note: In my case I started with an old version (manual installation). Before installing the latest one, I removed the `/config/custom_components/solax_modbus` directory and deleted the integration from *Configuration > Integrations*. After the obligatory reboot, I was able to continue with the next step. |

<br/>

**Installation with HACS (0.4.5)**

Since version 0.4.5, installation is possible from [HACS](https://hacs.xyz), the Home Assistant Community Store.

- HACS > Integrations > Explore & Download Repositories > search for "modbus"

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-16.png" alt="Installing Homsassistant Solax Modbus" width="500px" />
  <div class="image-caption">Installing Homsassistant Solax Modbus</div>
</div>

I select the latest version

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-17.png" alt="Selecting the latest version" width="500px" />
  <div class="image-caption">Selecting the latest version</div>
</div>

I **restart** Home Assistant from Configuration > Settings > Restart

I go to **Configuration** > **Device & Services** > **Add Integration** > **Setup a new Integration**, search for `solax` and select *SolaX Inverter Modbus*. I name it `SolaXM` (the M stands for Modbus), enter its IP, select MY MODEL and set the polling frequency to 15s, more than enough...

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-01.jpg" alt="Adding the new integration" width="600px" />
  <div class="image-caption">Adding the new integration</div>
</div>

It now appears in Configuration > Devices & Services > Integrations. I enter the **device** and add it to the Lovelace UI.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-02.png" alt="From now on we can see it in Lovelace" width="800px" />
  <div class="image-caption">From now on we can see it in Lovelace</div>
</div>

<br/>

**Migration from 0.4.x to 0.5.3a**

When version 0.5.x was released, the author recommended ([discussion #26](https://github.com/wills106/homsassistant-solax-modbus/discussions/26)) removing the integration (0.4.x) and recreating it with the new one (0.5.x) **keeping the same device name**, so that the rest of your configuration is preserved when installing the new version.

- I confirm my device name, in my case I had named it **`SolaXM`**
  - *Configuration > Devices & Services > SolaXM (SolaX Inverter Modbus) > "..." > Rename*
- I delete the Solax modbus device
  - *Configuration > Devices & Services > SolaXM (SolaX Inverter Modbus) > "..." > Delete*
- I restart HA
  - Configuration > Settings > Server Control > Home Assistant > Restart

- I remove the Solax modbus integration in HACS
  - HACS > Integrations > SolaX Inverter Modbus > "..." > Remove
- I reinstall the new version 0.5.3a
  - HACS > Integrations > Explore & Download Repositories > search for "modbus"
  - SolaX Inverter Modbus > Download this repository > Select the latest (0.5.3a) > Download
- I restart Home Assistant
  - Configuration > Settings > Server Control > Home Assistant > Restart
- I add the device again
  - Configuration > Device & Services > Add Integration > Setup a new Integration
  - Search for `solax` > *SolaX Inverter Modbus* > name it **`SolaXM`**
  - Enter its IP and other parameters.

| Note: This time I didn't need to specify my inverter model — it was detected by the beginning of its serial number. I shared this with the author ([discussion #26](https://github.com/wills106/homsassistant-solax-modbus/discussions/26)). |

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-11.png" alt="New version 0.5.3a" width="500px" />
  <div class="image-caption">New version 0.5.3a</div>
</div>

<br/>

**Exporting Data to InfluxDB**

To export data I'm going to use my external server with InfluxDB 2.x and Grafana ([a post about that]({{< relref "2022-02-06-grafana-influxdb.md" >}})). By the way, I migrated from InfluxDB 1.x (embedded in HASS) to this external version ([migration steps here]({{< relref "2022-02-06-hass-migrar-datos.md" >}})).

I configure `/config/configuration.yaml` to send my inverter data to the InfluxDB server. If your inverter is different, you'll have similar but not identical data.

```
:
influxdb:
  # New InfluxDB 2.x
  api_version: 2
  ssl: false
  host: 192.168.X.Y
  port: 8086
  token: MY-USER-TOKEN (influxdb>LoadData>API Token)
  bucket: home_assistant
  organization: MY-ORGANIZATION-ID (influxdb>User Icon>About)
  max_retries: 3
  default_measurement: state
  include:
    entities:
     :
      # Add sensor.solaxm entries here
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

**Grafana Configuration for Consumption Visualization**

The next step is to configure a Dashboard in Grafana to display some of that data.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-03.png" alt="Grafana configuration example" width="800px" />
  <div class="image-caption">Grafana configuration example</div>
</div>

Here are the queries using the new Flux Script...

```
// 🏠 Total house consumption 
// via Solax Modbus 
//
from(bucket: "home_assistant")
|> range(start: v.timeRangeStart, stop: v.timeRangeStop)
|> filter(fn: (r) => r["_measurement"] == "W")
|> filter(fn: (r) => r["_field"] == "value")
|> filter(fn: (r) => r["domain"] == "sensor")
|> filter(fn: (r) => r["entity_id"] == "solaxm_house_load")
|> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
|> yield(name: "mean")

// 🔌 Grid consumption
// via Solax Modbus 
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

// 🌞 Photovoltaic Production 1&2
// Total power (W) generated by the Panels:
// via SolaX Modbus
//
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solaxm_pv_power_1" or r["entity_id"] == "solaxm_pv_power_2")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")

// Batteries: ➕⚡️Charge   /  ➖🔋 Discharge
// Battery charge and discharge
// via SolaX Modbus
//
from(bucket: "home_assistant")
  |> range(start: v.timeRangeStart, stop: v.timeRangeStop)
  |> filter(fn: (r) => r["_measurement"] == "W")
  |> filter(fn: (r) => r["_field"] == "value")
  |> filter(fn: (r) => r["domain"] == "sensor")
  |> filter(fn: (r) => r["entity_id"] == "solaxm_battery_power_charge")
  |> aggregateWindow(every: v.windowPeriod, fn: mean, createEmpty: false)
  |> yield(name: "mean")

// 🔩 Production to House/Grid
// Inverter: AC power in Watts delivered by the Inverter 
// from the PV panels to the house (to meet the requested demand)
// via SolaX Modbus
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

**Pending Items**

- I still need to study the [configuration used by the Integration's author](https://github.com/wills106/homeassistant-config/blob/master/packages/solax_x1_hybrid_g3_triplepower.yaml).

- I still need to explore other interesting monitoring options, as well as investigate the possibility of programming the Inverter from Home Assistant, although that's something I'm quite cautious about for now...

<br/>

### Energy Dashboard Integration

With version 2021.8, Home Assistant released the Energy Dashboard.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-04.png" alt="Grafana configuration example" width="250px" />
  <div class="image-caption">Grafana configuration example</div>
</div>

Its goal is to help users understand their energy consumption, allowing them to see at a glance how they're doing today, with the option to drill down by hour to see what happened. It also includes indicators that help identify your grid dependency and whether adding energy storage would help.

There's a way to make this integration's data compatible with that Dashboard...

<br/>

#### Initial Configuration

The documentation to configure the Energy screen is at this [link](https://www.home-assistant.io/blog/2021/08/04/home-energy-management/).

| Note: If you've already done a configuration and can't edit it from the `Energy` Dashboard, it's because you can only edit it from **Configuration > Dashboard > Energy**. By the way, for reference, the configuration is saved in the file: `config/.storage/energy` |

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-05.png" alt="Configuration > Dashboard > Energy" width="600px" />
  <div class="image-caption">Configuration > Dashboard > Energy</div>
</div>

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-07.jpg" alt="image-1" width="250px" />
  <img src="/img/posts/2022-02-13-hass-solax-08.jpg" alt="image-2" width="250px" />
  <div class="image-caption">Detail of the configured data, click to enlarge</div>
</div>

| Note 1: For CO2 Signal, just visit the site and sign up — they'll send you your token. |

| Note 2: In the window where I define the grid consumption (SolaXM Today's Import Energy) I've added an entity that tracks total costs, but it's just a test — it's not required. |

The end result is the Energy Dashboard.

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-06.png" alt="Energy Dashboard integrated in HA" width="800px" />
  <div class="image-caption">Energy Dashboard integrated in HA</div>
</div>

Comparison with what we see in a custom Grafana Dashboard...

<div class="image-box">
  <img src="/img/posts/2022-02-13-hass-solax-10.png" alt="Consumption detail in a Grafana Dashboard" width="800px" />
  <div class="image-caption">Consumption detail in a Grafana Dashboard</div>
</div>

<br/>
