---
title: "WebGrab+Plus con TVHeadEnd en Linux"
date: "2015-02-03"
categories: apuntes
tags: cisco hiperconvergencia ucs
excerpt_separator: <!--more-->
---

_**[WebGrab+Plus](http://www.webgrabplus.com)**_ es un recolector de Guías EPG multi-sitio capaz de trabajar de manera incremental. Se baja la programación y genera un fichero en formato XMLTV que puedes usar para alimentar a tu media center o a Tvheadend. Primero probé a [instalarlo en un MacOSX](https://www.luispa.com/?p=1522) y ahora (este artículo) toca instalarlo en mi [servidor Linux](https://www.luispa.com/?p=7) y por supuesto **integrarlo con ![Tvheadend](/assets/img/original/){: width="730px" padding:10px }**.

Este apunte está relacionado con este otro: ![Tvheadend y Movistar TV (2016)](/assets/img/original/4571) . Aquí describo como configurar WebGrab para bajarme el EPG desde otras fuentes. El programa WebGrab+Plus genera un fichero guide.xml en formato XMLTV que hay que pasarle a TVHeadEnd y que este a su vez actualiza a los XBMC (en Raspberri Pi en mi caso){: width="730px" padding:10px }.

![twr-xbmc](/assets/img/original/twr-xbmc-1024x498.png){: width="730px" padding:10px } [dropshadowbox align="center" effect="lifted-both" width="550px" height="" background_color="#ffffff" border_width="1" border_color="#dddddd" ]

**Importante**: He creado un contenedor Docker con Tvheadend ya listo para su uso, mira al final del artículo. El contenedor Docker con WebGrab+Plus es una asignatura que todavía tengo pendiente :-).

[/dropshadowbox]

## Instalación de WebGrab+Plus en Linux

Pasos para realizar la instalación completa de WebGrab+Plus en un equipo linux:

- Instalar ![Mono](/assets/img/original/){: width="730px" padding:10px } en Linux. En Gentoo la última disponible es la versión 3.2.8. Seguramente te funcione con cualquiera superior a la 2.10.

\=dev-lang/mono-3.2.8   ~amd64

totobo ~ # emerge -v dev-lang/mono

- Descarga la última versión de ![WebGrab+Plus (Linux)](/assets/img/original/WebGrabPlusV1.1.1LINUX.rar) (V1.1.1){: width="730px" padding:10px }

Extraer el rar en el $HOME de tu usuario y renombrar el directorio a "**temp1**"

- Descargar el ![fichero de upgrade patchexe_54.zip](/assets/img/original/54){: width="730px" padding:10px }

Extraer el ZIP en el $HOME de tu usuario y renombrar el directorio a "**temp2**"

- Crear un directorio donde instalar la aplicación. En mi caso: /home/luis/wg++
    
- Copiar los directorios REX y MDB desde temp1 a /home/luis/wg++
    
- Copiar WebGrab+Plus.config.xml desde temp1 a /home/luis/wg++
    
- Copiar WebGrab+Plus.exe desde temp2 a /home/luis/wg++
    
