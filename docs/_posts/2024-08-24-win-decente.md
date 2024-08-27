---
title: "Un Windows decente"
date: "2024-08-24"
categories: administración
tags: linux wsl windows win11 ubuntu desarrollo dualboot limpio lean tiny mini
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-windows.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte explico cómo parametrizo un Windows 11 que voy a usar para pruebas y demos. No necesito florituras ya que no va a tener datos sensibles, quiero Windows a pelo, con pocas apliaciones, algo de navegación y punto.

Al final se ha convertido en un ejercicio técnico. ¿Cómo se haría?. Suena raro, pero sería como tener un Win 3.11, que estaba disponible de forma inmediata. Voy a quitarle todo lo que pueda, anuncios, edge, extras, instalaré drivers mínimos, una cuenta local, que arranque, haga login directo y esté disponible lo antes posible.

<br clear="left"/>
<!--more-->

## Primeros pasos

Parto de un equipo donde acabo de instalar Windows 11 desde cero. Lo he documentado en el apunte [Dualboot Linux Windows]({% post_url 2024-08-23-dual-linux-win %}). En él solo me ocupaba del dualboot, así que no llegué a configurar nada de Windows. Así es como empiezo, con un sistema recién instalado.

Lo ***básico***

* Instalo [Chrome para Windows](https://www.google.com/intl/es_es/chrome).
  * Lo descargué desde *Edge* (diciendole que no a todo lo que propone por cierto)
  * Durante la instalación me ofrece cambiar el navegador por defecto.
  * `Settings > Apps > Default apps` > Google Chrome.
    * Pongo Chrome como el valor por defecto
    * Aprovecho y cambio todas las extensiones (las que me deja) a Chrome.
* Instalo 7-Zip desde [7-Zip.org](https://7-zip.org), es un clásico.

***Teclado y Ratón***

* Empecé con teclado USB por cable y he añadido un Logitech K380 bluetooth
  * Conecto el K380
    * `Start > Settings > Bluetooth & devices`
    * `Add device > Bluetooth`
* Estoy investigando la opción de usar un Apple Magic Trackpad 2. De momento no me funciona bien.
* Instalo [Barrier](https://github.com/debauchee/barrier). Un KVM por software. Mi setup son dos ordenadores, con dos monitores. El objetivo es usar un único teclado/ratón.
  * Al instalar me pregunta `Enable autoconfig and install Bonjour`, le digo que Sí.

## Parametrización

Cambios en la ***seguridad***

* Start > Settings > **Privacy & Security**
  * Security > Windows Security > `Open Windows Security`: **Todo en On**
  * Security > `Location`: **Todo en Off**
  * Security > `Windows Permissions`: **Todas en Off**
    * `General, Speech, Inking`, **todo en Off**
    * `Diagnostics`: **todo a off y Feedback frequency: Never**.
    * Activity, `Search permissions, Searching Windows`: **todo off**
  * Security > `App Permissions`: **Location Off**, el **resto a valor por defecto**
* Start > Settings > Apps
  * `Startup` > **Quito todas, sobre todo Edge, excepto Security notification icon**.
  * `Default apps` > Microsoft Edge : **Reviso que todo sea Chrome**
  * `Apps for Websites` > **todo a off**

***Activación*** de Windows 11

* Compro una copia digital de Windows 11 Pro retail a un minorista autorizado. Mucho más barato y asequible. Me llega un correo con la clave de producto.
  * `Start > Settings > Sytem Activation > Change product key`, añado la clave recibida y queda activado.

Configuro que ***no pregunte*** cada vez que quiero arrancar un App

* `Start > busco por "User Account Control settings"` > **Never notify**

***Eliminar el PIN***, no lo quiero. Esto me va a obligar (durante un rato) a hacer login con mi cuenta de microsoft pero inmediatemente también voy a cambiar eso.

* Start > Settings > Accounts > `Sign-in options`
  * Desactivo Only allow Windows Hello sign-in.
  * **Quito PIN**.
  * Cambio a "**Never**" que solicite login cuando despierta.

Cambio el ***Home*** de mi usuario y cambio a ***login con Usuario local***. Durante la instalación me obligó a 2 cosas que no me gustan: 1) usar una cuenta de Microsoft usando un mail registrado. 2) creó el nombre corto del usuario con los 5 primeros caracteres de dicho mail, por lo que quedó comoo `luisp` y el HOME de mi usuario en `C:\Users\luisp\`.

* Primero cambio el nombre del directorio HOME ([guía](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/))
  * Habilito al Administrador
    * `net user Administrator /active:yes`
  * Rearranco el ordenador, hago login con Administrador sin contraseña
    * CMD > `wmic useraccount get name,SID`
    * ***`regedit`*** -> `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1* -> ProfileImagePath`
    * Explorer -> **Renombro el HOME**
    * CMD `mklink /d "C:\Users\luisp" "C:\Users\luis"`
* Luego cambio a Cuenta Local, en vez de usar una Microsoft Account con mi mail
  * `Start > Settings > Account > Your Info`
  * ***Cambio a cuenta local***, usuario `luis`, le pongo una contraseña

***Powershell 7***.

* Por defecto el equipo trae `CMD` y `PowerShell 5` (para ver la versión de PS usé el comando: `$PSVersionTable`)
* Desde [PowerShell Tags](https://github.com/PowerShell/PowerShell/tags) descargo desde el link "Downloads" la última versión (`PowerShell-7.4.5-win-x64.msi`) y la instalo.

***Eliminar anuncios***

* Quitar Ads del Lock Screen
  * Start > Settings > Personalization
    * Personalize your lock screen: **Selecciono una foto**
    * Get fun facts, tips, tricks, and more on your lock screen: **quito el checkbox**
* Quitar Ads/Apss del Start
  * Start > Botón derecho sobre los iconos que quiera hacer Unpin o "Uninstall" (por ejemplo en mi caso **quité Xbox, Spottify**, ...)
* Quitar Ads de la búsqueda
  * Start > Settings > Privacy and Security > “Search Permissions“, me aseguro que está **todo a off**
* Quitar Ads de los Widgets
  * Start > Settings > “Personalization” > “Taskbar”
    * Bajo “Taskbar items” **quito Widgets**
* Quitar contenido de Widgets
  * Pulso la tecla Windows+W, abre los Widgets
  * Clic en el icono de Profile Icon (arriba a la dcha.), **Sign-out button**.
  * Ejecuto Local Group Policy Editor **`gpedit.msc`**
    * `Computer Configuration\Administrative Templates\Windows Components\Widgets​` > **disabled**.
    * Hago **reboot**.
* Quitar Ads del Explorer
  * Window + E > tres puntos horizontales > Options > View > **Quito "Show sync provider notifications" > Apply**
* Quitar Notification Ads
  * Start > Settings > System > Notifications > Additional Settings > **Quito las tres opciones** que aparecen
* Quitar "Device Usage Settings"
  * Start > Settings > Personalization > Device Usage > **Quito todas**.
* Quitar contenido sugerido
  * Start > Settings > Privacy and Security > General > Me aseguro de que **"Show me notifications in the Settings app" esté desactivado**
* Quitar Ads de Diagnostic Data
  * Start > Settings > Privacy and Security > Diagnostics & feedback > Tailored experiences > Let Microsoft use your diagnostic data - **Off**
  * De hecho **tengo en Off todas las opciones bajo Diagnostics & feedback**
* Quito la papelera de reciclaje del Escritorio/Desktop
  * Start > Settings > Personalization > Themes > Desktop icon settings > **Quito el checkbox de Recycle Bin**
* Añado la papelera de reciclaje al Explorer (para que aparezca en "Este equipo / This PC")
  * ***`regedit`*** ->
    * `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace`
    * Nueva clave/Key: `{645FF040-5081-101B-9F08-00AA002F954E}`
    * **Reboot**
* Personalizo el Taskbar
  * Botón derecho sobre taskbar, **quito iconos que no uso**.
  * Start > tecleo "Start settings" >
    * Layout > More pins
    * Show recently added apps > **Off**
    * Show reocmmendations .. > **Off**
    * Show account notifications > **Off**
    * Show recently opened > **Off**
* Elimino el teclado US que me instaló por defecto.
  * Start > Settings > Time & Language > Language & Region > Options > Keyboards > **Quito US** (dejo solo el de Spanish)
* Añado ""Turn off display" al menú de contexto del escritorio
  * Sigo este apunte de [aquí](https://www.elevenforum.com/t/add-turn-off-display-context-menu-in-windows-11.8267/)

***Actualización*** del sistema operativo

* Ya va siendo hora, Start > escribo "Update " > Check for Updates > Hago todas las **actualizaciones/reboots** que me pide.

***Desinstalar Edge*** (En Europa es posible desde el propio Sistema)

* Sin comentarios. Start > Settings > Apps
  * Microsoft Edge > ***Uninstall, rearranco el equipo***
  * Microsoft Edge Update > No me deja hacer un Uninstall
  * Microsoft Edge WEbView2 > No me deja hacer un Uninstall

Si ahora entro en "buscar" ya empiezo a ver los efectos, cada vez menos morralla.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-01.png"
      caption="Versión minimalista de Buscar"
      width="400px"
      %}

***Habilitar File Sharing***. Es algo que voy a necesitar, así que lo configuro

* Start > Settings > `Network and Internet` > `Advanced network settings`
  * `Advance Sharing Settings`
  * `File & Printer sharing`: **On**
  * `Public folder sharing`: **On**
* Start > Settings > System > About
  * `Advance System Settings` > Computer Name > Change > "Me aseguro que está en **WORKGROUP**"
* Habilito SMB1.0
  * Start > busco "Control Panel"
  * `Programs` > `Programs and features`
  * `Turn Windows features on or off`
  * **Activo SMB 1.0/CIFS** File Sharing Support.

***Firewall de Windows***

* Lo configuro para minimizar alertas y notificaciones. El ordenador está conectado a una red privada pero por defecto la instalación lo puso en red Pública (error).
  * Start > Settings > Network & Internet > Ethernet (y también WiFi)
    * **Cambio ambas a `Private Network`**
* Configuro el Firewall de Windows para minimizar alertas y notificaciones
  * Start > busco "Control Panel" > System & Security > Windows Defender Firewall > Advanced Settings”
  * Reviso reglas de entrada y salida para bloquear o permitir aplicaciones específicas según lo necesite.
  * Desactivo las notificaciones del firewall en “System and Security > Windows Defender Firewall > Change notification settings”, y **desmarco las casillas de “Notify me when Windows Defender Firewall blocks a new app”**

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-02.png"
      caption="Versión minimalista de Start"
      width="450px"
      %}

***Instalación de PowerToys***

Las Microsoft PowerToys son un conjunto de utilidades para que los usuarios avanzados mejoren y optimicen su experiencia con Windows a fin de aumentar la productividad. Lo instalo desde la [página oficial](https://learn.microsoft.com/es-es/windows/powertoys/install). Algunas que me gustan a mi, incluyo pegado avanzado, editar el archivo `hosts`.

***Visual Studio Code***: Tampoco requiere mucha presentación, un editor de código fuente que incluye un terminal integrado. Puedo abrir diferentes **terminales integrados** dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL.

Soporta una amplia variedad de lenguajes de programación y una gran cantidad de extensiones para mejorar su funcionalidad. Lo instalo desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/).

## Recomendaciones adicionales

Al seguir los pasos anteriores obtengo un Windows 11 mucho más limpio, rápido y libre de distracciones, ideal para su uso en entornos específicos como pruebas o demostraciones. Además de las optimizaciones mencionadas, dejo aquí algunas medidas adicionales, que pueden llevar la personalización un paso más allá:

***Desactivar Cortana***

* Busco “gpedit.msc” en el menú de inicio y abro el Editor de directivas de grupo local (Local Group Policy Editor).
  * Navego a “Computer Configuration > Administrative Templates > Windows Components > Search”.
  * Hago doble clic en “Allow Cortana” y selecciono “Disabled”. Aplico los cambios para desactivar Cortana.

***Quitar bloatware/crapware***

* Eliminar aplicaciones preinstaladas (bloatware o crapware) mediante PowerShell.
* ¿Qué desinstalar? pues depende del fabricante de tu PC puedes echarle un ojo a [Should I Remove It?](http://www.shouldiremoveit.com) que no está mal y te da indicaciones.
* Puede usarse PowerShell como administrador. Comando para listar todas las aplicaciones instaladas
  * `Get-AppxPackage | Select Name, PackageFullName`
* Luego, uso este comando para desinstalar las aplicaciones que no necesito
  * `Get-AppxPackage *NombreDeLaApp* | Remove-AppxPackage`

***Desactivar la telemetría y recopilación de datos***

* Con lo que hice antes respectoa  Diagnostics & feedback debería ser suficiente, pero confirmo abriend `gpedit.ms`, compruebo si existe:
  * `Computer Configuration > Administrative Templates > Windows Components > Data Collection and Preview Builds`
  * Si existe `Allow Telemetry` selecciono “Disabled”. Esto asegura que Windows no recopile datos sobre mi uso.

***Optimizar el registro con herramientas como CCleaner***

* Descargo e instalo CCleaner desde su sitio oficial. Una vez instalado, lo abro y navego a la sección “Registry”.
  * Hago clic en “Scan for Issues” y luego en “Fix selected Issues”. Siempre hago una copia de seguridad del registro cuando lo solicita.

***Deshabilitar servicios innecesarios***

* Abro `services.msc` desde el menú de inicio.
  * Identifico los servicios que no necesito (por ejemplo, "xbox*", etc.). Hago doble clic en el servicio, cambio el “Startup type” a “Disabled” y aplico los cambios.

Con estas recomendaciones adicionales, el sistema estará preparado para ofrecer una experiencia de usuario más directa, sin distracciones ni interrupciones innecesarias.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-03.png"
      caption="Versión minimalista del escritorio"
      width="800px"
      %}

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-04.png"
      caption="Idoneo para trabajar"
      width="600px"
      %}
