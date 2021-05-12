---
title: "Limpiar master slides en PPT"
date: "2014-02-20"
categories: herramientas
tags: slides ppt vba
excerpt_separator: <!--more-->
---



![logo Visualbasic](/assets/img/posts/logo-vb.svg){: width="150px" style="float:left; padding-right:25px" } 

En este apunte explico cómo crear una **Macro VBA** para eliminar slides master (patrones) no utilizadas en un fichero Powerpoint, dedicado a mi amigo Alfonso. :-)

<br clear="left"/>
<!--more-->


La solución es sencilla, hay que borrar las no utilizadas, pero a veces es tal el número de slides "maestras" que el trabajo de ir borrándolas a mano es muy tedioso.

Con una Macro es mucho más fácil.

- **Herramienta->Macro->Macros**

    - Darle un nombre: "BorrarPatrones" y pulsar en Crear.
    - Lanza el editor Visual Basic, con una macro vacía.

- **Sustituimos lo que nos presenta**

ˋˋˋvba
Sub BorrarPatrones()

End Sub
ˋˋˋ

- **por lo siguiente**

ˋˋˋvba
Sub BorrarPatrones() 

' Preparar variables 
Dim aPresentation As Presentation 
Set aPresentation = ActivePresentation
Dim iDesign As Integer 
Dim iLayout As Integer 

' Ignorar un error al intentar borrar y continuar. El unico 
' error que puedo recibir es precisamente que no puede borrar 
' una utilizada, lo cual es bueno :), lo ignoro y paso a la siguiente 
On Error Resume Next 

' Loop para recorrer Diseños y sus Layouts 
With aPresentation 
    For iDesign = 1 To .Designs.Count 
        For iLayout = .Designs(iDesign).SlideMaster.CustomLayouts.Count To 1 Step -1 
            ' Elimino el layout 
            .Designs(iDesign).SlideMaster.CustomLayouts(iLayout).Delete 
        Next 
    Next iDesign 
End With 

End Sub
ˋˋˋ

En la barra de herramientas del editor de Visual Basic pulsar en el "PLAY" para que ejecute la macro. Dependiendo del tamaño de tu presentación y el número de slides patrones que tengas terminará en unos segundos o en minutos.

{% include showImagen.html
    src="/assets/img/original/MasterSlides.png"
    caption="MasterSlides"
    width="600px"
    %}

Cuando termine, salvar el archivo, avisará que si lo haces se perderá la macro, seguir adelante dado que la Macro la podemos ignorar, ya no la necesitamos más, volver a abrirlo y veréis que los patrones han desaparecido, bueno, los no usados. 

Esta mañana lo ejecuté en un PPT de 50MB con cientos de slides master y tardó 7 min en terminar, así que paciencia. Por cierto, lo dejó en 33MB :-)


