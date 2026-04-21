---
title: "WebGrab+Plus with Tvheadend"
date: "2015-02-03"
categories: ["tv"]
tags: ["linux","movistar","tvheadend"]
draft: false
cover:
  image: "/img/posts/logo-tvhWebGrab+.svg"
  hidden: true
---

<img src="/img/posts/logo-tvhWebGrab+.svg" alt="WebGrab+ logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

[WebGrab+Plus](http://www.webgrabplus.com/) is a multi-site EPG guide collector capable of working incrementally. It downloads the programming schedule and generates an XMLTV format file that you can use to feed your media center or Tvheadend. I first tried installing it on MacOSX and now (this article) it's time to install it on my Linux server and of course integrate it with [Tvheadend](https://tvheadend.org/).

<br clear="left"/>
<!--more-->

This post is related to the one about [Tvheadend and Movistar TV (2016)]({{< relref "2016-02-28-tvh-movistar-2016.md" >}}). Here I describe how to configure WebGrab to download the EPG from alternative sources. The WebGrab+Plus program generates a guide.xml file in XMLTV format that needs to be passed to TVHeadEnd, which in turn updates the XBMC clients (on Raspberry Pi in my case).

<div class="image-box">
  <img src="/img/posts/2015-02-03-webgrabplus-01.png" alt="WebGrab+Plus environment" width="600px" />
  <div class="image-caption">WebGrab+Plus environment</div>
</div>

| **Important**: I have created a Docker container with Tvheadend ready for use, check the end of the article. The Docker container with WebGrab+Plus is still on my to-do list :-). |

<br/>

### Installing WebGrab+Plus on Linux

Steps to perform the complete installation of WebGrab+Plus on a Linux machine:

- Install Mono on Linux. On Gentoo the latest available is version 3.2.8. It should work with any version above 2.10. In the `package.accept_keywords` file:

```config
=dev-lang/mono-3.2.8   ~amd64
```

- Run the installation

```shell
totobo ~ # emerge -v dev-lang/mono
```

- Download the latest version of WebGrab+Plus (Linux)
- Extract the `rar` in your user's $HOME and rename the directory to "**temp1**"
- Download patches, as documented on their website.
- Extract the ZIP in your user's $HOME and rename the directory to "**temp2**"
- Create a directory where to install the application. In my case: `/home/luis/wg++`
- Copy the `REX` and `MDB` directories from `temp1` to `/home/luis/wg++`
- Copy `WebGrab+Plus.config.xml` from `temp1` to `/home/luis/wg++`
- Copy `WebGrab+Plus.exe` from `temp2` to `/home/luis/wg++`
- I modify the configuration, starting from the list of EPG channels I can download and use with WG++. In my specific case I'm going to use sources available in Spain. I download for example the one from elpais.com and the final WG++ configuration file (WebGrab++.config.xml) I'm using is the following:

```shell
totobo wg++ $ curl -Ok http://webgrabplus.com/sites/default/files/download/ini/info/zip/Spain_elpais.com.zip
totobo wg++ $ unzip Spain_elpais.com.zip
Archive: Spain_elpais.com.zip
inflating: elpais.com.channels.xml
inflating: elpais.com.ini
```

