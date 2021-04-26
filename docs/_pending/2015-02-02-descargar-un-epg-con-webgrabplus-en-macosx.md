---
title: "EPG con WebGrab+Plus en MacOSX"
date: "2015-02-02"
categories: 
  - "apuntes"
---

_**[WebGrab+Plus](http://www.webgrabplus.com)**_ es un recolector de Guías EPG multi-sitio capaz de trabajar de manera incremental. Se baja la programación y genera un fichero en formato XMLTV que puedes usar para alimentar a tu media center. Recomiendo leer este [post](http://www.xbmcmania.com/index.php?topic=485.0) donde documenta bastante bien su uso.

  Nota: En Febrero de 2016 encontré una alternativa a conseguir el EPG, consiste en bajárselo directamente de un sitio donde lo publican, échale un ojo a [este apunte](https://www.luispa.com/?p=4571), busca por EPG.     [![EPG_fading](https://www.luispa.com/wp-content/uploads/2015/02/EPG_fading.jpg)](https://www.luispa.com/wp-content/uploads/2015/02/EPG_fading.jpg)  

En mi caso estoy usando la combinación de WebGrab+Plus para la recolecta, **TVHeadEnd** para gestionar los canales + el EPG y presentárselo a mi media center basado en [Raspberry + XBMC](https://www.luispa.com/?p=1225).

## Instalación y ejecución en MacOSX

Estos son los pasos ([fuente](http://www.webgrabplus.com/documentation/installation/os-x)) que he seguido para instalar y ejecutar WebGrab+Plus en MacOSX:

- Descargar e instalar [Mono MDK](http://www.mono-project.com/download/) (Mono Development Kit que ya trae incluído el MRE). En mi caso he probado con Mono 3.12.2)
    
- Descarga la [WebGrab+Plus (Linux) última versión](http://www.webgrabplus.com/sites/default/files/download/SW/V1.1.1/WebGrabPlusV1.1.1LINUX.rar) (V1.1.1)
    

Extraer el rar en el escritorio y renombrar la carpeta a "**temp1**"

- Descargar el [fichero de upgrade patchexe\_54.zip](http://www.webgrabplus.com/sites/default/files/download/sw/V1.1.1/upgrade/patchexe_54.zip) (V1.1.1/54)

Extraer el ZIP en el escritorio y renombrar la carpeta a "**temp2**"

- Crear un directorio donde instalar la aplicación. En mi caso: /Users/luis/priv/wg++
    
- Copiar los directorios REX y MDB desde temp1 a /Users/luis/priv/wg++
    
- Copiar WebGrab+Plus.config.xml desde temp1 a /Users/luis/priv/wg++
    
- Copiar WebGrab+Plus.exe desde temp2 a /Users/luis/priv/wg++
    
- Configurar WG++ (echa un ojo a la [documentación oficial](http://webgrabplus.com/node/324))
    

Descargar el fichero [dummy.ini](http://webgrabplus.com/sites/default/files/download/ini/info/SiteIni.Pack/Misc/dummy.ini), además modifica el fichero WebGrab++.config.xml. Al final debería quedarte lo siguiente en ambos ficheros:

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
  <channel site="dummy" site\_id="xx" update="i" xmltv\_id="Dummy">Dummy</channel>
 
</settings>

\*\*------------------------------------------------------------------------------------------------
\* @header\_start
\* WebGrab+Plus ini for grabbing EPG data from TvGuide websites
\* @Site: your\_site\_name
\* @MinSWversion: V0
\*   none
\* @Revision 2 - \[15/07/2014\] Jan van Straaten
\*   added a choice of more than one show per day
\* @Revision 1 - \[21/05/2014\] Jan van Straaten
\*   added timezone
\* @Revision 0 - \[22/04/2013\] Jan van Straaten
\*   none
\* @Remarks:
\*   A SiteIni that creates a dummy xmltv guide with one or more show every day
\* @header\_end
\*\*------------------------------------------------------------------------------------------------
site {cultureinfo=en-GB|timezone=UTC+00:00|maxdays=10.1|charset=utf-8|skip=<skip>noskip</skip>|keepindexpage}
url\_index {url|http://this-page-intentionally-left-blank.org/} \* just an empty page
index\_showsplit.scrub {single||||} \* copies the html page
index\_showsplit.modify {clear}
scope.range {(splitindex)|end}
\*
\* the shows for one day:
index\_variable\_element.modify {addstart|00:00-23:59##Full Day Show####} \* one show per day example
\*index\_variable\_element.modify {addstart|00:00-12:00##First show####12:00-00:00##Second show####} \* 2 shows per day example
\*index\_variable\_element.modify {addstart|00:00-06:00##Night show####6:00-12:00##Morning show####12:00-18:00##Afternoon show####18:00-00:00##Evening show####} \* 4 shows per day example
\*
index\_showsplit.modify {addstart()|'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'####'index\_variable\_element'}
index\_showsplit.modify {replace()|####|\\|} \* convert to multi
end\_scope
index\_start.scrub {single()|||-|-}
index\_stop.scrub {single()|-||#|#}
index\_title.scrub {single()|##|||}
\*index\_start.modify {addstart|00:00}
\*index\_stop.modify {addstart|23:59}
index\_title.modify {addstart|dummy program - }
index\_description.modify {addstart|Created by WebGrab+Plus, your favorite TVguide Grabber.}

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

- Consulta [la lista de canales EPG](http://webgrabplus.com/node/94) que puedes descargar y utilizar con WG++. En mi caso concreto voy a usar [fuentes disponibles en España](http://www.webgrabplus.com/epg-channels#stc_33). Descargo por ejempo la del pais.com

obelix:wg++ luis$ curl -Ok http://webgrabplus.com/sites/default/files/download/ini/info/zip/Spain\_elpais.com.zip
obelix:wg++ luis$ unzip Spain\_elpais.com.zip
Archive: Spain\_elpais.com.zip
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

\*\*------------------------------------------------------------------------------------------------
\* @header\_start
\* WebGrab+Plus ini for grabbing EPG data from TvGuide websites
\* @Site: elpais.com
\* @MinSWversion: V1.1.1/49
\* @Revision 0 - \[24/03/2014\] Steve Wildmore
\*     - creation
\* @Remarks:
\* @header\_end
\*\*------------------------------------------------------------------------------------------------

site {url=elpais.com|timezone=UTC+01:00|maxdays=3.1|cultureinfo=es-ES|charset=UTF-8|titlematchfactor=90|episodesystem=onscreen|ratingsystem=ES}

\*
url\_index{url|http://servicios.elpais.com/programacion-tv/canal/|channel|/}
index\_showsplit.scrub {multi(exclude="scope=")|<div class="rejilla-canal">|<tr>|</tr>|<div class="col-d">}
\*
scope.range {(indexshowdetails)|end}
index\_temp\_1.scrub {single|<h4>|onclick="ventanaPase(this,'|');">|}
index\_temp\_2.modify {substring(type=char)|'index\_temp\_1' 0 2}
index\_urlshow {url|http://servicios.elpais.com/programacion-tv/pases/####/|<h4>|onclick="ventanaPase(this,'|');">|}
index\_urlshow.modify {replace|####|'index\_temp\_2'}
index\_urlshow.modify {addend|.html}
index\_urlshow.modify {clear('index\_temp\_1' "")} \* programs without details

index\_start.scrub {single|<td class="hora">|<strong>|</strong>|<h4>}
index\_title.scrub {single|<td class="hora">|<h4>|</h4>|}
index\_title.modify {cleanup(tags="<"">")}
index\_description.scrub {single|</h4>|<p>|</p>|</td>}
index\_category.scrub {single|<td class="masinfo">|<ul>\\n<li>|</li>\\n<li|</td>}
end\_scope

title.scrub {single|<div class="cab estirar">|<h2>|</h2>|}
productiondate.scrub {single|<div class="cab estirar">|<li>Año: <strong>|</strong>}
rating.scrub {single|<div class="cab estirar">|<li>Calificación: <strong>|</strong>}
actor.scrub {multi(separator=",")|<div class="cab estirar">|<li>Actor: <strong>|</strong>}
director.scrub {multi(separator=",")|<div class="cab estirar">|<li>Director: <strong>|</strong>}
writer.scrub {multi(separator=",")|<div class="cab estirar">|<li>Guionista: <strong>|</strong>}
description.scrub {single|<div class="cab estirar">|</div>\\n<p>|</p>|}
category.scrub {multi(separator=" / ")|<div class="cab estirar">|<p class="ante">|</p>|<h2>}

\*
\*\*  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_  \_
\*\*      #####  CHANNEL FILE CREATION (only to create the xxx-channel.xml file)
\*\*
\*\* @auto\_xml\_channel\_start
\*scope.range {(channellist)|end}
\*url\_index{url|http://servicios.elpais.com/programacion-tv}
\*index\_site\_channel.scrub {multi|generalistas:|<img alt="|" src="|<div class="sh m0" id="modulo0">}
\*index\_site\_id.scrub {multi|generalistas:|<li> <a href="/programacion-tv/canal/|/"><span><img alt=|<div class="sh m0" id="modulo0">}
\*index\_site\_id.modify {cleanup(removeduplicates=equal,100 link="index\_site\_channel")}
\*end\_scope
\*\* @auto\_xml\_channel\_end

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

 

Una vez que tenemos el fichero xml ya podemos tratarlo con el programa que más nos guste y que sepa interpretarlo. Ahí no voy a entrar, en mi caso lo integro con TVHeadEnd y además todo lo que he descrito aquí lo hago en un equipo Linux (es prácticamente lo mismo), así que consulta el apunte [WebGrab+Plus con TVHeadEnd en Linux](https://www.luispa.com/?p=1587&preview=true).
