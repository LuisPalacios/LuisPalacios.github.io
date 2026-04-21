# Comando: Revisar Post Existente

Este comando revisa un post existente y proporciona feedback detallado sobre su calidad, consistencia y cumplimiento de las convenciones del proyecto, con especial atención al estilo personal y didáctico del autor.

## Uso

```bash
/revisar-post <nombre-del-post>
```

El nombre del post puede ser por ejemplo:

- El nombre completo del archivo: `2024-08-25-win-desarrollo.md`
- Solo el slug: `win-desarrollo`
- El título del post (se buscará en los posts existentes)

## Proceso de Revisión

### 1. Verificación de Estructura

- ✅ **Front matter completo**: Verifica que todos los campos requeridos estén presentes:
  - `title` (con comillas)
  - `date` (formato `"YYYY-MM-DD"` con comillas)
  - `categories` (array con al menos una categoría)
  - `tags` (array con al menos un tag)
  - `draft` (true o false)
  - `cover.image` (ruta correcta)
  - `cover.hidden` (true)

- ✅ **Formato de fecha**: Verifica que la fecha esté en formato `"YYYY-MM-DD"` con comillas

- ✅ **Categorías válidas**: Verifica que las categorías sean de la lista válida (ver `.cursor/rules/estructura-hugo.md`)

- ✅ **Separador `<!--more-->`**: Verifica que esté presente después de la introducción (típicamente después de 1-2 párrafos)

- ✅ **Logo flotante**: Verifica que el logo esté presente con la estructura correcta y `<br clear="left"/>` después

### 2. Verificación de Contenido

- ✅ **Introducción**: Verifica que haya una introducción clara (1-2 párrafos) antes del `<!--more-->`:
  - Debe ser personal y directa
  - Debe usar primera persona
  - Debe mencionar el tema/proyecto con enlace si es relevante
  - Debe explicar qué es y para qué sirve

- ✅ **Estructura de secciones**: Verifica que el contenido esté bien estructurado:
  - Secciones principales con `##`
  - Subsecciones con `###`
  - Títulos en minúsculas (excepto nombres propios)
  - Estructura lógica y clara

- ✅ **Tono y estilo personal**: Verifica que el tono sea personal y didáctico:
  - Uso de primera persona: "yo", "mi", "me", "recomiendo", "hago", "instalo"
  - Frases personales: "Lo acabo de descubrir", "Ya estamos listos", "Hago la comprobación"
  - Tono didáctico pero técnico
  - Explicaciones claras sin simplificar demasiado
  - Comentarios personales cuando sea apropiado

- ✅ **Enlaces internos**: Verifica que los enlaces a otros posts usen `{{< relref "YYYY-MM-DD-nombre-post.md" >}}` en lugar de URLs absolutas

- ✅ **Conclusión**: Verifica que haya una conclusión breve (1-2 párrafos) que resuma los puntos clave

- ✅ **Sección "Enlaces Interesantes"**: Verifica que si hay enlaces externos, estén en una sección al final

### 3. Verificación de Shortcodes

- ✅ **Uso de shortcodes**: Verifica que se usen shortcodes en lugar de HTML puro cuando sea posible:
  - `admonition` para bloques de advertencia/nota/info/tip
  - `codefile` o `coderemote` para código extenso (opcional, código inline también es válido)
  - `relref` para enlaces internos

- ✅ **Sintaxis correcta**: Verifica que los shortcodes estén correctamente formateados

- ⚠️ **Oportunidades de uso**: Sugiere usar `admonition` para notas importantes que están en negrita

### 4. Verificación de Imágenes

- ✅ **Rutas de imágenes**: Verifica que las rutas de imágenes empiecen con `/img/posts/`

- ✅ **Logo inicial**: Verifica que el logo tenga la estructura correcta:

  ```html
  <img src="/img/posts/logo-nombre.svg" alt="Logo nombre" width="150px" height="150px" style="float:left; padding-right:25px" />
  ```

- ✅ **Estructura image-box**: Verifica que las imágenes con caption usen la estructura `image-box`

- ✅ **Archivos existentes**: Verifica que los archivos de imagen mencionados existan en `src/static/img/posts/`

- ✅ **Nombres de archivo**: Verifica que los nombres sigan la convención `YYYY-MM-DD-titulo-corto-NN.<ext>` para imágenes de contenido

### 5. Verificación de Código

