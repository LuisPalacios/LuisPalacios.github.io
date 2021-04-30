---
title: "Asistente de filtrado de correo en Linux"
date: "2015-01-09"
categories: apuntes
tags: macosx peakhour snmp
excerpt_separator: <!--more-->
---

Este apunte trata sobre cómo automatizar el filtrado del correo electrónico con un sistema desatendido en Linux, es decir, delegarle la reorganización del correo y que nos ahorre algo de trabajo.

Hay varias formas de conseguirlo y ésta es una de las más sencillas y productivas que conozco, me topé con este software hace unos meses y me ha dado muy buen resultado, así que he decidido documentarlo aprovechando que lo estoy migrando a un contenedor Docker.

Se trata de ![imapfilter](/assets/img/original/X11){: width="730px" padding:10px }. Reconozco que al principio me costó hacerme con su fichero de configuración, pero una vez superado promete resolver todos los requisitos de filtrado, y lo que es mejor, no hace falta hacer prácticamente nada en los servidores de correo.

![imapfilter](/assets/img/original/imapfilter1.png){: width="730px" padding:10px }

## Objetivo

¿Cuál es el problema que queremos resolver?. Cualquier programa de correo decente es capaz de aplicar reglas de filtrado, pero el problema al que nos enfrentamos es que hoy en día tenemos varias cuentas de correo, varios dispositivos inteligentes, mucho spam y mucho ham (correo bueno).

El objetivo es ponerle algo de cordura, contar con un “asistente” único centralizado que filtre al máximo ese volumen tan grande, sin necesidad de programar reglas en todos nuestros clientes o en los servidores (al menos contamos con una cuenta personal y otra laboral). Reconozco que no es una herramienta para el usuario tradicional, sino para quien tiene múltiples cuentas de correo (y está habituado a trabajar con Linux).

## Imapfilter

Imapfilter es un motor de filtrado de correo basado en ![Lua](/assets/img/original/). La arquitectura es simple: en un único sitio ejecutamos imapfilter que se irá conectando vía IMAP a cada uno de tus servidores, hará sus tareas de forma desatendida, analizará y actuará: marcar, mover o borrar. Una cosa que tiene que me gusta mucho es que puedes mover correos entre cuentas distintas (por ejemplo para tener centralizado el archivado de correos en una cuenta IMAP que dedicas solo para hacer backups){: width="730px" padding:10px }

Soporta “imap-idle”, es decir, puede pedirle al servidor que le notifique cuando el inbox cambia, de modo que reaccionará de forma casi instantánea ante cambios.

- Nota: Para evitar confusiones, por ejemplo ver entrar un mail desde tu ordenador y que desaparezca de forma casi inmediata porque imapfilter lo ha movido a otro buzón, lo que puedes hacer es programar una regla en tu servidor para que entrege en un buzón “Pre-Inbox“, que imapfilter haga su magia en él y luego mueva lo "bueno" al Inbox real.

## Instalación y configuración

La instalación es sencilla, aunque depende de la distribución tengas, pero básicamente sería: Descarga ![imapfilter](/assets/img/original/imapfilter){: width="730px" padding:10px }, crear el directorio ~/.imapfilter en tu usuario, crear el fichero de configuración ~/.imapfilter/config.lua y por último ejecutar imapfilter

- Instalación en Gentoo: emerge -v imapfilter
- Instalación compilando desde los fuentes (así hago en mi ![Dockerfile](/assets/img/original/Dockerfile)){: width="730px" padding:10px }

 
:
# apt-get update && apt-get -y install make git liblua5.2-dev libssl-dev libpcre3-dev
:
# git clone https://github.com/lefcha/imapfilter.git
# cd /root/imapfilter && make INCDIRS=-I/usr/include/lua5.2 LIBLUA=-llua5.2 && make install
:

 

## Contenedor imapfilter en Docker

Como dije al principio, llevo tiempo con imapfilter en mi servidor con Gentoo pero llegó el momento de migrarlo a un contenedor basado en Docker:

- Repositorio en el registry hub de Docker: ![luispa/base-imapfilter](/assets/img/original/){: width="730px" padding:10px }
- Página del proyecto en GitHub: ![base-imapfilter](/assets/img/original/base-imapfilter){: width="730px" padding:10px }

## Ejemplos de configuración

