# Mejores Prácticas

## Al Crear un Nuevo Post

1. Usar `hugo new posts/YYYY-MM-DD-titulo.md` para crear el archivo con el front matter correcto
2. Añadir el logo/imagen inicial si existe
3. Escribir una introducción clara
4. Añadir `<!--more-->` después de la introducción
5. Estructurar el contenido en secciones claras
6. Usar shortcodes en lugar de HTML cuando sea posible
7. Incluir imágenes con la estructura `image-box` cuando sea necesario
8. Añadir enlaces internos con `relref` cuando se mencione otro post
9. Revisar que todos los tags y categorías sean correctos

## Al Editar Posts Existentes

1. Mantener el estilo y tono consistente con el resto del blog
2. Actualizar enlaces rotos
3. Verificar que las imágenes existan
4. Asegurar que los shortcodes estén correctamente formateados
5. Mantener la estructura de secciones clara

## Al Trabajar con Código

1. **Preferir shortcodes `codefile` o `coderemote`** sobre bloques de código inline cuando el código es extenso
2. Guardar snippets en `src/assets/snippets/` para reutilización
3. Usar sintaxis highlighting apropiado
4. Incluir comentarios en el código cuando sea necesario para claridad

## Al Trabajar con Imágenes

1. Guardar todas las imágenes en `src/static/img/posts/`
2. Usar nombres descriptivos que incluyan la fecha del post
3. Optimizar imágenes antes de subirlas (comprimir PNG, optimizar JPG)
4. Usar SVG cuando sea posible para logos e iconos
5. Siempre incluir texto alternativo (`alt`) descriptivo
6. Usar la estructura `image-box` con caption

## Recordatorios Críticos

1. ✅ **SIEMPRE usar shortcodes en lugar de HTML puro** cuando sea posible
2. ✅ **Todo el contenido en español** - Cursor debe trabajar en español
3. ✅ **Usar `relref` para enlaces internos** - Nunca URLs absolutas para posts internos
4. ✅ **Estructura `image-box` para imágenes con caption** - No usar HTML genérico
5. ✅ **Front matter completo y correcto** - Incluir todos los campos requeridos
6. ✅ **Separador `<!--more-->`** - Obligatorio en todos los posts
7. ✅ **Tono personal y didáctico** - Primera persona, estilo bitácora
8. ✅ **Código con sintaxis highlighting** - Especificar lenguaje siempre
9. ✅ **Imágenes optimizadas** - Comprimir antes de subir
10. ✅ **Enlaces útiles al final** - Sección "Enlaces interesantes" cuando sea apropiado

## Notas Finales

- Este blog es una **bitácora personal de aprendizaje técnico**
- El objetivo es **documentar procesos, configuraciones y soluciones** para referencia futura
- El estilo es **didáctico pero técnico**, dirigido a personas con conocimientos técnicos
- **Mantener consistencia** con el estilo y formato de posts existentes
- **Priorizar claridad y utilidad** sobre complejidad innecesaria
- **Siempre pensar en el lector** - ¿será útil este contenido? ¿está bien explicado?

