## Información Básica

**Título del Post**: La navaja suiza para PDF's

**Fecha propuesta**: [1015-11-30]

**Categoría principal**: [Seleccionar de la lista en `.cursor/rules/estructura-hugo.md`]

**Tags**: [documentación, pdf, firma, certificado, fusión, compresion, manipulación]

**Draft**: false

## Descripción del Contenido

**Propósito del post**: El objetivo es documentar en detalle **`pdfly`** (pronunciado PDF-li), una aplicación de interfaz de línea de comandos (CLI) escrita puramente en Python. Este proyecto es el más joven de la organización `py-pdf` y fue creado por Martin Thoma en 2022. El post destacará su utilidad para extraer (meta)datos y manipular archivos PDF, y mostrará comandos específicos para tareas avanzadas como la firma digital, la compresión y la reparación de documentos.

**Audiencia objetivo**: Desarrolladores y usuarios de CLI con un nivel técnico que buscan herramientas eficientes y *open-source* para la manipulación de documentos PDF. Se asume familiaridad con la ejecución de comandos en la terminal y un conocimiento básico del ecosistema Python (pip, pipx).

## Estructura del Contenido

### Introducción

Aunque lleva bastante tiempo existiendo, acabo de descubrir la navaja suiza para trabajar con PDF's. [pdfly](https://github.com/py-pdf/pdfly) (pronunciado PDF-li) es una aplicación de interfaz de línea de comandos (CLI) escrita puramente en Python, diseñada para extraer (meta)datos y manipular archivos PDF.

Está basado en las librerías `fpdf2` y `pypdf`, es un proyecto es de software libre y código abierto, sin afiliación comercial, y cuenta con una licencia BSD-3-Clause.

### Secciones principales

1. **Instalación y Requisitos (Python 3.10+ y Métodos de Instalación)**

- **Puntos clave a cubrir**: Requisitos de versión (**Python 3.10+**).
- **Puntos clave a cubrir**: Opciones de instalación: `pip install -U pdfly` o la recomendada con `pipx install pdfly` para un entorno aislado.
- **Ejemplos o casos de uso**: Mostrar los comandos de instalación y el comando de ayuda general (`$ pdfly --help`).

2. **Extracción, Información y Metadatos (Inspección del PDF)**

- **Puntos clave a cubrir**: Extracción de metadatos de documentos completos (`pdfly meta`).
- **Puntos clave a cubrir**: Obtención de detalles de una página específica, incluyendo dimensiones (*mediabox*, *cropbox*) y lista de anotaciones (`pdfly pagemeta`).
- **Puntos clave a cubrir**: Extracción de contenido: texto (`pdfly extract-text`) e imágenes sin remuestreo ni alteración (`pdfly extract-images`).
- **Ejemplos o casos de uso**: Mostrar ejemplos de salida de `pdfly meta` y el uso de `pdfly extract-annotated-pages` para extraer solo páginas con anotaciones.

3. **Manipulación Avanzada: Organización, Seguridad y Reparación**

- **Puntos clave a cubrir**: **Fusión, división y extracción** de páginas con `pdfly cat`, destacando que los índices de página comienzan en cero y usan sintaxis de *slices* de Python.
- **Puntos clave a cubrir**: Eliminación de páginas con `pdfly rm` y rotación de páginas con `pdfly rotate`.
- **Puntos clave a cubrir**: Funcionalidades de **impresión** (`pdfly 2-up` y `pdfly booklet`).
- **Puntos clave a cubrir**: **Seguridad y reparación**: Firma digital (`pdfly sign` con certificado PKCS12) y verificación (`pdfly check-sign` con certificado PEM).
- **Puntos clave a cubrir**: Reparación de archivos editados manualmente (`pdfly update-offsets`) para corregir *offsets* y longitudes en la sección `xref`.
- **Ejemplos o casos de uso**: Ejemplos de `pdfly cat input.pdf 1:4 -o out.pdf` (división) y `pdfly sign input.pdf --p12 certs.p12 -o signed.pdf` (firma).

### Conclusión

La conclusión debe cerrar destacando que `pdfly` es una "navaja suiza" integral para la gestión de PDF en la terminal, enfatizando su naturaleza *open-source* y el apoyo continuo de la comunidad (mencionar Hacktoberfest y la versión 0.5.1 de 2025-10-13). También debe invitar a la retroalimentación y la contribución, mencionando que se buscan nuevos colaboradores.

## Recursos y Referencias

**Enlaces externos relevantes**:

- https://github.com/py-pdf/pdfly - Repositorio oficial del proyecto `pdfly`
- https://pdfly.readthedocs.io/ - Documentación del proyecto

## Imágenes y Recursos Visuales

**Logo del post**: El logo que muestra la serpiente de Python envuelta alrededor de un documento PDF.

- Ruta: `/img/posts/logo-pdfly.svg`

**Imágenes a incluir**:

1. Captura de pantalla de la salida del comando `pdfly meta` (ejemplo de metadatos del sistema operativo y del PDF).
2. Captura de pantalla que ilustre la sintaxis de *slices* de Python para `pdfly cat` o `pdfly rm`.
3. Captura de pantalla mostrando el comando `pdfly sign` o `pdfly check-sign`.

## Código y Snippets

**Snippets de código a incluir**:

1. Instalación y Ayuda: `pipx install pdfly` y `pdfly --help`.
2. Concatenación/Extracción: `pdfly cat input.pdf 1:4 -o out.pdf` (Extracción de páginas).
3. Seguridad/Firma: `pdfly sign input.pdf --p12 certs.p12 -o signed.pdf`.

**Lenguajes de programación**: [bash, python]

## Notas Adicionales

- El proyecto utiliza el modelo de gobernanza de **"Dictador Benevolente"** (Benevolent Dictator), siendo Martin Thoma el actual dictador desde abril de 2022.
- Se debe recordar a los lectores que los **índices de página comienzan en cero** y la sintaxis de rango de páginas es similar a las *slices* de Python. Para rangos que comienzan con un valor negativo, se debe usar `--` para separarlos de las opciones de línea de comandos.
