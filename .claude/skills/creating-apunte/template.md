# Post Template

Hugo frontmatter and body structure for blog posts.

## Frontmatter

```yaml
---
title: "Título del Post"
date: "YYYY-MM-DD"
categories: ["categoria"]
tags: ["tag1", "tag2", "tag3"]
draft: true
cover:
  image: "/img/posts/logo-xxx.svg"
  hidden: true
---
```

### Field Details

| Field | Required | Notes |
| --- | --- | --- |
| title | Yes | Spanish, in quotes |
| date | Yes | ISO format YYYY-MM-DD |
| categories | Yes | Single category in array |
| tags | Yes | 3-7 relevant tags |
| draft | Yes | Always `true` initially |
| cover.image | Yes | Path to logo SVG |
| cover.hidden | Yes | Always `true` (hides cover, shown inline) |

### Valid Categories

- `administración`
- `desarrollo`
- `herramientas`
- `infraestructura`
- `productividad`
- `software`

## Post Body Structure

```markdown
<img src="/img/posts/logo-xxx.svg" alt="Logo Nombre" width="150px" height="150px" style="float:left; padding-right:25px" />

First paragraph introducing the topic. What is it? Why should I care?

Second paragraph (optional) providing more context or stating the problem.

<br clear="left"/>
<!--more-->

## First Section

Content here...

## Second Section

More content...

## Conclusión

Brief summary (optional for short posts).

## Enlaces interesantes

| Category | Links |
| --- | --- |
| Official | [Name](url) |
| Related | [Name](url) |
```

## Common Patterns

### Image Box with Caption

```html
<div class="image-box">
  <img src="/img/posts/YYYY-MM-DD-slug-01.png" alt="Description" width="450px" />
  <div class="image-caption">Caption text</div>
</div>
```

### Code Block

````markdown
```bash
# Comment explaining command
command --flag value
```
````

### Command Table

```markdown
| Command | Description |
| --- | --- |
| `cmd1` | What it does |
| `cmd2` | What it does |
```

### Internal Link

```markdown
Te recomiendo mi apunte ["Título"]({{< relref "YYYY-MM-DD-slug.md" >}}).
```

### External Link (tool introduction)

```markdown
**[Tool Name](https://url)** es una herramienta que...
```

### Admonition (callout)

```markdown
{{< admonition "tip" "Consejo" >}}
Content in **Markdown**.
{{< /admonition >}}
```

Types: `note`, `warning`, `tip`, `info`

### Collapsible Code from File

```markdown
{{< codefile path="snippets/example.sh" lang="bash" title="example.sh" >}}
```

## Logo SVG Template

If creating a new logo, use 150x150px viewBox:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 150 150">
  <!-- Simple icon or text -->
</svg>
```

Save to: `src/static/img/posts/logo-{concept}.svg`

## Complete Example

```markdown
---
title: "Herramienta CLI Ejemplo"
date: "2025-12-25"
categories: ["herramientas"]
tags: ["cli", "productividad", "automatización"]
draft: true
cover:
  image: "/img/posts/logo-ejemplo.svg"
  hidden: true
---

<img src="/img/posts/logo-ejemplo.svg" alt="Logo Ejemplo" width="150px" height="150px" style="float:left; padding-right:25px" />

Acabo de descubrir **[ejemplo](https://github.com/user/ejemplo)**, una herramienta CLI que simplifica las tareas de automatización. Es rápida, configurable y perfecta para scripts.

<br clear="left"/>
<!--more-->

## Instalación

Recomiendo instalarlo con `brew`:

` ` `bash
brew install ejemplo
` ` `

## Uso básico

El comando principal es sencillo:

| Comando | Descripción |
| --- | --- |
| `ejemplo init` | Inicializa configuración |
| `ejemplo run` | Ejecuta el proceso |

## Conclusión

**ejemplo** es una herramienta útil para automatizar tareas repetitivas.

## Enlaces interesantes

- [Repositorio oficial](https://github.com/user/ejemplo)
- [Documentación](https://ejemplo.dev/docs)
```