- Modifico la configuración, parto de [la lista de canales EPG](http://webgrabplus.com/node/94) que puedo descargar y utilizar con WG++. En mi caso concreto voy a usar ![fuentes disponibles en España](/assets/img/original/epg-channels#stc_33). Descargo por ejempo la del pais.com y al final el fichero de configuraicón de WG++ (WebGrab++.config.xml){: width="730px" padding:10px } que estoy usando es el siguiente:
    

totobo wg++ $ curl -Ok http://webgrabplus.com/sites/default/files/download/ini/info/zip/Spain_elpais.com.zip
totobo wg++ $ unzip Spain_elpais.com.zip
Archive: Spain_elpais.com.zip
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

- Creo un pequeño script para arrancar y ejecutar el programa de forma más sencilla, recuerda darle permisos de ejecución con chmod 755 wg++.sh

#!/bin/bash
#

cd /home/luis/wg++
mono Webgrab+Plus.exe "/home/luis/wg++"

A partir de ahora ya podrías ejecutar el programa y ver que todo funciona correctamente y se genera el fichero guide.xml. El siguiente paso será la integración con TVHeadEnd

## Integración con TVHeadEnd

![fuente](/assets/img/original/376)), mejor dicho, vamos a pasarle todo el EPG para que él a su vez lo procese y pueda entregárselo a los "consumidores" (Raspberry's con XBMC){: width="730px" padding:10px }.

- Descargo el fichero "tv_grab" diseñado por WebGraph+Plus para interactuar con TVHeadEnd y lo salvo como /usr/bin/tv_grab_wg++

# wget -O /usr/bin/tv_grab_wg++ http://www.webgrabplus.com/sites/default/files/tv_grab_wg.txt
# chmod +x /usr/bin/tv_grab_wg++

Dejo aquí una copia, notar que he cambiado la segunda línea del script para que deje el fichero guide.xml en mi directorio de trabajo: xmltv_file_location=/home/luis/wg++/guide.xml

#!/bin/bash
xmltv_file_location=/home/luis/wg++/guide.xml
dflag=
vflag=
cflag=
qflag=
if (( $# < 1 )) then   cat "$xmltv_file_location"   exit 0 fi for arg do     delim=""     case "$arg" in     #translate --gnu-long-options to -g (short options)        --description) args="${args}-d ";;        --version) args="${args}-v ";;        --capabilities) args="${args}-c ";;        --quiet) args="${args}-q ";;        #pass through anything else        *) [[ "${arg:0:1}" == "-" ]] || delim="\""            args="${args}${delim}${arg}${delim} ";;     esac done #Reset the positional parameters to the short options eval set -- $args while getopts "dvcq" option do     case $option in         d)  dflag=1;;         v)  vflag=1;;         c)  cflag=1;;         q)  qflag=1;;         \?) printf "unknown option: -%s\n" $OPTARG             printf "Usage: %s: [--description] [--version] [--capabilities] \n" $(basename $0)             exit 2             ;;     esac >&2
done

if [ "$dflag" ]
then
   printf "$0 is a wrapper grabber around WebGrab+Plus\n"
fi
if [ "$vflag" ]
then
   printf "0.2\n"
fi
if [ "$cflag" ]
then
   printf "baseline\n"
fi
if [ "$qflag" ]
then
   printf ""
fi

exit 0

- Puedes ejecutar el grabber desde la línea de comandos para comprobar que funciona correctamente, verás que va mostrando en el propio terminal un montón de datos xmltv.

# /usr/bin/tv_grab_wg++
:

- Pero lo más importante es configurar TVHeadEnd. Rearráncalo y entre medias pídele que busque este nuevo grabber. El programa tv_find_grabbers ejecuta una búsqueda de todos los ejecutables "/usr/bin/tv_grab*" que puedan ser "grabbers", aquellos que respondan de forma adecuada se habilitarán y podrán ser seleccionados en su configuración (vía Web).

totobo ~ # /etc/init.d/tvheadend stop
totobo ~ # tv_find_grabbers
/usr/bin/tv_grab_wg++|/usr/bin/tv_grab_wg++ is a wrapper grabber around WebGrab+Plus
totobo ~ # /etc/init.d/tvheadend start

- Configuro TVHeadEnd y selecciono el nuevo grabber "XMLTV: tv_grab_wg++".

![webgrabconfig](/assets/img/original/webgrabconfig.png){: width="730px" padding:10px }

- Por último, programo en el cron que se ejecute el grabber diariamente, al hacerlo desde el directorio cron.daily será alrededor de las 3.00am.

#!/bin/bash
#
export PATH=/usr/sbin:/usr/bin:/sbin:/bin:.
cd /home/luis/wg++
./wg++.sh > /dev/null 2>&1

## Tvheadend en contenedor Docker

He creado un contenedor Docker para ejecutar Tvheadend, échale un ojo, estos son los proyectos donde tienes todo lo necesario:

- Registry Hub de Docker ![luispa/base-tvheadend](/assets/img/original/){: width="730px" padding:10px }
- Conectado (Automatizado) con el proyecto en ![GitHub base-tvheadend](/assets/img/original/base-tvheadend){: width="730px" padding:10px }
- Relacionado con este otro proyecto en GitHub para ejecutarlo a través de FIG: ![GitHub servicio-tvheadend](/assets/img/original/servicio-tvheadend){: width="730px" padding:10px }

Si no conoces Docker, te dejo estos enlaces: [¿qué es Docker?](https://www.luispa.com/?p=874) y ![otros casos de uso de Docker](/assets/img/original/?p=172){: width="730px" padding:10px }