En mi contenedor utilizo una instancia de imapfilter por cada cuenta de correo. La razón reside en que empleo la técnica de un loop infinito con imap-idle para que el servidor notifique los cambios y despierte al programa. Dado que imapfilter no soporta imap-idle multicuenta entonces es necesario tener varias instancias.

- Cuenta personal

imapfilter -c /root/.imapfilter/cuenta-personal.lua

\------------------------
-- Opciones globales --
------------------------

-- Numero de segundos a esperar ante no respuestas
options.timeout = 60
-- Crear la carpeta destino si al ir a escribir un mensaje no existe
options.create = true
-- Normalmente los mensajes que se marcaron como a borrar se borrarán 
-- al cerrar el buzon. Al poner 'expunge' a true se borran de forma inmediata
options.expunge = true
-- Cerrar la carpeta en uso al terminar las operaciones, implica que se
-- eliminen, en ese momento, los mensajes marcados como a borrar.
options.close = true
-- Implica que las carpetas creadas automáticamente sean suscritas (visibles).
options.subscribe = true
-- Activo la opción de usar STARTTLS por el puerto 443. Nota: En mi servidor
-- IMAP he desactivado el uso de SSL por estar desaconsejado.
options.starttls = true
-- Ignorar los certificados. NOTA: Opción MUY peligrosa si no sabes lo que 
-- estás haciendo. Cuando se conecta con un servidor SSL/TLS y esta opción 
-- está en "false" entonces "no" se muestra su certificado y se pide confirmación
-- al usuario antes de aceptarlo. Cuando está en 'true' (valor por defecto) sí 
-- se pide confirmación. Solo puedo recomendar ponerlo en 'false' si se 
-- tiene un control absoluto sobre el servidor, en caso contrario dejarlo en 'true'
options.certificates = false
-- Opciones para recuperar al máximo de errores del servidor
options.reenter = false
options.recover = errors

----------------
-- Cuentas   --
----------------
--
-- Crear una entrada para cada cuenta de correo sobre la que quiero actuar.
-- En este caso voy a leer desde mail.midominio.com, y en este ejemplo la
-- mayoría de los mails los borraré o los mandaré a cuarentena, para que 
-- sea analizado por otro contenedor "chatarrero" con spamassassin/amavis/clamav

cuentaPersonal = IMAP {
     server = 'mail.midominio.com',
     username = 'usuario@midominio.com',
     password = 'micontraseña',
}

cuentaCuarentena = IMAP {
     server = 'mail.midominio.com',
     username = 'spam-cuarentena@midominio.com',
     password = 'micontraseña',
}

---------------------
-- Loop infinito  --
---------------------
--
-- Cada 10 minutos se relee el fichero config-CUENTA-aux.lua o cada
-- vez que se modifica, por ejemplo para cambiar las rules. 
--
-- Con este loop garantizo que si el administrador quiere 
-- cambiar una rule lo pueda hacer. Si estoy siendo ejecutado
-- en un contenedor de Docker y el fichero config-CUENTA-aux.lua está
-- en un directorio persistente entonces consigo que se pueda
-- modificar y este script se de cuenta.
--

_, timestamp = pipe_from('stat -c %Y /root/.imapfilter/config-personal-aux.lua')
while (true) do

    dofile('/root/.imapfilter/config-personal-aux.lua')

    if not cuentaPersonal.INBOX:enter_idle() then
       posix.sleep(300)
    else
       print('salgo de enter_idle()')    
    end
end

\--
-- check_status()
-- --------------------------------------------------------------------
-- 
-- Obtiene el estado actual del mailbox y devuelve tres valores: 
-- número de mensajes existentes
-- número de mensajes recientes no leidos. 
-- número de mensajes no vistos
-- 
cuentaPersonal.INBOX:check_status()
cuentaCuarentena.INBOX:check_status()

-----------------
-- Funciones  --
-----------------
--
-- parseRules para filtrar los mensajes usando una tabla de reglas

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleMove = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    if subresults:move_messages( entry["moveto"] ) == false then
      print("No puedo mover los menssajes !")
    end
  end
end

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleDelete = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    if subresults:delete_messages() == false then
      print("No puedo borrar los mensajes !")
    end
  end
end

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleFlag = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    subresults:add_flags({ 'Exec', '\\Seen' })
    subresults:unmark_seen()
  end
end

