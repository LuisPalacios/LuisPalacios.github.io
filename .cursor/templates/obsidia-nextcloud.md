## Información Básica

**Título del Post**: Obsidian en casa

**Fecha propuesta**: [2026-1-4]

**Categoría principal**: [Seleccionar de la lista en `.cursor/rules/estructura-hugo.md`]

**Tags**: [documentación, kiss, PKM, personal, knowledge, management, cloud, casa]

**Draft**: true

## Descripción del Contenido

**Propósito del post**: Ay! los PKM's, menuda cruz. Hay tantos y tan diversos que es un dolor de cabeza. Después de mucho trastear he llegado a la conclusión que necesito un buen sistema para gestionar Notas desde cualquier lugar y por supuesto que permita hacer búsquedas. El objetivo es documentar en detalle como he decidido abordar el tema con **`obsidian`** en casa.

**Audiencia objetivo**: Hackers que tienen un home lab con buen nivel técnico que buscan poder controlar su propio PKM en casa. Normalmente tienen un servidor o varios con KVM, Proxmox o similar.

## Estructura del Contenido

### Introducción

Para mi, lo de tomar notas, siempre ha sido un tema recurrente, llevo haciéndolo años, tengo cientos. Son mi **datos** y quiero tenerlos organizados y poder buscar en ellos desde cualquier sitio.

He pasado por varias técnicas, que fuese simple, rápido y cómodo. Desde el papel hasta aplicaciones para capturar las notas de las reuniones, ideas, HowTo's.

Si me fijo en la parte digital he hecho de todo, incluidas varias migraciones dolorosas. Cuando he optado por lo bonito y potente en la nube, acabé pagando el pato, propietario, secuestro y pérdida de control, así que me puse estos requisitos:

- Formato: Que la tecnología no guarde el dato de forma propietaria (evitar el secuestro). Que lo guarde en formato estándar: **Markdown y Sistema de Ficheros** de toda la vida. Cada nota un fichero y los gráficos en una carpeta por debajo
- Propiedad: Que el dato esté en **mi posesión**, en mis dispositivos, no en la nube (seguridad)
- Futuro: Que la tecnología para abrirlo sea **open source** y cualquiera que soporte markdown. Si no es open source, pues que cumpla **el punto anterior (propiedad)**.
- Disponibilidad: Que tenga **sincronización nativa o independiente**, sencilla y fiable; no necesito que sea en tiempo real, acepto retardo (he incluso manualmente si hace falta).
- **Multiplataforma**: Que pueda acceder a mis datos desde macOS, Windows, Linux, iOS y  Android; idealmente de forma nativa, o bien con editores o aplicaciones independientes.
- Búsqueda: Que se pueda buscar **texto dentro de cualquiera de mis notas**, independientemente de cómo las organice.

Mi histórico ha sido un dolor, como decía, empecé por papel, ficheros sueltos, Evernote, Notas.app de Apple, Craft.app, Standard Notes y por último Notion. Migraciones horribles, todo medio propietario, con pérdida de control y/o carísimo (Notion).

### Secciones principales

**¿Cómo lo he montado?**

Intenté que fuese KISS (Keep It Simple, Stupid!) y la verdad es no lo he conseguido. Aunque no he llegado al KISS, por lo menos he bajado a tierra y tengo "algo" que funciona y cumple.

**Solución**:

Cada nota es un  **fichero markdown**, sincronizados  con mi **NextCloud** casero, como editor/buscador uso  **Obsidian** y siempre accesible vía **WireGuard VPN**.

- **Markdowns en Carpetas y Ficheros** organizo el dato como quiero. No puede ser más KISS. Lleva años ahí, está ultra probado que funciona, es eficiente, sencillo, multiplataforma, y me da el control total. Puedo usar su estructura de carpetas y los nombres de ficheros como parte de la organización, ni etiquetas ni sistemas propietarios.
- **Nextcloud** - un proyecto open source absolutamente maravilloso. Tu nube tuya. Donde quieras. Te da el control total: puedes instalarlo en tu propio servidor o contratar uno gestionado. Él se encarga de sincronizar tus carpetas entre dispositivos, y tus archivos son simplemente ficheros Markdown, accesibles y editables donde quieras.
- **WireGuard** - por si quiero sincronizar estando fuera de casa, abro la VPN contra mi servidor casero y punto, sin complicaciones.
- **Obsidian** - Lo dejo para el final, explico cómo lo he montado. Obsidian es rápido, flexible y la edición en Markdown es una maravilla. Lo que más me gusta son sus clientes para IOS y Android, resuelven la búsqueda en el dispositivo móvil de forma eficiente. La interfaz recuerda a VSCode y los plugins llevan la experiencia a otro nivel (enlazado de notas, vista de grafo, plantillas...). Pero es que además puedo usar otros editores en paralelo (VSCode o Typora) cuando estoy en el Desktop.
  - IMPORTANTE: Obsidian para iOS **no soporta "Open folder as vault"** debido a las  restricciones de iOS, que no permiten montar la carpeta de Nextcloud directamente en Obsidian iOS como un “vault externo”.
  - Hay dos soluciones, la sencilla es usar el plugin **Remotely Save** y una más avanzada es usar el plugin **LiveSync**.

