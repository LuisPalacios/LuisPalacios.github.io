---
title: "Un Windows decente"
date: "2024-08-24"
categories: administración
tags: linux wsl windows win11 ubuntu desarrollo dualboot limpio lean tiny mini
excerpt_separator: <!--more-->
---


![logo linux desarrollo](/assets/img/posts/logo-windows.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte explico cómo parametrizo un Windows 11 que voy a usar para desarrollo de software, pruebas o demos. No necesito florituras ya que no va a tener datos sensibles, quiero su esencia, a pelo, con pocas aplicaciones, algo de navegación y punto.

Al final se ha convertido en un ejercicio técnico. ¿Cómo se haría?. Suena raro, pero sería como tener un Windows de los primeros, que estaban disponibles de forma inmediata. Voy a quitarle todo lo que pueda, anuncios, Edge, extras, instalaré drivers mínimos, una cuenta local, que arranque y esté disponible lo antes posible.

<br clear="left"/>
<style>
table {
    font-size: 0.8em;
}
</style>
<!--more-->

| Este apunte pertenece a la serie de desarrollo de software con Windows:<br>• Preparar un PC para [Dualboot Linux / Windows]({% post_url 2024-08-23-dual-linux-win %}) e instalar Windows 11 Pro.<br>• Configurar [un Windows 11 decente]({% post_url 2024-08-24-win-decente %}), dejarlo en su esencia minima, quitando la morralla.<br>• Preparar [Windows para desarrollo de software]({% post_url 2024-08-25-win-desarrollo %}) de software, CLI, WSL2 y herramientas.<br>• Instalación de [VMWare en Windows]({% post_url 2024-08-26-win-vmware %}) para tener una VM con Windows 11 Pro. |

## Introducción

**¿Qué es el debloat o eliminación del bloatware?**. El **bloatware** se refiere a las aplicaciones y servicios preinstalados en un sistema operativo que, aunque no esenciales, consumen recursos y pueden afectar al rendimiento del equipo.

Esas aplicaciones o servicios suelen incluirse por acuerdos/intereses comerciales o para promocionar ciertos servicios, pero en muchos casos resultan innecesarios para el usuario. El bloatware en Windows es como la morralla en el mar: una mezcla de elementos innecesarios que solo estorban, ocupan espacio y ralentizan todo. El proceso de **debloat** consiste en identificar y eliminarlo, liberando recursos y optimizando el funcionamiento del sistema. En este apunte encontrarás todo un proceso manual para hacerlo.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-07.png"
      caption="Evitar la morralla (fuente dall-e)"
      width="400px"
      %}

Existen herramientas que permiten automatizar todo este proceso mediante scripts, facilitando la tarea y asegurando una limpieza más profunda. Te dejo algunos de los proyectos más reconocidos en la comunidad técnica, no recomiendo ninguno porque sinceramente todavía no los he usado.

