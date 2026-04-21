---
title: "Limpiar PPT"
date: "2014-02-20"
categories: ["herramientas"]
tags: ["slides","ppt","vba"]
draft: false
cover:
  image: "/img/posts/logo-vb.svg"
  hidden: true
---



<img src="/img/posts/logo-vb.svg" alt="logo Visualbasic" width="150px" style="float:left; padding-right:25px"  />

En este apunte explico cómo crear una **Macro VBA** para eliminar slides master (patrones) no utilizadas en un fichero PowerPoint, dedicado a mi amigo Alfonso. :-)

**¿Por qué se acumulan tantos patrones en PowerPoint?** Cuando trabajamos con presentaciones que provienen de diferentes fuentes —como plantillas corporativas, presentaciones de terceros, o cuando copiamos diapositivas de múltiples archivos— PowerPoint automáticamente importa y mantiene todos los patrones de diseño (slide masters) asociados, incluso si no los estamos utilizando activamente en nuestra presentación.

<br clear="left"/>
<!--more-->

La solución es sencilla, hay que borrar las no utilizadas, pero a veces es tal el número de slides "maestras" que el trabajo de ir borrándolas a mano es muy tedioso.

Esta acumulación de patrones puede ser problemática por varias razones: **aumenta significativamente el tamaño del archivo**, hace que la navegación por los diseños disponibles sea confusa y desordenada, y puede ralentizar el rendimiento de PowerPoint, especialmente en presentaciones grandes. Además, cuando compartimos archivos con colegas o clientes, estos patrones innecesarios se transfieren junto con el archivo, perpetuando el problema.

**El desafío de la limpieza manual:** PowerPoint no ofrece una función nativa para eliminar automáticamente los patrones no utilizados. La única manera de limpiarlos manualmente es ir uno por uno identificando cuáles están en uso y eliminando los restantes, un proceso que puede ser extremadamente tedioso cuando hay docenas de patrones acumulados. Aquí es donde entra en juego la automatización con VBA (Visual Basic for Applications), que nos permite crear una solución elegante y eficiente para este problema común.

Con una Macro es mucho más fácil.

- **Herramienta->Macro->Macros**
  - Darle un nombre: "BorrarPatrones" y pulsar en Crear.
  - Lanza el editor Visual Basic, con una macro vacía.

- **Sustituimos lo que nos presenta**

```vba
Sub BorrarPatrones()

End Sub
```

- **por lo siguiente**

```vba
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
```

En la barra de herramientas del editor de Visual Basic pulsar en el "PLAY" para que ejecute la macro. Dependiendo del tamaño de tu presentación y el número de slides patrones que tengas terminará en unos segundos o en minutos.

<div class="image-box">
  <img src="/img/posts/2014-02-20-limpiar-slides-01.png" alt="Master Slides" width="300px" />
  <div class="image-caption">Master Slides</div>
</div>

Cuando termine, salvar el archivo, avisará que si lo haces se perderá la macro, seguir adelante dado que la Macro la podemos ignorar, ya no la necesitamos más, volver a abrirlo y veréis que los patrones han desaparecido, bueno, los no usados.

Esta mañana lo ejecuté en un PPT de 50MB con cientos de slides master y tardó 7 min en terminar, así que paciencia. Por cierto, lo dejó en 33MB :-)
