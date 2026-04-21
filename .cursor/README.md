# Configuración de Cursor para el Proyecto

Este directorio contiene la configuración y reglas para trabajar con Cursor en este proyecto de blog Hugo.

## Estructura

```text
.cursor/
├── index.mdc              # Archivo principal de contexto del proyecto
├── commands/              # Comandos personalizados de Cursor
│   ├── crear-post.md      # Comando para crear nuevos posts
│   └── revisar-post.md    # Comando para revisar posts existentes
├── rules/                 # Reglas detalladas del proyecto
│   ├── estructura-hugo.md # Estructura y convenciones de Hugo
│   ├── formato-post.md    # Formato y estilo de los posts
│   ├── shortcodes.md      # Uso de shortcodes de Hugo
│   └── mejores-practicas.md # Mejores prácticas
└── templates/             # Plantillas para crear contenido
    └── plantilla-descripcion-post.md  # Plantilla para describir nuevos posts
```

## Uso

### Crear un Nuevo Post

1. Crea un documento de descripción en `.cursor/templates/` siguiendo la plantilla `plantilla-descripcion-post.md`
2. Usa el comando: `/crear-post <nombre-del-documento>`

Ejemplo:

```bash
/crear-post post-docker-compose
```

### Revisar un Post Existente

Usa el comando: `/revisar-post <nombre-del-post>`

Ejemplo:

```bash
/revisar-post 2024-08-25-win-desarrollo
```

o

```bash
/revisar-post win-desarrollo
```

## Archivos de Reglas

- **`estructura-hugo.md`**: Información sobre la estructura de carpetas, convenciones de archivos, front matter, categorías y tags
- **`formato-post.md`**: Guía sobre formato, estilo, imágenes, código, listas y tablas
- **`shortcodes.md`**: Documentación completa sobre el uso de shortcodes de Hugo
- **`mejores-practicas.md`**: Mejores prácticas para crear, editar y trabajar con posts

## Notas

- El archivo `index.mdc` se carga automáticamente cuando trabajas en el proyecto
- Las reglas en `rules/` proporcionan detalles específicos sobre cómo trabajar con el proyecto
- Los comandos en `commands/` son instrucciones para Cursor sobre cómo ejecutar tareas específicas
- Las plantillas en `templates/` ayudan a mantener consistencia al crear nuevo contenido