- **[Chris Titus debloater](https://christitus.com/windows-tool/)**: Utilidad integral para Windows que simplifica la instalación de programas, la eliminación de bloatware, la aplicación de ajustes personalizados y la gestión de actualizaciones del sistema. Ejecutable desde PowerShell con privilegios de administrador
- **[Tiny 11 Builder](https://github.com/ntdevlabs/tiny11builder)**. Automatiza la creación de una imagen optimizada de Windows 11, eliminando componentes innecesarios para mejorar el rendimiento y reducir el uso de recursos. La versión más reciente ha sido completamente renovada, permitiendo su uso en cualquier versión, idioma o
- **[Win11Debloat](https://github.com/Raphire/Win11Debloat)**: Otro que parece diseñado específicamente para Windows 11. Facilita la eliminación de aplicaciones innecesarias, deshabilita la telemetría y realiza otros ajustes para mejorar el rendimiento del sistema.
- **[Windows10Debloater](https://github.com/Sycnex/Windows10Debloater)**: Este conjunto de scripts en PowerShell permite desactivar funciones, mejorar la privacidad y eliminar aplicaciones preinstaladas en Windows 10 y 11. Parece que es ampliamente utilizado y reconocido por su eficacia.
arquitectura de Windows 11, gracias a la implementación en PowerShell.
- **[Debloat Windows 10/11 de Andrew Taylor](https://andrewstaylor.com/2022/08/09/removing-bloatware-from-windows-10-11-via-script/)**: Este script automatiza la eliminación de aplicaciones innecesarias, desactiva servicios no esenciales y realiza ajustes para optimizar el rendimiento de Windows 10 y 11.

Como decía, todavía no he usado ninguno, pero el día que lo haga me los estudiaré a fondo, incluidos los fuentes, seguiré las instrucciones y haré backup antes de ejecutar cualquier cosa de por ahí... (algunas modificaciones pueden ser irreversibles y afectar la estabilidad del equipo). Te invito a hacer lo mismo.


## Primeros pasos

A partir de aqui me centro en mi proceso manual. Tiene menos riesgo porque vas viendo lo que hago, pero es mucho más largo. Parto de un windows 11 desde cero. Puede que sirva para uno con el que llevas tiempo trabajando, pero no lo he probado. En mi caso lo hice después de instalar [Dualboot Linux Windows]({% post_url 2024-08-23-dual-linux-win %}) o [VMWare en Windows]({% post_url 2024-08-26-win-vmware %}), es decir recién instalado en bare metal o en una VM.

Lo ***básico*** antes de meterle mano al bloatware.

* Me instalo [Chrome para Windows](https://www.google.com/intl/es_es/chrome)
  * Lo descargué desde *Edge* (diciendole que no a todo lo que propone por cierto)
  * Durante la instalación me ofrece cambiar el navegador por defecto.
  * `Settings > Apps > Default apps` > Google Chrome.
    * Pongo Chrome como el valor por defecto
    * Aprovecho y cambio todas las extensiones (las que me deja) a Chrome.

| Nota: ¿Porqué no uso Edge?. Se que Edge utiliza WebView2, que está basado en Chromium (poyecto open source), que usa Blink como motor de renderizado y V8 como motor de JavaScript. Hasta ahí bien, parece la mejor opción para Windows. Pero ese es su problema, muy endogámico. Prefiero una plataforma única de navegación multiplataforma, que funcione en Windows, Linux, MacOS de forma excelente. Ahí es donde entran otros proyectos que usan Chromium como Google Chrome, Brave, Vivaldi, Opera. De momento estoy con Google Chrome, pero echando un ojo a Vivaldi, que es sinceramente un trabajo impresionante. |

* Instalo 7-Zip desde [7-Zip.org](https://7-zip.org), es un clásico.

***Teclado y Ratón***

* Esto es muy particular en mi caso, así que sáltalo si no te aplica.
* Durante la [instalación dualboot]({% post_url 2024-08-23-dual-linux-win %}) usé Ratón/Teclado USB's por cable y al terminar añadí un Ratón Logitech (con un plugin USB) y el teclado Logitech K380 vía bluetooth
  * `Start > Settings > Bluetooth & devices > Add device > Bluetooth`
* Al final del apunte explico porqué y cómo instalo un Magic Trackpad 2 de Apple

## Activación de Windows

En mi Windows bare metal compré una licencia, pero para VM's o equipo de laboratorio existe el famoso Microsoft Activation Script (MAS). No es que lo recomiende, es que está ahí, accesible y es público. Solo comparto lo que ya está por internet.

* Opción 1: Comprar una copia digital de Windows 11 Pro retail a un minorista autorizado. Es barato y asequible, te llega un correo con la clave de producto.
  * `Start > Settings > Sytem Activation > Change product key`, añado la clave recibida y queda activado.
* Opción 2: [Microsoft Activation Script (MAS)](https://github.com/massgravel/Microsoft-Activation-Scripts), se trata de una activador de código abierto para Windows y Office que incluye los métodos de activación HWID, Ohook, TSforge, KMS38 y Online KMS.
  * Seguir la documentación del enlace, un ejemplo para licenciar una [VM Windows 11 Pro]({% post_url 2024-08-26-win-vmware %})
    * Click derecho sobre el menú start -> `Terminal (admin)`
    * Ejecuto el comando siguiente: `irm https://get.activated.win | iex`
    * Entre las opciones de activación, seleccionas `(1) HWID for Windows activation` y queda activado.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-05.png"
      caption="Método MAS"
      width="600px"
      %}

Para comprobar el estado de activación: `Start > Settings > Activation`

## Debloat manual

Empiezo con cambios en la ***seguridad***

* Start > Settings > **Privacy & Security**
  * Security > Windows Security > `Open Windows Security`: **Todo en On**
  * Security > `Location`: **Todo en Off**
  * Security > `Windows Permissions`: **Todas en Off**
    * `General, Speech, Inking`, **todo en Off**
    * `Diagnostics`: **todo a off y Feedback frequency: Never**.
    * Activity, `Search permissions, Searching Windows`: **todo off**
  * Security > `App Permissions`: **Location Off**, el **resto a valor por defecto**
* Start > Settings > Apps
  * `Startup` > **Quito todas, sobre todo Edge**
    * Excepción: dejo *Security notification icon*
    * Excepción: dejo *VMWare Tools Core Service* si estoy instalando en una VM Windows.
  * `Default apps` > Microsoft Edge : **Reviso que todo sea Chrome**
  * `Apps for Websites` > **todo a off**

Configuro que ***no pregunte*** cada vez que quiero arrancar un App

* `Start > busco por "User Account Control settings"` > **Never notify**

***Eliminar el PIN***, no lo quiero. Esto me va a obligar (durante un rato) a hacer login con mi cuenta de microsoft pero inmediatemente también voy a cambiar eso.

* Start > Settings > Accounts > `Sign-in options`
  * Desactivo `For improved security, only allow Windows Hello sign-in...`
  * **Quito PIN** > Remove. Me pide contraseña de mi usuario Microsoft.
  * En `If you've been away, when should Windows ...` lo pongo en "**Never**", que no me pida login cuando despierta.

Cambio el ***Home*** de mi usuario y cambio a ***login con Usuario local***. Durante la instalación me obligó a 2 cosas que no me gustan: 1) usar una cuenta de Microsoft usando un mail registrado. 2) creó el nombre corto del usuario con los 5 primeros caracteres de dicho mail, por lo que quedó comoo `luisp` y el HOME de mi usuario en `C:\Users\luisp\`.

* [Opcional] Cambiar el nombre del directorio HOME ([guía](https://www.elevenforum.com/t/change-name-of-user-profile-folder-in-windows-11.2133/))
  * Habilito al Administrador
    * `net user Administrator /active:yes`
  * Rearranco el ordenador, hago login con Administrador sin contraseña
    * CMD > `wmic useraccount get name,SID`
    * ***`regedit`*** -> `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\S-1* -> ProfileImagePath`
    * Explorer -> **Renombro el HOME**
    * CMD `mklink /d "C:\Users\luisp" "C:\Users\luis"`

Cambio a cuenta local

* Cambio a Cuenta Local, en vez de usar una Microsoft Account para hacer login en el equipo
  * `Start > Settings > Account > Account Settings > Your Info`
  * ***Cambio a cuenta local***, `Microsoft Account` > `Sign in with local account`: Creo un usuario `luis`, le pongo una contraseña.
* Si estoy en una Máquina Virtual con VMWare Workstation, puedo aprovechar para activar Autologin en la VM
  * Teniendo la VM arrancada: VMWare Worksation Pro > botón derecho sobre la VM > `Settings` > `Options` > `Autologin`.
  * Una vez que me pide el usuario/contraseña (mismo que puse para la cuenta local), rearranco la VM y observo que hace autologin!!

***Powershell 7***.

* Por defecto el equipo trae `CMD` y `PowerShell 5` (para ver la versión de PS usé el comando: `$PSVersionTable`)
* Desde [PowerShell Tags](https://github.com/PowerShell/PowerShell/tags) descargo desde el link "Downloads" la última versión (`PowerShell-7.4.5-win-x64.msi`) y la instalo.

***Eliminar anuncios y varios***

Algunos los he marcado como [Opcional] porque en instalaciones sucesivas de Windows he dejado de hacerlo

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
    * `Computer Configuration\Administrative Templates\Windows Components\Widgets​` > `Allow Widgets` **disabled**.
    * Hago **reboot**. Al arrancar verás que Windows+W ha dejado de funcionar !!
* Quitar Ads del Explorer
  * Window + E > tres puntos horizontales > Options > View > **Quito "Show sync provider notifications" > Apply** y **Ok**.
* Quitar Notification Ads
  * Start > Settings > System > Notifications > Additional Settings > **Quito las tres opciones** que aparecen
* Quitar "Device Usage Settings" (ya lo hice, me aseguro)
  * Start > Settings > Personalization > Device Usage > **Quito todas**.
* Quitar contenido sugerido  (ya lo hice, me aseguro)
  * Start > Settings > Privacy and Security > General > Me aseguro de que **"Show me notifications in the Settings app" esté desactivado**
* Quitar Ads de Diagnostic Data (ya lo hice, me aseguro)
  * Start > Settings > Privacy and Security > Diagnostics & feedback > Tailored experiences > Let Microsoft use your diagnostic data - **Off**
  * De hecho **tengo en Off todas las opciones bajo Diagnostics & feedback**
* [Opcional] Quitar la papelera de reciclaje del Escritorio/Desktop
  * Start > Settings > Personalization > Themes > Desktop icon settings > **Quito el checkbox de Recycle Bin**
  * Añado la papelera de reciclaje al Explorer (para que aparezca en "Este equipo / This PC")
    * ***`regedit`*** ->
      * `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace`
      * Nueva clave/Key: `{645FF040-5081-101B-9F08-00AA002F954E}`
      * **Reboot**
* Personalizo el Taskbar
  * Botón derecho iconos que están en el taskbar y uno a uno **quito iconos que no uso**.
  * Start > tecleo "Start settings" >
    * Layout > More pins
    * Show recently added apps > **Off**
    * Show reocmmendations .. > **Off**
    * Show account notifications > **Off**
    * Show recently opened > **Off**
* Elimino el teclado US que me instaló por defecto.
  * Start > Settings > Time & Language > Language & Region > Preferred Languages > "..." > Options > Keyboards > **Quito US** (dejo solo el de Spanish)
* [Opcional] Añado "Turn off display" al menú de contexto del escritorio
  * Sigo este apunte de [aquí](https://www.elevenforum.com/t/add-turn-off-display-context-menu-in-windows-11.8267/)

***Actualización*** del sistema operativo

* Ya va siendo hora, Start > escribo "Update " > Check for Updates > Hago todas las **actualizaciones/reboots** que me pide.

***Desinstalar Apps***

Que en Europa se regulen tantas cosas tiene sus beneficios :-), en Europa es posible desinstalar Edge y otras aplicaciones desde el propio Sistema Operativo.

* Sin comentarios. Start > Settings > Apps > Installed Apss
  * Microsoft Edge > ***Uninstall, rearranco el equipo***
  * Microsoft Edge Update > No me deja hacer un Uninstall
  * Microsoft Edge WEbView2 > No me deja hacer un Uninstall

Si ahora entro en "buscar" ya empiezo a ver los efectos, cada vez menos morralla.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-01.png"
      caption="Versión minimalista de Buscar"
      width="400px"
      %}

* [Opcional] Cuando instalo windows en una Virtual Manchine, en este paso aprovecho y elimino aplicaciones que no voy a usar nunca
  * Microsoft News, Microsoft Bing, Microsoft To Do, Microsoft Outlook,
  * Weather, Xbox, Xvox Live Live, Microsoft Teams, Microsoft 365 Office.

***File Explorer***. Mostrar archivos y directorios ocultos, file extensions, etc.

* Start > Settings > `System` > `For developers`
  * Habilitar el modo para desarrolladores si no lo estaba ya.
  * Entrar en > `File Explorer`
    * `Show file extensios`: **On**
    * `Show hidden and system files`: **On**
    * `Show full path in title bar`: **On**
    * `Show empty drives`: **On**

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

* Lo configuro para minimizar alertas y notificaciones. En mi caso el ordenador está conectado a una red privada pero por defecto la instalación lo puso en red Pública
  * Start > Settings > Network & Internet > Ethernet (y también WiFi)
    * **Cambio ambas a `Private Network`**
* Configuro el Firewall de Windows para minimizar alertas y notificaciones
  * Start > busco "Control Panel" > System & Security > Windows Defender Firewall > Advanced Settings”
    * Reviso reglas de entrada y salida para bloquear o permitir aplicaciones específicas según lo necesite.
  * Start > busco "Control Panel" > System & Security > Windows Defender Firewall > Change notification settings"
    * Desactivo las notificaciones, **desmarco las casillas de “Notify me when Windows Defender Firewall blocks a new app”**

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-02.png"
      caption="Versión minimalista de Start"
      width="450px"
      %}

***Instalación de PowerToys***

Las Microsoft PowerToys son un conjunto de utilidades para que los usuarios avanzados mejoren y optimicen su experiencia con Windows a fin de aumentar la productividad. Lo instalo desde la [página oficial](https://learn.microsoft.com/es-es/windows/powertoys/install). Algunas que me gustan a mi, incluyo pegado avanzado, editar el archivo `hosts`.

Un caso de uso interesante es remapear el teclado. Tengo un apunte donde describo cómo uso [Barrier para imitar la funcionalidad KVM]({% post_url 2024-06-13-kvm %}#unificar-las-teclas-de-control), al final del mismo trato el tema de remapeo.

***Visual Studio Code***: Tampoco requiere mucha presentación, un editor de código fuente que incluye un terminal integrado. Puedo abrir diferentes **terminales integrados** dentro de la misma ventana de VS Code, como CMD, PowerShell, Git Bash o WSL.

Soporta una amplia variedad de lenguajes de programación y una gran cantidad de extensiones para mejorar su funcionalidad. Lo instalo desde el [sitio oficial de Visual Studio Code](https://code.visualstudio.com/).

## Una vuelta de tuerca

Al seguir los pasos anteriores obtengo un Windows 11 mucho más limpio, rápido y libre de distracciones, ideal para su uso en entornos específicos como pruebas o demostraciones. Además de las optimizaciones mencionadas, dejo aquí algunas cosillas adicionales, que pueden llevar la personalización un paso más allá, ten en cuenta que a partir de aquí ya es decisión personal.

***Desactivar Cortana***

* Busco “gpedit.msc” en el menú de inicio y abro el Editor de directivas de grupo local (Local Group Policy Editor).
  * Navego a “Computer Configuration > Administrative Templates > Windows Components > Search”.
  * Hago doble clic en “Allow Cortana” y selecciono “Disabled”. Aplico los cambios para desactivar Cortana.

***Quito más aplicaciones preinstaladas***

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

***Deshabilitar servicios innecesarios***

* Abro `services.msc` desde el menú de inicio.
  * Identifico los servicios que no necesito (por ejemplo, "xbox*", etc.). Hago doble clic en el servicio, cambio el “Startup type” a “Disabled” y aplico los cambios.

Con estas recomendaciones adicionales, el sistema estará preparado para ofrecer una experiencia de usuario más directa, sin distracciones ni interrupciones innecesarias.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-03.jpg"
      caption="Versión minimalista del escritorio"
      width="800px"
      %}

Paso las pruebas de evaluación del sistema de Windows (WinSAT) se usan para analizar el rendimiento de varios componentes del sistema, como CPU, memoria, disco y gráficos.

```PS1
C:\Users\luis> winsat formal
C:\Users\luis> Get-CimInstance Win32_WinSat
```

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-04.png"
      caption="Idoneo para trabajar"
      width="600px"
      %}

Seguí los pasos anteriores para optimizar también un [máquina virtual windows]({% post_url 2024-08-26-win-vmware %}) corriendo en un windows optimizado, como puedes observar el rendimiento de la máquina virtual es muy decente.

{% include showImagen.html
      src="/assets/img/posts/2024-08-24-win-decente-06.png"
      caption="Otro windows 11 optimizado, esta vez como Guest de VMWare Workstation"
      width="600px"
      %}

***Mantenimiento: Comandos útiles***

Antes de terminar el apunte, dejo aqui algunos comandos útiles, que ejecuto desde como administrador

* `chkdsk`: Comprueba el estado del disco duro y nos muestra un informe con la información necesaria. Además, se encarga de corregir problemas e incluso recuperar información perdida.
* `dism /online /cleanup-image /restorehealth`: Se conecta con el **Windows Update service** para bajarse y reemplazar cualquier archivo importante que falte o esté corrupto.
* `sfc`. Analizar la integridad de todos los archivos de sistema y solucionar problemas en los mismos. ***AVISO!!***: Microsoft tiene un problema conocido que lleva años sin resolverse. De hecho a mi me ha pasado. Al ejecutarlo por primera vez (`sfc /SCANNOW` encuentra un problema en el archivo `bthmodem.sys` y lo elimina.
  * Cuando lo ejecutes indicará que ha encontrado corrupción y si miras su log `\Windows\Logs\CBS\CBS.log` verás que se refiere a `Corrupt File: bthmodem.sys`. Así que ejecuto el `dism /online /cleanup-image /restorehealth` que resuelve el entuerto.

## Personalizaciones

Doy por terminado el apunte, lo que viene ahora son algunas cosas que hice en mi caso y que quiero tener documentadas.

***Instalación de Barrier para KVM por software***

Esto que describo ahora ya no tiene que ver con un Windows "decente", así que puedes saltártelo. Es para acordarme yo mismo de cómo resolví una necesidad. Trabajo con dos ordenadores (mac mini y PC con dualboot Windows / Linux), cada uno con su monitor. Mi objetivo es poder tener un KVM por software para poder compartir el Teclado y el Ratón.

* Instalo [Barrier](https://github.com/debauchee/barrier).
  * Al instalar me pregunta `Enable autoconfig and install Bonjour`, le digo que Sí.

| Nota: Lo ideal sería configurar el Mac como **Server** para usar su teclado y su trackpad (contar con todas sus virguerías). Pero, no se pueden generar en el PC las AltGr Keys `\|@#[]{}~€¬` ni ` < > `. He dedicado muchas horas investigando este tema y no consigo encontrar la solución. |

La mejor opción que he encontrado es **usar el PC como Server** (Windows o Linux). He instalado un Magic Trackpad 2 de Apple para que la experiencia (gobernar el Mac desde el teclado/mouse del PC) sea lo más parecida posible.

***Drivers para Magic Trackpad 2***

De nuevo, otra necesidad que he aprovechado para documentar, porque pasé un pequeño calvario para que me funcionase. Hay múltiples artículos en internet sobre cómo usar el Magic Trackpad 2 de Apple en un PC con windows. Lo que ha mi me ha funcionado es lo siguiente, que saqué de [aquí](https://www.reddit.com/r/bootcamp/comments/ygv1mh/any_way_to_get_magic_trackpad_2_working_on/?tl=es&onetap_auto=true&one_tap=true):

* Descargo específiciamente la versión de Apple 6.1.8000.6 de 07/4/22 desde [el sitio oficial de Apple](https://swcdn.apple.com/content/downloads/03/60/041-96205/61hhcnj7q5dxosc171ytixty20vuqg0r0n/AppleBcUpdate.exe)
* Extraigo con 7-Zip a subdirectorio `AppleBcUpdate`
* Conecto el Magic Trackpad 2 vía Bluetooth (no cable), `Setting > Bluetooth > Add device > Bluetooth`, encender el MT2 y asociarlo.
* Instalo los Drivers, uno tras otro, sin rearrancar (activo ver los `.inf` en Explorer `View > Show > Filename extensions`)
  * Primero el de USB, bajo el directorio `ApplePrecisionTrackpadUSB` click derecho sobre `ApplePrecisionTrackpadUSB.inf` -> **Instalar**
  * Después el de Bluetooth, bajo el directorio `ApplePrecisionTrackpadBluetooth` click derecho sobre `ApplePrecisionTrackpadBluetooth.inf` -> **Instalar**
* **Reboot**
* El Trackpad (Windows lo llama Touchpad) funciona perfecto.
* Es posible entrar en los ajustes de precisión en `Settings > Bluetooth & devices > Touchpad`.

Importante: si instalaste drivers antiguos o hiciste pruebas con drivers de terceros, desinstálalos antes de hacer los pasos anteriores. A mi me pasó:

* Lita drivers instalados y fíjate en el valor de la columna **Published Name** para el que quieres desinstalar (en mi caso fue `oem19.inf`)

```PS
dism /Online /Get-Drivers /Format:Table
:
-------------- | ------------------ | ----- | ----------------- | -------------------- | ---------- | ---------------
Published Name | Original File Name | Inbox | Class Name        | Provider Name        | Date       | Version
-------------- | ------------------ | ----- | ----------------- | -------------------- | ---------- | ---------------
:
oem19.inf      | applewtp64.inf     | No    | HIDClass          | Apple Inc.           | 29/10/2011 | 5.0.0.0
:
```

* Lo desinstalé con `pnputil /delete-driver oem19.inf /uninstall` (puedes añadir `/force` si lo necesitas). Rearranqué el equipo antes de pasar a la instalación que mencionada antes.

***Herramientas útiles***

Para terminar, herramientas útiles que siempre suelo instalar:

* ***[7-Zip.org](https://7-zip.org)***: Ya la comenté, es un básico para mi
* ***[Clink](https://github.com/chrisant996/)***: Enriquece muchísimo el CMD (`command.com`) con una readline como el de Linux, añade múltiples funcionalidades, colores, history.
* ***[Ccleaner](https://www.ccleaner.com/)*** Muy buena pinta, aunque para tener acceso a lo "chulo" hay que comprar la licencia Profesinoal.
* ***[BleachBit](https://www.bleachbit.org/)*** Una alternativa Open Source a CCleaner, que tiene una pinta buenísima. Le falta la parte del Registry y la Optimización de rendimiento.
  * Antes de instalar la última versión, hay que bajarse el **[Visual Studio 2919 (VC++ 10.0) redistributable SP1 x86](https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe)**, es la versión x86. Aunque mi sistema es de 64-bit da igual porque va a usar la dll de la versión x86.