-----------------------
-- Filtros:         --
-----------------------
--

pre_filtersMovePersonal = {

  -- Emisores y/o temas que se son SPAM y que automáticamente quiero cargarme... 
  --
  { header = "From", p = "", moveto = cuentaCuarentena['INBOX'] },
  { header = "Subject", p = "", moveto = cuentaCuarentena['INBOX']  },
}

pre_filtersDeletePersonal = {

  -- Aquí pongo todos los mails que quiero cargarme directamente.. 
  --
  { header = "From", p = "" },

}

---------------------------
-- Ejecución principal  --
---------------------------
--

-- Leo todo el correo Personal
    allmsgsPersonal  = cuentaPersonal.INBOX:select_all()

-- Aplico las reglas al correo Personal
    ruleDelete(allmsgsPersonal, pre_filtersDeletePersonal)
    ruleMove(allmsgsPersonal, pre_filtersMovePersonal)
    

- Cuenta trabajo

imapfilter -c /root/.imapfilter/cuenta-trabajo.lua

\------------------------
-- Opciones globales --
------------------------

-- Numero de segundos a esperar ante no respuestas
options.timeout = 60
-- Crear la carpeta destino si al ir a escribir un mensaje no existe
options.create = true
-- Normalmente los mensajes que se marcaron como a borrar se borrarán 
-- al cerrar el buzon. Al poner 'expunge' a true se borran de forma inmediata
options.expunge = true
-- Cerrar la carpeta en uso al terminar las operaciones, implica que se
-- eliminen, en ese momento, los mensajes marcados como a borrar.
options.close = true
-- Implica que las carpetas creadas automáticamente sean suscritas (visibles).
options.subscribe = true
-- Activo la opción de usar STARTTLS por el puerto 443. Nota: En mi servidor
-- IMAP he desactivado el uso de SSL por estar desaconsejado.
options.starttls = true
-- Ignorar los certificados. NOTA: Opción MUY peligrosa si no sabes lo que 
-- estás haciendo. Cuando se conecta con un servidor SSL/TLS y esta opción 
-- está en "false" entonces "no" se muestra su certificado y se pide confirmación
-- al usuario antes de aceptarlo. Cuando está en 'true' (valor por defecto) sí 
-- se pide confirmación. Solo puedo recomendar ponerlo en 'false' si se 
-- tiene un control absoluto sobre el servidor, en caso contrario dejarlo en 'true'
options.certificates = false
-- Opciones para recuperar al máximo de errores del servidor
options.reenter = false
options.recover = errors

----------------
-- Cuentas   --
----------------
--
-- Crear una entrada para cada cuenta de correo sobre la que quiero actuar.
-- En este caso voy a leer desde mail.empresa.com, la mayoría de los mails
-- los archivaré en otra cuenta distinta en el usuario "archivo"

cuentaTrabajo = IMAP {
     server = 'mail.empresa.com',
     username = 'usuario@empresa.com',
     password = 'micontraseña',
}

cuentaArchivo = IMAP {
     server = 'mail.midominio.com',
     username = 'archivo@midominio.com',
     password = 'micontraseña',
}
               
---------------------
-- Loop infinito  --
---------------------
--
-- Cada 10 minutos se relee el fichero config-CUENTA-aux.lua o cada
-- vez que se modifica, por ejemplo para cambiar las rules. 
--
-- Con este loop garantizo que si el administrador quiere 
-- cambiar una rule lo pueda hacer. Si estoy siendo ejecutado
-- en un contenedor de Docker y el fichero config-CUENTA-aux.lua está
-- en un directorio persistente entonces consigo que se pueda
-- modificar y este script se de cuenta.
--

_, timestamp = pipe_from('stat -c %Y /root/.imapfilter/config-trabajo-aux.lua')
while (true) do

    dofile('/root/.imapfilter/config-trabajo-aux.lua')

    if not cuentaTrabajo.INBOX:enter_idle() then
       posix.sleep(300)
    else
       print('salgo de enter_idle()')    
    end
end

\--
-- check_status()
-- --------------------------------------------------------------------
-- 
-- Obtiene el estado actual del mailbox y devuelve tres valores: 
-- número de mensajes existentes
-- número de mensajes recientes no leidos. 
-- número de mensajes no vistos
-- 
cuentaTrabajo.INBOX:check_status()
cuentaArchivo.INBOX:check_status()
            
