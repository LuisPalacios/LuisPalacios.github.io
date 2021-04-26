---
title: "Servidor FTP en tu Mac"
date: "2016-01-03"
categories: 
  - "apuntes"
tags: 
  - "ftp"
  - "ftpserver"
  - "osx"
---

Obviamente no es algo que vayas a necesitar a menudo, pero si por un casual requieres de un FTP Server para algo recuerda que puedes activarlo en tu Mac OSX (ésta documentación está basada en la versión **10.11 - El Capitán**) Veamos cómo activar y desactivar el servidor FTP en nuestro Mac.

No te olvides de DESACTIVARLO una vez termines con él, es de sobra conocido que un Servidor FTP es probablemente uno de los sistemas más inseguros que existe.

### Activación

Arrancamos la aplicación Terminal.app (se encuentra en Aplicaciones>Utilidades>Terminal) y ejecutamos el comando siguiente. Notar que os pedirá la contraseña del usuario y que tu usuario debe derechos de "Administrador" para que funcione (podéis comprobarlo en Preferencias del Sistema->Usuarios y grupos).

sudo -s launchctl load -w /System/Library/LaunchDaemons/ftp.plist

 

[![ftpdosx1](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx1.jpg)](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx1.jpg)

Ya está, ahora puedes consumir este servidor desde cualquier cliente FTP. Cuando conectes con él (puerto 21) utiliza el usuario y contraseña de tu usuario principal y verás que conecta con el directorio HOME del mismo.

[![ftpdosx2](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx2.jpg)](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx2.jpg)

[![ftpdosx3](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx3.jpg)](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx3.jpg)

 

### Desactivación

Una vez que terminas de usar tu servidor FTP te recomiendo que inmediatamente lo desactives. Arrancamos de nuevo la aplicación Terminal.app (se encuentra en Aplicaciones>Utilidades>Terminal) y ejecutamos el comando siguiente:

sudo -s launchctl load -w /System/Library/LaunchDaemons/ftp.plist

[![ftpdosx4](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx4.jpg)](https://www.luispa.com/wp-content/uploads/2016/01/ftpdosx4.jpg)
