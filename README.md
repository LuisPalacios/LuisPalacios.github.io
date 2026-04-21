## LuisPalacios.github.io

Este repositorio contiene mi *blog* usando el generador de páginas [Hugo](https://gohugo.io/) y hospedado en [GitHub Pages](https://pages.github.com).

* Enlace al blog: [https://www.luispa.com](https://www.luispa.com)

---

### Trabajo en local

Esta documentación la dejo a modo informativo y referencia para aquellos que quieran montarse un sitio usando [GitHub Pages](pages.github.com)

Una vez que has pasado por la documentación oficial y tienes tu repo 100% preparado, para clonarlo en local y trabajar con él, sigo estos pasos:

```shell
# 1. Clonar el repositorio
git clone https://github.com/LuisPalacios/LuisPalacios.github.io.git
cd LuisPalacios.github.io

# 2. Descargar el tema PaperMod (submodule)
#    ⚠️  SIN ESTE PASO Hugo genera páginas en blanco
git submodule update --init --recursive

# 3. Arrancar el servidor local
cd src
hugo server -D

# OPCIONAL. Si prefieres con limpieza total de la caché
hugo server --disableFastRender --noHTTPCache --ignoreCache --cleanDestinationDir --logLevel debug

# NOTA: Si ves **páginas en blanco**, lo más probable es que falte el paso 2.
# Verifica que `src/themes/PaperMod/` NO esté vacío.
```

Abre <http://localhost:1313> en el navegador. Los cambios se recargan automáticamente.

---

### Actualizar Hugo

**macOS (Homebrew):**

```shell
brew update && brew upgrade hugo
hugo version
```

**Windows** (usar uno de los tres):

```shell
# Scoop / también vale "-a (all)"
scoop update hugo-extended

# Chocolatey
choco upgrade hugo-extended -y

# winget
winget upgrade Hugo.Hugo.Extended
```

---

### Actualizar el tema PaperMod

El tema es un submodule de Git. Para actualizarlo a la última versión:

```shell
git submodule update --remote --merge src/themes/PaperMod
```

Después verifica que el sitio compila correctamente (`cd src && hugo`). Si todo va bien, haz commit del nuevo puntero del submodule (Git no trackea el contenido del tema, solo a qué commit apunta):

```shell
git add src/themes/PaperMod
git commit -m "Actualizado PaperMod a última versión"
```

---

### Crear nuevos posts

```shell
cd src
hugo new posts/2025-12-25-es-navidad.md
```

Los posts van en `src/content/posts/` con formato `YYYY-MM-DD-slug.md`.

---

### Multilingüe (ES/EN)

El blog soporta español (por defecto) e inglés. La organización es por nombre de fichero:

```text
src/content/posts/
├── 2026-04-03-gitbox.md        ← Español (por defecto)
└── 2026-04-03-gitbox.en.md     ← Traducción al inglés
```

- **Español:** `https://www.luispa.com/posts/slug/`
- **English:** `https://www.luispa.com/en/posts/slug/`

Hugo enlaza automáticamente las traducciones por el nombre del fichero. PaperMod muestra el selector de idioma en la cabecera.

Para traducir un post usa el skill `/translating-apunte <slug>`.

---

### Claude Code

Este repositorio incluye configuración para [Claude Code](https://claude.ai/claude-code) con la siguiente estructura:

```text
.claude/
├── CLAUDE.md                # Instrucciones del proyecto (siempre se carga)
├── context/                 # Ficheros de contexto (carga condicional)
│   ├── guideline_skills.md  # Guía para crear skills
│   ├── guideline_python.md  # Scripts Python (PEP 723 + uv)
│   ├── guideline_js.md      # Scripts JS/TS (pnpm dlx)
│   └── ...
└── skills/                  # Skills disponibles
    ├── creating-apunte/
    ├── translating-apunte/
    ├── fixing-markdown/
    └── removing-notebooklm/
```

**Zero-footprint**: Los scripts usan `uv run` (Python) y `pnpm dlx` (JS) — no se crean `.venv` ni `node_modules` en el repo.

| Skill | Descripción |
| --- | --- |
| `/creating-apunte [topic]` | Genera posts en español para el blog |
| `/translating-apunte <slug>` | Traduce un post de español a inglés |
| `/fixing-markdown <target>` | Valida y corrige formato markdown |
| `/removing-notebooklm <file>` | Elimina watermark de NotebookLM |

Ver [usar-skills.md](usar-skills.md) para guía detallada de uso.

---

### Pull Requests

Si te gusta este repositorio y quieres contribuir sigue las [pautas para hacer pull requests](PR.md).
