---
title: "Un Windows decente"
date: "2024-08-24"
categories: administración
tags: linux wsl windows win11 ubuntu desarrollo dualboot limpio lean tiny mini
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-windows.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte explico cómo parametrizo un Windows 11 que voy a usar para pruebas y demos. No necesito florituras, no va a tener datos sensibles, quiero Windows a pelo, para formación con VSCode, algo de navegación y punto.

Al final se ha convertido en un ejercicio técnico. ¿Cómo se haría?. Suena raro, pero sería como tener un Win 3.11, que estaba disponible de forma inmediata. Voy a quitarle todo lo que pueda, anuncios, edge, extras, instalaré los mínimos drivers una cuenta local, que arranque y esté disponible lo antes posible.

<br clear="left"/>
<!--more-->

## Primeros pasos

Parto de la instalación desde cero que realicé de mi Windows 11 en el apunte [Dualbot Linux Windows]({% post_url 2024-08-23-dual-linux-win %}). Cuando terminé de configurar el Dualboot todavía no había hecho ninguna configuración en Windows, así que está tal cual, recién instalado.

Lo básico

* Chrome. Lo primero es lo primero. Desde Edge (diciendole que no a todo) busco, descargo e instalo [Chrome para Windows](https://www.google.com/intl/es_es/chrome). Durante la instalación me ofrece cambiar el navegador por defecto.
  * Settings > Apps > Default apps > Google Chrome. Pongo Chrome como el valor por defecto y en todas las extensiones, incluidas las que no tenían nada.
* 7-Zip. Lo instalo desde [7-Zip.org](https://7-zip.org), Lo voy a necesitar.

Teclado y Ratón

* Empiecé con teclado USB por cable y he añadido un Logitech K380 bluetooth
  * Conecto el K380: Start > Settings > Bluetooth & devices > Add device > Bluetooth.
* Empiezo con un ratón Bluetooth normal pero estoy investigando la opción de usar un Apple Magic Trackpad 2.
  * Me vendría bien para compartir teclado/ratón con un Mac usando [Barrier](https://github.com/debauchee/barrier) (un KVM por software). De momento no me funciona.
  * Bootcamp [Support 5.1.5769](https://support.apple.com/en-gb/106378) - Descomprimo y ejecuto `BootCamp/Drivers/Apple/AppleWirelessTrackpad64.exe` como Admin
  * Bootcamp [Update 2.2](desconocido) - Descargo y descomprimo con 7-Zip. Ejecuto BCUpdateInstaller.exe como adimn
  * Bootcamp [Update 3.3](https://support.apple.com/en-gb/106463)
* Instalo [Barrier](https://github.com/debauchee/barrier). Un KVM por software. Mi setup son dos ordenadores, con dos monitores. El objetivo es usar un único teclado/ratón.
  * Enable autoconfig and install Bonjour - Yes. Aún así siempre configuro Barrier en manual. Pongo la IP del server. Cambio settings para que ararnque durante el boot.

Cambio el Home de mi usuario.

* Durante la instalación creó "C:\Users\luisp" y quiero cambiarlo a "luis". Al final no lo hice. Dejo los pasos documentados (referencia de esta [guia](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/))
  * Habilito al Administrador, rearranco el ordenador, hago login con él y sigo los pasos para cambiar el Home > `net user Administrator /active:yes`
  * CMD > `wmic useraccount get name,SID`
  * Registry -> `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1* -> ProfileImagePath`
  * Explorer -> Renombro el HOME
  * CMD `mklink /d "C:\Users\luisp" "C:\Users\luis"`
* No cambié el directorio porque he decidido NO usar login con usuario de Microsoft Account, he preferido cambiar a usuario local. Al hacer el cambio seleccioné el usuario "luis" y luego renombré el directorio HOME tal como pone más arriba

Sigo con los cambios

* Start > Settings > Privacy & Security
  * Security > Windows Security: Open Windows Security: Todo en On
  * Security > Location: Todo en Off
  * Security > Windows Permissions: Entro en todas y Off
    * General, Speech, Inking..., todo a off
    * Diagnostics: todo a off y Feedback frequency: Never.
    * Activity, Search permissions, Searching Windows: todo off
  * Security > App Permissions: Entro en todas y Off
  * Security > App Permissions: Location Off, el resto a valor por defecto
* Start > Settings > Apps
  * Startup > Quito todas, sobre todo Edge, excepto Security notification icon.
  * Default apps > Microsoft Edge : Reviso que todo lo posible sea Chrome
  * Apps for Websites > todo a off

Activación de Windows 11

* Compro una copia digital de Windows 11 Pro retail a un minorista autorizado. Mucho más barato y asequible. Me llega un correo con la clave de producto. Desde Start > Settings > Sytem Activation > Change product key, añado la clave recibida por correo y queda activado.

Configuro que NO pregunte cada vez que quiero arrancar un App

* Start > busco por "User Account Control settings" > Never notify

Eliminar el PIN, no lo necesito, como decía al principio, es un equipo para demos y documentar.

* Start > Settings > Accounts > Sign-in options
  * Desactivo Only allow Windows Hello sign-in.
  * Quito PIN.
  * Cambio a "Never" que solicite login cuando despierta.
* Start > Settings > Account > Your Info > ***Cambio a cuenta local, en vez de usar la de Microsoft Account vía internet***
* Start > netplwiz - desactivo que pida contraseña
* Botón derecho sobre Start > Computer Management > Local Users & Groups > Users
  * Pongo contraseña en blanco

Instalo Powershell 7. Por defecto incluye CMD y PowerShell 5 (se ve con el comando `$PSVersionTable`)

* Desde GitHub [PowerShell Tags](https://github.com/PowerShell/PowerShell/tags) entro en el link de Downloads de la última versión, que era PowerShell-7.4.5-win-x64.msi

Eliminar anuncios

* Quitar Ads del Lock Screen
  * Start > Settings > Personalization
    * Personalize your lock screen: Selecciono una foto
    * Get fun facts, tips, tricks, and more on your lock screen: quito el checkbox
* Quitar Ads/Apss del Start
  * Start > Botón derecho sobre los iconos que quiera hacer Unpin o "Uninstall" (por ejemplo en mi caso quité Xbox, Spottify, ...)
* Quitar Ads de la búsqueda
  * Start > Settings > Privacy and Security” > “Search Permissions“, me aseguro que está todo a off
* Quitar Ads de los Widgets
  * Start > Settings > “Personalization” > “Taskbar”
    * Bajo “Taskbar items” quito “Widgets“.
* Quitar contenido de Widgets
  * Pulso la tecla Windows+W, abre los Widgets
  * Clic en el icono de Profile Icon (arriba a la dcha.), Sign-out button.
  * Ejecuto Local Group Policy Editor `gpedit.msc`
    * `Computer Configuration\Administrative Templates\Windows Components\Widgets​` > disabled. Hago reboot.
* Quitar Ads del Explorer
  * Window + E > tres puntos horizontales > Options > View > Quito "Show sync provider notifications" > Apply
* Quitar Notification Ads
  * Start > Settings > System > Notifications > Additional Settings > Quitar las tres opciones que aparecen
* Quitar "Device Usage Settings"
  * Start > Settings > Personalization > Device Usage > Me aseguro de quitarlas todas.
* Quitar contenido sugerido
  * Start > Settings > Privacy and Security > General > Me aseguro de que "Show me notifications in the Settings app" esté desactivado.
* Quitar Ads de Diagnostic Data
  * Start > Settings > Privacy and Security > Diagnostics & feedback > Tailored experiences > Let Microsoft use your diagnostic data - OFF
  * De hecho tengo en Off todas las opciones bajo Diagnostics & feedback
* Quito la papelera del escritorio
  * Start > Settings > Personalization > Themes > Desktop icon settings > Quito el checkbox a Recycle Bin
* Personalizo el Taskbar
  * Botón derecho sobre taskbar, quito iconos que no uso.
  * Start > tecleo "Start settings" >
    * Layout > More pins
    * Show recently added apps > Off
    * Show reocmmendations .. > Off
    * Show account notifications > Off
    * Show recently opened > Off
* Elimino el teclado US que me instaló por defecto.
  * Start > Settings > Time & Language > Language & Region > Options > Keyboards > US (lo elimino y dejo solo el de Spanish)

Actualización.

* Ya va siendo hora, Start > escribo "Update " > Check for Updates > Hago todas las actualizaciones/reboots que me pide.

Desinstalar Edge (En Europa es posible desde el propio Sistema)

* Sin comentarios. Start > Settings > Apps
  * Microsoft Edge > ***Uninstall, rearranco el equipo***
  * Microsoft Edge Update > No me deja hacer un Uninstall
  * Microsoft Edge WEbView2 > No me deja hacer un Uninstall
