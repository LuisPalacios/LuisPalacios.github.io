---
title: "iTerm en modo IA"
date: "2026-04-25"
categories: ["herramientas"]
tags: ["iTerm2", "CLI", "productividad", "python", "automatización", "terminal"]
draft: false
cover:
  image: "/img/posts/logo-iterm-modo-ia.svg"
  hidden: true
---

<img src="/img/posts/logo-iterm-modo-ia.svg" alt="Logo iTerm2 modo IA" width="150px" height="150px" style="float:left; padding-right:25px" />

Cuando trabajas con un harnes de IA (Claude Code, Gemini CLI, Codex, ...) acabas arrancando varias instancias una y otra vez. Queríá tener un atajo de teclado para que me abriese mi configuración más típica usando paneles en una ventana.

Lo he llamado el terminal en "modo IA". Arranco cuatro paneles, tres con `claude` (cada uno con un modelo distinto) y el cuarto con una shell limpia para comandos auxiliares.

El requisito _no negociable_ es que los cuatro paneles arrancasen en el directorio desde el que uso el atajo y que no tenga pasos manuales.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2026-04-25-iterm-modo-ia-01.png" alt="Flujo: desde keystroke a workspace unificado" width="800px" />
  <div class="image-caption">Aspecto final.</div>
</div>

## El problema

Instintivamente empecé buscando una forma "simple" que aprovechara lo que [iTerm2](https://iterm2.com/) ya trae de fábrica:

**Window Arrangements de iTerm2.** La forma "oficial" de guardar una disposición de paneles. El problema es triple: no se puede invocar bajo demanda con parámetros, los Profiles asociados son rígidos, y la directiva _Working Directory_ del Profile no tiene una opción "usa el `$PWD` del shell que me lanzó".

**tmux o Zellij.** Hiperconfigurables, layouts declarativos preciosos, y soporte nativo para "abrir en `$PWD`". Pero introducen una capa entre iTerm2 y la terminal: prefijo de teclado propio, copy/paste con sus particularidades, integraciones con shell que hay que mantener. Para mi flujo —donde iTerm2 ya hace el trabajo del multiplexor— era cambiar un problema pequeño por otro mediano.

## iTerm2 [Python API](https://iterm2.com/python-api/)

La solución fué usar el runtime de Python embebido que viene con iTerm2. Incluye una API completa con la que se puede crear ventanas, dividir paneles, fijar tamaños, leer variables de cada sesión y enviar texto.

Los scripts viven en `~/Library/Application Support/iTerm2/Scripts/` y, si los pones en la subcarpeta `AutoLaunch`, arrancan como demonios cada vez que iTerm2 se abre. Una vez registrado un script (como una RPC con nombre), se le puede asignar un atajo de teclado desde el propio iTerm2.

</pr>

## Fase de preparación

- Activar el Python API en iTerm2

`iTerm2 → Settings → General → Magic → Enable Python API`. Marca la casilla y confirma el diálogo de seguridad.

- Crear la carpeta AutoLaunch

Cualquier script dentro de `AutoLaunch` se ejecuta automáticamente al arrancar iTerm2. Es lo que queremos para que el atajo esté siempre disponible:

```bash
mkdir -p ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch
```

- Crea con tu editor preferido el fichero para el script, un ejemplo con vscode:

```bash
code ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/aimode.py
```

- **Pega el contenido siguiente**:

{{< codefile path="snippets/2026-04-25-iterm-modo-ia/aimode.py" lang="python" title="aimode.py" >}}

- Arrancar el demonio

Una vez salvado el fichero anterior, hay que decirle a iTerm2 que lo lea, tienes dos opciones:

- Ejecutarlo una vez ahora desde `Scripts → AutoLaunch → aimode.py` en la barra de menú.
- Reiniciar iTerm2 — Como lo hemos salvado bajo `AutoLaunch` lo arrancará solo, en cada apertura.

La primera vez que iTerm2 ejecute un script puede pedirte permiso. Acepta. Para verificar que el demonio está corriendo, abre `Scripts → Manage → Console`: deberías ver `aimode` en la lista sin errores.

- Asignar el atajo de teclado

`Settings → Keys → Key Bindings → +`:

- **Keyboard Shortcut**: el que prefieras (yo uso `⌃⌥⌘A`, pero cualquiera libre vale).
- **Action**: _Invoke Script Function_.
- **Function**: `aimode()` — los paréntesis son obligatorios.

## Cómo se usa

Desde cualquier sesión de iTerm2, en cualquier directorio, pulsas el atajo. Acabas con una ventana con cuatro paneles en el directorio donde estabas, y los tres paneles de Claude lanzan opus, sonnet y haiku automáticamente.

Puedes tunear el script, tiene un bloque `CONFIG`:

- `LEFT_RATIO` — qué porcentaje del ancho se lleva la columna izquierda (`0.65` = 65%).
- `LEFT_TOP_RATIO` — dentro de la columna izquierda, cuánto del alto se lleva el panel de arriba (opus).
- `RIGHT_TOP_RATIO` — lo mismo para la columna derecha (sonnet vs haiku).
- `READY_TIMEOUT` — cuánto esperar a que cada shell termine de inicializar antes de enviar comandos. Súbelo si tu `~/.zshrc` es lento (mise, nvm, completions pesados).
- `SEND_GAP` — pausa entre comandos consecutivos. Súbelo a `0.1` si alguna vez ves un comando truncado.

Cuando edites el script:

`Scripts → Manage → Console` → buscar `aimode` → _Stop_ → `Scripts → AutoLaunch → aimode.py` para reiniciar. O cierras y vuelves a abrir iTerm2, da igual.

## Próximos pasos

Una vez tienes la base, puedes crearte tus propios scripts, te dejo algunas ideas para que experimentes:

- **`aimode plan`** — los tres Claudes arrancando con `--permission-mode plan` para sesiones de planificación.
- **`aimode review <PR>`** — abrir el panel de shell con un `gh pr checkout <PR>` y los Claudes en modo revisión.
- **Layouts alternativos** — un script `aireview.py` con tres paneles verticales para comparar diffs en paralelo, otro `aiops.py` con shells en distintos servidores vía SSH.

Como cada layout es un script Python en `AutoLaunch` y cada uno se registra como su propia RPC, puedes tener varios atajos —`⌃⌥⌘A`, `⌃⌥⌘P`, `⌃⌥⌘R`— invocando layouts distintos sin que se pisen.

## Enlaces interesantes

| Tipo      | Links                                                        |
| --------- | ------------------------------------------------------------ |
| Official  | [iTerm2 Python API](https://iterm2.com/python-api/)          |
| Reference | [claude CLI docs](https://github.com/anthropics/claude-code) |