```xml
<!--?xml version="1.0"?-->
<settings>

  <!-- WebGrab configuration file to download the Movistar EPG from alternative sources -->

  <!-- filename - Full path of the EPG (Guide) file that will be generated -->
  <filename>/home/luis/wg++/guide.xml</filename>

  <!-- mode - Option to detect errors that may arise, left empty -->
  <mode></mode>

  <!-- postprocess - Extract more metadata from the EPG using REX.    -->
  <!-- Recommended to use the following:                -->
  <!-- <postprocess run="y" grab="y">n</postprocess>  -->
  <postprocess grab="y" run="y">m</postprocess>

  <!-- logging - Enable or disable logging  -->
  <logging>on</logging>

  <!-- retry - number of times to retry downloading info from a site if it fails  -->
  <retry time-out="5">4</retry>

  <!-- timespan - Number of future days we want the guide downloaded for,
                  this is the number of days in addition to today, so 3 means 4 days -->
  <timespan>3</timespan>

  <!-- update - download method to use -->
  <update>f</update>

 <!-- CHANNELS from elpais.com (uses the elpais.com.ini file) -->

 <channel update="i" site="elpais.com" site_id="tve-1" xmltv_id="TVE 1">TVE 1</channel>
 <channel update="i" site="elpais.com" site_id="la-2" xmltv_id="LA 2">LA 2</channel>
 <channel update="i" site="elpais.com" site_id="antena-3" xmltv_id="Antena 3">Antena 3</channel>
 <channel update="i" site="elpais.com" site_id="cuatro" xmltv_id="Cuatro">Cuatro</channel>
 <channel update="i" site="elpais.com" site_id="telecinco" xmltv_id="Telecinco">Telecinco</channel>
 <channel update="i" site="elpais.com" site_id="la-sexta" xmltv_id="La Sexta">La Sexta</channel>
 <channel update="i" site="elpais.com" site_id="andalucia-tv" xmltv_id="Andalucía TV">Andalucía TV</channel>
 <channel update="i" site="elpais.com" site_id="aragon-television" xmltv_id="Aragón Televisión">Aragón Televisión</channel>
 <channel update="i" site="elpais.com" site_id="canal-extremadura" xmltv_id="Canal Extremadura">Canal Extremadura</channel>
 <channel update="i" site="elpais.com" site_id="canal-sur" xmltv_id="Canal Sur">Canal Sur</channel>
 <channel update="i" site="elpais.com" site_id="castilla-la-mancha-tv" xmltv_id="Castilla la Mancha TV">Castilla la Mancha TV</channel>
 <channel update="i" site="elpais.com" site_id="etb1" xmltv_id="ETB1">ETB1</channel>
 <channel update="i" site="elpais.com" site_id="etb2" xmltv_id="ETB2">ETB2</channel>
 <channel update="i" site="elpais.com" site_id="ib3-televisio" xmltv_id="IB3 Televisió">IB3 Televisió</channel>
 <channel update="i" site="elpais.com" site_id="radiotelevision-de-murcia" xmltv_id="Radiotelevisión de Murcia">Radiotelevisión de Murcia</channel>
 <channel update="i" site="elpais.com" site_id="tv-p.-asturias" xmltv_id="TV P. Asturias">TV P. Asturias</channel>
 <channel update="i" site="elpais.com" site_id="tv3" xmltv_id="TV3">TV3</channel>
 <channel update="i" site="elpais.com" site_id="telemadrid" xmltv_id="Telemadrid">Telemadrid</channel>
 <channel update="i" site="elpais.com" site_id="television-canaria" xmltv_id="Televisión Canaria">Televisión Canaria</channel>
 <channel update="i" site="elpais.com" site_id="television-de-galicia" xmltv_id="Televisión de Galicia">Televisión de Galicia</channel>
 <channel update="i" site="elpais.com" site_id="13-tv" xmltv_id="13 Tv">13 Tv</channel>
 <channel update="i" site="elpais.com" site_id="24-horas" xmltv_id="24 Horas">24 Horas</channel>
 <channel update="i" site="elpais.com" site_id="40-tv" xmltv_id="40 TV">40 TV</channel>
 <channel update="i" site="elpais.com" site_id="arirang-tv" xmltv_id="ARIRANG TV">ARIRANG TV</channel>
 <channel update="i" site="elpais.com" site_id="axn" xmltv_id="AXN">AXN</channel>
 <channel update="i" site="elpais.com" site_id="axn-white" xmltv_id="AXN White">AXN White</channel>
 <channel update="i" site="elpais.com" site_id="al-jazeera-english" xmltv_id="Al Jazeera English">Al Jazeera English</channel>
 <channel update="i" site="elpais.com" site_id="arte" xmltv_id="Arte">Arte</channel>
 <channel update="i" site="elpais.com" site_id="bbc-world" xmltv_id="BBC World">BBC World</channel>
 <channel update="i" site="elpais.com" site_id="bio" xmltv_id="BIO">BIO</channel>
 <channel update="i" site="elpais.com" site_id="baby-tv" xmltv_id="Baby TV">Baby TV</channel>
 <channel update="i" site="elpais.com" site_id="barca-tv" xmltv_id="Barça TV">Barça TV</channel>
 <channel update="i" site="elpais.com" site_id="bloomberg" xmltv_id="Bloomberg">Bloomberg</channel>
 <channel update="i" site="elpais.com" site_id="boing" xmltv_id="Boing">Boing</channel>
 <channel update="i" site="elpais.com" site_id="cplus-1" xmltv_id="C+ 1">C+ 1</channel>
 <channel update="i" site="elpais.com" site_id="cplus-1-...30" xmltv_id="C+ 1 ...30">C+ 1 ...30</channel>
 <channel update="i" site="elpais.com" site_id="cplus-2" xmltv_id="C+ 2">C+ 2</channel>
 <channel update="i" site="elpais.com" site_id="cplus-3d" xmltv_id="C+ 3D">C+ 3D</channel>
 <channel update="i" site="elpais.com" site_id="cplus-accion" xmltv_id="C+ Acción">C+ Acción</channel>
 <channel update="i" site="elpais.com" site_id="cplus-comedia" xmltv_id="C+ Comedia">C+ Comedia</channel>
 <channel update="i" site="elpais.com" site_id="cplus-dcine" xmltv_id="C+ DCine">C+ DCine</channel>
 <channel update="i" site="elpais.com" site_id="cplus-deportes" xmltv_id="C+ Deportes">C+ Deportes</channel>
 <channel update="i" site="elpais.com" site_id="cplus-deportes-2-hd" xmltv_id="C+ Deportes 2 HD">C+ Deportes 2 HD</channel>
 <channel update="i" site="elpais.com" site_id="cplus-futbol" xmltv_id="C+ Fútbol">C+ Fútbol</channel>
 <channel update="i" site="elpais.com" site_id="cplus-golf" xmltv_id="C+ Golf">C+ Golf</channel>
 <channel update="i" site="elpais.com" site_id="cplus-liga" xmltv_id="C+ Liga">C+ Liga</channel>
 <channel update="i" site="elpais.com" site_id="cplus-liga-multi" xmltv_id="C+ Liga Multi">C+ Liga Multi</channel>
 <channel update="i" site="elpais.com" site_id="cplus-liga-de-campeones" xmltv_id="C+ Liga de Campeones">C+ Liga de Campeones</channel>
 <channel update="i" site="elpais.com" site_id="cplus-liga-de-campeones2" xmltv_id="C+ Liga de Campeones2">C+ Liga de Campeones2</channel>
 <channel update="i" site="elpais.com" site_id="cplus-liga-de-campeones3" xmltv_id="C+ Liga de Campeones3">C+ Liga de Campeones3</channel>
 <channel update="i" site="elpais.com" site_id="cplus-series" xmltv_id="C+ Series">C+ Series</channel>
 <channel update="i" site="elpais.com" site_id="cplus-toros" xmltv_id="C+ Toros">C+ Toros</channel>
 <channel update="i" site="elpais.com" site_id="cplus-toros-hd" xmltv_id="C+ Toros HD">C+ Toros HD</channel>
 <channel update="i" site="elpais.com" site_id="cplus-xtra" xmltv_id="C+ Xtra">C+ Xtra</channel>
 <channel update="i" site="elpais.com" site_id="cnbc" xmltv_id="CNBC">CNBC</channel>
 <channel update="i" site="elpais.com" site_id="cnn-int" xmltv_id="CNN Int">CNN Int</channel>
 <channel update="i" site="elpais.com" site_id="calle-13" xmltv_id="Calle 13">Calle 13</channel>
 <channel update="i" site="elpais.com" site_id="canal-33" xmltv_id="Canal 33">Canal 33</channel>
 <channel update="i" site="elpais.com" site_id="canal-cocina" xmltv_id="Canal Cocina">Canal Cocina</channel>
 <channel update="i" site="elpais.com" site_id="canal-decasa" xmltv_id="Canal Decasa">Canal Decasa</channel>
 <channel update="i" site="elpais.com" site_id="canal-panda" xmltv_id="Canal Panda">Canal Panda</channel>
 <channel update="i" site="elpais.com" site_id="canal-de-las-estrellas" xmltv_id="Canal de las Estrellas">Canal de las Estrellas</channel>
 <channel update="i" site="elpais.com" site_id="canalplus-radios" xmltv_id="Canal+ RADIOS">Canal+ RADIOS</channel>
 <channel update="i" site="elpais.com" site_id="caza-y-pesca" xmltv_id="Caza y Pesca">Caza y Pesca</channel>
 <channel update="i" site="elpais.com" site_id="clan-tve" xmltv_id="Clan TVE">Clan TVE</channel>
 <channel update="i" site="elpais.com" site_id="cosmopolitan" xmltv_id="Cosmopolitan">Cosmopolitan</channel>
 <channel update="i" site="elpais.com" site_id="cubavision" xmltv_id="Cubavisión">Cubavisión</channel>
 <channel update="i" site="elpais.com" site_id="dcine-espanol" xmltv_id="DCine Español">DCine Español</channel>
 <channel update="i" site="elpais.com" site_id="disney-channel" xmltv_id="Disney Channel">Disney Channel</channel>
 <channel update="i" site="elpais.com" site_id="disney-cinemagic" xmltv_id="Disney Cinemagic">Disney Cinemagic</channel>
 <channel update="i" site="elpais.com" site_id="disney-junior" xmltv_id="Disney Junior">Disney Junior</channel>
 <channel update="i" site="elpais.com" site_id="disney-xd" xmltv_id="Disney XD">Disney XD</channel>
 <channel update="i" site="elpais.com" site_id="divinity" xmltv_id="Divinity">Divinity</channel>
 <channel update="i" site="elpais.com" site_id="el-garage-tv" xmltv_id="El Garage TV">El Garage TV</channel>
 <channel update="i" site="elpais.com" site_id="energy" xmltv_id="Energy">Energy</channel>
 <channel update="i" site="elpais.com" site_id="euronews" xmltv_id="Euronews">Euronews</channel>
 <channel update="i" site="elpais.com" site_id="france-24" xmltv_id="FRANCE 24">FRANCE 24</channel>
 <channel update="i" site="elpais.com" site_id="factoria-de-ficcion" xmltv_id="Factoría de Ficción">Factoría de Ficción</channel>
 <channel update="i" site="elpais.com" site_id="fashiontv" xmltv_id="FashionTV">FashionTV</channel>
 <channel update="i" site="elpais.com" site_id="fox" xmltv_id="Fox">Fox</channel>
 <channel update="i" site="elpais.com" site_id="fox-crime" xmltv_id="Fox Crime">Fox Crime</channel>
 <channel update="i" site="elpais.com" site_id="fox-news" xmltv_id="Fox News">Fox News</channel>
 <channel update="i" site="elpais.com" site_id="goltv" xmltv_id="GolTV">GolTV</channel>
 <channel update="i" site="elpais.com" site_id="historia" xmltv_id="Historia">Historia</channel>
 <channel update="i" site="elpais.com" site_id="hollywood" xmltv_id="Hollywood">Hollywood</channel>
 <channel update="i" site="elpais.com" site_id="intereconomia" xmltv_id="Intereconomía">Intereconomía</channel>
 <channel update="i" site="elpais.com" site_id="la-siete" xmltv_id="La Siete">La Siete</channel>
 <channel update="i" site="elpais.com" site_id="la-tienda-en-casa" xmltv_id="La tienda en casa">La tienda en casa</channel>
 <channel update="i" site="elpais.com" site_id="mtv-espana" xmltv_id="MTV ESPAÑA">MTV ESPAÑA</channel>
 <channel update="i" site="elpais.com" site_id="mtv-rocks" xmltv_id="MTV ROCKS">MTV ROCKS</channel>
 <channel update="i" site="elpais.com" site_id="mezzo" xmltv_id="Mezzo">Mezzo</channel>
 <channel update="i" site="elpais.com" site_id="mezzo-live-hd" xmltv_id="Mezzo Live HD">Mezzo Live HD</channel>
 <channel update="i" site="elpais.com" site_id="motors-tv" xmltv_id="Motors TV">Motors TV</channel>
 <channel update="i" site="elpais.com" site_id="mexico-travel-channel" xmltv_id="México Travel Channel">México Travel Channel</channel>
 <channel update="i" site="elpais.com" site_id="nhk-world" xmltv_id="NHK World">NHK World</channel>
 <channel update="i" site="elpais.com" site_id="nick-jr" xmltv_id="NICK JR">NICK JR</channel>
 <channel update="i" site="elpais.com" site_id="nat-geo-wild" xmltv_id="Nat Geo Wild">Nat Geo Wild</channel>
 <channel update="i" site="elpais.com" site_id="nat-geographic" xmltv_id="Nat Geographic">Nat Geographic</channel>
 <channel update="i" site="elpais.com" site_id="neox" xmltv_id="Neox">Neox</channel>
 <channel update="i" site="elpais.com" site_id="nickelodeon" xmltv_id="Nickelodeon">Nickelodeon</channel>
 <channel update="i" site="elpais.com" site_id="nitro" xmltv_id="Nitro">Nitro</channel>
 <channel update="i" site="elpais.com" site_id="nova" xmltv_id="Nova">Nova</channel>
 <channel update="i" site="elpais.com" site_id="odisea" xmltv_id="Odisea">Odisea</channel>
 <channel update="i" site="elpais.com" site_id="paramount-channel" xmltv_id="Paramount Channel">Paramount Channel</channel>
 <channel update="i" site="elpais.com" site_id="paramount-comedy" xmltv_id="Paramount Comedy">Paramount Comedy</channel>
 <channel update="i" site="elpais.com" site_id="playboy-tv" xmltv_id="Playboy TV">Playboy TV</channel>
 <channel update="i" site="elpais.com" site_id="rt" xmltv_id="RT">RT</channel>
 <channel update="i" site="elpais.com" site_id="rt-en-espanol" xmltv_id="RT en español">RT en español</channel>
 <channel update="i" site="elpais.com" site_id="real-madrid-tv" xmltv_id="Real Madrid TV">Real Madrid TV</channel>
 <channel update="i" site="elpais.com" site_id="syfy" xmltv_id="SYFY">SYFY</channel>
 <channel update="i" site="elpais.com" site_id="sexta-3" xmltv_id="Sexta 3">Sexta 3</channel>
 <channel update="i" site="elpais.com" site_id="sky-news" xmltv_id="Sky News">Sky News</channel>
 <channel update="i" site="elpais.com" site_id="sol-musica" xmltv_id="Sol Música">Sol Música</channel>
 <channel update="i" site="elpais.com" site_id="sportmania" xmltv_id="Sportmanía">Sportmanía</channel>
 <channel update="i" site="elpais.com" site_id="super-3" xmltv_id="Super 3">Super 3</channel>
 <channel update="i" site="elpais.com" site_id="tcm" xmltv_id="TCM">TCM</channel>
 <channel update="i" site="elpais.com" site_id="tnt" xmltv_id="TNT">TNT</channel>
 <channel update="i" site="elpais.com" site_id="tv-record" xmltv_id="TV RECORD">TV RECORD</channel>
 <channel update="i" site="elpais.com" site_id="tv5monde" xmltv_id="TV5MONDE">TV5MONDE</channel>
 <channel update="i" site="elpais.com" site_id="tvi-internacional" xmltv_id="TVI Internacional">TVI Internacional</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--1" xmltv_id="Taquilla  1">Taquilla  1</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--2" xmltv_id="Taquilla  2">Taquilla  2</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--3" xmltv_id="Taquilla  3">Taquilla  3</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--4" xmltv_id="Taquilla  4">Taquilla  4</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--5" xmltv_id="Taquilla  5">Taquilla  5</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--6" xmltv_id="Taquilla  6">Taquilla  6</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--7" xmltv_id="Taquilla  7">Taquilla  7</channel>
 <channel update="i" site="elpais.com" site_id="taquilla--8" xmltv_id="Taquilla  8">Taquilla  8</channel>
 <channel update="i" site="elpais.com" site_id="taquilla-hd" xmltv_id="Taquilla HD">Taquilla HD</channel>
 <channel update="i" site="elpais.com" site_id="taquilla-hd-2" xmltv_id="Taquilla HD 2">Taquilla HD 2</channel>
 <channel update="i" site="elpais.com" site_id="teledeporte" xmltv_id="Teledeporte">Teledeporte</channel>
 <channel update="i" site="elpais.com" site_id="telesur" xmltv_id="Telesur">Telesur</channel>
 <channel update="i" site="elpais.com" site_id="trace-sport-stars" xmltv_id="Trace Sport Stars">Trace Sport Stars</channel>
 <channel update="i" site="elpais.com" site_id="vh1" xmltv_id="VH1">VH1</channel>
 <channel update="i" site="elpais.com" site_id="viajar" xmltv_id="Viajar">Viajar</channel>
 <channel update="i" site="elpais.com" site_id="xplora" xmltv_id="Xplora">Xplora</channel>
 <channel update="i" site="elpais.com" site_id="yomvi" xmltv_id="YOMVI">YOMVI</channel>

</settings>
```

