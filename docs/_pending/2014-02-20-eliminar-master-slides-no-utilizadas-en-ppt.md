---
title: "\"Master Slides\" no utilizadas en PPT"
date: "2014-02-20"
categories: 
  - "apuntes"
---

En este apunte explico cómo crear una **Macro** para eliminar slides master (patrones) no utilizadas en un fichero Powerpoint, dedicado a mi amigo Alfonso. :-)

[![1hsYpTpH-vba-logo](https://www.luispa.com/wp-content/uploads/2014/12/1hsYpTpH-vba-logo-300x114.png)](https://www.luispa.com/wp-content/uploads/2014/12/1hsYpTpH-vba-logo.png) Muy útil para reducir el tamaño de ciertas presentaciones donde hemos ido insertando muchísimas slides (copy/paste desde otros PPTs) durante mucho tiempo y la sección de Master Slides (Patrones maestros) ha crecido sin control.

La solución es sencilla, borrar las no utilizadas, pero a veces es tal el número de slides "maestras" que el trabajo de ir borrando las no utilizadas a mano es muy tedioso.

Con una Macro es mucho más fácil.

- **Herramienta->Macro->Macros**
    - Darle un nombre: "BorrarPatrones" y pulsar en Crear.
    - Lanza el editor Visual Basic, con una macro vacía.

- **Sustituimos lo que nos presenta**

\[code light="false" collapse="false" toolbar="false"\] Sub BorrarPatrones()

End Sub \[/code\]

- **por lo siguiente**

\[code light="false" collapse="false" toolbar="false"\] Sub BorrarPatrones() ' Preparar variables Dim aPresentation As Presentation Set aPresentation = ActivePresentation Dim iDesign As Integer Dim iLayout As Integer ' Ignorar un error al intentar borrar y continuar. El unico ' error que puedo recibir es precisamente que no puede borrar ' una utilizada, lo cual es bueno :), lo ignoro y paso a la siguiente On Error Resume Next ' Loop para recorrer Diseños y sus Layouts With aPresentation For iDesign = 1 To .Designs.Count For iLayout = .Designs(iDesign).SlideMaster.CustomLayouts.Count To 1 Step -1 ' Elimino el layout .Designs(iDesign).SlideMaster.CustomLayouts(iLayout).Delete Next Next iDesign End With End Sub \[/code\]

En la barra de herramientas del editor de Visual Basic pulsar en el "PLAY" que ejecutará la macro. Dependiendo del tamaño de tu presentación y el número de slides patrones que tengas terminará en unos segundos o en minutos.

[![MasterSlides](https://www.luispa.com/wp-content/uploads/2015/11/MasterSlides.png)](https://www.luispa.com/wp-content/uploads/2015/11/MasterSlides.png)

Cuando termine, salvar el archivo, avisará que si lo haces se perderá la macro, seguir adelante dado que la Macro la podemos ignorar, ya no la necesitamos más, volver a abrirlo y veréis que los patrones han desaparecido, bueno, los no usados. Esta mañana lo ejecuté en un PPT de 50MB con cientos de slides master y tardó 7 min en terminar, así que paciencia. Por cierto, lo dejó en 33MB :-)
