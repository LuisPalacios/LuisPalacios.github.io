---
title: "EPG con WebGrab+Plus en MacOSX"
date: "2015-02-02"
categories: apuntes
tags: linux nuc
excerpt_separator: <!--more-->
---

_**[WebGrab+Plus](http://www.webgrabplus.com)**_ es un recolector de Guías EPG multi-sitio capaz de trabajar de manera incremental. Se baja la programación y genera un fichero en formato XMLTV que puedes usar para alimentar a tu media center. Recomiendo leer este ![post](/assets/img/original/index.php?topic=485.0){: width="730px" padding:10px } donde documenta bastante bien su uso.

  Nota: En Febrero de 2016 encontré una alternativa a conseguir el EPG, consiste en bajárselo directamente de un sitio donde lo publican, échale un ojo a [este apunte](https://www.luispa.com/?p=4571), busca por EPG.     ![EPG_fading](/assets/img/original/EPG_fading.jpg){: width="730px" padding:10px }  

En mi caso estoy usando la combinación de WebGrab+Plus para la recolecta, **TVHeadEnd** para gestionar los canales + el EPG y presentárselo a mi media center basado en ![Raspberry + XBMC](/assets/img/original/?p=1225){: width="730px" padding:10px }.

## Instalación y ejecución en MacOSX

![fuente](/assets/img/original/os-x)){: width="730px" padding:10px } que he seguido para instalar y ejecutar WebGrab+Plus en MacOSX:

- Descargar e instalar ![Mono MDK](/assets/img/original/) (Mono Development Kit que ya trae incluído el MRE). En mi caso he probado con Mono 3.12.2){: width="730px" padding:10px }
    
- Descarga la ![WebGrab+Plus (Linux) última versión](/assets/img/original/WebGrabPlusV1.1.1LINUX.rar) (V1.1.1){: width="730px" padding:10px }
    

Extraer el rar en el escritorio y renombrar la carpeta a "**temp1**"

- Descargar el ![fichero de upgrade patchexe_54.zip](/assets/img/original/54){: width="730px" padding:10px }

Extraer el ZIP en el escritorio y renombrar la carpeta a "**temp2**"

- Crear un directorio donde instalar la aplicación. En mi caso: /Users/luis/priv/wg++
    
- Copiar los directorios REX y MDB desde temp1 a /Users/luis/priv/wg++
    
- Copiar WebGrab+Plus.config.xml desde temp1 a /Users/luis/priv/wg++
    
- Copiar WebGrab+Plus.exe desde temp2 a /Users/luis/priv/wg++
    
- Configurar WG++ (echa un ojo a la ![documentación oficial](/assets/img/original/324)){: width="730px" padding:10px }
    

Descargar el fichero ![dummy.ini](/assets/img/original/dummy.ini){: width="730px" padding:10px }, además modifica el fichero WebGrab++.config.xml. Al final debería quedarte lo siguiente en ambos ficheros:

<!--?xml version="1.0"?-->
<settings>
   
  <!-- Ejemplo básico para probar WebGrab, fuente: http://webgrabplus.com/node/324 -->
  <!-- El fichero original WebGrab++.config.xml con documentación lo encuentras en el .rar original -->

  <!-- filename - Ruta completa del archivo EPG (Guia) que se generará -->
  <filename>/Users/luis/priv/wg++/WebGrab/guide.xml</filename>

  <!-- mode - Opción para detectar los errores que pudieran surgir, lo dejo vacío -->
  <mode></mode>
  
  <!-- postprocess - Extraer más metadatos de la EPG usando REX.    -->
  <!--               Recomiendan usar los siguiente:                -->
  <!--               <postprocess run="y" grab="y">n</postprocess>  -->
  <postprocess grab="y" run="n">mdb</postprocess>

  <!-- logging - Activar o no el logging  -->
  <logging>on</logging>
  
  <!-- retry - veces que debe reintentar descargar la info de una web si falla  -->
  <retry time-out="5">4</retry>
  
  <!-- timespan - Número de días futuros que queremos que nos descargue la guía, 
                  es el número de días ademas del día de hoy, un 3 serían 4 días -->
  <timespan>0</timespan>
  
  <!-- update - forma que queremos utilizar para la descarga -->
  <update>f</update>
 
  <!-- Ejemplo de canal dummy -->
  <!-- Una vez que funcione, consultar http://webgrabplus.com/node/94 para lista de canales/sitios -->
  <channel site="dummy" site_id="xx" update="i" xmltv_id="Dummy">Dummy</channel>
 
</settings>