-----------------
-- Funciones  --
-----------------
--
-- parseRules para filtrar los mensajes usando una tabla de reglas

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleMove = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    if subresults:move_messages( entry["moveto"] ) == false then
      print("No puedo mover los menssajes !")
    end
  end
end

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleDelete = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    if subresults:delete_messages() == false then
      print("No puedo borrar los mensajes !")
    end
  end
end

-- @param res         la tabla con los mensajes a filtrar
-- @param ruleTable   la tabla de reglas con las que hacer el matching de los mensajes
--
ruleFlag = function ( res, ruleTable )
local subresults = {}
  for _,entry in pairs(ruleTable) do
    -- no uso match_field porque se baja el mensaje entero y es lento
    subresults = res:contain_field(entry["header"], entry["p"])
    subresults:add_flags({ 'Exec', '\\Seen' })
    subresults:unmark_seen()
  end
end

-----------------------
-- Filtros:         --
-----------------------
--

pre_filtersMoveTrabajo = {

  -- Ejemplo donde bloqueo IP's (ej. ficticias) que típicamente mandan spam
  { header = "Received" , p = "85.11.111.58", moveto = acc1['Trash'] },
  { header = "Received" , p = "176.16.16.16", moveto = acc1['Trash'] },
  
}

pre_filtersDeleteTrabajo = {

  -- Varias fuentes que borro directamente (algún día me daré de bajo :-)
  { header = "From", p = "tal-sitio.com" },
  { header = "From", p = "new.muypesados.es" },
  { header = "From", p = "promocion@tld.org" },

}

filtersMoveTrabajo = {

  -- Newsletters, las archivo...
  { header = "From", p = "bounce@emisor-newsleteers.com", moveto = cuentaArchivo['Archivo'] },

  -- Mailing lists, me interesan pero no en el Inbox, las archivo
  { header = "From", p = "noreply@servicios.talytal.com", moveto = cuentaArchivo['Archivo_TalTal'] },

  -- Departamentos
  { header = "Subject", p = "_Equipos_Ventas", moveto = cuentaArchivo['Ventas'] },
  { header = "Subject", p = "_Reuniones", moveto = cuentaArchivo['Reuniones'] },
  { header = "To", p = "mailinglist@empresa.com", moveto = cuentaArchivo['Archivo'] },

}

post_filtersMoveTrabajo = {

  -- Añadir aquí cualquier otra regla que me interese... 
  { header = "Subject" , p = "[SPAM?] ", moveto = cuentaArchivo['Junk'] },

}

---------------------------
-- Ejecución principal  --
---------------------------
--

-- Leo todo el correo Trabajo
   allmsgsTrabajo  = cuentaTrabajo.INBOX:select_all()

-- Aplico las reglas al correo del Trabajo
   ruleMove(allmsgsTrabajo, pre_filtersMoveTrabajo)
   ruleDelete(allmsgsTrabajo, pre_filtersDeleteTrabajo)
   ruleMove(allmsgsTrabajo, filtersMoveTrabajo)
   ruleMove(allmsgsTrabajo, post_filtersMoveTrabajo)
    
-------------------------
-- Mensajes complejos --
-- 
-- Operadores:
-- +  OR
-- *  AND
-- - NOT
-------------------------

msgs = cuentaTrabajo.INBOX:is_unseen() *
  cuentaTrabajo.INBOX:contain_from('Nombre_Persona') *
  cuentaTrabajo.INBOX:contain_subject('Invitaciones:')
msgs:move_messages(cuentaArchivo['Archivo'])

msgs = cuentaTrabajo.INBOX:contain_to('mi_usuario') *
  cuentaTrabajo.INBOX:contain_from('mi_jefe') +
  cuentaTrabajo.INBOX:contain_from('mi_superjefe')
msgs:add_flags({ 'Exec', '\\Seen' })
msgs:unmark_seen()

Como ves arriba, cada instancia tiene un par de ficheros de configuración, el principal que se le pasa a imapfilter como argumento y el auxiliar que se carga desde el principal y contiene las reglas en sí. Lo hago así para implementar un sistema que re-lea las reglas cada cierto tiempo. Permite editar de forma externa (desde mi Host) el fichero de reglas y evito parar/arrancar el contenedor cada vez que cambio una regla.
