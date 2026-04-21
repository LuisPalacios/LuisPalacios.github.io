---
title: "Jerarquía con Apple Creator Studio"
date: "2026-02-08"
categories: ["productividad"]
tags: ["final-cut-pro", "motion", "video", "edición", "macos", "workflow"]
draft: false
cover:
  image: "/img/posts/logo-fcp.svg"
  hidden: true
---

<img src="/img/posts/logo-fcp.svg" alt="Logo Final Cut Pro" width="150px" height="150px" style="float:left; padding-right:25px" />

**[Apple Creator Studio](https://www.apple.com/es/apple-creator-studio/)** es la **nueva** suscripción de Apple que agrupa sus herramientas creativas profesionales: Final Cut Pro, Motion, Compressor, Logic Pro y Pixelmator Pro. En este apunte describo cómo organizo mis proyectos de vídeo para aprovechar al máximo los discos disponibles y mantener todo bajo control.

El reto no es usar Final Cut Pro —que es bastante intuitivo— sino gestionar la jerarquía de archivos entre discos sin acabar con librerías huérfanas, cachés desbordadas o perder las fuentes en bruto. Después de varios proyectos familiares, he consolidado un protocolo que me funciona.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2026-02-08-apple-creator-studio-01.png" alt="Qué incluye Apple Creator Studio" width="650px" />
  <div class="image-caption">El nuevo paquete para gente creativa.</div>
</div>

<br/>

## Introducción

**Final Cut Pro** es el editor de vídeo profesional de Apple. Su Magnetic Timeline permite mover clips sin dejar huecos, y el renderizado aprovecha el hardware del Mac para previsualizar efectos en tiempo real. Es potente pero accesible —ideal tanto para proyectos profesionales como familiares.

**Motion** es el complemento ideal para hacerte tus propios gráficos animados: títulos, transiciones, lower thirds y efectos. Lo que diseñas en Motion se integra directamente en Final Cut Pro como si fuera un recurso nativo. Ambos comparten el mismo motor de renderizado, así que la fluidez está garantizada.

## Filosofía de la jerarquía

Este apunte se centra en organizar la jerarquía de carpetas y decidir dónde guardar cada cosa. Con un solo disco es trivial, pero cuando tienes varios —con distintas capacidades y velocidades— merece la pena pensarlo bien desde el principio.

Mi setup tiene tres discos con roles diferenciados:

| Disco            | Tipo        | Rol                                                                 |
| ---------------- | ----------- | ------------------------------------------------------------------- |
| **Macintosh_HD** | SSD interno | Sistema Operativo. Lo usaré para caché y render. Disco ultra rápido |
| **Baúl**         | SSD externo | Trabajo activo. Disco SSD muy rápido                                |
| **Trastero**     | HDD externo | Almacén maestro. Disco rápido normal                                |

La idea es simple: el SSD interno es rápido pero limitado (capacidad), así que solo almacena archivos temporales. El SSD externo (Baúl) contiene los proyectos en curso. El HDD (Trastero) guarda todo lo finalizado —es lento pero enorme.

## Estructura de directorios

```text
Macintosh_HD/
└── Users/luis/Multimedia/FCP_Cache            ← Caché y renders

Baul/ (SSD)
└── Multimedia/Familia_Active/
    ├── 01_Media_Active/YYYY-MM-DD_Proyecto/   ← Clips importados
    ├── 02_Library_Files/                      ← Librerías .fcpbundle
    └── 03_Motion_Content/                     ← Archivos .motn

Trastero/ (HDD)
└── Multimedia/Familia_Master/
    ├── 01_Source_Originals/YYYY-MM-DD_Proyecto/   ← Brutos + librería archivada
    ├── 02_Final_Deliverables/                     ← Vídeos exportados
    ├── 03_Audio_Library/                          ← Música y efectos
    ├── 04_FCP_Backups/                            ← Backups automáticos
    └── 05_Graphic_Assets/                         ← Logos y vectores
```

Cada proyecto tiene su carpeta con fecha (`YYYY-MM-DD_Proyecto`), lo que facilita ordenar cronológicamente y evitar colisiones de nombres.

## Librería, evento y proyecto

Final Cut Pro organiza el trabajo en tres niveles jerárquicos:

```text
Librería (.fcpbundle)
└── Evento
    ├── Clips (medios importada)
    └── Proyecto (timeline de edición)
```

<div class="image-box">
  <img src="/img/posts/2026-02-08-apple-creator-studio-02.png" alt="Librería, evento y proyecto" width="300px" />
  <div class="image-caption">Librería, evento y proyecto.</div>
</div>

La **Librería** es el contenedor principal —un fichero `.fcpbundle` que agrupa todo. Dentro hay **Eventos**, que funcionan como carpetas lógicas para organizar material (por fecha, tema o lo que prefieras). Y dentro de cada Evento viven los **Proyectos**, que son las líneas de tiempo donde editas.

Un ejemplo práctico: para el cumpleaños de mi hijo, creo una librería `Cumple_Luis.fcpbundle`. Dentro tengo un evento llamado "Cumple 2026" con todos los clips importados. Y dentro del evento, un proyecto "Montaje Final" donde hago la edición.

Esta jerarquía es importante porque las configuraciones de almacenamiento (Storage Locations) se aplican a nivel de **Librería**, no de proyecto. Todos los eventos y proyectos dentro de una librería comparten la misma configuración.

## Configuración de Storage Locations

La librería (el fichero `.fcpbundle`) lo voy a crear en `Baul/.../02_Library_Files/[Nombre_Proyecto].fcpbundle`.

Al crear una librería nueva, configuro dónde guarda FCP cada tipo de archivo. Voy a **Library** > **Inspector** > **Storage Locations** > **Modify Settings**:

| Parámetro          | Ubicación                         | Disco        |
| ------------------ | --------------------------------- | ------------ |
| **Media**          | `Baul/.../01_Media_Active`        | Baúl         |
| **Motion Content** | In Library                        | Baúl         |
| **Cache**          | `Users/luis/Multimedia/FCP_Cache` | Macintosh_HD |
| **Backups**        | `Trastero/.../04_FCP_Backups`     | Trastero     |

<div class="image-box">
  <img src="/img/posts/2026-02-08-apple-creator-studio-03.png" alt="Propiedades de la librería" width="400px" />
  <div class="image-caption">Propiedades de la librería.</div>
</div>

{{< admonition "tip" "Nomenclatura coherente" >}}
Nombra la librería igual que la carpeta de medios. Si los clips están en `2026-02-08_Cumple_Luis/`, la librería debería ser `Cumple_Luis.fcpbundle`. Esto evita confusiones cuando tienes varias Librerías y sus Evento y Proyectos abiertos.
{{< /admonition >}}

## Flujo de trabajo

### Importar con "Leave in Place"

Al importar (`Cmd + I`), en el panel derecho selecciono **"Leave files in place"**. FCP no duplica los archivos —los lee directamente desde el Baúl. Ahorra espacio y CPU.

### Keywords automáticas

En la misma ventana de importación, bajo **Keywords**, marco **"From folders"**. FCP crea etiquetas automáticamente basadas en las subcarpetas. Si tengo `01_Assets/Drone/`, los clips de esa carpeta tendrán la keyword "Drone".

### Integración Motion ↔ FCP

El flujo entre Motion y Final Cut es directo:

1. **Diseño** en Motion (título, lower third, transición)
2. **Guardo** el archivo `.motn` en `Baul/.../03_Motion_Content`
3. **Publico** desde Motion (File > Publish)
4. El recurso aparece automáticamente en el navegador de FCP

Al configurar Motion Content como "In Library", FCP absorbe el recurso publicado dentro del `.fcpbundle`. El archivo `.motn` original queda como fuente de trabajo por si necesito editarlo.

## Consolidación y archivado

Cuando termino un proyecto, lo archivo siguiendo estos pasos:

### 1. Limpiar la caché

`File` > `Delete Generated Library Files` > Marco todo (Render Files, Optimized Media, Proxy Media). Esto libera el disco de sistema.

### 2. Consolidar la librería

En el Inspector de la Library, pulso **Consolidate**. Respondo **SÍ** a incluir Motion Content. FCP copia todo lo necesario dentro del `.fcpbundle`, haciéndolo portable.

### 3. Mover al Trastero

Muevo la librería consolidada junto con los brutos:

- **Origen:** `Baul/.../02_Library_Files/[Proyecto].fcpbundle`
- **Destino:** `Trastero/.../01_Source_Originals/YYYY-MM-DD_Proyecto/`

Así, brutos y librería quedan juntos en la misma carpeta del archivo maestro.

### 4. Verificar integridad

Abro la librería desde el Trastero para confirmar que todo enlaza correctamente. Solo entonces borro los archivos del Baúl y la caché del Macintosh_HD.

## Tips de experto

### Sincronía de formato

Configura siempre FCP y Motion con la misma resolución y frame rate. Si el proyecto es 1920x1080 a 24p, Motion debe estar en 1080p / 23.98 fps. Esto evita interpolación de frames y escalado innecesario.

### Múltiples proyectos simultáneos

Con la estructura propuesta, puedes tener varias librerías abiertas sin conflictos:

```text
Baul/Multimedia/Familia_Active/
├── 01_Media_Active/
│   ├── 2026-01-01_Viaje_Japon/
│   └── 2026-02-08_Cumple_Luis/
└── 02_Library_Files/
    ├── Viaje_Japon.fcpbundle  ← Apunta a clips de Japón
    └── Cumple_Luis.fcpbundle  ← Apunta a clips del cumple
```

Cada librería tiene sus Storage Locations independientes.

### Desactivar Background Render

Para evitar que la caché crezca sin control:

1. **Settings** > **Playback**
2. Desmarca **Background Render**
3. Renderiza manualmente con `Ctrl + R` cuando pierdas fluidez

### Mantenimiento de caché

- **Durante el proyecto:** Si Macintosh_HD baja de 50GB libres, borra Render Files desde `File` > `Delete Generated Library Files`
- **Al finalizar:** Borra manualmente `Users/luis/Multimedia/FCP_Cache` tras verificar el archivo

## Enlaces interesantes

- [Final Cut Pro User Guide](https://support.apple.com/guide/final-cut-pro/) — Manual de Final Cut Pro
- [Motion User Guide](https://support.apple.com/guide/motion/) — Manual de Motion
- [Apple Creator Studio](https://www.apple.com/es/apple-creator-studio/) — Suscripción oficial
