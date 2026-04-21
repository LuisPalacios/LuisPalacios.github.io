# Tone & Style Reference

Writing patterns extracted from the blog's existing posts. Use these to maintain consistency.

## Voice & Persona

- **First-person singular**: "instalo", "uso", "configuro", "mis datos", "mi objetivo"
- **Conversational but technical**: Explain concepts accessibly without dumbing down
- **Personal learning journal**: These are notes for future self, shared publicly
- **Practical focus**: Problem → Solution → Examples

## Opening Patterns

### Tool Discovery

```markdown
Acabo de descubrir **[nombre](url)**, una herramienta...
```

### Descriptive Introduction

```markdown
En este apunte describo cómo...
En este apunte explico cómo gestiono...
```

### Goal Statement

```markdown
Mi objetivo es...
```

### Direct Definition

```markdown
[Nombre](url) es un/una [descripción corta] que permite...
```

### Philosophy/Problem First

```markdown
[Concepto] es un desafío. Llevo años [haciendo X]...
El problema no es [A], es el **modelo**...
```

## Action Phrases

| Pattern | Example |
| --- | --- |
| Installation | "Recomiendo instalarlo con..." |
| Readiness | "Ya estamos listos, instalo..." |
| Verification | "Hago la comprobación con..." |
| Configuration | "Configuro..." / "Verifico..." |
| Command execution | "Ejecuto..." / "Lanzo..." |

## Transition Phrases

- "Ahora al lio..." / "Al lio..."
- "Veamos..."
- "Vamos a ver..."
- "Para provocarlo..."
- "Dicho de otra forma..."
- "En resumen..."

## Personal Commentary

### Enthusiasm

- "esta maravilla"
- "este proyecto es espectacular"
- "Mola porque..."
- "Es liberador..."

### Challenges

- "La dificultad radica en..."
- "He dedicado muchas horas a..."
- "Tengo pendiente..."

### Recommendations

- "Te recomiendo..."
- "Mi recomendación es..."
- "Ojo: [advertencia]"

### Asides

- "(más info [aquí](url))"
- "Nota: ..."
- "Importante: ..."

## Structure Patterns

### Heading Hierarchy

- `##` for main sections
- `###` for subsections
- `####` rarely, only for deep nesting
- **Capitalization**: Only first word capitalized, NOT Title Case
  - Good: `## Mi caso de uso`
  - Bad: `## Mi Caso De Uso`

### Lists

- Use `-` for unordered lists (not `*`)
- Command tables for CLI tools
- Comparison tables for options

### Code Blocks

Always specify language:

```bash
# Installation command
brew install tool
```

### Internal Links

```markdown
Te recomiendo que eches un ojo a mi apunte ["Título"]({{< relref "YYYY-MM-DD-slug.md" >}}).
```

### External Links

Bold the tool name, link it:

```markdown
**[pdfly](https://github.com/py-pdf/pdfly)** es una herramienta...
```

## Post Length Guidelines

| Type | Length | Characteristics |
| --- | --- | --- |
| Short (default) | ~5-10 min | Quick intro, practical examples, no deep-dive |
| Long (tutorial) | 15-30 min | Step-by-step, detailed explanations, diagrams |
| Cheatsheet | ~3-5 min | Minimal prose, command tables, links |

## Common Section Names

- `## Introducción`
- `## Instalación`
- `## Configuración`
- `## Mi caso de uso`
- `## Trucos` / `## Consejos`
- `## Conclusión`
- `## Enlaces interesantes` / `## Recursos`

## Things to Avoid

- Overly formal language
- Passive voice (prefer active)
- Long paragraphs (break them up)
- English when Spanish suffices (but English tech terms OK)
- Excessive emojis (occasional use acceptable)
- Placeholder text or TODOs in final content
- Unnecessary filler phrases ("Vamos a resolver esta confusión", "Es la pregunta más frecuente")
- Redundant subsection headers (e.g., "### Características clave" before a simple list)
- Tables when prose flows better (explain concepts conversationally, not in grids)
- Anglicisms when Spanish works: "Testea" → "Prueba", "expertise" → "experiencia"
- Long heading prefixes: "Mi workflow: X" → just "X"

## Heading Style

- Keep headings short and direct
- Bad: "La revolución de las Skills"
- Good: "La revolución"
- Bad: "Mi workflow: iterar para mejorar"
- Good: "Iterar para mejorar"
- Bad: "Consejos para crear buenos Skills"
- Good: "Consejos para crear Skills"

## Conversational Explanations

Prefer flowing prose over tables for conceptual comparisons:

```markdown
# Bad (table)
| Enfoque | Qué es | Cuándo usarlo |
| --- | --- | --- |
| **Instrucciones** | Config global | Preferencias universales |

# Good (prose)
Vamos a explicarlas. Por un lado tenemos las **Instrucciones personalizadas**,
son la configuración global que afecta a todas las conversaciones con la IA...
```

## Direct Invitations

Engage the reader directly:

```markdown
# Bad
Para este mismo blog uso un skill que genera apuntes.

# Good
Si consultas la rama [gh-pages](https://github.com/LuisPalacios/LuisPalacios.github.io/tree/gh-pages) de este mismo blog, verás que he creado
una Skill para crear apuntes, échale un ojo.
```