- I create a small script to launch and run the program more easily, remember to give it execution permissions with chmod 755 wg++.sh

```shell
#!/bin/bash
#
cd /home/luis/wg++
mono Webgrab+Plus.exe "/home/luis/wg++"
```

From now on you can run the program and verify that everything works correctly and the guide.xml file is generated. The next step will be the integration with TVHeadEnd.

<br/>

### Integration with Tvheadend

I pass the entire EPG so that it can process it and deliver it to the "consumers" (Raspberry's with XBMC).

- I download the "tv_grab" file designed by WebGrab+Plus to interact with TVHeadEnd and save it as `/usr/bin/tv_grab_wg++`

```shell
# wget -O /usr/bin/tv_grab_wg++ http://www.webgrabplus.com/sites/default/files/tv_grab_wg.txt
# chmod +x /usr/bin/tv_grab_wg++
```

- You can run the grabber from the command line to verify that it works correctly, you'll see it displays a lot of xmltv data in the terminal.

- But the most important thing is to configure TVHeadEnd. Restart it and in between ask it to search for this new grabber. The tv_find_grabbers program searches for all executables "/usr/bin/tv_grab*" that can be "grabbers", those that respond properly will be enabled and can be selected in its configuration (via Web).

```shell
totobo ~ # /etc/init.d/tvheadend stop
totobo ~ # tv_find_grabbers
/usr/bin/tv_grab_wg++|/usr/bin/tv_grab_wg++ is a wrapper grabber around WebGrab+Plus
totobo ~ # /etc/init.d/tvheadend start
```

- I configure TVHeadEnd and select the new grabber "XMLTV: tv_grab_wg++".

<div class="image-box">
  <img src="/img/posts/2015-02-03-webgrabplus-02.png" alt="Grabber configuration" width="600px" />
  <div class="image-caption">Grabber configuration</div>
</div>

- Finally, I schedule the grabber to run daily in cron. By placing it in the cron.daily directory, it will run around 3:00am.

```shell
#!/bin/bash
#
export PATH=/usr/sbin:/usr/bin:/sbin:/bin:.
cd /home/luis/wg++
./wg++.sh > /dev/null 2>&1

```

### Tvheadend in Docker container

I have created a Docker container to run Tvheadend, take a look. Here are the projects where you have everything you need:

- [Docker luispa/base-tvheadend](https://hub.docker.com/r/luispa/base-tvheadend/)
- [GitHub base-tvheadend](https://github.com/LuisPalacios/base-tvheadend)
- [GitHub servicio-tvheadend](https://github.com/LuisPalacios/servicio-tvheadend)
