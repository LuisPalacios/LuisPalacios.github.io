---
title: "Personal Knowledge Management"
date: "2026-01-24"
draft: false
categories: ["productividad"]
tags: ["documentación", "kiss", "pkm", "markdown", "obsidian", "nextcloud", "wireguard", "webdav", "homelab"]
cover:
  image: "/img/posts/logo-pkm.svg"
  hidden: true
---

<img src="/img/posts/logo-pkm.svg" alt="Logo PKM" width="150px" height="150px" style="float:left; padding-right:25px" />

La Gestión Personal del Conocimiento (PKM - Personal Knowledge Management) es un desafío. Llevo años tomando notas, acumulando ideas, apuntes, meeting notes. He probado de todo: papel, ficheros sueltos, Evernote, Notas.app, Craft, Standard Notes y Notion. Todas prometían ser "la definitiva". Ninguna lo fue.

El problema no es la aplicación, es el **modelo**. Cuando tus notas viven en un formato propietario, en servidores ajenos, estás alquilando tu conocimiento. Y un día la empresa cierra, sube precios, o simplemente decides cambiar... y descubres que migrar es un infierno.

<br clear="left"/>
<!--more-->

## El caso Notion

Notion fue ilusionante. Base de datos, vistas, templates, colaboración. Pero tiene un problema fundamental: **tus datos son suyos**. No tienes ficheros, tienes "bloques" en su nube. Exportar a Markdown produce un Frankenstein lleno de IDs y enlaces rotos. Si Notion desaparece mañana, tu conocimiento de años se convierte en basura digital difícil de recuperar.

No es solo Notion. Cualquier app que:

- Guarde en formato propietario
- Requiera internet para acceder
- No te deje exportar limpiamente

...te está secuestrando. Y el rescate es tu tiempo y frustración cuando quieras irte.

## La filosofía: Markdown + ficheros locales

Mi solución es volver a lo básico: **ficheros de texto en mi disco**. Suena anticuado, pero es liberador:

| Característica de tus notas | Apps propietarias | Markdown local |
| --- | --- | --- |
| Formato | Propietario, opaco | Texto plano, universal |
| Ubicación | Su nube | Tu disco |
| Dependencia | Requiere su app | Cualquier editor |
| Migración | Dolorosa o imposible | Copiar carpeta |
| Búsqueda | Solo con su app | Puedes usar cualquiera, VSCode, Obsidian... |
| Aplicas IA | Depende de sus características | Pues usar cualquier IA, le dices dónde está tu carpeta |

Un fichero `.md` de hoy se podrá abrir en 50 años.

## Por qué Obsidian

