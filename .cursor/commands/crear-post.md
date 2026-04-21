# Comando: Crear Nuevo Post

Actúa como un autor experto capaz de crear un nuevo post de Hugo basándote en un documento de descripción que especifica los requisitos del post. El estilo debe ser personal, didáctico y técnico, en primera persona, como una bitácora personal de aprendizaje.

## Uso

```bash
/crear-post <nombre-del-documento-descripcion>
```

El documento de descripción debe estar en `.cursor/templates/` y seguir la plantilla definida en `.cursor/templates/plantilla-descripcion-post.md`.

## Proceso

1. **Leer el documento de descripción**: El comando lee el archivo de descripción desde `.cursor/templates/<nombre>.md`

2. **Validar información**: Verifica que el documento tenga toda la información necesaria:
   - Título del post
   - Categoría (debe ser una de las categorías válidas)
   - Tags
   - Estructura del contenido

3. **Generar nombre de archivo**: Crea el nombre del archivo siguiendo el formato `YYYY-MM-DD-titulo-corto.md`:
   - Si se especifica fecha en el documento, se usa esa fecha
   - Si no, se usa la fecha actual
   - El título se convierte a kebab-case, se eliminan acentos y caracteres especiales
   - Ejemplo: "La navaja suiza para PDF's" → `2025-11-30-la-navaja-suiza-para-pdfs.md`

4. **Crear el post**: Usa `hugo new posts/YYYY-MM-DD-titulo-corto.md` para crear el archivo con el front matter correcto

5. **Completar el contenido inicial** siguiendo el estilo personal del autor:

   **a) Front matter completo:**
   - `title`: Título exacto del documento
   - `date`: Fecha en formato `"YYYY-MM-DD"` (con comillas)
   - `categories`: Array con al menos una categoría válida
   - `tags`: Array con tags relevantes
   - `draft`: false (a menos que se especifique lo contrario)
   - `cover.image`: Ruta al logo (ej: `/img/posts/logo-nombre.svg`)
   - `cover.hidden`: true

   **b) Logo flotante (si está especificado):**

   ```html
   <img src="/img/posts/logo-nombre.svg" alt="Logo nombre" width="150px" height="150px" style="float:left; padding-right:25px" />
   ```

   **c) Introducción (1-2 párrafos antes del `<!--more-->`):**
   - Estilo personal y directo, primera persona
   - Frases como: "Lo acabo de descubrir...", "En este apunte describo...", "Recomiendo..."
   - Mencionar el nombre del proyecto/tema con enlace si es relevante
   - Explicar qué es y para qué sirve de forma clara
   - Segundo párrafo con detalles técnicos (librerías, licencia, características)
   - Usar `<br clear="left"/>` después del logo y antes del `<!--more-->`

   **d) Separador obligatorio:**

   ```markdown
   <!--more-->
   ```

   **e) Estructura de secciones:**
   - Usar `##` para secciones principales
   - Usar `###` para subsecciones
   - No siempre es necesario una sección "Introducción" - a veces se va directo a "Instalación"
   - Las secciones deben seguir la estructura descrita en el documento
   - Títulos de secciones en minúsculas (excepto nombres propios): "Instalación", "Organización, seguridad y reparación"

   **f) Estilo de escritura en secciones:**
   - Tono personal: "Recomiendo", "Hago", "Ya estamos listos", "Instalo"
   - Explicaciones técnicas pero accesibles
   - Frases cortas y directas
   - Comentarios personales cuando sea apropiado
   - Usar negrita `**texto**` para destacar conceptos importantes
   - Usar cursiva `*texto*` para términos técnicos o énfasis

   **g) Bloques de código:**
   - Siempre especificar el lenguaje: ` ```bash `, ` ```powershell `, ` ```python `, etc.
   - Incluir comentarios en el código cuando sea necesario
   - Mostrar ejemplos prácticos y reales
   - Si hay salidas de comandos, incluirlas cuando sea relevante
   - Para código extenso, considerar usar `codefile` o `coderemote` si está en `src/assets/snippets/`

   **h) Enlaces internos:**
   - Usar `{{< relref "YYYY-MM-DD-nombre-post.md" >}}` para enlaces a otros posts
   - Nunca usar URLs absolutas para posts internos

   **i) Imágenes:**
   - Si se mencionan imágenes, usar la estructura `image-box` para imágenes con caption
   - El logo ya está incluido al inicio, no repetir

   **j) Conclusión:**
   - Breve, 1-2 párrafos
   - Resumir los puntos clave
   - Mencionar características destacadas del proyecto/tema
   - Invitar a probar o usar la herramienta

   **k) Sección "Enlaces Interesantes" (si hay enlaces externos):**

   ```markdown
   ## Enlaces Interesantes

   - [Descripción del enlace](URL)
   - [Descripción del enlace](URL)
   ```

6. **Verificar estructura**: Asegura que el post sigue todas las convenciones:
   - Front matter completo y correcto
   - Separador `<!--more-->` presente después de la introducción
   - Estructura de secciones clara
   - Enlaces internos usando `relref`
   - Código con sintaxis highlighting
   - Tono personal y didáctico en primera persona

## Ejemplo de Uso

```bash
/crear-post pdf-con-pdfly
```

Esto leerá `.cursor/templates/pdf-con-pdfly.md` y creará el post correspondiente.

## Estructura del Documento de Descripción

El documento debe seguir la plantilla en `.cursor/templates/plantilla-descripcion-post.md` e incluir:

- **Información básica**: Título, fecha, categoría, tags, draft
- **Descripción del contenido**: Propósito y audiencia
- **Estructura del contenido**: Secciones principales con puntos clave
- **Recursos**: Enlaces externos e internos
- **Imágenes**: Lista de imágenes a incluir
- **Código**: Snippets de código a incluir

## Notas Importantes

- **Estilo personal**: El post debe sonar como una bitácora personal, no como documentación formal
- **Primera persona**: Usar "yo", "mi", "me", "recomiendo", "hago", "instalo"
- **Tono didáctico pero técnico**: Explicar conceptos de forma clara sin simplificar demasiado
- **El post se crea en `src/content/posts/`**
- **Si el archivo ya existe**, se debe preguntar al usuario si desea sobrescribirlo
- **El post se crea con `draft: false` por defecto**, a menos que se especifique lo contrario
- **Las imágenes mencionadas** deben existir o se deben crear placeholders
- **Los snippets de código** deben existir en `src/assets/snippets/` o se deben crear

## Validaciones

- Verificar que la categoría sea válida (consultar `.cursor/rules/estructura-hugo.md`)
- Verificar que el formato de fecha sea correcto (YYYY-MM-DD)
- Verificar que el título no esté vacío
- Verificar que haya al menos una categoría y un tag
- Verificar que el logo existe en `src/static/img/posts/` si se especifica

## Patrones de Estilo a Seguir

- **Inicio de introducción**: "Lo acabo de descubrir...", "En este apunte describo...", "Describo cómo..."
- **Recomendaciones**: "Recomiendo instalarlo con...", "Te recomiendo que..."
- **Acciones personales**: "Hago la comprobación", "Instalo", "Ya estamos listos"
- **Explicaciones técnicas**: Usar negrita para conceptos clave, cursiva para términos técnicos
- **Comentarios personales**: "ésta maravilla", "Ya estamos listos", cuando sea apropiado
