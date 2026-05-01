---
title: "Terminal en modo IA"
date: "2026-04-25"
categories: ["herramientas"]
tags: ["WezTerm", "iTerm2", "CLI", "productividad", "multiplataforma", "lua", "python", "automatización", "terminal"]
draft: false
cover:
  image: "/img/posts/logo-term-modo-ia.svg"
  hidden: true
---

<img src="/img/posts/logo-term-modo-ia.svg" alt="Logo terminal en modo IA" width="150px" height="150px" style="float:left; padding-right:25px" />

Cuando trabajas con un harness de IA (Claude Code, Gemini CLI, Codex, ...) acabas arrancando varias instancias una y otra vez. Quería tener un atajo de teclado para que me abriese mi configuración más típica usando paneles en una ventana.

Lo he llamado el terminal "modo IA": cuatro paneles, tres con `claude` (cada uno con un modelo distinto: opus, sonnet, haiku) y un cuarto con una shell limpia para comandos auxiliares. El requisito _no negociable_ es que los cuatro paneles arranquen en el directorio desde el que pulso el atajo, sin pasos manuales.

Este post cubre dos rutas para montarlo: **WezTerm** (recomendada, multiplataforma — Windows / macOS / Linux) e **iTerm2** (fallback para quien ya viva en iTerm en macOS y no quiera cambiar de terminal).

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2026-04-25-modo-ia-en-la-terminal-01.png" alt="Modo IA: 4 paneles con opus, sonnet, haiku y shell" width="800px" />
  <div class="image-caption">Aspecto final del modo IA — el layout es esencialmente el mismo en WezTerm y en iTerm2.</div>
</div>

## El problema

Instintivamente empecé buscando una forma "simple" que aprovechara lo que el terminal ya trae de fábrica:

**Window Arrangements de iTerm2.** La forma "oficial" de guardar una disposición de paneles. El problema es triple: no se puede invocar bajo demanda con parámetros, los Profiles asociados son rígidos, y la directiva _Working Directory_ del Profile no tiene una opción "usa el `$PWD` del shell que me lanzó".

**tmux o Zellij.** Hiperconfigurables, layouts declarativos preciosos, y soporte nativo para "abrir en `$PWD`". Pero introducen una capa entre el terminal y la shell: prefijo de teclado propio, copy/paste con sus particularidades, integraciones con shell que hay que mantener. Para mi flujo —donde el terminal ya hace el trabajo del multiplexor— era cambiar un problema pequeño por otro mediano.

**Solución que me funcionó.** Empotrar el layout en la propia configuración del terminal y bindearlo a un atajo. La receta cambia según el terminal: en WezTerm es Lua, en iTerm2 es Python sobre su Python API.

## WezTerm o iTerm2

| Criterio | WezTerm | iTerm2 |
| --- | --- | --- |
| OS soportados | Windows / macOS / Linux | Sólo macOS |
| Configuración | Lua | Python API + GUI |
| Distribución | Una config = los tres OS | Sólo aplica si vives en macOS |
| Aprendizaje | Lua mínimo (sintaxis ligera) | Conocido si ya usas iTerm |
| Recomendado para | Setup nuevo o multiplataforma | Si solo usas Mac y no quieres moverte |

Si trabajas en más de un OS o estás eligiendo terminal desde cero, te recomiendo la **ruta WezTerm**. Si estás en macOS, conoces iTerm de memoria y no quieres tocar tu setup, salta a la **ruta iTerm2**.

## Ruta WezTerm (multiplataforma) ⭐

