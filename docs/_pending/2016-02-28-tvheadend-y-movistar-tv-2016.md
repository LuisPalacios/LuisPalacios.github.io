---
title: "Tvheadend y Movistar TV (2016)"
date: "2016-02-28"
categories: 
  - "apuntes"
  - "gentoo"
  - "linux"
  - "media-center"
  - "raspberry-pi"
---

En este apunte describo cómo instalar Tvheadend en un servidor Linux (**basado en Gentoo**) para ver canales IPTV que recibo a través de mi contrato Movistar Fusión TV. En esta versión utilizo **Tvheadend 4.1-1566** y un **nuevo método de descarga del EPG**. Hace un año hice la [versión del 2015](https://www.luispa.com/?p=1225) que he dejado como referencia aunque ha quedado obsoleta.

El motivo de hacer un apunte tan parecido es que han cambiado algunas cosas, pero antes me gustaría recordar una vez más que no utilizo el router oficial ni el deco de Movistar, lo he sustituido todo por un equipo linux que hace de router y agregador de canales y empleo como cliente \*Kodi en Raspberry\* para ver la televisión, así que todo lo descrito aquí está pensado, orientado y probado para funcionar así; quiero decir que no lo he probado con un router "oficial", ni con un Deco. Para entender mejor mi \*setup\* te recomiendo echarle un ojo a este apunte: [Movistar Fusión Fibra + TV + VoIP con router Linux.](https://www.luispa.com/?p=266). Después del aviso: eso no significa que no te va a funcionar con el router+deco's de Movistar TV, por supuesto que debería funcionar, pero yo no lo he probado y si sigues dicha opción recuerda que utiliza UDP y en este apunte todo lo hago con TCP (como veremos más adelante).

## Tvheadend como agregador de canales de Movistar TV

Tvheadend es un fantástico agregador de diferentes fuentes (Satélite, Tdt, IPTV). Aquí me concentro en usarlo exclusivamente como agregador de canales de Movistar TV.

[![fuentesstb2016](https://www.luispa.com/wp-content/uploads/2016/02/fuentesstb2016.png)](https://www.luispa.com/wp-content/uploads/2016/02/fuentesstb2016.png)

**MUY importante: En este apunte describo como configurar todos los canales, el epg, los logos, etc. Te recomiendo encarecidamente que si no tienes experiencia con Tvheadend hagas todo lo que está aquí descrito pero SOLO CON UN ÚNICO CANAL. Si ya has hecho una configuración y algo no te funciona (por ejemplo el EPG), mi recomendación es que empieces de nuevo desde cero (Mira cómo limpiar la configuración al final en \*trucos de mantenimiento\*) y vuelve a empezar, configura solo un único canal, ten siempre un terminal mirando el LOG del programa. Es muy importante, no intentes correr, primero verifica que te funciona todo con un único canal, que recibes el logo, que se asocia el EPG, en definitiva que aprendas a conocer cómo reacciona el programa, cómo algunas cosas no se ejecutan de manera instantánea, etc. Creo que una vez conozcas bien el programa te será más fácil pasar a configurar todos los canales.**

### Instalación

Veamos el proceso de instalación (recuerdo, mi distro linux está basada en **Gentoo**, pero si conoces bien tu Distro eso es indiferente). Nota: **sí que es importante y por tanto aviso: estoy compilando una versión descargada directamente de GitHub**, es la última versión de desarrollo disponible en el momento en el que escribí el apunte. Significa dos cosas: 1) tiene riesgo y 2) si estás usando otra versión más antigua es muy probable que muchas cosas no te funcionen. He decidido probar la última versión 4.1 porque trae cosas chulas (como importar/vincularse a un fichero M3U con los canales), pero recuerda... tiene el riesgo de reventar cada dos por tres :-)

Después del aviso: ¿cómo de inestable es? pues es bastante estable, de vez en cuando (cada 4-5 días) de repente se queda colgado. Lo que he hecho es programar en el cron que **rearranque el servicio cada día** y ya está (ver cómo al final del apunte). Dicho esto, procedo a instalar el software:

tv # cat /etc/portage/package.accept\_keywords
# tvheadend
~media-tv/tvheadend-9999 \*\*       <=== Esto es lo que hace que se baje lo "último" desde github
media-libs/libhdhomerun ~amd64

tv ~ # cat /etc/portage/package.use/tvheadend
media-tv/tvheadend avahi capmt constcw cwc dbus dvb dvbscan ffmpeg hdhomerun imagecache inotify iptv -libav satip timeshift uriparser xmltv zlib

tv ~ # emerge -v libhdhomerun
tv ~ # ln -s /usr/include/hdhomerun/ /usr/include/libhdhomerun

tv ~ # emerge -v tvheadend
:

Más avisos: Compilar una versión \*en desarrollo\* (-9999 \*) puede traerte dolores de cabeza. En mi caso utilizo Gentoo y verisones de FFMPEG que están "Hard Masked", es decir, estoy al filo del precipicio.

#### Otras distribuciones

Si trabajas con otra distribución no deberías tener ningún problema, solo asegúrate de, si quieres comparar con este apunte técnico, usar la misma versión que estoy usando yo o quizá tengas funcionalidades distintas, asegúrate de temas de permisos, usuario/grupo, opciones de compilación, librerías, etc. Temas estándar sobre paquetes de software en Linux que no cubro en este documento.

### Fichero .service para systemd

Aquí tienes el fichero **.service**, verás que hay una dependencia a un servicio que llamé \`igmpproxy.service\`, y es que, una vez más, está vinulado al montaje que uso en mi casa y que describí hace tiempo en [Movistar Fusión Fibra + TV + VoIP con router Linux](https://www.luispa.com/?p=266).

tv ~ # cat /etc/systemd/system/tvheadend.service

\[Unit\]
Description=Tvheadend TV Aggregator
After=network-online.target igmpproxy.service

\[Service\]
Type=forking
EnvironmentFile=/etc/conf.d/tvheadend
ExecStart=/usr/bin/tvheadend -f -C -u $TVHEADEND\_USER -g $TVHEADEND\_GROUP -c $TVHEADEND\_CONFIG $TVHEADEND\_OPTIONS
Restart=always
RestartSec=3

\[Install\]
WantedBy=multi-user.target

En este caso se utiliza el fichero de configuración \`/etc/conf.d/tvheadend\` para definir las variables que se utilizan en los argumentos de arranque. La más importante es el directorio de trabajo del programa que se define con \`TVHEADEND\_CONFIG=/etc/tvheadend\`. Este es el directorio en el que bucear cuando quieras ver toda la configuración de tvheadend. Ojo que usuario y grupo con el que se ejecutará el programa también son importantes :-)

tv ~ # cat /etc/conf.d/tvheadend
# See the tvheadend(1) manpage for more info.

# Run Tvheadend as this user.
TVHEADEND\_USER="tvheadend"

# Run Tvheadend as this group.
TVHEADEND\_GROUP="video"

# Path to Tvheadend config.
TVHEADEND\_CONFIG="/etc/tvheadend"

# Other options you want to pass to Tvheadend.
TVHEADEND\_OPTIONS=""

### Habilitar y arrancar

Antes de arrancarlo, te recomiendo que observes en otro terminal la salida del LOG, es muy instructivo.

tv ~ # journalctl -f    ((Ejecutarlo en otra sesión en otro terminal))

Habilito el servicio (para futuros boots) y lo arranco manualmente. La primera vez se crea una estructura de directorios nueva bajo el directorio del programa \`/etc/tvheadend\` (recuerda la variable \`TVHEADEND\_CONFIG\` que vimos antes).

tv ~ # systemctl enable tvheadend
tv ~ # systemctl start tvheadend
:
tv ~ # cd /etc/tvheadend
tv tvheadend # ls -al
total 40
drwx------ 7 tvheadend video 4096 feb 27 09:11 .
drwxr-xr-x 77 root      root  4096 feb 27 09:02 ..
drwx------ 2 tvheadend video 4096 feb 27 09:11 accesscontrol
drwx------ 2 tvheadend video 4096 feb 27 09:11 bouquet
-rw------- 1 tvheadend video  866 feb 27 09:11 config
drwx------ 3 tvheadend video 4096 feb 27 09:11 dvr
-rw-r--r-- 1 tvheadend video   22 feb 27 09:11 .lock
drwx------ 2 tvheadend video 4096 feb 27 09:11 profile

### Preparar Logos, fichero M3U y EPG

Antes de arrancar Tvheadend y configurarlo vamos a preparar tres cosas: los logos (picons) de los canales, el fichero M3U que importaré (y quedará vinculado) y los scripts que necesito para descargar y preparar el EPG. Por cierto, he dejado copia de todo esto en [este repositorio en GitHub](https://github.com/LuisPalacios/tvheadend_movistar).

**ESTOS TRES (Logos, fichero M3U y EPG) ESTÁN MUY VINCULADOS ENTRE SÍ. Por ejemplo, el nombre de los canales, el nombre de los ficheros, el identificativo del EPG, etc... fíjate bien en las descripciones que hago en estos apuntes, si te despistas puede que haya cosas que no te funcionen. Iré avisando con ejemplos.**

#### Directorio picons (para los Logos)

Hay varias formas de enfrentarse al dilema de los logos de los programas de TV, en mi caso me he decantado por uno bastate sencillo, consiste en dedicar un directorio local en el mismo ordenador donde ejecuto Tvheadend: **/etc/tvheadend/picons** y copiar ahí los ficheros. Es un directorio adicional que creo dentro del de configuración del programa por comodidad y tenerlo todo junto (puedes utilizar otro cualquiera).

El nombre del fichero jpg o png es **IMPORTANTE** porque si lo nombras de acuerdo a lo que espera Tvheadend te ahorras un montón de trabajo, así que te recomiendo que **hagas** **coincidir el nombre del fichero** **con** el **nombre del Canal**, y tenemos dos opciones:

- "Nombre del canal".png
- nombredelcanal.png   <== Esta es la opción que utilizo yo.

_**En mi caso utilizo la segunda opción**_: hago que **el nombre de los ficheros con los logos de los programas sea igual al nombre del programa que se encontrará en el M3U pero: sin espacios, en minúsculas y terminado en .png**. Un ejemplo, si el programa se llama "National Geographic HD", el nombre de su fichero con su Logo debe ser "/etc/tvheadend/picons/nationalgeographichd.png".

Creo el directorio, lo asigno los permisos adecuados y me bajo los logos.

tv tvheadend # mkdir /etc/tvheadend/picons
tv tvheadend # chown tvheadend:video /etc/tvheadend/picons
tv tvheadend # cd /etc/tvheadend/picons
tv picons # wget https://raw.githubusercontent.com/LuisPalacios/tvheadend\_movistar/master/2016/picons.tgz
tv picons # tar xvfz picons.tgz
tv picons # chown tvheadend:video \*
tv picons # ls -al
total 3000
drwx------ 2 tvheadend video    4096 feb 28 10:58 .
drwx------ 13 tvheadend video    4096 feb 27 20:44 ..
-rw-r--r-- 1 tvheadend video    3106 feb 27 21:01 0-fondo.png
-rw-r--r-- 1 tvheadend video   24054 feb 27 21:01 0hd.png
:

#### Fichero M3U

Para poder crear los canales en Tvheadend tienes de nuevo múltiples mecanismos. Vuelvo a avisar, en este apunto **estoy optando por un sistema de creación de canales muy automatizado, aprovechando una funcionalidad que se soporta en la versión 4.1**: Permite auto-importar los canales que está definidos dentro de un fichero .m3u.

El proceso es sencillo y más adelante en la sección \*Configuración de Tvheadend\* lo describo, no lo hagas ahora pero te adelanto cómo se hace: Creas una \`NETWORK\` de tipo \`IPTV AUTOMATIC NETWORK\`, vinculada a un fichero M3U del disco duro y si construyes de forma adecuada el fichero .m3u puedes ahorrarte muchas horas de trabajo.

Aquí tienes una copia de mi fichero [tv.m3u](https://raw.githubusercontent.com/LuisPalacios/tvheadend_movistar/master/2016/tv.m3u), está preparado para mi demarcación (verás que tengo configurado Telemadrid porque estoy en Madrid), está diseñado para mi \*setup\* donde empleo [http gracias a udpxy](https://www.luispa.com/?p=266#udpxy) y por supuesto tiene mis canales contratados.

Importante: si te bajas el fichero anterior verás que tiene la NUMERACIÓN DE CANALES que emplea oficialmente Movistar TV. Una de las ventajas de Tvheadend es que puedes hacer lo que quieras con la numeración de los canales y para evitar tener que asignar uno a uno el número apropiado, lo que hago es añadir (en la línea EXTINF) el número final que quiero que tenga cada canal en el fichero M3U.

Probablemente tengas que bajarte el fichero y editarlo para adecuarlo a tu caso concreto (las MRL's son distintas si usas multicast o si tienes otros canales contratados u otra demarcación). En mi caso no mantengo actualizado el fichero en el enlace anterior, si quieres una versión actualizada de la lista de canales de Movistar, te recomiendo esta fuente llamada "[LISTA ACTUALIZADA DE CANALES PARA VLC](http://www.adslzone.net/postt350532.html)" disponible en ADSL ZONE. Lo dicho, adáptalo a tu instalación. Dejo una línea comentada a continuación para explicar qué significa cada cosa:

:
#EXTINF:-1 tvh-epg="disable" tvh-chnum="1" tvh-tags="tv|Ocio y cultura",La 1 HD
http://192.168.1.1:4022/udp/239.0.0.185:8208
:

1) #EXTINF:-1 tvh-epg="disable" tvh-chnum="1" tvh-tags="tv|Ocio y cultura",La 1 HD
              |                  |             |                            |
              |                  |             |                            +--> Nombre canal
              |                  |             +---> Tags
              |                  +---> Número de canal 
              +---> EPG scan

Nombre del canal: Importante que coincida con el usado en el EPG
Tags: En este caso defino 2.
Número de canal, que quiero que se asigne al hacer el MAPPING
Deshabilito el "EPG scan" en el MUX. No lo usaré porque proveo el EPG mediante otro mecanismo. 

:
2) http://192.168.1.1:4022/udp/239.0.0.185:8208
Como decía, en mi caso utilizo HTTP porque empleo "udpxy". 

tv ~ # chown tvheadend:video /etc/tvheadend/tv.m3u

**Aquí va otro de los Avisos**. Si te fijas he puesto que el \*Nombre del canal: Importante que coincida con el usado en el EPG\*, pues eso, tenlo en cuenta porque es importantísimo. Si usas mi fichero no deberías tener problema, pero si haces el M3U tú mismo, acuérdate de este detalle.

#### EPG Grabber

Siempre he creido que el mejor método para bajarme el EPG sería el que corresponde con mi contrato, pedirlo por la VLAN2 directamente a Movistar TV utilizando su API, pero por desgracia no lo tienen documentado, el resumen de alternativas que conozco:

- Usar el API a través de la VLAN2 (no tengo la documentación)
- El trabajo [movistartv2xmltv](https://www.luispa.com/?p=1225) (que por desgracia ya **no funciona**)
- Bajarse el XMLTV desde algún sitio (**funciona**).
- Exportación desde web de Movistar TV (**funciona,** \*descubierto\* en 2017).
- Usar técnicas complejas como [WebGrab+Plus](https://www.luispa.com/archivos/1587) (en mi caso lo uso para complementar)

Hago mención aquí a un trabajo muy interesante ([Add-on para KODI](https://sourceforge.net/projects/movistartv/)) pero por desgracia el autor no ha liberado los fuentes a la fecha de escribir este apunte.

#### Opciones:

Aquí un resumen de las últimas dos opciones que he utilizado en mi caso:

- _(2016) Empecé con los Ficheros pre-creados_: La solución que he estado utilizando durante el 2016 consiste en bajarse directamente el fichero XMLTV dirariamente desde algún sitio donde "alguien" sea tan generoso como para dejarlo. Hasta Julio/2016 utilizaba este [proyecto que descarga el fichero desde rytec en la comunidad vuplus](http://www.iptvsaga.com/xmltv-epg-graber-batch-script-for-windows/), a partir de esa fecha dejó de funcionar y he pasado, gracias **Josu** (zona comentarios), a usar [esta otra fuente desde tododream](http://epg.tododream.com/latinmunich_xmltv-movistar-spain.gz) que viene de este [apunte hecho por el usuario latinmunic en el foro de tododream](http://www.tododream.com/foro/e2-plugins/177073-nuevo-epg-movistar-enigma2-crossepg.html).

- _(2017) Descargo desde la Web Movistar TV_: Novedad en el 2017, gracias a **Neoshinji** (zona comentarios), compartió un método muy interesante, aprovechando que Movistar TV permite exportar la programación desde su página web y **además lo complemento** con [WebGrab+Plus](https://www.luispa.com/?p=1587) para completar los canales que me faltan.

#### Ficheros pre-creados

Creo una serie de scripts que se encargan de descargar el EPG directamente a un fichero XMLTV. Puedes **[encontrar los scripts en mi repositorio de GitHub](https://github.com/LuisPalacios/tvheadend_movistar)**. El script principal se llama [descarga\_guia.sh](https://github.com/LuisPalacios/tvheadend_movistar/blob/master/2016/descarga_guia.sh "descarga_guia.sh"), ejecuta la descarga y el renombrado de canales coincidan con los nombres de canal que doy de alta en Tvheadend. Los he creado/instalado en un usuario normal donde además configuro el cron para que se ejecute una vez al día, a las 07:00 am (es más que suficiente).

luis@tv ~ $ crontab -e     ((( Añade la línea siguiente))) 
0 7 \* \* \* /home/luis/guia/descarga\_guia.sh

:

luis@tv ~ $ crontab -l
0 7 \* \* \* /home/luis/guia/descarga\_guia.sh

Una vez que tengo todo preparado ejecuto el script manualmente para que haga una primera descarga de la guia.xml. Quiero tenerla antes de añadir los canales..

luis@tv ~ $ /home/luis/guia/descarga\_guia.sh

Después de ejecutarlo deberías tener el fichero \`/tu/directorio/destino/guia.xml\` perfectamente creado y con contenido.

NOTA: Recuerda, hasta Julio/2016 estaba usando el script [descarga\_guia\_vuplus.sh](https://github.com/LuisPalacios/tvheadend_movistar/blob/master/2016/descarga_guia_vuplus.sh) pero dejó de funcionar. He creado una versión llamada [descarga\_guia\_tododream.sh](https://github.com/LuisPalacios/tvheadend_movistar/blob/master/2016/descarga_guia_tododream.sh) gracias a un enlace que nos ha pasado Josu (sección comentarios).

#### Descarga web Movistar TV (2017)

Esto es nuevo en el 2017, gracias a **Neoshinji** (zona comentarios, 4 de enero) nos ha dado una pista muy buena sobre un método que desconocía.

Movistar TV tiene una página desde la cual se puede [EXPORTAR LA PROGRAMACIÓN](http://comunicacion.movistarplus.es/guiaProgramacion/exportarProgramacion), si conectas verás que puedes seleccionar qué cadenas y formato (xml, csv, excel, texto) prefieres. Mirando en más detalle vemos que se trata de un programa en Javascript y dicho programa, una vez eliges lo que quieres, realizará un **POST** parametrizado a dicha web para solicitar la exportación.

Después de un par de días investigando he creado un programa en Javascript para **node.js** que voy a ejecutar periódicamente en mi mismo servidor linux donde ejecuto Tvheadend:

- Proyecto [**tvhstar** en GitHub](https://github.com/LuisPalacios/tvhstar)

El objetivo era que crease el fichero epg en formato XMLTV: **guia.xml**,  pero ya puestos le he ido añadiendo más cosas:

- Descarga periódica de la programación de TV (EPG) desde la web de Movistar y creación de un fichero XMLTV compatible con Tvheadend
- Creación de los ficheros tvHOME.m3u y tvREMOTE.m3u para ser consumidos por Tvheadend como fuentes para redes IPTV dinámicas
- Logos de los programas de TV en formato 800x400 para ser consumidos por Tvheadend (y sus clientes).

#### Completo canales que faltan con WebGrab+Plus (2017)

Una vez que tengo el fichero XMLTV usando el proyecto anterior estoy completando algunos canales que me faltan (como por ejemplo Telemadrid) apoyándome en WebGrab+Plus. Estos scripts crean un fichero adicional XMLTV (guia-wg.xml).

- Proyecto  [**tvhwg en GitHub**](https://github.com/LuisPalacios/tvhwg)

#### Configurar Tvheadend para "leer" los ficheros XMLTV

Lo que describo a continuación se debe hacer para cada fichero XMLTV que tengas. En este ejemplo verás que hablo del guia.xml que genera mi proyecto "tvhstar", pero tendrás que hacer lo mismo con el "guia-wg.xml". Una vez tenemos el fichero \`/tu/directorio/destino/guia.xml\`configuro Tvheadend para que lo "consuma" y lo guarde en su propio formato en su propio directorio.

Tvheadend se va a **apropiar**, a través de un "Grabber **interno**", de la programación. En nuestro caso, que ya tenemos el fichero en el formato final (XMLTV), lo único  que hacemos es crear dicho grabber como un ejecutable que simplemente hace un \`cat\` del fichero. Cuando Tvheadend lo reciba lo transformará a su propio formato en el fichero \`/etc/tvheadend/epgdb.v2\`.

Creo el fichero /usr/bin/tv\_grab\_movistartv. Recuerda cambiar sus permisos a ejecutable y la próxima vez que ejecutes tvheadend lo descubrirá automáticamente (tvheadend encuentra todos los ficheros que empiezan por /usr/bin/tv\_grab\* durante su arranque).

No te olvides de cambiar la línea donde pone "xmltv\_file\_location" por el path completo al fichero final XMLTV que quieres que procese (en este primer ejemplo \`guia.xml\`).

https://gist.github.com/LuisPalacios/b6242399229b87d86d28f9db540f66bd

**IMPORTANTE:** Si tienes más ficheros XMLTV pues creas otro fichero, por ejemplo /usr/bin/tv\_grab\_w para el que creo con mi complemento de WebGrab+Plus.

Ahora que tenemos ya una idea de los ficheros entremos en harina y empecemos a configurar Tvheadend. Hasta ahora lo único que hemos hecho antes de arrancar Tvheadend y configurarlo es preparar tres cosas: los logos (picons) de los canales, el fichero M3U que importaré (y quedará vinculado) y los scripts que necesito para descargar y preparar el EPG.

## Configuración de Tvheadend

A partir de aquí configuramos desde el interfaz Web. Arranco Tvheadend y desde un navegador conectamos con el Administrador Web de Tvheadend: **http://tu-servidor.dominio.com:9981**.

tv # systemctl start tvheadend

#### Configuración general

[![ng-tvh-0](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-0-1024x755.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-0.png)

Verás como automáticamente **arranca el asistente para realizar una configuración guiada. Yo prefiero cancelarlo** y hacer una configuración manual. Lo primero que hago es cambiar parámetros de la configuración general: Configuración->General->Base.

- **User interface level: Expert**
- **Default Languages Selected: **Spanish y English****
- **Channel Icon Path: _file:///etc/tvheadend/picons/%c.png  (%C.png)_**
- **Channel Icon Name Scheme: Service name picons**

El parámetro "Channel Icon Path" sirve para decirle a Tvheadend: Busca los logos de los programas en el directorio /etc/tvheadend y que tengan como nombre del fichero el nombre del programa, sin espacios, sin símbolos raros, todo en minúsculas. Puedes usar %c o %C (apropiada para canales con caracteres diacríticos, he empezado a usarla recientemente). La opción "Service name picons" es la que elimina los espacios en el nombre.

[![ng-tvh-10](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-10.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-10.png)

Este path al icono del canal lo verás más adelante en la opción **User Icon** en Configuración->Channel/EPG->Channels. Verás cómo Tvheadend "pre-rellena" dicho campo con lo mismo que pone en Channel Icon Path pero obviamente sustituyendo %c o %C por el nombre del canal. Lo que quiero anticiparte es que siempre podrás volver aquí a cambiar "Channel Icon path / Channel icon name scheme" y desde Configuración->Channel/EPG->Channels podrás pedir que se regeneren todos los User Icon's con el cambio que hagas aquí.

#### Configuro el EPG Grabber

Necesitas tener un fichero en formato XMLTV (ya vimos antes las opciones), en micaso lo llamé \`guia.xml\`. Necesitas además un script \`tv\_grab\*\` que simplemente usará Tvheadend para \*leer\* dicha \`guia.xml\`. En mi ejemplo el script \`/usr/bin/tv\_grab\_movistartv\` buscará fichero /tu/directorio/guia.xml y le hará un simple \`cat\`. Tvheadend absorverá esos datos, los interpretará, buscará qué canales tiene ya configurados con esos nombres y si hay coincidencias las utilizará. Ah!, y lo salvará todo dentro de un fichero llamado \`/etc/tvheadend/epgdb.v2\` ([por cierto, aquí tienes más información sobre el Epgdb](https://tvheadend.org/projects/tvheadend/wiki/Epgdb)).

Nota: Si tienes más de un fichero XMLTV simplemente repite exactamente lo mismo y crea un segundo grabber interno, de hecho es lo que yo hago para añadir el que genero con WebGrab+Plus.

Por lo tanto, lo que vamos a hacer es configurar Tvheadend para indicarle que a partir de ahora debe hacer \*EPG Grabbing\*. Entra en \`Configuration->Channel/EPG->EPG Grabber Modules\`. Deberías ver el grabber de movistar (tvheadend escanea el directorio /usr/bin en busca de ficheros que empiezan por tv\_grab\*). Áctivalo (enable) y desactiva el resto (disable). Ojo!, en cuanto le das al botón del Save verás en el log (journalctl -f) cómo hace el parse del EPG.

[![](https://www.luispa.com/wp-content/uploads/2017/01/tvhgrabbers2-1024x452.png)](https://www.luispa.com/wp-content/uploads/2017/01/tvhgrabbers2.png)

Configura la periodicidad en la que Tvheadend ejecuta el grabber. ¿Qué es esto?, simplemente estás diciendole a Tvheadend cada cuanto tiempo debe ejecutar el programa \`/usr/bin/tv\_grab\*\`. Observa que usa el mismo formato que crontab. En mi caso recordarás que tengo un script que se va a internet a bajarse el EPG, así que configuro el \*grabber\* de Tvheadend para que lo leo aproximadamente media hora después.

[![ng-tvh-13](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-13.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-13.png)

Vale, ya tenemos \*programado y configurado\* el EPG Grabber, pero obviamente no funciona nada todavía, porque hay que crear las fuentes de los canales, los propios canales, asociarlos al EPG. Nota: \*el orden NO es importante\*, yo estoy siguiendo un orden que te \*ahorrará tiempo\*, simplemente.

#### Añado una red nueva IPTV

Añado una red nueva de tipo **IPTV Automática** (significa que va a importar desde un M3U): Configuración->DBV Inpurts->Network.

- **Network name: iptv**
- **Maximum # of input streams: 3 (Al terminar lo volveremos a dejar a 0)**
- **URL: file:///etc/tvheadend/tv.m3u**
- **Maximum timeout (seconds): 2 (Puedes incluso poner 1, al terminar lo volveremos a dejar en 15)**
- **Idle Scan Muxes: (x) marcado (Al terminar lo desmarcaremos)**
- **EIT time offset: Local server time**
- **Re-fetch period (mins): 60** No lo cambio, pero podrías poner un 1

[![ng-tvh-11](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-11.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-11.png)

En cuanto le das al botón "create" lo que ocurre es lo siguiente. Tvheadend analiza el fichero M3U, importa cada una de las líneas en MUXES. Gracias a tener "input streams: 3" y "idle scan muxes: activo" estamos pidiendo que se quede analizando de forma continua los muxes, que lo haga de tres en tres, compruebe si funcionan y si es así los "añada" como SERVICEs. En mi caso, mi fichero m3u, tengo 108 líneas que se escanean de 3 en 3, por lo tanto tarda unos cuantos minutos en terminar. Termina cuando tienes el mismo número de SERVICES que MUXES.

Nota sobre el parámetro "Re-fetch period". Indica cada cuanto tiempo debe releer el fichero M3U para configurar los cambios que detecte. Muy interesante ponerlo a '1min' si estás haciendo pruebas.

[![tvh-14](https://www.luispa.com/wp-content/uploads/2016/02/tvh-14.png)](https://www.luispa.com/wp-content/uploads/2016/02/tvh-14.png)

[![tvh-15](https://www.luispa.com/wp-content/uploads/2016/02/tvh-15.png)](https://www.luispa.com/wp-content/uploads/2016/02/tvh-15.png)

Una vez que termina (el número de MUXES==número de SERVICES) ya puedes cambiar la configuración del NETWORK, es decir volver a dejar en sus valors de por defecto parámetros como input streams, idle scan muxes, maximum timeout, etc.

- Maximum timeout (seconds): 15
- Maximum # of input streams: 0
- Idle Scan Muxes: ( )
- Re-fetch period: 60

El siguiente paso consiste en crear los canales. Entra en SERVICES y haz click en Mapp All Services

[![ng-tvh-16](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-16.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-16.png)

Ve a CHANNELS, verás que tienen asignado el logo adecuado (según el nombre del canal, en minúsculas y sin espacios...); **pero nos falta el EPG**

[![ng-tvh-17](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-17.png)](https://www.luispa.com/wp-content/uploads/2016/02/ng-tvh-17.png)

Podemos hacer un truco para que nos "autocomplete" el nombre del EPG. Si te fijas en los canales todos tienen la opción "Automatically Map EPG Source" así que: 1) abajo a la derecha donde pone "per page" pon "all", 2) selecciona TODOS los canales, 3) haz click en Edit, deshabilitalos, 4) Apply, 5) sin salir habilitalos de nuevo, 6) Apply, Boom!! verás cómo automáticamente todos los canales cuyo nombre sea el mismo que el del EPG se auto-asociarán. Esto te evitará mucho trabajo, algunos quedarán pendientes de asociar, pero serán muy pocos, así que haz tú la asociación manualmente (no te olvides !!!!).

[![tvh-18](https://www.luispa.com/wp-content/uploads/2016/02/tvh-18.png)](https://www.luispa.com/wp-content/uploads/2016/02/tvh-18.png)

#### ¿qué pasa con el EPG?

Llegados a este punto ya has terminado y puedes disfrutar de esta nueva versión de Tvheadend 4.1. Lo que te puede ocurrir es que NO ves todavía el EPG y el motivo es que Tvheadend se puede tomar con mucha calma este tema, es decir, puedes tener todo perfectamente configurado pero hasta que le toque un ciclo de lectura, asociación y activación del EPG no lo verás. Mira la sección de Trucos de mantenimiento donde creo que puedes encontrar consejos útiles.

Si estás trasteando con el EPG y no te funciona: 1) Para tvheadend. 2) Borra el fichero \`/etc/tvheadend/epgdb.v2\`. 3) Arranca el log en otro terminal y 4) arranca de nuevo Tvheadend, verás que se recrea el \`epgdb.v2\`.

tv ~ # cd /etc/tvheadend/
tv tvheadend # ls -al epgdb.v2
-rw------- 1 tvheadend video 3031661 mar 25 19:24 epgdb.v2
tv tvheadend # rm epgdb.v2
tv tvheadend # systemctl stop tvheadend

(( EN OTRO TERMINAL SIEMPRE MIRA EL LOG ))
tv # journalctl -f -u tvheadend

(( VUELVE A ARRANCAR tvheadend: Verás que el fichero epgdb se recrea de nuevo al cabo de un rato ))
tv tvheadend # systemctl start tvheadend

#### ¿re-nombrar los picons?

No necesitas hacer nada si has seguido las instrucciones hasta aquí. En esta sección describo un truco interesante si quieres utilizar una nomenclatura distinta para el nombre de los picons, puedes pedirle a Tvheadend que renombre el campo "User icon" de TODOS los canales a la vez.

Si cambias los parámetros "Channel icon path y/o Channel icon name scheme" en Configuration->General->Base, sigue los siguientes pasos para re-crear el nombre del canal en el campo User icon de TODOS los canales: Ve a Configuration->Channel/EPG->Channels 1) abajo a la derecha donde pone "per page" pon "all", 2) selecciona TODOS los canales, 3) haz click en Reset icons (se borrará User icon en todos), 4) pulsa en Save, Boom!! verás cómo automáticamente se regenera el nombre de nuevo en todos los canales.

## Canales simultáneos

En los comentarios de abajo se consultó sobre el número máximo de canales simultáneos soportados. Hacía tiempo que no lo probaba así que dejo aquí los resultados de las pruebas. Notar que hago todas las pruebas desde un equipo OSX utilizando múltiples instancias de VLC. Es mucho más rápido (y barato) que poner raspberry's :-).

### Prueba 1: múltiples VLC's usando RTP (Multicast) en directo, sin tvheadend.

Consigo abrir hasta 10 canales HD distintos simultáneos con VLC (~99.5Mbps). Utilizo URI's que piden los streams en modo RTP (Multicast) de forma directa sin pasar por tvheadend:

#EXTINF:-1,\[000\] Movistar+ HD
rtp://@239.0.5.185:8208
#EXTINF:-1,\[001\] La 1 HD
rtp://@239.0.0.185:8208
:

Utilizo el siguiente script para lanzar múltiples instancias de VLC en OSX.

#!/bin/bash
# Script para ver la TV directamente desde VLC
#
open -na /Applications/VLC.app/Contents/MacOS/VLC --args /Users/luis/priv/TV/0-MovistarTV\_RTP\_HD.m3u --deinterlace-mode=blend --deinterlace=-1

En el gráfico podemos ver todos los canales reproduciendose simultáneamente y cómo consume aproximadamente ~99.5Mbps en la vlan2 a través de mi router (linux). Los VLC's acceden directamente al router, no vía tvheadend.

[![9canales](https://www.luispa.com/wp-content/uploads/2016/05/9canales.jpg)](https://www.luispa.com/wp-content/uploads/2016/05/9canales.jpg)

### Prueba 2: tvheadend con canales configurados para usar RTP/Multicast

En esta segunda prueba abro 11 canales HD distintos (11 instancias VLC) simultáneas (95,3Mbps). En esta ocasión voy a través de tvheadend, así que he añadido unos cuantos canales al fichero /etc/tvheadend/tv.m3u usando RTP, le pongo un número de canal y un nombre distintos para que me aparezcan y no se confunda con los que ya tenía.

:
#EXTINF:-1 tvh-epg="disable" tvh-chnum="210" tvh-tags="tv|Entretenimiento",RTP Movistar+ HD
rtp://@239.0.5.185:8208
#EXTINF:-1 tvh-epg="disable" tvh-chnum="211" tvh-tags="tv|Entretenimiento",RTP La 1 HD
rtp://@239.0.0.185:8208
:

Descargo la nueva lista de canales. Se puede hacer desde tu servidor tvheadend con: http://tvheadend.server.org:9981/playlist/channels

:
#EXTINF:-1 logo="http://tvheadend.server.org:9981/imagecache/167" tvg-id="058471559a7ad089c26d395b12345678",Movistar+
http://tvheadend.server.org:9981/stream/channelid/1433502725?ticket=0CCF3D5A07BC3E0F3A5EFE44068502DF12345678&profile=pass
#EXTINF:-1 logo="http://tv.parchis.org:9981/imagecache/207" tvg-id="3d1dd75176c47386c37b50bf12345678",La 1 HD
http://tvheadend.server.org:9981/stream/channelid/1373052221?ticket=FA06FE51437BCBCA504B71D9683D4DAE12345678&profile=pass
:

[![11canalesHD](https://www.luispa.com/wp-content/uploads/2016/05/11canalesHD.jpg)](https://www.luispa.com/wp-content/uploads/2016/05/11canalesHD.jpg)

### Prueba 3: tvheadend a través de udpxy

No conseguía pasar de 3 canales y he descubierto que la razón no podía ser más simple, udpxy sirve un máximo de 3 clientes por defecto, y si quieres soportar más solo tienes que usar el argumento '-c'. He corregido mi apunte [Movistar Fusión Fibra + TV + VoIP con router Linux](https://www.luispa.com/?p=266#udpxy) para reflejarlo.

Repito las pruebas desde OSX con VLC, le pido que conecte con el servidor Tvheadend y a este a su vez que vaya a través de UDPXY.

Fichero M3U usado en el Servidor donde corre tvheadend

:
#EXTINF:-1 tvh-epg="disable" tvh-epg="disable" tvh-chnum="0" tvh-tags="tv|Info",Movistar+
http://192.168.1.1:4022/udp/239.0.5.185:8208
#EXTINF:-1 tvh-epg="disable" tvh-chnum="1" tvh-tags="tv|Ocio y cultura",La 1 HD
http://192.168.1.1:4022/udp/239.0.0.185:8208
:

Fichero M3U usado en el OSX con VLC. Este fichero lo puedes descargar desde tu servidor tvheadend con: http://tvheadend.server.org:9981/playlist/channels

:
#EXTINF:-1 logo="http://tvheadend.server.org:9981/imagecache/167" tvg-id="058471559a7ad089c26d395b12345678",Movistar+
http://tvheadend.server.org:9981/stream/channelid/1433502725?ticket=0CCF3D5A07BC3E0F3A5EFE44068502DF12345678&profile=pass
#EXTINF:-1 logo="http://tv.parchis.org:9981/imagecache/207" tvg-id="3d1dd75176c47386c37b50bf12345678",La 1 HD
http://tvheadend.server.org:9981/stream/channelid/1373052221?ticket=FA06FE51437BCBCA504B71D9683D4DAE12345678&profile=pass
:

[![11canalestcp](https://www.luispa.com/wp-content/uploads/2016/05/11canalestcp.jpg)](https://www.luispa.com/wp-content/uploads/2016/05/11canalestcp.jpg)

### Prueba 4: ¿dónde está el límite? ¿núm. de canales o ancho de banda?

Hago una última prueba concluyente. Intento abrir el número máximo de canales en SD y descubro que **no me deja pasar de 11 canales**, al intentar abrir el duodécimo da un error.

[![11canalesSD](https://www.luispa.com/wp-content/uploads/2016/05/11canalesSD.jpg)](https://www.luispa.com/wp-content/uploads/2016/05/11canalesSD.jpg)

### Conclusión

Según las pruebas realizadas Movistar TV por fibra (300/300) soporta hasta 11 Canales o 100Mbps, lo que antes se alcance.

## Trucos de mantenimiento

### Forzar la ejecución del EPG Grabber

Si no ves el EPG es probablemente por culpa de 1) No has asociado el nombre del EPG que viene del fichero XMLTV a tu canal o 2) No se ha ejecutado el EPG Grabber todavía. De hecho, Tvheadend se puede tomar con mucha calma este tema, es decir, puedes tener todo perfectamente configurado pero hasta que le toque un ciclo de lectura, asociación y activación del EPG no hará el grab, es un tema bastante asíncrono.

Para el primer caso (no tienes bien la configuración) solo te puedo recomendar repasar todo lo que describo en este apunte. Para el segundo caso (no se ha ejecutado el EPG Grabber), mira a ver si el siguietne truco te sirve:

Una vez que creo tener todo bien configurado fuerzo la ejecución del EPG Grabber: Paro Tvheadend, borro el fichero \`epgdb.v2\`, dejo en otro terminal ir viendo el Log, vuelvo a arrancar Tvheadend y fuerzo un EPG Scan.

tv ~ # systemctl stop tvheadend
tv ~ # cd /etc/tvheadend/
tv tvheadend # rm epgdb.v2
:
tv ~ # systemctl start tvheadend

En otro terminal tengo arrancado \`journalctl\` y observo que efectivamente re-crea todo lo relacionado con EPG pero curiosamente "no" ejecuta el grabber. Lo que decía, cosas de Tvheadend :-).

tv ~ # journalctl -f -u tvheadend
:
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module eit created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module uk\_freesat created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module uk\_freeview created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module viasat\_baltic created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module Bulsatcom\_39E created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module psip created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module opentv-skyit created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module opentv-skyuk created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module opentv-ausat created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module opentv-skynz created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module pyepg created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module xmltv created
abr 09 09:07:28 tv tvheadend\[23245\]: spawn: Executing "/usr/bin/tv\_find\_grabbers"
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module /usr/bin/tv\_grab\_combiner created
abr 09 09:07:28 tv tvheadend\[23245\]: epggrab: module /usr/bin/tv\_grab\_movistartv created

Entro en la configuración de Tvheadend y fuerzo un EPG Scan.

[![epggrab](https://www.luispa.com/wp-content/uploads/2016/04/epggrab.png)](https://www.luispa.com/wp-content/uploads/2016/04/epggrab.png)

tv ~ # journalctl -f -u tvheadend
:
abr 09 09:09:28 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv: grab /usr/bin/tv\_grab\_movistartv
abr 09 09:09:28 tv tvheadend\[23245\]: spawn: Executing "/usr/bin/tv\_grab\_movistartv"
abr 09 09:09:28 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv: grab took 1 seconds
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv: parse took 2 seconds
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv:   channels   tot=  108 new=    0 mod=    0
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv:   brands     tot=    0 new=    0 mod=    0
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv:   seasons    tot=    0 new=    0 mod=    0
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv:   episodes   tot=24178 new=24178 mod=24178
abr 09 09:09:30 tv tvheadend\[23245\]: /usr/bin/tv\_grab\_movistartv:   broadcasts tot=24178 new=23757 mod=23757

Por último, échale un ojo a la captura siguiente, en esta sección de la configuración deberías ver todas las asociaciones que se han realizado pero es importante que conozca que esta parte NO la he tenido que configurar, sino que automáticamente ha quedado así configurada por el hecho de seguir todos los pasos que he documentado.

[![epggrabberchannels](https://www.luispa.com/wp-content/uploads/2016/04/epggrabberchannels.png)](https://www.luispa.com/wp-content/uploads/2016/04/epggrabberchannels.png)

### Backup de la configuración

En mi caso, que trabajo con versiones "en desarrollo" de Tvheadend, siempre me hago copia del ejecutable y de su configuración. Usa el código de versión exacto que estás ejecutando para ambos backups, así puedes dar "marcha atrás" de forma sencilla.

tv ~ # /usr/bin/tvheadend --version
/usr/bin/tvheadend: version 4.1-1116~gf51239c-dirty
tv ~ # cp /usr/bin/tvheadend /usr/bin/tvheadend-4.1-1116~gf51239c-dirty

tv ~ # systemctl stop tvheadend
tv ~ # cd /etc/tvheadend/
tv tvheadend # tar cvfz /directorio/destino/del/backup/fecha-tvheadend-4.1-1116~gf51239c-dirty
tv tvheadend # systemctl start tvheadend

### Restaurar un backup de la configuración

**OJO!! que aquí se usa el comando \`rm -fr\` y ya sabes lo peligroso que es. Mucho quidadito :-)**. Lo dicho, si quieres recuperar un backup de la configuración:

tv ~ # systemctl stop tvheadend
tv ~ # rm -fr /etc/tvheadend/
tv ~ # mkdir /etc/tvheadend
tv ~ # cd /etc/tvheadend/
tv tvheadend # tar xvfz /directorio/destino/del/backup/backup\_tvheadend\_fecha.tgz tv ~ # systemctl start tvheadend

### Limpiar la configuración

**OJO!! de nuevo, un ejemplo con el comando \`rm -fr\` y ya sabes lo peligroso que es**. Si en el futuro quieres empezar con una configuración completamente limpia o si quieres volver a empezar de cero necesitarás hacer lo siguiente (sin tener que reinstalar el software). Fíjate que salvo los logos de los programas y también el fichero M3U temporalmente.

tv ~ # mv /etc/tvheadend/picons /tmp
tv ~ # mv /etc/tvheadend/tv.m3u /tmp
tv ~ # systemctl stop tvheadend
tv ~ # rm -fr /etc/tvheadend
tv ~ # mkdir /etc/tvheadend
tv ~ # mv /tmp/picons /etc/tvheadend
tv ~ # mv /tmp/tv.m3u /etc/tvheadend
tv ~ # cd /etc/tvheadend
tv ~ # chown -R tvheadend:video picons/ tv.m3u
tv ~ # systemctl start tvhe/adend

### Trabajo con los servicios Systemd

Estos son los comandos más utilizados para habilitar, des-habilitar, arrancar o parar el servicio

tv ~ # systemctl enable tvheadend
tv ~ # systemctl disable tvheadend
tv ~ # systemctl start tvheadend
tv ~ # systemctl stop tvheadend

### Rearrancar Tvheadend cada cierto tiempo

Lo avisaba al principio del apunte, aquí describo una versión \*en desarrollo\* y acepto que pueda \*petar\* de vez en cuando. De hecho, cada 4 o 5 días de repente se queda colgado. Lo que he hecho es programar que el servicio se re-arranque a las 4 de la mañana todos los días, que no veo la tele :-), lo hago con **systemd**:

- Fichero /etc/systemd/system/tvh-restart.timer

\[Unit\]
Description=Rearrancar Tvheadend a las 4:00

\[Timer\]
OnCalendar=\*-\*-\* 04:00:00
Unit=tvh-restart.service

\[Install\]
WantedBy=timers.target

- Fichero /etc/systemd/system/tvh-restart.service

\[Unit\]
Description=Rearranco Tvheadend

\[Service\]
Type=oneshot
ExecStart=/usr/bin/systemctl try-restart tvheadend.service

- Habilito y arranco el **.timer (no el .service)**.

tv ~ # systemctl enable tvh-restart.timer
tv ~ # systemctl start tvh-restart.timer

- Si quieres ver los timers

tv ~ # systemctl list-timers --all

- Solo si modificas los ficheros y quieres que interprete las nuevas modificaciones no olvides:

tv ~ # systemctl daemon-reload

* * *
