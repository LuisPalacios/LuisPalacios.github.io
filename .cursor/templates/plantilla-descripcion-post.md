# Plantilla de Descripción de Post

Usa esta plantilla para describir los requisitos de un nuevo post. Guarda este archivo en `.cursor/templates/` con un nombre descriptivo (por ejemplo: `post-docker-basics.md`, `post-kubernetes-advanced.md`).

---

## Información Básica

**Título del Post**: [Título descriptivo y claro]

**Fecha propuesta**: [YYYY-MM-DD] (opcional, si no se especifica se usará la fecha actual)

**Categoría principal**: [Seleccionar de la lista en `.cursor/rules/estructura-hugo.md`]

**Tags**: [tag1, tag2, tag3, ...] (separados por comas)

**Draft**: [true/false] (por defecto: false)

## Descripción del Contenido

**Propósito del post**: [1-2 párrafos explicando qué se va a documentar y por qué]

**Audiencia objetivo**: [¿Para quién es este post? ¿Qué nivel técnico se asume?]

## Estructura del Contenido

### Introducción

[Descripción de lo que debe incluir la introducción]

### Secciones principales

1. **[Nombre de sección 1]**
   - [Puntos clave a cubrir]
   - [Ejemplos o casos de uso]

2. **[Nombre de sección 2]**
   - [Puntos clave a cubrir]
   - [Ejemplos o casos de uso]

3. **[Nombre de sección 3]**
   - [Puntos clave a cubrir]
   - [Ejemplos o casos de uso]

### Conclusión

[Qué debe incluir la conclusión o cierre del post]

## Recursos y Referencias

**Enlaces externos relevantes**:

- [URL 1 - Descripción]
- [URL 2 - Descripción]

**Posts relacionados (enlaces internos)**:

- [Nombre del post relacionado 1]
- [Nombre del post relacionado 2]

## Imágenes y Recursos Visuales

**Logo del post**: [¿Existe un logo? ¿Dónde está? ¿Necesita crearse?]

- Ruta: `/img/posts/logo-<nombre>.svg`

**Imágenes a incluir**:

1. [Descripción de imagen 1] - `YYYY-MM-DD-titulo-01.<ext>`
2. [Descripción de imagen 2] - `YYYY-MM-DD-titulo-02.<ext>`
3. [Descripción de imagen 3] - `YYYY-MM-DD-titulo-03.<ext>`

## Código y Snippets

**Snippets de código a incluir**:

1. [Descripción del snippet 1] - `snippets/YYYY-MM-DD-titulo/script1.sh`
2. [Descripción del snippet 2] - `snippets/YYYY-MM-DD-titulo/script2.sh`

**Lenguajes de programación**: [bash, python, yaml, etc.]

## Notas Adicionales

[Any additional notes, special considerations, or requirements]

---

## Ejemplo de Uso

```markdown
# Información Básica

**Título del Post**: Introducción a Docker Compose

**Fecha propuesta**: 2025-12-01

**Categoría principal**: desarrollo

**Tags**: docker, docker-compose, contenedores, devops, linux

**Draft**: false

## Descripción del Contenido

**Propósito del post**: Documentar cómo usar Docker Compose para orquestar múltiples contenedores en un entorno de desarrollo local.

**Audiencia objetivo**: Desarrolladores con conocimientos básicos de Docker que quieren aprender a gestionar aplicaciones multi-contenedor.

## Estructura del Contenido

### Introducción
Explicar qué es Docker Compose y cuándo usarlo en lugar de comandos docker individuales.

### Secciones principales
1. **Instalación de Docker Compose**
   - Instalación en Linux
   - Verificación de la instalación

2. **Archivo docker-compose.yml**
   - Estructura básica
   - Servicios, redes y volúmenes
   - Variables de entorno

3. **Comandos básicos**
   - docker-compose up
   - docker-compose down
   - docker-compose ps

### Conclusión
Resumen de ventajas y casos de uso típicos.

## Recursos y Referencias

**Enlaces externos relevantes**:
- https://docs.docker.com/compose/ - Documentación oficial

**Posts relacionados (enlaces internos)**:
- 2014-11-01-inicio-docker.md

## Imágenes y Recursos Visuales

**Logo del post**: logo-docker-compose.svg (ya existe)

**Imágenes a incluir**:
1. Arquitectura de servicios - `2025-12-01-docker-compose-01.svg`
2. Ejemplo de docker-compose.yml - `2025-12-01-docker-compose-02.png`

## Código y Snippets

**Snippets de código a incluir**:
1. docker-compose.yml básico - `snippets/2025-12-01-docker-compose/docker-compose.yml`
2. Script de inicio - `snippets/2025-12-01-docker-compose/start.sh`

**Lenguajes de programación**: yaml, bash
```