**------------------------------------------------------------------------------------------------
* @header_start
* WebGrab+Plus ini for grabbing EPG data from TvGuide websites
* @Site: your_site_name
* @MinSWversion: V0
*   none
* @Revision 2 - [15/07/2014] Jan van Straaten
*   added a choice of more than one show per day
* @Revision 1 - [21/05/2014] Jan van Straaten
*   added timezone
* @Revision 0 - [22/04/2013] Jan van Straaten
*   none
* @Remarks:
*   A SiteIni that creates a dummy xmltv guide with one or more show every day
* @header_end
**------------------------------------------------------------------------------------------------
site {cultureinfo=en-GB|timezone=UTC+00:00|maxdays=10.1|charset=utf-8|skip=<skip>noskip</skip>|keepindexpage}
url_index {url|http://this-page-intentionally-left-blank.org/} * just an empty page
index_showsplit.scrub {single||||} * copies the html page
index_showsplit.modify {clear}
scope.range {(splitindex)|end}
*
* the shows for one day:
index_variable_element.modify {addstart|00:00-23:59##Full Day Show####} * one show per day example
*index_variable_element.modify {addstart|00:00-12:00##First show####12:00-00:00##Second show####} * 2 shows per day example
*index_variable_element.modify {addstart|00:00-06:00##Night show####6:00-12:00##Morning show####12:00-18:00##Afternoon show####18:00-00:00##Evening show####} * 4 shows per day example
*
index_showsplit.modify {addstart()|'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'####'index_variable_element'}
index_showsplit.modify {replace()|####|\|} * convert to multi
end_scope
index_start.scrub {single()|||-|-}
index_stop.scrub {single()|-||#|#}
index_title.scrub {single()|##|||}
*index_start.modify {addstart|00:00}
*index_stop.modify {addstart|23:59}
index_title.modify {addstart|dummy program - }
index_description.modify {addstart|Created by WebGrab+Plus, your favorite TVguide Grabber.}

- Prepára un script para arrancar y ejecutar el programa desde la línea de comandos (Terminal.app):

#!/bin/bash
#
cd /Users/luis/priv/wg++
mono WebGrab+Plus.exe "/Users/luis/priv/wg++"

Ejecutamos el programa:

obelix:wg++ luis$ ./wg++.sh

         WebGrab+Plus/w MDB & REX Postprocess -- version 1.54.6/0.01

                           Jan van Straaten
                         Francis de Paemeleere

        many thanks to Paul Weterings and all the contributing users
        ------------------------------------------------------------

file /Users/luis/priv/wg++/WebGrab/guide.xml not found, creating a new one ..

update requested for - 1 - out of - 1 - channels for 1 day(s)
update mode - full - for all channels

      i=index  .=same  c=change  g=gab  r=replace  n=new

Dummy updating, using site DUMMY, mode full
in

job finished  ..  done in 1 seconds

- Hemos usado una configuración muy simple para poder "probar" que todo va bien, debería haberse bajado el canal "dummy" con una programación de un día. El resultado lo verás en el fichero guide.xml

<U+FEFF><?xml version="1.0" encoding="UTF-8"?>
<tv generator-info-name="WebGrab+Plus/w MDB &amp; REX Postprocess -- version 1.54.6/0.01 -- Jan van Straaten" generator-info-url="http://www.webgrabplus.com">
  <channel id="Dummy">
    <display-name lang="en">Dummy</display-name>
    <url>http://www.dummy</url>
  </channel>
  <programme start="20150202000000 +0000" stop="20150202235900 +0000" channel="Dummy">
    <title lang="en">dummy program - Full Day Show</title>
    <desc lang="en">Created by WebGrab+Plus, your favorite TVguide Grabber.(n)</desc>
  </programme>
</tv>

- Consulta [la lista de canales EPG](http://webgrabplus.com/node/94) que puedes descargar y utilizar con WG++. En mi caso concreto voy a usar ![fuentes disponibles en España](/assets/img/original/epg-channels#stc_33){: width="730px" padding:10px }. Descargo por ejempo la del pais.com

obelix:wg++ luis$ curl -Ok http://webgrabplus.com/sites/default/files/download/ini/info/zip/Spain_elpais.com.zip
obelix:wg++ luis$ unzip Spain_elpais.com.zip
Archive: Spain_elpais.com.zip
inflating: elpais.com.channels.xml
inflating: elpais.com.ini

- Modifico el fichero WebGrab++.config.xml, que se apoya en elpais.com.ini y ejecuto de nuevo el programa

<!--?xml version="1.0"?-->
<settings>
   
  <!-- Ejemplo básico para probar WebGrab, fuente: http://webgrabplus.com/node/324 -->
  <!-- El fichero original WebGrab++.config.xml con documentación lo encuentras en el .rar original -->

  <!-- filename - Ruta completa del archivo EPG (Guia) que se generará -->
  <filename>/Users/luis/priv/wg++/WebGrab/guide.xml</filename>

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

**------------------------------------------------------------------------------------------------
* @header_start
* WebGrab+Plus ini for grabbing EPG data from TvGuide websites
* @Site: elpais.com
* @MinSWversion: V1.1.1/49
* @Revision 0 - [24/03/2014] Steve Wildmore
*     - creation
* @Remarks:
* @header_end
**------------------------------------------------------------------------------------------------

site {url=elpais.com|timezone=UTC+01:00|maxdays=3.1|cultureinfo=es-ES|charset=UTF-8|titlematchfactor=90|episodesystem=onscreen|ratingsystem=ES}

*
url_index{url|http://servicios.elpais.com/programacion-tv/canal/|channel|/}
index_showsplit.scrub {multi(exclude="scope=")|<div class="rejilla-canal">|<tr>|</tr>|<div class="col-d">}
*
scope.range {(indexshowdetails)|end}
index_temp_1.scrub {single|<h4>|onclick="ventanaPase(this,'|');">|}
index_temp_2.modify {substring(type=char)|'index_temp_1' 0 2}
index_urlshow {url|http://servicios.elpais.com/programacion-tv/pases/####/|<h4>|onclick="ventanaPase(this,'|');">|}
index_urlshow.modify {replace|####|'index_temp_2'}
index_urlshow.modify {addend|.html}
index_urlshow.modify {clear('index_temp_1' "")} * programs without details

index_start.scrub {single|<td class="hora">|<strong>|</strong>|<h4>}
index_title.scrub {single|<td class="hora">|<h4>|</h4>|}
index_title.modify {cleanup(tags="<"">")}
index_description.scrub {single|</h4>|<p>|</p>|</td>}
index_category.scrub {single|<td class="masinfo">|<ul>\n<li>|</li>\n<li|</td>}
end_scope

title.scrub {single|<div class="cab estirar">|<h2>|</h2>|}
productiondate.scrub {single|<div class="cab estirar">|<li>Año: <strong>|</strong>}
rating.scrub {single|<div class="cab estirar">|<li>Calificación: <strong>|</strong>}
actor.scrub {multi(separator=",")|<div class="cab estirar">|<li>Actor: <strong>|</strong>}
director.scrub {multi(separator=",")|<div class="cab estirar">|<li>Director: <strong>|</strong>}
writer.scrub {multi(separator=",")|<div class="cab estirar">|<li>Guionista: <strong>|</strong>}
description.scrub {single|<div class="cab estirar">|</div>\n<p>|</p>|}
category.scrub {multi(separator=" / ")|<div class="cab estirar">|<p class="ante">|</p>|<h2>}

*
**  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _
**      #####  CHANNEL FILE CREATION (only to create the xxx-channel.xml file)
**
** @auto_xml_channel_start
*scope.range {(channellist)|end}
*url_index{url|http://servicios.elpais.com/programacion-tv}
*index_site_channel.scrub {multi|generalistas:|<img alt="|" src="|<div class="sh m0" id="modulo0">}
*index_site_id.scrub {multi|generalistas:|<li> <a href="/programacion-tv/canal/|/"><span><img alt=|<div class="sh m0" id="modulo0">}
*index_site_id.modify {cleanup(removeduplicates=equal,100 link="index_site_channel")}
*end_scope
** @auto_xml_channel_end

obelix:wg++ luis$ ./wg++.sh

         WebGrab+Plus/w MDB & REX Postprocess -- version 1.54.6/0.01

                           Jan van Straaten
                         Francis de Paemeleere

        many thanks to Paul Weterings and all the contributing users
        ------------------------------------------------------------

processing /Users/luis/priv/wg++/WebGrab/guide.xml ..............................................................................................................................................
update requested for - 137 - out of - 137 - channels for 4 day(s)
update mode - full - for all channels

      i=index  .=same  c=change  g=gab  r=replace  n=new

TVE 1 updating, using site ELPAIS.COM, mode full
innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn

LA 2 updating, using site ELPAIS.COM, mode full
innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn

:

 

Una vez que tenemos el fichero xml ya podemos tratarlo con el programa que más nos guste y que sepa interpretarlo. Ahí no voy a entrar, en mi caso lo integro con TVHeadEnd y además todo lo que he descrito aquí lo hago en un equipo Linux (es prácticamente lo mismo), así que consulta el apunte ![WebGrab+Plus con TVHeadEnd en Linux](/assets/img/original/?p=1587&preview=true){: width="730px" padding:10px }.