[WezTerm](https://wezterm.org) es un emulador moderno escrito en Rust con configuración en Lua y aceleración GPU. Lo importante es que usa un único fichero de configuración `~/.config/wezterm/wezterm.lua` que funciona de forma idéntica en Windows, macOS y Linux.

### Instalación rápida

Échale un ojo a mi proyecto [devcli](https://github.com/LuisPalacios/devcli), que además de hacer muchas otras cosas, te instala WezTerm y le añade mi configuración completa (selector de shells, persistencia de tamaño, theme picker, modo IA, etc.) que siempre puedes adaptar:

- [WezTerm con devcli](https://github.com/LuisPalacios/devcli/blob/main/docs/wezterm.md) — guía general.
- [AI Mode — cuatro Claudes en una ventana](https://github.com/LuisPalacios/devcli/blob/main/docs/wezterm-ai-mode.md) — una guía sobre lo que va este apunte.

Si prefieres no usar devcli, instala WezTerm a mano siguiendo [wezterm.org](https://wezterm.org) y échale un ojo a mi [`wezterm.lua`](https://github.com/LuisPalacios/devcli/blob/main/dotfiles/wezterm.lua).

### El modo IA en WezTerm

Desde cualquier ventana, te vas al directorio sobre el que quieres trabajar y pulsas el atajo, se abre una ventana nueva con los cuatro paneles.

| Plataforma | Atajo | Por qué |
| --- | --- | --- |
| Windows | `CTRL+ALT+N` | `WIN+N` está reservado para el Centro de notificaciones. |
| macOS / Linux | `⌃⌘N` o `CTRL+SUPER+N` | `ALT+N` produce el dead-key `~` en layouts españoles. |

Comportamiento:

- Hereda el `cwd` (directorio actual) desde donde estabas — los cuatro Claudes y la shell arrancan en ese directorio.
- Layout: `opus` arriba-izquierda (grande), `sonnet` arriba-derecha, `haiku` abajo-derecha, shell limpia abajo-izquierda.

### Cómo está implementado (alto nivel)

La super-config es un único `wezterm.lua` partido en secciones (§0 personalización, §1 helpers, §2 shell, §3 apariencia, §4 AI Mode, §5 shell picker, §6 estado de ventana, §7 atajos, §8 ratón). Sólo §4 implementa el modo IA — todo lo demás son features ortogonales.

- **Cada Claude se lanza como proceso _foreground_ del pane** (`args = { 'claude', '--model', X }`), sin shell intermedio. Esto evita la condición de carrera "esperar a que el shell esté listo" que la versión iTerm/Python sí necesita resolver con `READY_TIMEOUT` y `SEND_GAP`. Trade-off explícito: cuando Claude se cierra (por `/exit` o crash), el pane se cierra con él — no hay shell al que volver. Yo lo prefiero así.
- **`find_claude_bin()`** prueba paths absolutos en macOS porque las apps lanzadas desde Finder/Spotlight reciben un PATH mínimo (`/usr/bin:/bin:/usr/sbin:/sbin`) que excluye Homebrew y `~/.local/bin`. En Windows y Linux confía en el PATH heredado.
- **Layout** = porcentajes en `AI.LAYOUT_X/Y/W/H` (origen + tamaño respecto a la pantalla). Y las proporciones internas son `AI.LEFT_RATIO`, `AI.LEFT_TOP_RATIO`, `AI.RIGHT_TOP_RATIO`. Todos tunables al inicio del bloque §4.

El código vive en mi proyecto [devcli](https://github.com/LuisPalacios/devcli): la implementación está en [`dotfiles/wezterm.lua`](https://github.com/LuisPalacios/devcli/blob/main/dotfiles/wezterm.lua) (siempre la última versión). El modo IA es la sección §4 de ese fichero; el resto son features ortogonales que puedes leer en el mismo.

### Tunables principales

Tocando los valores en `AI = { ... }` (al principio de §4) ajustas el layout sin tocar lógica:

- `AI.LEFT_RATIO` — qué porcentaje del ancho se lleva la columna izquierda (`0.65` = 65% para opus).
- `AI.LEFT_TOP_RATIO` — dentro de la columna izquierda, cuánto se lleva el panel de arriba (opus vs shell).
- `AI.RIGHT_TOP_RATIO` — lo mismo para la columna derecha (sonnet vs haiku).
- `AI.LAYOUT_X / Y / W / H` — origen (X, Y) y tamaño (W, H) de la ventana respecto a la pantalla principal, en fracciones de 0 a 1.
- `AI.MODELS` — qué modelo va en cada esquina (`tl` top-left, `tr` top-right, `br` bottom-right).

Son los equivalentes Lua a los `LEFT_RATIO`/`LEFT_TOP_RATIO`/`RIGHT_TOP_RATIO` que verás más abajo en el `aimode.py` de iTerm.

## Ruta iTerm2 (solo macOS)

La solución consiste en usar el runtime de Python embebido que viene con la propia aplicación. El [Python API](https://iterm2.com/python-api/) permite crear ventanas, dividir paneles, fijar tamaños, leer variables de cada sesión y enviar texto.

Los scripts viven en `~/Library/Application Support/iTerm2/Scripts/` y, si los pones en la subcarpeta `AutoLaunch`, arrancan como demonios cada vez que iTerm2 se abre. Una vez registrado un script, se le puede asignar un atajo de teclado desde el propio iTerm2.

### Preparación

- **Activar el Python API en iTerm2**

  `iTerm2 → Settings → General → Magic → Enable Python API`. Marca la casilla y confirma el diálogo de seguridad.

- **Crear la carpeta AutoLaunch**

  Cualquier script dentro de `AutoLaunch` se ejecuta automáticamente al arrancar iTerm2:

  ```bash
  mkdir -p ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch
  ```

- **Crear el fichero del script** (ejemplo con vscode):

  ```bash
  code ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch/aimode.py
  ```

- **Pegar el contenido siguiente**:

  {{< codefile path="snippets/2026-04-25-modo-ia-en-la-terminal/aimode.py" lang="python" title="aimode.py" >}}

- **Arrancar el demonio**

  Una vez salvado el fichero, hay dos opciones:

  - Ejecutarlo una vez ahora desde `Scripts → AutoLaunch → aimode.py` en la barra de menú.
  - Reiniciar iTerm2 — como está en `AutoLaunch` lo arrancará en cada apertura.

  La primera vez que iTerm2 ejecute un script puede pedirte permiso. Acepta. Para verificar que el demonio está corriendo, abre `Scripts → Manage → Console`: deberías ver `aimode` en la lista sin errores.

- **Asignar el atajo de teclado**

  `Settings → Keys → Key Bindings → +`:

  - **Keyboard Shortcut**: el que prefieras (yo uso `⌃⌘N`, pero cualquiera libre vale).
  - **Action**: _Invoke Script Function_.
  - **Function**: `aimode()` — los paréntesis son obligatorios.

### Cómo se usa en iTerm2

Desde cualquier sesión de iTerm2, en cualquier directorio, pulsas el atajo. Acabas con una ventana con cuatro paneles en el directorio donde estabas, y los tres paneles de Claude lanzan opus, sonnet y haiku automáticamente.

Puedes tunear el script tocando el bloque `CONFIG` en la cabecera:

- `LEFT_RATIO` — porcentaje del ancho que se lleva la columna izquierda (`0.65` = 65%).
- `LEFT_TOP_RATIO` — dentro de la columna izquierda, cuánto se lleva el panel de arriba (opus).
- `RIGHT_TOP_RATIO` — lo mismo para la columna derecha (sonnet vs haiku).
- `READY_TIMEOUT` — cuánto esperar a que cada shell termine de inicializar antes de enviar comandos. Súbelo si tu `~/.zshrc` es lento (mise, nvm, completions pesados).
- `SEND_GAP` — pausa entre comandos consecutivos. Súbelo a `0.1` si alguna vez ves un comando truncado.

Cuando edites el script:

`Scripts → Manage → Console` → buscar `aimode` → _Stop_ → `Scripts → AutoLaunch → aimode.py` para reiniciar. O cierras y vuelves a abrir iTerm2, da igual.

## Próximos pasos / extensiones

Una vez tienes la base, puedes crearte tus propios layouts. Algunas ideas:

- **`aimode plan`** — los tres Claudes arrancando con `--permission-mode plan` para sesiones de planificación.
- **`aimode review <PR>`** — abrir el panel de shell con un `gh pr checkout <PR>` y los Claudes en modo revisión.
- **Layouts alternativos** — un `aireview.py` con tres paneles verticales para comparar diffs en paralelo, o un `aiops.py` con shells en distintos servidores vía SSH.

Como cada layout es un script Python en `AutoLaunch` y cada uno se registra como su propia RPC, puedes tener varios atajos —`⌃⌥⌘A`, `⌃⌥⌘P`, `⌃⌥⌘R`— invocando layouts distintos sin que se pisen.

En WezTerm el paralelo es duplicar el bloque §4 con `AI.MODELS` distintos y bindear más atajos (por ejemplo `CTRL+ALT+P`, `CTRL+ALT+R`) sobre las mismas funciones — todo sin tocar Python ni la API de iTerm.

## Enlaces interesantes

| Tipo | Enlaces |
| --- | --- |
| Proyecto | [devcli](https://github.com/LuisPalacios/devcli) |
| Oficial | [WezTerm](https://wezterm.org) |
| Oficial | [iTerm2 Python API](https://iterm2.com/python-api/) |
| Referencia | [Documentación de Claude CLI](https://github.com/anthropics/claude-code) |