- ✅ **Sintaxis highlighting**: Verifica que los bloques de código tengan el lenguaje especificado:
  - `bash` para comandos Linux/macOS
  - `powershell` o `ps1` para PowerShell
  - `python`, `yaml`, `json`, etc. según corresponda

- ✅ **Comentarios en código**: Verifica que el código tenga comentarios cuando sea necesario para claridad

- ✅ **Ejemplos prácticos**: Verifica que los ejemplos de código sean prácticos y reales

- ✅ **Snippets**: Verifica que los snippets referenciados con `codefile` existan en `src/assets/snippets/`

### 6. Verificación de Listas y Tablas

- ✅ **Formato de listas**: Verifica que las listas usen `-` y tengan una línea en blanco antes

- ✅ **Tablas**: Verifica que las tablas estén correctamente formateadas en Markdown

### 7. Verificación de Estilo Personal

- ✅ **Frases características**: Verifica el uso de frases características del estilo:
  - "Lo acabo de descubrir..."
  - "Recomiendo..."
  - "Hago...", "Instalo...", "Ya estamos listos"
  - "En este apunte describo..."

- ✅ **Uso de negrita y cursiva**: Verifica uso apropiado:
  - Negrita `**texto**` para conceptos importantes
  - Cursiva `*texto*` para términos técnicos o énfasis

- ✅ **Explicaciones técnicas**: Verifica que las explicaciones sean claras pero no simplificadas en exceso

### 8. Sugerencias de Mejora

- 💡 **Enlaces rotos**: Identifica enlaces internos que apuntan a posts que no existen

- 💡 **Imágenes faltantes**: Identifica referencias a imágenes que no existen

- 💡 **Oportunidades de uso de shortcodes**: Sugiere reemplazar HTML puro con shortcodes cuando sea apropiado (especialmente `admonition` para notas importantes)

- 💡 **Mejoras de estructura**: Sugiere mejoras en la organización del contenido

- 💡 **Tags y categorías**: Sugiere tags o categorías adicionales si son relevantes

- 💡 **Consistencia de estilo**: Sugiere mejoras para mantener el estilo personal consistente

- 💡 **Errores tipográficos**: Identifica errores tipográficos comunes (PCKS12 → PKCS12, etc.)

## Salida del Comando

El comando debe proporcionar:

1. **Resumen ejecutivo**: Estado general del post (✅ Aprobado / ⚠️ Necesita mejoras / ❌ Errores críticos)

2. **Lista de verificaciones**: Cada verificación con su estado (✅ / ⚠️ / ❌)

3. **Errores críticos**: Problemas que deben corregirse antes de publicar:
   - Front matter incompleto
   - Separador `<!--more-->` faltante
   - Categorías inválidas
   - Enlaces internos con URLs absolutas
   - Imágenes que no existen

4. **Advertencias**: Problemas menores que deberían corregirse:
   - Errores tipográficos
   - Lenguaje de código incorrecto
   - Falta de punto final en oraciones
   - Inconsistencias en mayúsculas/minúsculas en títulos

5. **Sugerencias**: Mejoras opcionales que podrían hacerse:
   - Usar `admonition` para notas importantes
   - Mejorar explicaciones técnicas
   - Añadir más ejemplos
   - Mejorar consistencia de estilo

6. **Estadísticas**:
   - Número de palabras (aproximado)
   - Número de secciones principales (`##`)
   - Número de subsecciones (`###`)
   - Número de imágenes
   - Número de bloques de código
   - Número de enlaces internos
   - Número de enlaces externos

## Ejemplo de Uso

```bash
/revisar-post 2024-08-25-win-desarrollo
```

o

```bash
/revisar-post win-desarrollo
```

## Notas

- El comando debe ser **no destructivo** (solo lectura)
- Debe proporcionar **feedback claro y accionable**
- Debe seguir las reglas definidas en `.cursor/rules/`
- Debe ser útil tanto para posts nuevos como para posts existentes que se están actualizando
- Debe prestar especial atención al **estilo personal y didáctico** del autor
- Debe identificar **patrones de escritura** característicos del autor

## Patrones de Estilo a Verificar

- Uso de primera persona: "yo", "mi", "me"
- Frases características: "Lo acabo de descubrir", "Recomiendo", "Hago", "Ya estamos listos"
- Tono personal y didáctico
- Explicaciones técnicas claras pero no simplificadas
- Uso apropiado de negrita y cursiva
- Comentarios personales cuando sea apropiado
