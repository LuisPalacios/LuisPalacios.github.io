---
title: "WebGrab+Plus con TVHeadEnd en Linux"
date: "2015-02-03"
categories: 
  - "apuntes"
---

_**[WebGrab+Plus](http://www.webgrabplus.com)**_ es un recolector de Guías EPG multi-sitio capaz de trabajar de manera incremental. Se baja la programación y genera un fichero en formato XMLTV que puedes usar para alimentar a tu media center o a Tvheadend. Primero probé a [instalarlo en un MacOSX](https://www.luispa.com/?p=1522) y ahora (este artículo) toca instalarlo en mi [servidor Linux](https://www.luispa.com/?p=7) y por supuesto **integrarlo con [Tvheadend](https://tvheadend.org/)**.

Este apunte está relacionado con este otro: [Tvheadend y Movistar TV (2016)](https://www.luispa.com/archivos/4571) . Aquí describo como configurar WebGrab para bajarme el EPG desde otras fuentes. El programa WebGrab+Plus genera un fichero guide.xml en formato XMLTV que hay que pasarle a TVHeadEnd y que este a su vez actualiza a los XBMC (en Raspberri Pi en mi caso).

[![twr-xbmc](https://www.luispa.com/wp-content/uploads/2015/02/twr-xbmc-1024x498.png)](https://www.luispa.com/wp-content/uploads/2015/02/twr-xbmc.png) \[dropshadowbox align="center" effect="lifted-both" width="550px" height="" background\_color="#ffffff" border\_width="1" border\_color="#dddddd" \]

**Importante**: He creado un contenedor Docker con Tvheadend ya listo para su uso, mira al final del artículo. El contenedor Docker con WebGrab+Plus es una asignatura que todavía tengo pendiente :-).

\[/dropshadowbox\]

## Instalación de WebGrab+Plus en Linux

Pasos para realizar la instalación completa de WebGrab+Plus en un equipo linux:

- Instalar [Mono](http://www.mono-project.com/download/) en Linux. En Gentoo la última disponible es la versión 3.2.8. Seguramente te funcione con cualquiera superior a la 2.10.

\=dev-lang/mono-3.2.8   ~amd64

totobo ~ # emerge -v dev-lang/mono

- Descarga la última versión de [WebGrab+Plus (Linux)](http://www.webgrabplus.com/sites/default/files/download/SW/V1.1.1/WebGrabPlusV1.1.1LINUX.rar) (V1.1.1)

Extraer el rar en el $HOME de tu usuario y renombrar el directorio a "**temp1**"

- Descargar el [fichero de upgrade patchexe\_54.zip](http://www.webgrabplus.com/sites/default/files/download/sw/V1.1.1/upgrade/patchexe_54.zip) (V1.1.1/54)

Extraer el ZIP en el $HOME de tu usuario y renombrar el directorio a "**temp2**"

- Crear un directorio donde instalar la aplicación. En mi caso: /home/luis/wg++
    
- Copiar los directorios REX y MDB desde temp1 a /home/luis/wg++
    
- Copiar WebGrab+Plus.config.xml desde temp1 a /home/luis/wg++
    
- Copiar WebGrab+Plus.exe desde temp2 a /home/luis/wg++
    
- Modifico la configuración, parto de [la lista de canales EPG](http://webgrabplus.com/node/94) que puedo descargar y utilizar con WG++. En mi caso concreto voy a usar [fuentes disponibles en España](http://www.webgrabplus.com/epg-channels#stc_33). Descargo por ejempo la del pais.com y al final el fichero de configuraicón de WG++ (WebGrab++.config.xml) que estoy usando es el siguiente:
    

totobo wg++ $ curl -Ok http://webgrabplus.com/sites/default/files/download/ini/info/zip/Spain\_elpais.com.zip
totobo wg++ $ unzip Spain\_elpais.com.zip
Archive: Spain\_elpais.com.zip
inflating: elpais.com.channels.xml
inflating: elpais.com.ini

<!--?xml version="1.0"?-->
<settings>

  <!-- Fichero de configuración de WebGrab para bajarme el EPG de movistar desde fuentes alternativas -->

  <!-- filename - Ruta completa del archivo EPG (Guia) que se generará -->
  <filename>/home/luis/wg++/guide.xml</filename>

  <!-- mode - Opción para detectar los errores que pudieran surgir, lo dejo vacío -->
  <mode></mode>

  <!-- postprocess - Extraer más metadatos de la EPG usando REX.    -->
  <!-- Recomiendan usar los siguiente:                -->
  <!-- <postprocess run="y" grab="y">n</postprocess>  -->
  <postprocess grab="y" run="y">m</postprocess>

  <!-- logging - Activar o no el logging  -->
  <logging>on</logging>

  <!-- retry - veces que debe reintentar descargar la info de una web si falla  -->
  <retry time-out="5">4</retry>

  <!-- timespan - Número de días futuros que queremos que nos descargue la guía,
                  es el número de días ademas del día de hoy, un 3 serían 4 días -->
  <timespan>3</timespan>

  <!-- update - forma que queremos utilizar para la descarga -->
  <update>f</update>

 <!-- CANALES desde elpais.com (usa el fichero elpais.com.ini) -->

 <channel update="i" site="elpais.com" site\_id="tve-1" xmltv\_id="TVE 1">TVE 1</channel>
 <channel update="i" site="elpais.com" site\_id="la-2" xmltv\_id="LA 2">LA 2</channel>
 <channel update="i" site="elpais.com" site\_id="antena-3" xmltv\_id="Antena 3">Antena 3</channel>
 <channel update="i" site="elpais.com" site\_id="cuatro" xmltv\_id="Cuatro">Cuatro</channel>
 <channel update="i" site="elpais.com" site\_id="telecinco" xmltv\_id="Telecinco">Telecinco</channel>
 <channel update="i" site="elpais.com" site\_id="la-sexta" xmltv\_id="La Sexta">La Sexta</channel>
 <channel update="i" site="elpais.com" site\_id="andalucia-tv" xmltv\_id="Andalucía TV">Andalucía TV</channel>
 <channel update="i" site="elpais.com" site\_id="aragon-television" xmltv\_id="Aragón Televisión">Aragón Televisión</channel>
 <channel update="i" site="elpais.com" site\_id="canal-extremadura" xmltv\_id="Canal Extremadura">Canal Extremadura</channel>
 <channel update="i" site="elpais.com" site\_id="canal-sur" xmltv\_id="Canal Sur">Canal Sur</channel>
 <channel update="i" site="elpais.com" site\_id="castilla-la-mancha-tv" xmltv\_id="Castilla la Mancha TV">Castilla la Mancha TV</channel>
 <channel update="i" site="elpais.com" site\_id="etb1" xmltv\_id="ETB1">ETB1</channel>
 <channel update="i" site="elpais.com" site\_id="etb2" xmltv\_id="ETB2">ETB2</channel>
 <channel update="i" site="elpais.com" site\_id="ib3-televisio" xmltv\_id="IB3 Televisió">IB3 Televisió</channel>
 <channel update="i" site="elpais.com" site\_id="radiotelevision-de-murcia" xmltv\_id="Radiotelevisión de Murcia">Radiotelevisión de Murcia</channel>
 <channel update="i" site="elpais.com" site\_id="tv-p.-asturias" xmltv\_id="TV P. Asturias">TV P. Asturias</channel>
 <channel update="i" site="elpais.com" site\_id="tv3" xmltv\_id="TV3">TV3</channel>
 <channel update="i" site="elpais.com" site\_id="telemadrid" xmltv\_id="Telemadrid">Telemadrid</channel>
 <channel update="i" site="elpais.com" site\_id="television-canaria" xmltv\_id="Televisión Canaria">Televisión Canaria</channel>
 <channel update="i" site="elpais.com" site\_id="television-de-galicia" xmltv\_id="Televisión de Galicia">Televisión de Galicia</channel>
 <channel update="i" site="elpais.com" site\_id="13-tv" xmltv\_id="13 Tv">13 Tv</channel>
 <channel update="i" site="elpais.com" site\_id="24-horas" xmltv\_id="24 Horas">24 Horas</channel>
 <channel update="i" site="elpais.com" site\_id="40-tv" xmltv\_id="40 TV">40 TV</channel>
 <channel update="i" site="elpais.com" site\_id="arirang-tv" xmltv\_id="ARIRANG TV">ARIRANG TV</channel>
 <channel update="i" site="elpais.com" site\_id="axn" xmltv\_id="AXN">AXN</channel>
 <channel update="i" site="elpais.com" site\_id="axn-white" xmltv\_id="AXN White">AXN White</channel>
 <channel update="i" site="elpais.com" site\_id="al-jazeera-english" xmltv\_id="Al Jazeera English">Al Jazeera English</channel>
 <channel update="i" site="elpais.com" site\_id="arte" xmltv\_id="Arte">Arte</channel>
 <channel update="i" site="elpais.com" site\_id="bbc-world" xmltv\_id="BBC World">BBC World</channel>
 <channel update="i" site="elpais.com" site\_id="bio" xmltv\_id="BIO">BIO</channel>
 <channel update="i" site="elpais.com" site\_id="baby-tv" xmltv\_id="Baby TV">Baby TV</channel>
 <channel update="i" site="elpais.com" site\_id="barca-tv" xmltv\_id="Barça TV">Barça TV</channel>
 <channel update="i" site="elpais.com" site\_id="bloomberg" xmltv\_id="Bloomberg">Bloomberg</channel>
 <channel update="i" site="elpais.com" site\_id="boing" xmltv\_id="Boing">Boing</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-1" xmltv\_id="C+ 1">C+ 1</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-1-...30" xmltv\_id="C+ 1 ...30">C+ 1 ...30</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-2" xmltv\_id="C+ 2">C+ 2</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-3d" xmltv\_id="C+ 3D">C+ 3D</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-accion" xmltv\_id="C+ Acción">C+ Acción</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-comedia" xmltv\_id="C+ Comedia">C+ Comedia</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-dcine" xmltv\_id="C+ DCine">C+ DCine</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-deportes" xmltv\_id="C+ Deportes">C+ Deportes</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-deportes-2-hd" xmltv\_id="C+ Deportes 2 HD">C+ Deportes 2 HD</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-futbol" xmltv\_id="C+ Fútbol">C+ Fútbol</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-golf" xmltv\_id="C+ Golf">C+ Golf</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-liga" xmltv\_id="C+ Liga">C+ Liga</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-liga-multi" xmltv\_id="C+ Liga Multi">C+ Liga Multi</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-liga-de-campeones" xmltv\_id="C+ Liga de Campeones">C+ Liga de Campeones</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-liga-de-campeones2" xmltv\_id="C+ Liga de Campeones2">C+ Liga de Campeones2</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-liga-de-campeones3" xmltv\_id="C+ Liga de Campeones3">C+ Liga de Campeones3</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-series" xmltv\_id="C+ Series">C+ Series</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-toros" xmltv\_id="C+ Toros">C+ Toros</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-toros-hd" xmltv\_id="C+ Toros HD">C+ Toros HD</channel>
 <channel update="i" site="elpais.com" site\_id="cplus-xtra" xmltv\_id="C+ Xtra">C+ Xtra</channel>
 <channel update="i" site="elpais.com" site\_id="cnbc" xmltv\_id="CNBC">CNBC</channel>
 <channel update="i" site="elpais.com" site\_id="cnn-int" xmltv\_id="CNN Int">CNN Int</channel>
 <channel update="i" site="elpais.com" site\_id="calle-13" xmltv\_id="Calle 13">Calle 13</channel>
 <channel update="i" site="elpais.com" site\_id="canal-33" xmltv\_id="Canal 33">Canal 33</channel>
 <channel update="i" site="elpais.com" site\_id="canal-cocina" xmltv\_id="Canal Cocina">Canal Cocina</channel>
 <channel update="i" site="elpais.com" site\_id="canal-decasa" xmltv\_id="Canal Decasa">Canal Decasa</channel>
 <channel update="i" site="elpais.com" site\_id="canal-panda" xmltv\_id="Canal Panda">Canal Panda</channel>
 <channel update="i" site="elpais.com" site\_id="canal-de-las-estrellas" xmltv\_id="Canal de las Estrellas">Canal de las Estrellas</channel>
 <channel update="i" site="elpais.com" site\_id="canalplus-radios" xmltv\_id="Canal+ RADIOS">Canal+ RADIOS</channel>
 <channel update="i" site="elpais.com" site\_id="caza-y-pesca" xmltv\_id="Caza y Pesca">Caza y Pesca</channel>
 <channel update="i" site="elpais.com" site\_id="clan-tve" xmltv\_id="Clan TVE">Clan TVE</channel>
 <channel update="i" site="elpais.com" site\_id="cosmopolitan" xmltv\_id="Cosmopolitan">Cosmopolitan</channel>
 <channel update="i" site="elpais.com" site\_id="cubavision" xmltv\_id="Cubavisión">Cubavisión</channel>
 <channel update="i" site="elpais.com" site\_id="dcine-espanol" xmltv\_id="DCine Español">DCine Español</channel>
 <channel update="i" site="elpais.com" site\_id="disney-channel" xmltv\_id="Disney Channel">Disney Channel</channel>
 <channel update="i" site="elpais.com" site\_id="disney-cinemagic" xmltv\_id="Disney Cinemagic">Disney Cinemagic</channel>
 <channel update="i" site="elpais.com" site\_id="disney-junior" xmltv\_id="Disney Junior">Disney Junior</channel>
 <channel update="i" site="elpais.com" site\_id="disney-xd" xmltv\_id="Disney XD">Disney XD</channel>
 <channel update="i" site="elpais.com" site\_id="divinity" xmltv\_id="Divinity">Divinity</channel>
 <channel update="i" site="elpais.com" site\_id="el-garage-tv" xmltv\_id="El Garage TV">El Garage TV</channel>
 <channel update="i" site="elpais.com" site\_id="energy" xmltv\_id="Energy">Energy</channel>
 <channel update="i" site="elpais.com" site\_id="euronews" xmltv\_id="Euronews">Euronews</channel>
 <channel update="i" site="elpais.com" site\_id="france-24" xmltv\_id="FRANCE 24">FRANCE 24</channel>
 <channel update="i" site="elpais.com" site\_id="factoria-de-ficcion" xmltv\_id="Factoría de Ficción">Factoría de Ficción</channel>
 <channel update="i" site="elpais.com" site\_id="fashiontv" xmltv\_id="FashionTV">FashionTV</channel>
 <channel update="i" site="elpais.com" site\_id="fox" xmltv\_id="Fox">Fox</channel>
 <channel update="i" site="elpais.com" site\_id="fox-crime" xmltv\_id="Fox Crime">Fox Crime</channel>
 <channel update="i" site="elpais.com" site\_id="fox-news" xmltv\_id="Fox News">Fox News</channel>
 <channel update="i" site="elpais.com" site\_id="goltv" xmltv\_id="GolTV">GolTV</channel>
 <channel update="i" site="elpais.com" site\_id="historia" xmltv\_id="Historia">Historia</channel>
 <channel update="i" site="elpais.com" site\_id="hollywood" xmltv\_id="Hollywood">Hollywood</channel>
 <channel update="i" site="elpais.com" site\_id="intereconomia" xmltv\_id="Intereconomía">Intereconomía</channel>
 <channel update="i" site="elpais.com" site\_id="la-siete" xmltv\_id="La Siete">La Siete</channel>
 <channel update="i" site="elpais.com" site\_id="la-tienda-en-casa" xmltv\_id="La tienda en casa">La tienda en casa</channel>
 <channel update="i" site="elpais.com" site\_id="mtv-espana" xmltv\_id="MTV ESPAÑA">MTV ESPAÑA</channel>
 <channel update="i" site="elpais.com" site\_id="mtv-rocks" xmltv\_id="MTV ROCKS">MTV ROCKS</channel>
 <channel update="i" site="elpais.com" site\_id="mezzo" xmltv\_id="Mezzo">Mezzo</channel>
 <channel update="i" site="elpais.com" site\_id="mezzo-live-hd" xmltv\_id="Mezzo Live HD">Mezzo Live HD</channel>
 <channel update="i" site="elpais.com" site\_id="motors-tv" xmltv\_id="Motors TV">Motors TV</channel>
 <channel update="i" site="elpais.com" site\_id="mexico-travel-channel" xmltv\_id="México Travel Channel">México Travel Channel</channel>
 <channel update="i" site="elpais.com" site\_id="nhk-world" xmltv\_id="NHK World">NHK World</channel>
 <channel update="i" site="elpais.com" site\_id="nick-jr" xmltv\_id="NICK JR">NICK JR</channel>
 <channel update="i" site="elpais.com" site\_id="nat-geo-wild" xmltv\_id="Nat Geo Wild">Nat Geo Wild</channel>
 <channel update="i" site="elpais.com" site\_id="nat-geographic" xmltv\_id="Nat Geographic">Nat Geographic</channel>
 <channel update="i" site="elpais.com" site\_id="neox" xmltv\_id="Neox">Neox</channel>
 <channel update="i" site="elpais.com" site\_id="nickelodeon" xmltv\_id="Nickelodeon">Nickelodeon</channel>
 <channel update="i" site="elpais.com" site\_id="nitro" xmltv\_id="Nitro">Nitro</channel>
 <channel update="i" site="elpais.com" site\_id="nova" xmltv\_id="Nova">Nova</channel>
 <channel update="i" site="elpais.com" site\_id="odisea" xmltv\_id="Odisea">Odisea</channel>
 <channel update="i" site="elpais.com" site\_id="paramount-channel" xmltv\_id="Paramount Channel">Paramount Channel</channel>
 <channel update="i" site="elpais.com" site\_id="paramount-comedy" xmltv\_id="Paramount Comedy">Paramount Comedy</channel>
 <channel update="i" site="elpais.com" site\_id="playboy-tv" xmltv\_id="Playboy TV">Playboy TV</channel>
 <channel update="i" site="elpais.com" site\_id="rt" xmltv\_id="RT">RT</channel>
 <channel update="i" site="elpais.com" site\_id="rt-en-espanol" xmltv\_id="RT en español">RT en español</channel>
 <channel update="i" site="elpais.com" site\_id="real-madrid-tv" xmltv\_id="Real Madrid TV">Real Madrid TV</channel>
 <channel update="i" site="elpais.com" site\_id="syfy" xmltv\_id="SYFY">SYFY</channel>
 <channel update="i" site="elpais.com" site\_id="sexta-3" xmltv\_id="Sexta 3">Sexta 3</channel>
 <channel update="i" site="elpais.com" site\_id="sky-news" xmltv\_id="Sky News">Sky News</channel>
 <channel update="i" site="elpais.com" site\_id="sol-musica" xmltv\_id="Sol Música">Sol Música</channel>
 <channel update="i" site="elpais.com" site\_id="sportmania" xmltv\_id="Sportmanía">Sportmanía</channel>
 <channel update="i" site="elpais.com" site\_id="super-3" xmltv\_id="Super 3">Super 3</channel>
 <channel update="i" site="elpais.com" site\_id="tcm" xmltv\_id="TCM">TCM</channel>
 <channel update="i" site="elpais.com" site\_id="tnt" xmltv\_id="TNT">TNT</channel>
 <channel update="i" site="elpais.com" site\_id="tv-record" xmltv\_id="TV RECORD">TV RECORD</channel>
 <channel update="i" site="elpais.com" site\_id="tv5monde" xmltv\_id="TV5MONDE">TV5MONDE</channel>
 <channel update="i" site="elpais.com" site\_id="tvi-internacional" xmltv\_id="TVI Internacional">TVI Internacional</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--1" xmltv\_id="Taquilla  1">Taquilla  1</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--2" xmltv\_id="Taquilla  2">Taquilla  2</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--3" xmltv\_id="Taquilla  3">Taquilla  3</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--4" xmltv\_id="Taquilla  4">Taquilla  4</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--5" xmltv\_id="Taquilla  5">Taquilla  5</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--6" xmltv\_id="Taquilla  6">Taquilla  6</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--7" xmltv\_id="Taquilla  7">Taquilla  7</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla--8" xmltv\_id="Taquilla  8">Taquilla  8</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla-hd" xmltv\_id="Taquilla HD">Taquilla HD</channel>
 <channel update="i" site="elpais.com" site\_id="taquilla-hd-2" xmltv\_id="Taquilla HD 2">Taquilla HD 2</channel>
 <channel update="i" site="elpais.com" site\_id="teledeporte" xmltv\_id="Teledeporte">Teledeporte</channel>
 <channel update="i" site="elpais.com" site\_id="telesur" xmltv\_id="Telesur">Telesur</channel>
 <channel update="i" site="elpais.com" site\_id="trace-sport-stars" xmltv\_id="Trace Sport Stars">Trace Sport Stars</channel>
 <channel update="i" site="elpais.com" site\_id="vh1" xmltv\_id="VH1">VH1</channel>
 <channel update="i" site="elpais.com" site\_id="viajar" xmltv\_id="Viajar">Viajar</channel>
 <channel update="i" site="elpais.com" site\_id="xplora" xmltv\_id="Xplora">Xplora</channel>
 <channel update="i" site="elpais.com" site\_id="yomvi" xmltv\_id="YOMVI">YOMVI</channel>

</settings>

- Creo un pequeño script para arrancar y ejecutar el programa de forma más sencilla, recuerda darle permisos de ejecución con chmod 755 wg++.sh

#!/bin/bash
#

cd /home/luis/wg++
mono Webgrab+Plus.exe "/home/luis/wg++"

A partir de ahora ya podrías ejecutar el programa y ver que todo funciona correctamente y se genera el fichero guide.xml. El siguiente paso será la integración con TVHeadEnd

## Integración con TVHeadEnd

Vamos a interactuar con TVHeadEnd ([fuente](http://www.webgrabplus.com/node/376)), mejor dicho, vamos a pasarle todo el EPG para que él a su vez lo procese y pueda entregárselo a los "consumidores" (Raspberry's con XBMC).

- Descargo el fichero "tv\_grab" diseñado por WebGraph+Plus para interactuar con TVHeadEnd y lo salvo como /usr/bin/tv\_grab\_wg++

\# wget -O /usr/bin/tv\_grab\_wg++ http://www.webgrabplus.com/sites/default/files/tv\_grab\_wg.txt
# chmod +x /usr/bin/tv\_grab\_wg++

Dejo aquí una copia, notar que he cambiado la segunda línea del script para que deje el fichero guide.xml en mi directorio de trabajo: xmltv\_file\_location=/home/luis/wg++/guide.xml

#!/bin/bash
xmltv\_file\_location=/home/luis/wg++/guide.xml
dflag=
vflag=
cflag=
qflag=
if (( $# < 1 )) then   cat "$xmltv\_file\_location"   exit 0 fi for arg do     delim=""     case "$arg" in     #translate --gnu-long-options to -g (short options)        --description) args="${args}-d ";;        --version) args="${args}-v ";;        --capabilities) args="${args}-c ";;        --quiet) args="${args}-q ";;        #pass through anything else        \*) \[\[ "${arg:0:1}" == "-" \]\] || delim="\\""            args="${args}${delim}${arg}${delim} ";;     esac done #Reset the positional parameters to the short options eval set -- $args while getopts "dvcq" option do     case $option in         d)  dflag=1;;         v)  vflag=1;;         c)  cflag=1;;         q)  qflag=1;;         \\?) printf "unknown option: -%s\\n" $OPTARG             printf "Usage: %s: \[--description\] \[--version\] \[--capabilities\] \\n" $(basename $0)             exit 2             ;;     esac >&2
done

if \[ "$dflag" \]
then
   printf "$0 is a wrapper grabber around WebGrab+Plus\\n"
fi
if \[ "$vflag" \]
then
   printf "0.2\\n"
fi
if \[ "$cflag" \]
then
   printf "baseline\\n"
fi
if \[ "$qflag" \]
then
   printf ""
fi

exit 0

- Puedes ejecutar el grabber desde la línea de comandos para comprobar que funciona correctamente, verás que va mostrando en el propio terminal un montón de datos xmltv.

\# /usr/bin/tv\_grab\_wg++
:

- Pero lo más importante es configurar TVHeadEnd. Rearráncalo y entre medias pídele que busque este nuevo grabber. El programa tv\_find\_grabbers ejecuta una búsqueda de todos los ejecutables "/usr/bin/tv\_grab\*" que puedan ser "grabbers", aquellos que respondan de forma adecuada se habilitarán y podrán ser seleccionados en su configuración (vía Web).

totobo ~ # /etc/init.d/tvheadend stop
totobo ~ # tv\_find\_grabbers
/usr/bin/tv\_grab\_wg++|/usr/bin/tv\_grab\_wg++ is a wrapper grabber around WebGrab+Plus
totobo ~ # /etc/init.d/tvheadend start

- Configuro TVHeadEnd y selecciono el nuevo grabber "XMLTV: tv\_grab\_wg++".

[![webgrabconfig](https://www.luispa.com/wp-content/uploads/2015/02/webgrabconfig.png)](https://www.luispa.com/wp-content/uploads/2015/02/webgrabconfig.png)

- Por último, programo en el cron que se ejecute el grabber diariamente, al hacerlo desde el directorio cron.daily será alrededor de las 3.00am.

#!/bin/bash
#
export PATH=/usr/sbin:/usr/bin:/sbin:/bin:.
cd /home/luis/wg++
./wg++.sh > /dev/null 2>&1

## Tvheadend en contenedor Docker

He creado un contenedor Docker para ejecutar Tvheadend, échale un ojo, estos son los proyectos donde tienes todo lo necesario:

- Registry Hub de Docker [luispa/base-tvheadend](https://registry.hub.docker.com/u/luispa/base-tvheadend/)
- Conectado (Automatizado) con el proyecto en [GitHub base-tvheadend](https://github.com/LuisPalacios/base-tvheadend)
- Relacionado con este otro proyecto en GitHub para ejecutarlo a través de FIG: [GitHub servicio-tvheadend](https://github.com/LuisPalacios/servicio-tvheadend)

Si no conoces Docker, te dejo estos enlaces: [¿qué es Docker?](https://www.luispa.com/?p=874) y [otros casos de uso de Docker](https://www.luispa.com/?p=172)
