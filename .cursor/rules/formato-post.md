# Formato y Estilo de los Posts

## Estructura Típica de un Post

1. **Front matter** Obligatorio (ver `.cursor/rules/estructura-hugo.md`)

2. **Logo/Imagen inicial** (opcional, flotante a la izquierda):

   ```html
   <img src="/img/posts/logo-nombre.svg" alt="Descripción" width="150px" height="150px" style="float:left; padding-right:25px" />
   ```

3. **Introducción**: 1-3 párrafos explicando el propósito del apunte

4. **Separador de resumen**: `<!--more-->` (obligatorio para que aparezca el resumen en la lista)

5. **Contenido principal**: Varias secciones usando `##` y subsecciones con `###`.

6. **Enlaces internos**: Usar `{{< relref "YYYY-MM-DD-nombre-post.md" >}}` en lugar de URLs absolutas

## Tono y Estilo

- **Tono personal y didáctico**: Es un blog personal, debe transmitir la personalidad y forma de escribir. "En este apunte describo...", "Mi estrategia...", "He decidido..."
- **Primera persona**: Es una bitácora personal, usar "yo", "mi", "me"
- **Claridad técnica**: Explicar conceptos de forma clara pero sin simplificar demasiado.
- **Estructura clara**: Usar secciones bien definidas, listas, tablas cuando sea apropiado.
- **Referencias útiles**: Incluir enlaces a recursos externos relevantes al final del post.

## Imágenes

Siempre usar esta estructura para imágenes con caption:

```html
<div class="image-box">
  <img src="/img/posts/YYYY-MM-DD-titulo-corto-NN.<ext>" alt="Descripción alt" width="800px" />
  <div class="image-caption">Texto del caption</div>
</div>
```

### Mejores Prácticas para Imágenes

1. Guardar todas las imágenes en `src/static/img/posts/`
2. Usar nombres descriptivos que incluyan la fecha del post
3. Optimizar imágenes antes de subirlas (comprimir PNG, optimizar JPG)
4. Usar SVG cuando sea posible para logos e iconos
5. Siempre incluir texto alternativo (`alt`) descriptivo
6. Usar la estructura `image-box` con caption

## Código

- Usar bloques de código con sintaxis resaltada: ` ```lenguaje `
- Especificar el lenguaje siempre que sea posible
- Para archivos completos, usar el shortcode `codefile` o `coderemote` en lugar de pegar código directamente
- Ver `.cursor/rules/shortcodes.md` para más detalles

### Mejores Prácticas para Código

1. **Preferir shortcodes `codefile` o `coderemote`** sobre bloques de código inline cuando el código es extenso
2. Guardar snippets en `src/assets/snippets/` para reutilización
3. Usar sintaxis highlighting apropiado
4. Incluir comentarios en el código cuando sea necesario para claridad

## Listas

- Cuando se usen listas, usar siempre `-`.
- Siempre poner una línea en blanco antes de la primera entrada de la lista

## Tablas

Usar sintaxis Markdown para tablas. Si necesitas estilos especiales, usar CSS inline en un bloque `<style>` al inicio del post:

```html
<style>
table {
    font-size: 0.8em;
}
</style>
```

## Ejemplos de Buenas Prácticas

### ✅ CORRECTO - Estructura image-box

```html
<div class="image-box">
  <img src="/img/posts/2025-08-03-win-decente-01.png" alt="Ejecución del script" width="800px" />
  <div class="image-caption">Ejecución del primer script automático</div>
</div>
```

### ✅ CORRECTO - Usar codefile para código extenso

```markdown
{{< codefile path="snippets/script.sh" lang="bash" title="script.sh" open="1" >}}
```

### ✅ CORRECTO - Usar relref para enlaces internos

```markdown
Ver el post sobre [Windows para desarrollo]({{< relref "2024-08-25-win-desarrollo.md" >}})
```

### ❌ INCORRECTO - URL absoluta para post interno

```markdown
Ver el post sobre [Windows para desarrollo](https://www.luispa.com/posts/2024-08-25-win-desarrollo/)
```

