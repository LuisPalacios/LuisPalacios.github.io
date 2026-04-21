# Shortcodes de Hugo (CRÍTICO)

## Regla Fundamental

**Siempre preferir shortcodes de Hugo sobre HTML puro**. Los shortcodes son más mantenibles, consistentes y siguen las convenciones de Hugo.

## Shortcodes Disponibles

### 1. `admonition` - Bloques de advertencia/nota/info

```markdown
{{< admonition note "Título de la nota" >}}
Contenido en **Markdown** dentro del bloque.
{{< /admonition >}}
```

Tipos disponibles: `note`, `warning`, `tip`, `info`, `danger`

**NUNCA usar HTML puro** para crear bloques de advertencia. Siempre usar `admonition`.

#### Ejemplo de uso correcto:

```markdown
{{< admonition note "Serie de apuntes sobre Windows">}}
- Preparar un PC para [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}})
- Configurar [un Windows 11 decente]({{< relref "2025-08-03-win-decente.md" >}})
{{< /admonition >}}
```

#### ❌ INCORRECTO - HTML puro para advertencia

```html
<div class="note">
  <strong>Nota:</strong> Lista de posts...
</div>
```

### 2. `codefile` - Mostrar código desde archivo local

```markdown
{{< codefile path="snippets/ejemplo.sh" lang="bash" title="script.sh" open="1" linenos="inline" >}}
```

Parámetros:

- `path` (req): Ruta relativa a `assets/` o ruta física
- `lang` (opt): Lenguaje (bash, python, yaml, etc.)
- `title` (opt): Texto del summary
- `linenos` (opt): "table" | "inline" | "false"
- `open` (opt): "1" para abrir por defecto
- `from`/`to` (opt): Rango de líneas

### 3. `coderemote` - Mostrar código desde URL remota

```markdown
{{< coderemote url="https://raw.githubusercontent.com/user/repo/main/file.sh" lang="bash" title="script.sh" >}}
```

### 4. `relref` - Enlaces internos

```markdown
Ver el post sobre [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}})
```

**SIEMPRE usar `relref` para enlaces internos** en lugar de URLs absolutas.

## Cuándo NO usar Shortcodes

Solo usar HTML puro cuando:

1. No existe un shortcode equivalente
2. Es necesario para casos muy específicos (como la estructura `image-box` para imágenes con caption)
3. Es para estilos CSS inline muy específicos

## Ejemplos de Buenas Prácticas

### ✅ CORRECTO - Usar shortcode admonition

```markdown
{{< admonition note "Serie de apuntes sobre Windows">}}
- Preparar un PC para [Dualboot Linux / Windows]({{< relref "2024-08-23-dual-linux-win.md" >}})
- Configurar [un Windows 11 decente]({{< relref "2025-08-03-win-decente.md" >}})
{{< /admonition >}}
```

### ✅ CORRECTO - Usar relref para enlaces internos

```markdown
Ver el post sobre [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}})
```

### ✅ CORRECTO - Usar codefile para código extenso

```markdown
{{< codefile path="snippets/script.sh" lang="bash" title="script.sh" open="1" >}}
```