Como ves, todo perfecto excepto el iPhone/iPad, que necesito un dichoso plugin y tener cuidado sincronizando manualmente. Pero no me preocupa, incluso con esa “molestia” merece la pena.

1. **Markdown en carpetas y ficheros**:

Explicar aqui que Obsidian usa la misma estructura de carpetas y ficheros estándar del sistema operativo donde corre. Es por eso que voy a usar NextCloud en los diferentes clientes desde los que accederé, para que este ofrezca dichas carpetas.

2. **NextCloud**:

Hablar de la importancia de NextCloud, como servidor de ficheros compartidos en casa.

[Nextcloud](https://nextcloud.com/es/) son una serie de programas cliente-servidor que permiten la creación de servicios de alojamiento de archivos. Su funcionalidad es similar a Dropbox, aunque código abierto y me permite crear [mi propio NextCloud at home](https://nextcloud.com/athome/).

Tengo disponible mi servidor `https://nextcloud.parchis.org` en casa (y accesible desde internet vía WireGuard)

Relacionado con lo que nos ocupa, he creado una contraseña de Aplicación para WebDav, que voy a necesitar más adelante para el iPhone. Desde una sesión web Settings > Personal > [Security](http://cloud.parchis.org/settings/admin/security), a la izquierda la segunda opción y abajo añado un App, que me genera una password.

El siguiente paso es instalar los clientes en Linux, Mac, Windows y smartphones. Lo hago todo desde la página oficial de NextCloud > [Install Clients](https://nextcloud.com/install/#install-clients). Una vez configurados, compruebo que en todos los dispositivos tengo los mismos archivos y se sincronizan de forma perfecta.

3. **WireGuard**:

Hablar de wireguard para acceso remoto

4. **Obsidian**:

Instalación: Ya estoy listo para descargar [Obsidian](https://obsidian.md/download) e instalarlo en Mac, Win, Linux, iOS.

4.1 Cliente Desktop MacOs/Windows/Linux

Uso obsidian como un Lector e Indexador del directorio "Notas" de NextCloud

> nota Linux:  AppImage**
> Salirse de Obsidian
> Clic `Obsidian-1.8.10.AppImage` → AppImageLauncher → **Integrate & Launch**
> Borrar versión antigua `~/Applications/Obsidian-*`

Para los escritorios, todos igual, usando la opción de **OPEN FOLDER AS VAULT**.

<div class="image-box">
  <img src="/img/posts/2026-01-05-obsidian-01.png" alt="." width="400px" />
  <div class="image-caption">Caption</div>
</div>

Selecciono **Open folder as vault** > **`Nextcloud/Directorio/Personal/Notas`**

El propio Obsidian crea un subdirectorio llamado `.obsidian`
Preferencias:

- General
  - Language - English (o Español)
- Editor
  - Spellcheck - On
  - Spellcheck languages
    - English + Spanish
- Files and Links
  - Automatically update internal links - On
  - Default location for new notes - Same folder as current file
  - New link format - Relative path to file
  - Use [[Wikilinks]] - No
  - Detect all file extensions - Yes
  - Default locations for new attachments: In subfolder under current folder
  - Subfolder name: assets
- Hotkeys
  - Toggle Live Preview/Source mode:
    - Mac - `CMD + Shift + S`
    - Win - `ALT + Shift + S`
    - Linux - `Ctrl + Shift + S`
- Sync
  - Desactivado - utilizo NextCloud

Extra: en los Desktop también accedo a los ficheros Markdown desde Typora y desde VSCode. Para este último, como uso la extension Markdownlint, para hacerlo compatible, recomiendo poner en User Settings (Globales)

```json
      "markdownlint.config": {
        "MD013": false,
        "MD033": false,
        "MD041": false,
        "MD045": false
    },
```

4.1 Cliente iOS con Remotely Save

Uso Obsidian como Cliente del servicio WebDav de mi servidor NextCloud, debido a las limitaciones del cliente NextCloud para iOS junto con Obsidian.

Instalo Obsidian para iOS y el plugin "Remotely Save".

- Instalo Obsidian en iOS
- **Creo un Vault local en Obsidian iOS** (lo llamo “**Notas**”).
- Instalo el plugin **Remotely Save** (Settings > Community Plugins)
- Permite sincronizar un Vault local de Obsidian con NextCloud usando WebDAV, sin pasar por iCloud ni por el servicio de pago de Obsidian.
- **Configuro Remotely Save**:
  - Hago un backup del directorio NextCloud/Notas.
  - Habilito el Plugin.
  - Entro en Options, selecciono WebDAV como método de sincronización.
  - Server: `http://<IP-DE-MI-NEXTCLOUD>/remote.php/dav/files/luis/priv/Luis`
  - User: `luis` y Password de aplicación: `<Creada en Cloud Server>`

IMPORTANTE: Vuelvo a obsidian, clic en menú abajo a la derecha > **Remotely Save** para lanzar una sincronización manual. Esto lo hago de vez en cuando

Puede programarse la sincronización para que se ejecute en el background (se hace en los settings de Remtely Save), pero yo prefiero hacerlo manualmente. En realidad en el móvil haré muy pocas ediciones, pero muchas búsquedas :-)

No es perfecto porque la sincronización no es automática, pero a cambio tengo mis notas bajo control, en formato abierto y accesibles desde cualquier dispositivo. Todos los plugins y mejoras de Obsidian funcionan igual en escritorio y móvil.


## Estandarización de Indentación en Obsidian (4 Espacios)

Este documento define el estándar de indentación para nuestro Vault de Obsidian y cómo migrar las notas existentes para cumplirlo.

**Configuración del Editor en Obsidian**: **Ajustes → Editor**

- **Usar tabulaciones para indentar**: `Desactivado` (usar espacios)
- **Ancho visual de la indentación**: `4`
- **Mostrar guías de indentación**:
    - Recomendado: `Activado` → ayuda a confirmar visualmente la alineación con indentación de 4 espacios.

## Migración del Vault Existente

Para normalizar todos los ficheros a **4 espacios**:

### A) Convertir 2 espacios → 4 espacios

Ejecutar en la raíz del Vault:

```bash
find . -type f -name "*.md" -exec sed -i 's/^\(  \)/    /g' {} +
```

Esto reemplaza indentaciones de 2 espacios por 4 espacios.
⚠️ Primero hacer una prueba en seco:

```bash
find . -type f -name "*.md" -exec grep -n '^  ' {} \;
```

### B) Convertir Tabulaciones → 4 espacios

Expandir tabulaciones a 4 espacios:

```bash
find . -type f -name "*.md" -exec sed -i 's/\t/    /g' {} +
```

### C) Normalizar Listas (tema crítico)

Usar `markdownlint-cli2` con la regla MD007:

1. Instalar una vez:

   ```bash
   npm install -g markdownlint-cli2
   ```

2. Crear `.markdownlint.jsonc` en la raíz del Vault:

   ```jsonc
   {
     // Forzar indentación de listas a 4 espacios
     "MD007": { "indent": 4, "start_indented": false }
   }
   ```

3. Ejecutar verificación y corrección:

   ```bash
   markdownlint-cli2 "**/*.md" "#node_modules"
   markdownlint-cli2-fix "**/*.md" "#node_modules"
   ```

Esto reformatea las listas para que usen siempre 4 espacios.

---

## 3. Aplicar Reglas Adicionales

Puedes ampliar `.markdownlint.jsonc` con otras reglas.
Ejemplo: **MD012 – Múltiples líneas en blanco consecutivas**

```jsonc
{
  "MD007": { "indent": 4, "start_indented": false },
  "MD012": { "maximum": 1 } // Colapsa >1 línea en blanco en una sola
}
```

Después, volver a ejecutar:

```bash
markdownlint-cli2-fix "**/*.md" "#node_modules"
```

Esto elimina todas las líneas en blanco sobrantes en el Vault.

---


### Conclusión

La conclusión debe cerrar destacando que `pdfly` es una "navaja suiza" integral para la gestión de PDF en la terminal, enfatizando su naturaleza *open-source* y el apoyo continuo de la comunidad (mencionar Hacktoberfest y la versión 0.5.1 de 2025-10-13). También debe invitar a la retroalimentación y la contribución, mencionando que se buscan nuevos colaboradores.

## Recursos y Referencias

**Enlaces externos relevantes**:

- https://github.com/py-pdf/pdfly - Repositorio oficial del proyecto `pdfly`
- https://pdfly.readthedocs.io/ - Documentación del proyecto

## Imágenes y Recursos Visuales

**Logo del post**: El logo que muestra la serpiente de Python envuelta alrededor de un documento PDF.

- Ruta: `/img/posts/logo-pdfly.svg`

**Imágenes a incluir**:

1. Captura de pantalla de la salida del comando `pdfly meta` (ejemplo de metadatos del sistema operativo y del PDF).
2. Captura de pantalla que ilustre la sintaxis de *slices* de Python para `pdfly cat` o `pdfly rm`.
3. Captura de pantalla mostrando el comando `pdfly sign` o `pdfly check-sign`.

## Código y Snippets

**Snippets de código a incluir**:

1. Instalación y Ayuda: `pipx install pdfly` y `pdfly --help`.
2. Concatenación/Extracción: `pdfly cat input.pdf 1:4 -o out.pdf` (Extracción de páginas).
3. Seguridad/Firma: `pdfly sign input.pdf --p12 certs.p12 -o signed.pdf`.

**Lenguajes de programación**: [bash, python]

## Notas Adicionales

- El proyecto utiliza el modelo de gobernanza de **"Dictador Benevolente"** (Benevolent Dictator), siendo Martin Thoma el actual dictador desde abril de 2022.
- Se debe recordar a los lectores que los **índices de página comienzan en cero** y la sintaxis de rango de páginas es similar a las *slices* de Python. Para rangos que comienzan con un valor negativo, se debe usar `--` para separarlos de las opciones de línea de comandos.
