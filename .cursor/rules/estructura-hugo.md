# Estructura y Convenciones de Hugo

## Estructura de Carpetas Principales

- **`src/content/posts/`**: Todos los posts del blog. Nombre de archivo: `YYYY-MM-DD-titulo-del-post.md`
- **`src/layouts/`**: Templates y layouts personalizados
  - **`src/layouts/shortcodes/`**: Shortcodes personalizados (SIEMPRE preferir shortcodes sobre HTML puro)
  - **`src/layouts/_default/`**: Layouts por defecto
  - **`src/layouts/partials/`**: Partials reutilizables
- **`src/static/`**: Archivos estáticos (imágenes, favicons, etc.)
  - **`src/static/img/posts/`**: Imágenes de los posts
- **`src/assets/`**: Assets procesados por Hugo (CSS, JS, snippets de código)
  - **`src/assets/snippets/`**: Snippets de código para usar con el shortcode `codefile`
- **`src/data/`**: Archivos de datos (YAML, JSON, TOML)
- **`src/themes/PaperMod/`**: Tema Hugo PaperMod (submódulo Git)
- **`src/hugo.toml`**: Archivo de configuración principal

## Convenciones de Archivos

### Posts

- Siempre deben residir en `src/content/posts/`
- Nombre de archivo: `YYYY-MM-DD-titulo-corto.md`
- Formato: kebab-case, sin acentos en el nombre del archivo
- Ejemplo: `2024-08-25-win-desarrollo.md`

### Imágenes

- Deben estar guardadas en `src/static/img/posts/`
- Nombres siguiendo el formato: `YYYY-MM-DD-titulo-corto-NN.<ext>`
- Donde `NN` es un número secuencial (01, 02, 03...)
- Extensiones típicas: `svg`, `png`, `jpg`
- Ejemplo: `2024-08-25-win-desarrollo-01.png`

### Logos

- Los logos usados en el frontmatter están en `src/static/img/posts/`
- Convención de nombres: `logo-<nombre>.svg`
- Ejemplo: `logo-win-desarrollo.svg`

### Snippets de Código

- Preferiblemente en `src/assets/snippets/` para usar con el shortcode `codefile`
- Organizar por tema o post si es necesario
- Ejemplo: `src/assets/snippets/2014-10-19-bridge-ethernet/script.sh`

## Front Matter de los Posts

Todos los posts deben incluir este front matter estándar:

```yaml
---
title: "Título del Post"
date: "YYYY-MM-DD"
categories: ["categoría-principal"]
tags: ["tag1","tag2","tag3"]
draft: false
cover:
  image: "/img/posts/logo-nombre.svg"
  hidden: true
---
```

### Categorías Disponibles

- `administración`
- `apuntes`
- `desarrollo`
- `desarrollo-web`
- `domótica`
- `herramientas`
- `infraestructura`
- `linux`
- `macos`
- `migración`
- `productividad`
- `seguridad`
- `software`
- `terminal`
- `tv`
- `virtualización`

### Tags

Usar tags descriptivos y relevantes. Ejemplos: `linux`, `windows`, `wsl`, `docker`, `git`, `hugo`, `networking`, `dhcp`, `dns`, `proxmox`, `kvm`, `desarrollo`, `cli`, `python`, etc.

## Convenciones de Hugo

### Nombres de Archivos

- **Posts**: `YYYY-MM-DD-titulo-corto.md` - kebab-case, sin acentos en el nombre del archivo
- **Imágenes**: `YYYY-MM-DD-titulo-corto-NN.<ext>` - donde NN es un número secuencial y ext es la extensión, típicamente será svg o png.

### Rutas y URLs

- Hugo genera URLs automáticamente basadas en el nombre del archivo
- Las rutas de imágenes deben empezar con `/img/posts/` para que sean absolutas desde la raíz del sitio
- Los enlaces internos deben usar `relref` para que Hugo los resuelva correctamente

### Configuración

- El archivo `src/hugo.toml` contiene toda la configuración
- No modificar sin entender el impacto
- El tema PaperMod está en `src/themes/PaperMod/` (submódulo Git)

## Comandos Hugo Importantes

```bash
# Servidor de desarrollo local
cd src
hugo server -D

# Servidor con limpieza de cache y debug
hugo server --disableFastRender --noHTTPCache --ignoreCache --cleanDestinationDir --logLevel debug

# Crear nuevo post
hugo new posts/YYYY-MM-DD-titulo-corto.md

# Generar sitio estático
hugo
```