[Obsidian](https://obsidian.md/) no es una app de notas, es un **editor + buscador** sobre tu carpeta de Markdown. La diferencia es crucial:

- **Tus ficheros primero**: Obsidian trabaja sobre tu carpeta. Si lo desinstalas, tus notas siguen ahí.
- **Búsqueda potente**: Indexa todo en `.obsidian/` para búsquedas instantáneas.
- **Enlaces bidireccionales**: Conecta ideas con `[[wikilinks]]` o enlaces normales.
- **Plugins**: Dataview, templates, canvas, diagramas...
- **Multiplataforma**: macOS, Windows, Linux, iOS, Android.

Y lo mejor: puedo abrir la misma carpeta con VSCode, Typora o cualquier CLI de IA. Obsidian es mi interfaz principal, no mi carcelero.

## Sincronización: las opciones

Necesitas que la carpeta esté sincronizada entre dispositivos. Hay tres caminos:

### Opción 1: Obsidian Sync (recomendada para empezar)

La solución oficial. Funciona perfecto, sin configuración, cifrado E2E. Si valoras tu tiempo más que el dinero, es la mejor opción.

### Opción 2: Cloud Storage providers

Puedes sincronizar la carpeta con tu servicio cloud favorito:

| Servicio | Funciona en desktop | Funciona en iOS |
| --- | --- | --- |
| iCloud | Sí | Sí (nativo) |
| Google Drive | Sí | Con limitaciones |
| Dropbox | Sí | Con plugin |
| OneDrive | Sí | Con plugin |

**Ojo**: algunos tienen problemas de conflictos o sincronización lenta. Investiga antes.

### Opción 3: Self-hosted (mi setup actual)

Si tienes un servidor en casa (NAS, Raspberry Pi, etc.), puedes montar tu propia nube. Es lo que yo uso: **Nextcloud + WireGuard**. Más trabajo inicial, control total. Lo detallo más adelante.

## Instalación básica

### Desktop (macOS / Windows / Linux)

1. Descarga [Obsidian](https://obsidian.md/)
2. **Open folder as vault** → selecciona tu carpeta de notas (o crea una nueva)

<div class="image-box">
  <img src="/img/posts/2026-01-24-obsidian-02.png" alt="Obsidian: abrir directorio como vault" width="450px" />
  <div class="image-caption">Tan simple como abrir una carpeta.</div>
</div>

Si la carpeta no tiene `.obsidian/`, lo crea automáticamente para guardar configuración e índices.

### Configuración recomendada

- **Editor**
  - Spellcheck: On
  - Spellcheck languages: según necesites
- **Files and Links**
  - Automatically update internal links: On
  - Default location for new notes: Same folder as current file
  - New link format: Relative path to file
  - Default location for new attachments: In subfolder under current folder (`assets`)
- **Sync**
  - Según tu opción elegida

### iOS y Android

**Con Obsidian Sync**: instala la app, login, listo.

**Con iCloud**: en iOS funciona nativo si tu vault está en iCloud Drive.

**Con otros providers**: necesitas el plugin [Remotely Save](https://github.com/remotely-save/remotely-save) que soporta WebDAV, S3, Dropbox, OneDrive. Más detalles en la sección de setup casero.

## Setup casero: Nextcloud + WireGuard

Esta sección es para frikis tecnólogos que quieren control total. Si prefieres simplicidad, usa Obsidian Sync y sáltate esto.

### La arquitectura

<div class="image-box">
  <img src="/img/posts/2026-01-24-obsidian-01.png" alt="Arquitectura Obsidian en casa" width="700px" />
  <div class="image-caption">Mi setup: Nextcloud en casa + WireGuard para acceso remoto.</div>
</div>

- **Nextcloud**: servidor de ficheros self-hosted, sincroniza entre todos los clientes
- **WireGuard**: VPN ligera para acceder desde fuera de casa

### Desktop con Nextcloud

1. Instala el [cliente de Nextcloud](https://nextcloud.com/install/#install-clients)
2. Configura tu cuenta y sincroniza la carpeta del vault
3. En Obsidian: **Open folder as vault** → la carpeta sincronizada

Comprueba que sincroniza ida y vuelta: crea una nota de prueba, espera a verla en otro dispositivo, bórrala.

### iOS con Nextcloud

Aquí viene el truco. Obsidian iOS no soporta "Open folder as vault" por restricciones del sistema. La solución es el plugin **Remotely Save**:

1. Instala Obsidian en iOS
2. **Crea un vault local** (lo llamo "Notas")
3. Instala el plugin **Remotely Save** (Settings → Community Plugins)
4. Configura WebDAV:
   - Server: `https://nextcloud.tu-dominio/remote.php/dav/files/USUARIO/RUTA/AL/VAULT`
   - User: `USUARIO`
   - Password: `<contraseña de aplicación>`
5. Lanza sync manual cuando necesites

{{< admonition "warn" "Seguridad" >}}
**No uses tu contraseña principal** de Nextcloud para WebDAV. Crea una **contraseña de aplicación** (Settings → Security) específica para esto.
{{< /admonition >}}

{{< admonition "tip" "Consejo práctico" >}}
Haz backup del vault en desktop antes de jugar con sincronización móvil.
{{< /admonition >}}

### WireGuard para acceso remoto

WireGuard te permite conectarte a tu red de casa desde cualquier sitio. Levantas la VPN y accedes a Nextcloud como si estuvieras en el sofá. Configurarlo está fuera del scope de este post, pero es relativamente sencillo si ya tienes un servidor en casa.

## Organizar tu vault

Antes de crear 500 notas, **para y piensa**. Decide tu estructura de carpetas, naming conventions, y si usarás MOCs (Map of Content). Migrar después es tedioso.

Un ejemplo de estructura:

```text
Notas/
├── .obsidian/             # Config de Obsidian (no tocar)
├── .vscode/               # Si usas VSCode en paralelo
├── .claude/               # Si usas Claude Code
├── :
└── Priv/                  # Mis notas, organizadas en pilares
    ├── Personal/
    │   ├── 00.Personal.md           # MOC del dominio
    │   ├── Casa/
    │   │   ├── 00.Casa.md           # MOC del subdominio
    │   │   └── 2026/
    │   │       ├── 00.2026.Casa.md  # MOC del año
    │   │       └── Antenista.md     # Nota
    │   └── :
    ├── Trabajo/
    │   ├── :
    └── :
```

Los ficheros `00.*.md` son MOCs que enlazan al contenido de esa sección. Con el plugin Dataview pueden auto-generar listas de notas hijas.

## Mantenimiento y normalización

### Indentación consistente

Si editas desde varios editores, estandariza la indentación. Yo uso 4 espacios:

- **En Obsidian**: Settings → Editor → Use tabs: Off, Tab size: 4

### Linting con markdownlint

Para mantener el Markdown limpio uso `markdownlint-cli2` y `prettier`, pero **sin instalar nada
globalmente**. Con `pnpm dlx` se descargan al vuelo y quedan cacheados:

```bash
pnpm dlx markdownlint-cli2@0.23.2 "**/*.md"          # revisa
pnpm dlx markdownlint-cli2@0.23.2 --fix "**/*.md"    # corrige
```

Crea `.markdownlint-cli2.jsonc` en la raíz:

```jsonc
{
  "ignores": [".obsidian/**", "Templates/**"],
  "config": {
    "MD007": { "indent": 4, "start_indented": false },
    "MD012": { "maximum": 1 },
    "MD013": false
  }
}
```

{{< admonition "warn" "Dos trampas que me costaron tiempo" >}}
**No pongas `"fix": true` en el config.** Ese fichero se descubre solo en cada ejecución y
además tiene prioridad sobre `--config`, así que `true` hace que *cualquier* comprobación
reescriba ficheros, y `false` hace que `--fix` no funcione nunca. Omite la clave: sin `--fix`
informa, con `--fix` corrige.

**Fija la versión.** `pnpm dlx markdownlint-cli2` sin versión resuelve a *latest*, así que la
misma orden acaba ejecutando versiones distintas en cada ordenador.

**Si añades `prettier`, `tabWidth` debe coincidir con `MD007.indent`**, o las dos herramientas
se deshacen mutuamente en cada pasada. Y activa `embeddedLanguageFormatting: "off"`, o prettier
te reindenta también el frontmatter YAML.
{{< /admonition >}}

## Uso de la IA

Si tienes acceso a Claude Code, Gemini CLI, Cursor, Copilot o similar, puedes aplicar IA directamente sobre tu vault. La ventaja de tener ficheros locales: cualquier herramienta puede abrirlos.

### Dos modos

- **Modo Chat**: copiar/pegar en la web. Funciona, pero es lento.
- **Modo Agéntico**: le das acceso a la carpeta y que trabaje. El bueno.

### Ejemplo con Claude Code

```bash
cd ~/ruta/a/tu/vault
claude
```

Una vez dentro:

- "*Crea una nota sobre Docker Compose en la carpeta Trabajo*"
- "*Revisa el formato de todas las notas*"
- "*Busca notas huérfanas sin enlaces entrantes*"
- "*Mejora la redacción de esta nota*"

### CLAUDE.md + rules + skills

Lo potente es **enseñarle tu sistema**. Todo vive en `.claude/`, que es lo único que edito a mano:

```text
Notas/
├── .claude/
│   ├── CLAUDE.md          # Instrucciones principales (~100 líneas)
│   ├── rules/             # Reglas que se cargan SOLAS al tocar ciertos ficheros
│   │   ├── doc-coding.md      # cómo se escribe una nota
│   │   └── doc-frontmatter.md # esquema del frontmatter
│   ├── context/           # Documentación que se lee bajo demanda
│   ├── scripts/           # Librería compartida
│   └── skills/            # Comandos personalizados
│       ├── creating-note/
│       ├── fixing-markdown/
│       └── finding-orphans/
├── .codex/  AGENTS.md     # generados desde .claude/
└── .gemini/ GEMINI.md     # generados desde .claude/
```

Tres capas, y la distinción importa:

- **`CLAUDE.md`** se carga siempre. Conviene que sea corto.
- **`rules/`** se cargan *solas* cuando la IA abre un fichero que encaja con su patrón. Así las
  reglas de formato solo ocupan contexto cuando toca una nota.
- **`context/`** solo se lee cuando la tarea lo pide.

Los skills son comandos definidos en ficheros `SKILL.md`. Como sus descripciones incluyen las
frases que uso de verdad, basta con pedirlo en español:

```text
"créame una nota sobre Git worktrees en Developer"
→ Priv/Luis/Developer/2026/Git worktrees.md
  con parent, tags y fecha ya correctos
```

Lo que mejor me ha funcionado: que los skills **llamen a scripts** en vez de describir el
algoritmo en prosa. Un script que recorre la jerarquía y devuelve JSON es determinista; pedirle
a la IA que la recorra cada vez, no. Y que **fallen en vez de adivinar**: si el subdominio no
existe o el nombre de fichero no vale en Windows, error explicando por qué. Una nota mal
archivada en silencio es peor que un error.

### Un solo `.claude/`, varios asistentes

Codex y Gemini no leen `CLAUDE.md`, sino `AGENTS.md` y `GEMINI.md`. En vez de mantener tres
copias, `.claude/` es la fuente única y un script genera el resto. No es copiar y pegar: Claude
Code carga `.claude/rules/` automáticamente y los demás no, así que la tabla de reglas se
regenera como *«antes de editar X, lee Y»*. Copiarla tal cual sería mentirles.

## Conclusión

Mi stack actual:

- **Formato**: Markdown en ficheros locales
- **Editor**: Obsidian (+ VSCode cuando me apetece)
- **Sync**: Nextcloud casero (pero Obsidian Sync es igual de válido)
- **Historial**: git contra un Forgejo en casa, desde un único ordenador
- **IA**: Claude Code, con la misma configuración replicada a Codex y Gemini

Sobre lo de git: no sustituye a Nextcloud, hace algo que Nextcloud no sabe hacer. Nextcloud
recupera ficheros de uno en uno; git te devuelve **el estado anterior a una operación completa**.
Cuando le pides a una IA que reescriba 30 notas de golpe, esa diferencia importa.

Dos avisos por experiencia propia:

- **Excluye `.git` de la sincronización de Nextcloud.** Si no, Nextcloud sincroniza el propio
  repositorio mientras git escribe en él. En el cliente de escritorio: Ajustes → tu cuenta →
  ⋯ → Editor de ficheros ignorados.
- **Que solo un ordenador lleve git.** Con el árbol de trabajo ya sincronizado por Nextcloud,
  dos máquinas haciendo commits sobre los mismos ficheros es buscarse problemas.

Lo importante es que **mis notas son mías**. Ficheros de texto en mi disco, que puedo abrir con cualquier herramienta, mover a cualquier sitio, y que seguirán siendo legibles dentro de 50 años. Notion no puede decir lo mismo.

## Enlaces interesantes

| Notas | Sync | IA |
| --- | --- | --- |
| [Obsidian](https://obsidian.md/) | [Nextcloud](https://nextcloud.com/) | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) |
| [Plugin Remotely Save](https://github.com/remotely-save/remotely-save) | [Nextcloud WebDAV](https://docs.nextcloud.com/server/latest/user_manual/en/files/access_webdav.html) | [Gemini CLI](https://github.com/google-gemini/gemini-cli) |
| | [WireGuard](https://www.wireguard.com/) | |
