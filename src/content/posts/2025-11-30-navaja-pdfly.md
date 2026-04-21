---
title: "La navaja suiza para PDF's"
date: "2025-11-30"
categories: ["herramientas"]
tags: ["documentación", "pdf", "firma", "certificado", "fusión", "compresion", "manipulación"]
draft: false
cover:
  image: "/img/posts/logo-pdfly.svg"
  hidden: true
---

<img src="/img/posts/logo-pdfly.svg" alt="Logo pdfly" width="150px" height="150px" style="float:left; padding-right:25px" />

Acabo de descubrir **[pdfly](https://github.com/py-pdf/pdfly)** (pronunciado PDF-li en inglés), la navaja suiza para trabajar con PDF's desde la línea de comandos (CLI). Se trata de una aplicación escrita puramente en Python, diseñada para extraer (meta)datos y manipular archivos PDF.

Está basado en las librerías `fpdf2` y `pypdf`, es un proyecto de software libre y código abierto, sin afiliación comercial, y cuenta con una licencia BSD-3-Clause.

<br clear="left"/>
<!--more-->

## Instalación

**pdfly** requiere **Python 3.10+** para funcionar correctamente. Asegúrate de tener una versión compatible antes de instalarlo.

Recomiendo instalarlo con `pipx`, que permite instalar aplicaciones "Python" para el CLI en tu PATH, crea automáticamente un entorno virtual aislado, instala la aplicación junto con sus dependencias en ese entorno, y añade un wrapper en tu PATH. Para instalarlo:

```bash
# En Linux/macOS
pip install pipx
pipx ensurepath

# Windows
scoop install pipx
pipx ensurepath
```

Ya estamos listos, instalo `pdfly`:

```bash
pipx install pdfly
pipx ensurepath

# En windows por ejemplo, salgo y vuelvo a entrar en el terminal
where pdfly
c:\Users\luis\.local\bin\pdfly.exe
```

Crea el envoltorio `.local\bin\pdfly.exe`, conocido técnicamente como wrapper o shim. Cuando lo ejecutas, busca dónde está su entorno virtual (`<home>\pipx\venvs`), localiza el intérprete de Python dentro de ese entorno y le pasa el script de inicio en python para interpretarlo. Quizá tengas que salir y entrar en el terminal, después ya puedes verificar la instalación y obtener ayuda general con:

```bash
pdfly --help
```

## Extracción, información y metadatos

### Inspección del PDF

**pdfly** ofrece varias herramientas para inspeccionar y extraer información de documentos PDF:

**Extracción de metadatos completos**: Este comando muestra información detallada sobre el documento, incluyendo metadatos del sistema operativo y del PDF.

```bash
pdfly meta documento.pdf
```

**Información de páginas específicas**: Para obtener detalles de una página específica, incluyendo dimensiones (*mediabox*, *cropbox*) y lista de anotaciones:

```bash
pdfly pagemeta documento.pdf <número-página>
```

**Extracción de contenido**:

**pdfly** permite extraer diferentes tipos de contenido:

- **Extracción de texto**: Para extraer el texto de un PDF:

```bash
pdfly extract-text documento.pdf
```

- **Extracción de imágenes**: Para extraer imágenes sin remuestreo ni alteración:

```bash
pdfly extract-images documento.pdf
```

- **Extracción de páginas con anotaciones**: Para extraer solo las páginas que contienen anotaciones:

```bash
pdfly extract-annotated-pages documento.pdf
```

## Organización, seguridad y reparación

### Fusión, división y extracción de páginas

**pdfly** permite manipular páginas de documentos PDF de forma muy flexible usando el comando `pdfly cat`:

**Importante**: Los índices de página comienzan en cero y usan sintaxis de *slices* de Python, similar a cómo funcionan los rangos en Python.

**Ejemplo de extracción de páginas**: Extrae las páginas 1, 2 y 3

```bash
pdfly cat input.pdf 1:4 -o out.pdf
```

**Nota sobre rangos negativos**: Para rangos que comienzan con un valor negativo, se debe usar `--` para separarlos de las opciones de línea de comandos:

```bash
pdfly cat input.pdf -- -5:-1 -o ultimas-paginas.pdf
```

### Eliminación y rotación de páginas

**Eliminación de páginas**:

```bash
pdfly rm documento.pdf <página1> <página2> -o documento-sin-paginas.pdf
```

**Rotación de páginas**:

```bash
pdfly rotate documento.pdf <página> <grados> -o documento-rotado.pdf
```

### Funcionalidades de impresión

**pdfly** incluye funciones útiles para preparar documentos para impresión:

- **`pdfly 2-up`**: Organiza el documento en formato 2-up (dos páginas por hoja)
- **`pdfly booklet`**: Crea un formato de libreta para impresión

```bash
pdfly booklet input.pdf salida.pdf
```

### Seguridad y reparación

**Firma Digital**:

**pdfly** permite firmar documentos PDF digitalmente usando certificados PKCS12.

```bash
pdfly sign input.pdf --p12 mi-certificado.p12 -p <contraseña-del-archivo-p12> -o signed.pdf
```

**Verificación de Firmas**:

Para verificar la firma de un documento PDF firmado con un PKCS12, necesito el certificado PEM con el que comprobarlo. En este ejemplo lo saco de mi propio certificado.

```bash
openssl pkcs12 -in mi-certificado.p12 -clcerts -nokeys -out certs.pem
```

Hago la comprobación

```bash
pdfly check-sign firmado.pdf --pem certs.pem
Check succeeded.
```

**Reparación de Archivos**:

Si un archivo PDF ha sido editado manualmente y tiene problemas con los *offsets* y longitudes en la sección `xref`, **pdfly** puede repararlo:

```bash
pdfly update-offsets documento-corrupto.pdf -o documento-reparado.pdf
```

Este comando corrige los *offsets* y longitudes en la sección `xref` del documento.

## Conclusión

**pdfly** es una verdadera "navaja suiza" integral para la gestión de PDF desde el CLI. El proyecto utiliza el modelo de gobierno de **"Dictador Benevolente"** (Benevolent Dictator), ahora es Martin Thoma. La comunidad está abierta a retroalimentación y contribuciones, y siempre se buscan nuevos colaboradores.

<div class="image-box">
  <img src="/img/posts/2025-11-30-navaja-pdfly-01.png" alt="La navaja suiza en el CLI" width="800px" />
  <div class="image-caption">La navaja suiza en el CLI</div>
</div>

Si trabajas frecuentemente con archivos PDF desde la línea de comandos, **pdfly** es definitivamente una herramienta que deberías tener en tu arsenal.

## Enlaces Interesantes

- [Repositorio oficial de pdfly en GitHub](https://github.com/py-pdf/pdfly)
- [Documentación oficial de pdfly](https://pdfly.readthedocs.io/)
