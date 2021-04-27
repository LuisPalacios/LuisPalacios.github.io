---
title: "GIT en detalle"
date: "2021-04-17"
categories: desarrollo
tags: git
excerpt_separator: <!--more-->
---

![Logo GIT](/assets/img/post/logo-git.png){: width="150px" style="float:left; padding-right:20px" } 

[GIT] es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia.

<!--more-->

No depende de un repositorio central, múltiples usuarios pueden instalarse GIT y comunicarse entre ellos sin necesidad de conectar con un servidor central. Lo que pasa es que sería inmanejable, así que los "servidores o repositorios centrales (remotos)" son muy útiles y necesarios, **los más famosos son [GitHub] y [GitLab]**. 

[Git]: https://git-scm.com
[GitHub]: https://www.github.com
[GitLab]: https://www.gitlab.com
[Gitolite]: https://gitolite.com

<br/>

## Introducción

Muy útiles, la [Cheatsheet en Español](https://training.github.com/downloads/es_ES/github-git-cheat-sheet/) o la [Visual Git Cheat Sheet](https://ndpsoftware.com/git-cheatsheet.html) o este pequeño [Guía burros](https://rogerdudler.github.io/git-guide/index.es.html) o la [documentación oficial](https://git-scm.com/doc) o si te vas a cualqueir buscador en internet vas a encontrar cientos de videos, tutoriales y documentos. 

¿Porqué mola GIT?. Hay muchos motivos, como su velocidad, que lo hizo Linus Torvals, que es libre, que nos permite movernos, como si tuviéramos un puntero en el tiempo, por todas las revisiones de código y desplazarnos una manera muy ágil.

Tiene un sistema de trabajo con ramas (branches) que lo hace especialmente potente. Están destinadas a provocar proyectos divergentes de un proyecto principal, para hacer experimentos o para probar nuevas funcionalidades.

Antes de entrar en harina, tenemos dos formas de trabajar, con el cliente (programa) `git` para la línea de comandos o con un cliente gráfico, muchísimo más sencillo y agradable. Aún así te recomiendo empezar por la línea de comandos (`git` a secas) y cuando entiendas cuatro cosillas importantes te pases a un cliente GUI.

* Cliente `git`, programa para línea de comandos
* Cliente GUI [GitKraken](https://www.gitkraken.com) <- Este es el que uso yo 🤗
* Cliente GUI [GitHub Desktop](https://desktop.github.com) desarrollado por GitHub.
* Cliente GUI [SourceTree](https://www.sourcetreeapp.com)
* Aquí tienes más.. [clientes GUI](https://git-scm.com/downloads/guis)

<br/>

### Instalación de Git

Para trabajar con GIT te recomiendo que siempre te instales la versión de la línea de comandos (programa `git`) y que elijas UNO de los **clientes GUI anteriores (el que más te guste)**, lo descargues y lo instales en tu ordenador. 

* Aquí tienes una pequeña guía para [instalar](https://git-scm.com/book/es/v2/Inicio---Sobre-el-Control-de-Versiones-Instalación-de-Git) `git` en línea de comandos en Linux, Windows y Mac.

Una vez que lo tengas instalado deberías funcionarte al menos lo siguiente: 


```zsh
➜  ~ > git
usage: git [--version] [--help] [-C <path>] [-c <name>=<value>]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | -P | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           <command> [<args>]
           :
➜  ~ > git --version
git version 2.24.3 (Apple Git-128)
```
<br/>

Uno de los mejores artículos técnicos **con detalle** que me encontré en el pasado para aprender fue [Git from the inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out) **(GIT desde el interior)**. De hecho me gustó tanto que me he tomado la libertad de traducirlo y crear esta versión a medida con mis propias palabras. Por supuesto todo el crédito va para su Autora [Mary Rose Cook](https://maryrosecook.com), muchas gracias desde aquí!.

<br/>

---

<br/>

## GIT desde el interior

Este apunte explica cómo funciona y asume que has dedicado algo de tiempo a entender más o menos de qué va y quieres usarlo para el control de versiones de tus proyectos. Puede ser fácil pero hay que dedicarle algo de tiempo.

Supera a otras herramientas de control de versiones (SCM-Source code management) como Subversion, CVS, Perforce y ClearCase por sus características como la **ramificación local (ramas/branches)**, las **áreas de preparación (staging)** y los **múltiples flujos de trabajo**.

El apunte se centra en la estructura de grafos que sustenta a Git y en la forma en que
sus propiedades dictan su comportamiento. Vas a ver una serie de comandos Git ejecutados en un único proyecto, con observaciones sobre la estructura gráfica para ilustrar una propiedad
y el resultado que produce.

<br/>

### Creación de un proyecto

Empezamos directamente en la línea de comandos, con la creación de un proyecto. Cada proyecto debe estar en un directorio distinto.

```zsh
➜  ~ > clear
➜  ~ > mkdir alpha
```

Creamos el directorio `alpha` para contener el proyecto. 

```zsh
➜  ~ > cd alpha
➜  alpha > mkdir data
➜  alpha > echo 'a' > data/letter.txt
```

Cambiamos al directorio `alpha` y creamos un directorio llamado "data" con un archivo
llamado `letter.txt` que contiene el caracter `a`, quedará con este aspecto:

```zsh
alpha
└── data
    └── letter.txt        <- Contiene la letra 'a'
```

<br/>

### Inicializamos el repositorio

Un **repositorio GIT** es una carpeta dedicada dentro de tu proyecto (directorio). Este repositorio es local y contendrá todos los archivos que queremos 'versionar'.


```zsh
➜  alpha > git init
Initialized empty Git repository
```

El comando `git init` crea el subdirectorio `.git` con una estructura inicial, formándose así un nuevo repositorio local, definiendo la configuración de Git y la historia del proyecto. Son archivos ordinarios, sin ninguna magia, el usuario puede leerlos y editarlos con un editor de texto o un shell. 

El directorio `alpha` tiene ahora este aspecto:


| ![Estructura de un proyecto con GIT](/assets/img/git/0-project.png) | 
|:--:| 
| *Estructura de un proyecto con GIT* |


Lo que hay dentro de `.git` es propiedad de GIT (ahí van a estar todas las versiones del proyecto y todo dentro de él se manipula usando el comando). El resto de ficheros (fuera de .git) se han convertido en la que GIT llama la COPIA DE TRABAJO (WORKING COPY) y son propiedad del usuario.

<br/>

### Añadimos algunos ficheros

Nuestro repositorio local empieza vacío (excepto los ficheros mínimos que vimos antes). Vamos a empezar a pasarle ficheros, es decir, vamos a <ins>añadir ficheros **a GIT!!!**</ins> desde la Working Copy.

<br/>

**Añadimos el fichero letter.txt a GIT**

```zsh
➜  alpha git:(master) ✗ > git add data/letter.txt
```

Ejecutar `git add` sobre `data/letter.txt` tiene dos efectos

<br/>

**PRIMERO**, se crea un fichero "blob" (binary large object) en el directorio `.git/objects/`. Se trata del contenido comprimido de `data/letter.txt` (lo comprime con zlib). El nombre del fichero blob se fabrica con el resultado de hacer un `hash` de tipo SHA-1 sobre su contenido. Hacer un `hash` de un fichero significa ejecutar un programa que lo convierte en un trozo de texto más pequeño [^1] (40bytes) que identifica de forma exclusiva [^2] al original. 

El fichero se sitúa en una subcarpeta con los primeros 2 caracteres de su nombre (`.git/objects/2e/`) y dentro de dicha carpeta está el fichero, con un nombre con el resto de los 38 caracteres, con todo el contenido dentro en formato comprimido.

```zsh
alpha
├── .git
:   :
│   ├── objects
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e    <- versión comprimida de letter.txt con a
```

Fíjate en que al añadir un archivo a Git se guarda su contenido en el directorio directorio `objects`, por lo tanto podrías incluso borrarlo de tu "WORKING COPY" `data/carta.txt`.

<br/>

**SEGUNDO**, `git add` añade el archivo al índice `.git/index`. El índice es una lista que contiene todos los archivos a los que hemos pedido hacer seguimiento/rastreo.

El índice se utiliza para controlar quién está en el área de espera (stage) entre tu directorio de trabajo y la confirmación (commit). Puedes usar el índice para construir un conjunto de cambios que más adelante quieras confirmar (commit). Cuando hagas la confirmación (commit), lo que se confirma es lo que está actualmente en el índice, no lo que está en tu directorio de trabajo.

En cada línea del archivo índice (`.git/index`) tienes un archivo rastreado, con la información del hash de su contenido. Así que ahora nuestro indice es así: 

````zsh
➜  ~ > cat alpha/.git/index
DIRC`~ٳ���`~ٳ���	��}���.e��Eݧ�Q�t��H�u.data/letter.txt���;V��JަI�(7/7�%
````

¿Pero qué es eso?. recuerda con los ficheros se guardan como blobs, en formato binario, no puedes verlos como ficheros de texto, hay que usar otro tipo de comandos para ver su contenido. 

```zsh
➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt

➜  alpha git:(master) ✗ > git status
:
Changes to be committed:
:
	new file:   data/letter.txt
```

<br/>

**Creamos un segundo fichero, number.txt**

Creamos un fichero llamado `data/number.txt` con un contenido `1234`.

```
➜  alpha git:(master) ✗ > echo 1234 > data/number.txt
```

El WORKING COPY contiene lo siguiente: 

```zsh
alpha
└── data
    ├── letter.txt
    └── number.txt
```

<br/>

**Añadimos el fichero number.txt a GIT**

El suuario añade el fichero `number.txt` a GIT

```zsh
➜  alpha git:(master) ✗ > git add data
```

Como vimos antes, de nuevo, el comando `git add` crea un objeto blob que contiene el contenido de `data/number.txt`. Añade una entrada de índice para `datos/número.txt` que apunta al blob. Este es el nuevo contenido del índice:


```zsh
➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt
100644 274c0052dd5408f8ae2bc8440029ff67d79bc5c3 0	data/number.txt
```

Observa que sólo los archivos del directorio `data` aparecen en el índice, aunque el usuario haya ejecutado `git add data` el directorio `data` no aparece por ningún sitio... paciencia.

Vamos a hacer un pequeño cambio. Cuando el usuario creó originalmente `datos/número.txt`, quería escribir `1`, no `1234`. 

```zsh
➜  alpha git:(master) ✗ > echo '1' > data/number.txt
```

Añadimos de nuevo `number.txt` a Git.

```zsh
➜  alpha git:(master) ✗ > git add data
```

Fíjate que tenemos 3 blobs... ¿podrías decirme porqué?. 

```zsh
alpha
├── .git
│   ├── objects
│   │   ├── 27
│   │   │   └── 4c0052dd5408f8ae2bc8440029ff67d79bc5c3    <- number.txt con 1234
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e    <- letter.txt con a
│   │   ├── 56
│   │   │   └── a6051ca2b02b04ef92d5150c9ef600403cb1de    <- number.txt con 1
:
└── data
    ├── letter.txt
    └── number.txt
```

Además, en el índice solo aparecen dos ficheros ¿Podrías decirme porqué?

```zsh
➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt
100644 56a6051ca2b02b04ef92d5150c9ef600403cb1de 0	data/number.txt
```

Respuesta: 

Al cambiar `datos/número.txt` y hacer un `add` estamos añadiendo el "nuevo" archivo al índice, se crea un nuevo blob con el nuevo contenido y además actualiza la entrada del índice "datos/número.txt" para que **apunte al nuevo blob**. El indice en la zona de espera contiene un puntero a la última versión de cada archivo agregado.

<br/>

### Hacemos un COMMIT (Confirmamos)

Recuerda que `git commit` trabaja en tu repositorio local (no en GitHub). Hacer un commit consiste en "confirmar" lo que tenemos en el STAGING AREA (área de espera) y lo lleva a tu repositorio local, **capturando una instantánea de los ficheros preparados en el área de espera** y guardándola como una versión. Las instantáneas confirmadas pueden considerarse como versiones "seguras" de un proyecto. Al hacer un commit es obligatorio describirlo con `-m "mensaje descriptivo sobre este commit"`.

En este tutorial aprovechamos el mensaje del commit como una nomenclatura sencilla para seguir mejor el tutorial. A este primer commit lo llamaremos `a1`. 

El usuario hace el commit `a1`. Git imprime algunos datos sobre la confirmación. Estos datos tendrán sentido en breve.


```zsh
➜  alpha git:(master) ✗ > git commit -m 'a1'
[master (root-commit) 8c80d78] a1
 2 files changed, 2 insertions(+)
 create mode 100644 data/letter.txt
 create mode 100644 data/number.txt
```

<br/>

## Los tres pasos de un "Commit"

Cuando haces un commit ocurren tres cosas (más info [aquí](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)): 

* Se crea un **"tree graph"** representando los directorios y ficheros afectados. En este ejemplo que nos ocupa vemos que se crean dos objetos de tipo `tree` vinculados a dos objetos ya existentes de tipo `blob`. 
* Se crea un **objeto commit** con tocda la información sobre el mismo, el autor, el committer, el comentario y por último el puntero al objeto `tree` raíz del "tree graph"
* Se conecta la **rama actual** (branch) para que **apunte al dicho objeto commit** que se ha creado

```zsh
│   ├── objects
│   │   ├── 0e
│   │   │   └── ed12..0b74    <- nuevo: TREE  >--------+  <-+
│   │   ├── 27                                         |    |
│   │   │   └── 4c00..c5c3    <- number.txt con 1234 <-+    |
│   │   ├── 2e                                         |    |
│   │   │   └── 65ef..752e    <- letter.txt con a      |    |
│   │   ├── 56                                         |    |
│   │   │   └── a605..b1de    <- number.txt con 1 <----+    |
│   │   ├── 8c                                              |
│   │   │   └── 80d7..784c    <- nuevo: COMMIT >--+         |
│   │   ├── ff                                    |         |
│   │   │   └── e298..6db4    <- nuevo: TREE <----+ -(data)-+
```

<br/>

#### Se crea el "tree graph"

Git registra el estado actual del proyecto creando un árbol virtual a partir del índice. Este árbol se denomina el "tree graph" y contiene la información necesaria sobre la ubicación y contenido de los punteros (objetos `tree`) y los archivos (objetos `blob`). Por lo tanto, el "tree graph" se compone de dos tipos de objetos: 

* Los blobs, que son los archivos que habíamos añadido con `git add` 
* Los trees, se usan para apuntar a otros objetos (por ejemplo los subdirectorios que contienen archivos)

Veamos uno de los objetos `tree` que se ha creado: `0eed...`. Este fichero contiene un puntero a los archivos dentro del directorio `data`:

```zsh
➜  alpha git:(master) > git --no-pager show 0eed
tree 0eed

letter.txt
number.txt
```

```
➜  alpha git:(master) > git --no-pager cat-file -p 0eed
100644 blob 2e65efe2a145dda7ee51d1741299f848e5bf752e	letter.txt  <- contiene 'a'
100644 blob 56a6051ca2b02b04ef92d5150c9ef600403cb1de	number.txt  <- contiene '1'
```

La primera línea registra todo lo necesario para reproducir `data/letter.txt`: los permisos del archivo, su tipo (blob), el hash del fichero y el nombre del archivo. La segunda línea lo mismo para reproducir `data/number.txt`.

<br/>

Veamos el otro puntero `tree`: `ffe2...`. Es el del directorio raíz del proyecto (`alpha`), por lo tanto contiene la el puntero al objeto anterior (el que apunta a `data`), el otro objeto de tipo tree que se acababa de crear, `0eed`.


```zsh
➜  alpha git:(master) > git --no-pager show  ffe2
tree ffe2

data/
```

```zsh
➜  alpha git:(master) > git --no-pager cat-file -p ffe2
040000 tree 0eed1217a2947f4930583229987d90fe5e8e0b74	data
```

Tiene una línea apuntando al directorio `data`. Contiene el valor 040000 (tipoe directorio), el tipo (tree), el hash del objeto tree que vimos antes y el nombre del directorio `data`.

<br/>

| ![Tree graph del primer commit](/assets/img/git/1-a1-tree-graph.png) | 
|:--:| 
| *Tree graph del primer commit* |


Lo mismo visto gráficamente nos muestra cómo el objeto tree `raíz (root)` apunta al objeto tree `data` que apunta a los dos objetos blobs `data/letter.txt` y `datos/número.txt`.

<br/>

#### Se crea el objeto Commit

Además de los dos objetos (ficheros) `tree` que componen el tree graph, se ha creado un nuevo objeto (fichero) de tipo `commit` que también se guarda en `.git/objects/`:

```zsh
➜  alpha git:(master) > git --no-pager cat-file -p 8c80
tree ffe298c3ce8bb07326f888907996eaa48d266db4
author Luis Palacios <luis@mail.com> 1618933917 +0200
committer Luis Palacios <luis@mail.com> 1618933917 +0200

a1
```

La primera línea apunta al inicio del `tree graph`, al objeto raíz `raíz (root)` de la working copy, es decir, el directorio `alpha`. La última línea es el mensaje del commit. 

<br/>

| ![Commit a1 apuntando a su tree graph](/assets/img/git/2-a1-commit.png) | 
|:--:| 
| *Commit `a1` apuntando a la raíz `root` de su tree graph* |

<br/>

#### Se conecta la rama actual con el commit

La tercera acción consiste en conectar la rama actual con el objeto commit recién creado. GIT tiene el nombre de la rama actual en el archivo `.git/HEAD`:


```zsh
➜  alpha git:(master) ✗ cat .git/HEAD
ref: refs/heads/master
```

Vemos que `HEAD` (una referencia) está apuntando a `master` (otra referencia), por lo tanto `master` es la rama actual. Las referencias son etiquetas utilizada por Git o por el usuario para identificar un commit. El archivo que representa la referencia `master` debe contener un puntero al hash del commit (`8c80`) y dicha conexión se crea en el archivo `.git/refs/heads/master`

```
➜  alpha git:(master) ✗ cat .git/refs/heads/master
8c80d787e43ca98d7a3f8465a5f323684899784c
```

(No lo he dicho antes, pero todos ciertos HASHs que estás viendo no van a coincidir con los tuyos, los objetos con contenido como los blobs y los tress siempre hacen un hash al mismo valor, pero los commits cambian porque contienen fechas y nombres distintos)

Ahora que tenemos todo conectado vamos a añadir `HEAD` y `master` a nuestro gráfico: 

<br/>

| ![\`master\` apunta al commit \`a1\`](/assets/img/git/3-a1-refs.png) | 
|:--:| 
| *`HEAD` apunta a `master` que apunta al commit `a1`* |

Ya tenemos todo conectado: `HEAD` apunta a `master` con un hash apuntando al `objeto commit`, que apunta al objeto `root` (alpha) que a su vez apunta a `data` que apunta a `letter.txt`y `number.txt`.

<br/>

## Hacemo un commit adicional

Ahora vamos a ver qué pasa cuando se hace un commit que no es el primer commit.

Nos fijamos en la siguiente gráfica que muestra el estado después del primer commit `a1`. Enseño a la derecha a quién apunta el índice y a la izquierda cual es el contenido de la working copy (qué hay actualmente fuera de Git, en el directorio de trabajo)

<br/>

| ![a1 con la working copy y el índice](/assets/img/git/4-a1-wc-and-index.png) | 
|:--:| 
| *`a1` con la working copy y el `indice`* |

Fíjate que los ficheros que están en la copia de trabajo y los blob's que se apuntan desde el índice y los que se apuntan desde el commit `a1` apuntan todos a ficheros que tienen exáctamente el mismo contenido (los diferentes `data/letter.txt` y `data/number.txt` comparten contenido). Pero son ficheros disntintos. El índice y el commit `HEAD` utilizan hashes para referirse a los objetos blob pero el contenido de la copia de trabajo se almacena como texto en un lugar distinto (fuera de .git)

Vamos a cambiar una cosilla... vamos a cambiar el contenido del fichero number.txt con un '2'.

```
➜  alpha git:(master) > echo 2 > data/number.txt
```

Esto ocurre en la working copy, pero se deja el índice y el commit (`HEAD`) intactos. 

<br/>

| ![cambiamos number.txt con un `2`](/assets/img/git/5-a1-wc-number-set-to-2.png) | 
|:--:| 
| *cambiamos number.txt con un `2` en la working copy* |

A continuación "añado" este fichero a la zona de espera (stagin area) o "índice", por lo tanto se añade un nuevo blob que contiene un `2` al directorio `.git/objects/` y además la entrada del índice apunta a este nuevo blob.


```
➜  alpha git:(master) ✗ > git add data/number.txt
```

Lo que ha ocurrido es lo siguiente: number.txt tiene un `2` en la working copy y en el índice (zona de espera)

| ![number.txt con un `2` en la working copy y en el índice](/assets/img/git/6-a1-wc-and-index-number-set-to-2.png) | 
|:--:| 
| *number.txt con un `2` en la working copy y en el índice* |

Ejecuto el segundo commit. 

```
➜  alpha git:(master) ✗ > git commit -m 'a2'
[master 850918e] a2
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Al hacer el commit los pasos son los mismos que la vez anteriore. 

**Primero** se crea un NUEVO TREE GRAPH para representar el contenido del índice. Un nuevo BLOB para el tree `data` (porque `data/number.txt` ha cambiado el tree antigo ya nos nos vale)

```
➜  alpha git:(master) >  git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt <-- reutiliza blob. Contiene 'a'
100644 0cfbf08886fca9a91cb753ec8734c84fcbe52c9f 0	data/number.txt <== nuevo blob, contiene '2'
```

Un segundo BLOB nuevo para `root` que apunte al nuevo blob de `data` recién creado

```
➜  alpha git:(master) > git --no-pager cat-file -p fbfd
040000 tree b580fd166d4b75627577d2632ca7d806e07639d8	data
```

**Segundo**, se crea un nuevo objeto commit. 

```
➜  alpha git:(master) > git --no-pager cat-file -p 8509
tree fbfdfef0e0ad86ff61aedcc0a0d5643f7a54fea6
parent 8c80d787e43ca98d7a3f8465a5f323684899784c
author Luis Palacios <luis.palacios.derqui@gmail.com> 1619459710 +0200
committer Luis Palacios <luis.palacios.derqui@gmail.com> 1619459710 +0200
a2
```

La primera línea del commit apunta al nuevo objeto tree `root`, la segunda línea apunta al commit anterior `a1` (para poder encontrar el commit padre GIT se fue a `HEAD` y lo siguió hasta que dió con el hash del commit de `a1`)

**Tercero**, el contenido de la rama (brancho) `master` pasa a apuntar al hash del nuevo commit (`a2`)

<br/>

| ![commit `a2`](/assets/img/git/7-a2.png) | 
|:--:| 
| *commit `a2`* |

Veamos la gráfica sin reflejar los datos de los ficheros: 

<br/>

| ![sin la working copy y el índice](/assets/img/git/8-a2-just-objects-commits-and-refs.png) | 
|:--:| 
| *commit `a2` (sin la información de su contenido)* |


<br/>

#### Características de los tree graphs 

Veamos algunos conceptos interesantes respecto a los árboles dentro del directorio `objects/`

* El contenido se almacena como un árbol de objetos. Esto significa que en la base de datos de objetos sólo se almacenan las diferencias. Observa el gráfico de arriba. El commit `a2` reutiliza el blob `letter.txt con 'a'` que se hizo antes del commit `a1`. Del mismo modo, si un directorio completo no cambia de un commit a otro, su árbol y todos los blobs y árboles por debajo se reutilizan. Generalmente, hay pocos cambios de contenido entre commits, por lo que GIT puede almacenar grandes historiales de commits ahorrando mucho espacio. 

* Cada commit tiene un padre. Esto significa que un repositorio puede almacenar la historia completa de las modificaciones y versiones que ha tenido un proyecto.

* Las referencias son puntos de entrada a una parte del historial de commits. Esto significa que los commits pueden tener nombres significativos que nos digan algo interesante. El usuario organiza su trabajo en linajes que son significativos para su proyecto con referencias concretas como
`fijo-para-el-bug-376`. Git se reserva y emplea referencias simbólicas como `HEAD`, `MERGE_HEAD` y `FETCH_HEAD` para soportar comandos que manipulan el historial de confirmaciones.

* Los nodos en el directorio `objects/` son inmutables. Esto significa que el contenido se edita, no se borra. Cada objeto que se ha añadido y cada confirmación que se ha hecho está en algún lugar del directorio `objects` [^3].


* Las referencias son mutables. Por lo tanto, el significado de una ref puede cambiar. El commit al que apunta `master` puede estar apuntando a una versión del proyecto ahora pero apuntar a otra dentro de un rato. 

<br/>

#### Características de moverse por la historia

Veamos algunos conceptos interesantes respecto a la facilidad o dificultad de recuperar un determinado commit (ir a esa versión) que también podemos describir como "acceder a un momento en el tiempo" o moverse por la historia del proyecto.

* La copia de trabajo y los commits a los que apuntan las referencias (`refs`) están fácilmente disponibles, pero otros commits (sin referencias) no lo están. Esto significa que la historia reciente es más fácil de recuperar.

* La copia de trabajo es el punto de la historia más fácil de recuperar porque está en la raíz de tu directorio del proyecto. Acceder a la working copy ni siquiera requiere un comando Git. También es el punto menos permanente del historial. El usuario puede hacer una docena de versiones de un archivo que Git no registrará ninguna a menos que que se le añadan.

* El commit al que apunta `HEAD` es muy fácil de recuperar. Normalmente apunta a la punta de la rama que se ha extraido (checkout). Si hemos modificado algo en la working copy y queremos volver a la versíon de `HEAD` el usuario puede hacer un `git stash` (esconder la modificación en la working copy [^4]), examina lo que tenía y luego hace un `git stash pop` para volver a la versión de la copia de trabajo. Al mismo tiempo, `HEAD` es la referencia que cambia con más frecuencia.

* El commit al que apunta una `ref` (referencia) concreta es fácil de recuperar. El usuario puede simplemente hacer un checkout de esa rama. La punta de una rama cambia con menos frecuencia que `HEAD`, pero con la suficiente frecuencia como para que tuviese sentido asignarle un nombre en su momento.

* Es difícil recordar un commit que no esté señalado por ninguna `ref`, cuanto más se aleje el usuario de una referencia, más difícil le resultará reconstruir el significado de un commit (¿porqué hice aquel commit en su momento?). Por otro lado, cuanto más se remonte, menos probable es que alguien haya cambiado la historia desde la última vez que miró [^5].


<br/>

## Hacer un "checkout" de un commit

El comando `git checkout` puede usarse para cambiarse a una rama o para irse a un commit concreto. Veamos un ejemplo de esto último, vamos a hacer un checkout a un commit concreto.

De hecho vamos a hacer un checkout al commit en el que estamos. Ahora mismo tu `HEAD` está apuntando a través de `master` al commit `a2` y vamos a hacer un checkout de `a2`. Realmente no tiene ningún sentido práctico pero lo hacemos para formarnos y aprender cual es la implicación. 

<br/>

```zsh
➜  alpha git:(master) > git checkout 850918   <-- Este es el hash del commit `a2`
Note: switching to '850918'.
You are in 'detached HEAD' state...
HEAD is now at 850918e a2
```

<br/>

Hemos hecho un checkout thel commit `a2` **utilizando su hash**. Nota: Si estás siguiendo este tutorial debes mirar cual es el hash de tu commit `a2`, usa el comando `git log`. Este checkout provoca que ocurran cuatro cosas: 

- **1**. Git obtiene el commit `a2` y el tree graph (árbol) al que apunta.
- **2**. Saca los archivos que hay en el tree graph y los copia a la working copy (directorio de trabajo) fuera de `.git/`. En nuestro caso no hay ningún cambio porque como decía ya teníamos ese contenido, recuerda que 
`HEAD` ya estaba apuntando a través de `master` al commit `a2`. 
- **3**. GIT escribe las entradas de los archivos del tree graph en el índice. Una vez más, ningún cambio, el índice ya tiene el contenido del commit `a2`.
- **4**. El contenido de `HEAD` se establece en el hash del commit `a2`.

<br/>

```zsh
➜  alpha git:(850918e) > cat .git/HEAD
850918e87cb094f6f01f73d971619ed79f8cfb43
```

<br/>

Aquí está la diferencia. Cuando el contenido de `HEAD` contiene el hash de un commit vs referencia a la rama, lo que hace es poner al repositorio en el estado de `detached HEAD` (HEAD separado). Observe en el gráfico de abajo que `HEAD` apunta directamente a la confirmación a2, en lugar de apuntar a `master`

<br/>

| ![Detached HEAD apuntando al commit `a2`](/assets/img/git/9-a2-detached-head.png) | 
|:--:| 
| *Detached HEAD apuntando al commit `a2`* |

<br/>

Si ahora tocamos la working copy, por ejemplo cambiamos `number.txt`, le ponemos un `3` y hacemos un commit...

```zsh
➜  alpha git:(850918e) > echo 3 > data/number.txt
➜  alpha git:(850918e) ✗ > git add data/number.txt
➜  alpha git:(850918e) ✗ > git commit -m 'a3'
[detached HEAD 92ffe65] a3
 1 file changed, 1 insertion(+), 1 deletion(-)
```

<br/>

GIT se va a `HEAD` para obtener el que sería el padre del commit y lo que se encuentra  y devuelve es el hash al commit `a2`. Actualiza `HEAD` para que apunte directamente al hash del nuevo commit `a3`. Pero el repositorio sigue en el estado de `detached HEAD`. No estamos en una rama porque ningún commit apunta a `a3` o sus futuros descencientes, por lo que sería fácil perderlos.

A partir de ahora, voy a omitir los `tree` y `blob` en la mayoría de los diagramas gráficos para simplificar.


| ![Commit `a3` que NO está en ninguna rama (branch)](/assets/img/git/10-a3-detached-head.png) | 
|:--:| 
| *HEAD apunta al commit `a3` que NO está en ninguna rama (branch)* |

<br/>

## Crear una rama (branch)

Creamos una nueva rama llamada `deputy`. Lo que ocurre es que simplemente se crea un nuevo archivo en `.git/refs/heads/deputy` que contiene el hash al que apunta `HEAD`, en este caso el hash del commit `a3`.


```zsh
➜  alpha git:(92ffe65) > git branch deputy
```

Nota: Las ramas (branches) no son más que `refs` (referencias) y las referencias no son más que ficheros, hace que GIT sea ligero. 

La creación La creación de la rama `deputy` pone al commit `a3` de forma segura en una rama, pero ojo porque la rama `HEAD` sigue estando separada porque sigue apuntando directamente a un commit.



| ![Commit `a3` ahora en rama `deputy`](/assets/img/git/11-a3-on-deputy.png) | 
|:--:| 
| *El commit `a3` ahora está en la rama `deputy`* |

<br/>

## Checkout de una rama (branch)

Vamos a ver qué pasa si le pedimos a GIT que haga un checkout de la rama `master`.

```
➜  alpha git:(92ffe65) > git checkout master
Previous HEAD position was 92ffe65 a3
Switched to branch 'master'
➜  alpha git:(master) >
```

Primero, GIT consigue el commit `a2` al que apunta `master` y por tanto consigue el tree graph (recuerda, estructura de subdirectorios y archivos) de dicho commit.

En segundo lugar, GIT saca los archivos desde el tree graph y los copia a la working copy (desde `.git`). Eso provoca que el contenido en la working copy de `data/number.txt` pase de ser `3` a `2`.

En tercer lugar, Git escribe las entradas de los archivos en el tree graph en el índice. Esto actualiza la entrada de `datos/número.txt` con el hash del blob `2`

Cuarto, GIT hace que `HEAD` apunte a `master`, cambiando su contenido desde el hash anterior a `refs/heads/master`.

<br/>

```
➜  alpha git:(master) > cat .git/HEAD
ref: refs/heads/master
```

<br/>

| ![Checkout de `master` que apuntaba a `a2`](/assets/img/git/12-a3-on-master-on-a2.png) | 
|:--:| 
| *Checkout de `master` que apuntaba a `a2`* |

<br/>

## Checkout de rama incompatible

Vamos a ver un caso curioso, hacer un **checkout de una rama que es incompatible con nuestra working copy**. Si intentamos introducir los comandos siguientes, GIT nos avisa de una incompatibilidad y aborta el checkout.

```
➜  alpha git:(master) > echo '789' > data/number.txt

➜  alpha git:(master) ✗ > git checkout deputy
error: Your local changes to the following files would be overwritten by checkout:
	data/number.txt
Please commit your changes or stash them before you switch branches.
Aborting
➜  alpha git:(master) ✗ >
```

<br/>

Hemos modificado el contenido de `data/number.txt` con `789` y después intentado hacer un checkout de la rama `deputy`. Git aborta este último para evitar que perdamos dicho cambioen `number.txt`en nuestra copia local. 

`HEAD` apunta al `master` que apunta a `a2` donde `data/number.txt` contiene un `2`. La rama `deputy` apunta a `a3` donde `data/number.txt` contiene un `3`. La copia de trabajo tiene `data/number.txt` con `789`. Todas estas versiones son diferentes y las diferencias deben ser resueltas.

GIT podría haber ignorado el rpoblema pero está diseñado para evitar la pérdida de datos. Otra opción es que GIT hubiese fusionado la copy version con la versión de `deputy`, pero sería un poco chapuza, así que aborta...

El usuario se da cuenta que no quería dicha modificación, vuelve a poner el contenido original e intenta cambiarse a la rama `deputy`.

```
➜  alpha git:(master) ✗ > echo '2' > data/number.txt
➜  alpha git:(master) > git checkout deputy
Switched to branch 'deputy'
➜  alpha git:(deputy) >
```

Ahora sí que funciona, no hay nada que se vaya a perder, por lo tanto GIT acepta el checkout de `deputy` y cambia al mismo, lo extrae, lo copia a la workign copy y hace que `HEAD`a punte a él.

<br/>

| ![Checkout de `deputy`](/assets/img/git/13-a3ondeputy.png) | 
|:--:| 
| *Checkout de `deputy`* |

<br/>

## Merge de un antepasado

Vamos a adentrarnos en una de las funciones más interesantes de GIT, el poder "fusionar" datos entre commits. 

Si recordamos, eshemos extraído la rama `deputy`, nos encontramos en ella. Vamos a ver qué pasa si le pedimos a GIT que se traiga y fusione los datos de `master` en esta rama en la que estoy (`deputy`). 

```
➜  alpha git:(deputy) > git merge master
Already up to date.
```

El intento consiste en hacer una fusión (merge) de `master` dentro de `deputy`. El merge de dos ramas significa fusionar dos commits. El primer commit **receptor** es siempre en el que nos encontramos (`deputy`). El segundo commit es el **emisor**, aquel que indicamos en el comando git merge (`master`). En resumen, pedimos que el contenido de `master` se fusione dentro de `deputy`. 

En este caso GIT no hace nada, nos dice `Already up-to-date.`.

Los commits del gráfico se interpretan como una serie de cambios realizados en el contenido del repositorio. Esto significa que, durante una fusión, si el commit emisor (dador) es un antepasado del commit receptor, GIT no hará nada. Dicho de otra forma, el commit de `deputy` venía desde `master (a2)`. Significa que nació desde `a2` y por lo tanto no necesita que le incorporemos nada, porque no hay nada nuevo a incorporar. 

<br/>

## Merge de un descendiente

¿Pero qué pasa si intentamos hacer lo contrario?. Vámonos a la otra rama, cambiamos a `master`.

```zsh
➜  alpha git:(deputy) > git checkout master
Switched to branch 'master'
➜  alpha git:(master) >
```

<br/>

| ![Checkout de `msater` que apunta al commit `a2`](/assets/img/git/14-a3-on-master-on-a2.png) | 
|:--:| 
| *Checkout de `msater` que apunta al commit `a2`* |

<br/>

Intentamos fusionar pero ahora desde `deputy` dentro de `master`. El primer commit **receptor** es en el que nos encontramos (ahora es `mnsater`). El segundo commit es el **emisor**, aquel que indicamos en el comando git merge (`deputy`). En resumen, pedimos que el contenido de `deputy` se fusione dentro de `master`. 

```zsh
➜  alpha git:(master) > git merge deputy
Updating 850918e..92ffe65
Fast-forward
 data/number.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(master) >
```

Se hace una fusión de `deputy` en `master`. GIT se da cuenta de que el **commit receptor**, `a2`, es más viejo qu e el **commit emisor**, `a3`, por lo tanto acepta la fusión, y provoca el `fast-forward merge` (fast-forward significa que lo adelanta en el tiempo, hace que `a2` se ponga a la altura temporal de `a3` con las modificaciones que este hubiese realizado posteriormente). Tan sencillo como que ahora `master` apunta a `a3`: Obtiene el commit del emisor (dador) y el tree graph al que apunta. Se sacan y escriben las entradas de los archivos desde el tree graph, se copian al working copy y al índice y se hace que `master` se "adelante" aapuntando a `a3`.


| ![El commit `a3` de `deputy` se fusiona en `master` con un fast-forward](/assets/img/git/15-a3-on-master.png) | 
|:--:| 
| *El commit `a3` de `deputy` se fusiona en `master` con un fast-forward* |

<br/>

Las series de commits en el gráfico se interpretan
como una serie de cambios realizados en el contenido del repositorio. Esto significa
que, en una fusión, si el dador es un descendiente del receptor, la historia
no se modifica. Ya existe una secuencia de commits que describen el
cambio a realizar: la secuencia de commits entre el receptor y el
dador. Pero, aunque el historial de Git no cambia, el gráfico de Git sí
cambia. La referencia concreta a la que apunta `HEAD` se
se actualiza para apuntar al commit del dador (en este caso `a3`).

<br/>

## Merge desde linajes distintos

Vamos a ver otro caso, ahora vamos a intentar hacer una fusión de dos commits que están en linajes distintos.  Empezamos preparando un nuevo commit, cambiamos a `4` el contenido de `number.txt` y hacemos un commit `a4` en `master`.

```zsh
➜  alpha git:(master) > echo '4' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ > git commit -m 'a4'
[master 3a8599e] a4
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(master) >
```

<br/>

Hacemos un checkout de `deputy`. Cambiamos el contenido de `data/letter.txt` a `b` y hacemos un commit `b3` en `deputy`.

```zsh
➜  alpha git:(master) > git checkout deputy
Switched to branch 'deputy'
➜  alpha git:(deputy) > echo 'b' > data/letter.txt
➜  alpha git:(deputy) ✗ > git add data/letter.txt
➜  alpha git:(deputy) ✗ > git commit -m 'b3'
[deputy ce860c7] b3
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(deputy) >
```

<br/>

| ![commit `a4` en master y `b3` en deputy, checkout de `deputy`](/assets/img/git/16-a4-b3-on-deputy.png) | 
|:--:| 
| *commit `a4` en master y `b3` en deputy, checkout de `deputy`* |

<br/>

Fíjate que ambos commits (`a4` y `b3`) parten del contenido del commit padre `a3`, por lo tanto: 

- Los commits pueden compartir "padres". Eso significa que los nuevos linajes se crearon desde la misma historio (en este caso partían desde `a3`)

- Los commits pueden tener múltiples padres. Esto significa que linajes separados pueden ser fusionados en un nuevo commit con dos padres con el comando `commit merge`

Dicho de otra forma, si no hay conflicto (modificar mismo fichero) en ambos linajes, debería ser realtivamente sencillo fusionar ambos contenidos y crear un nuevo commit. Veamos cómo !! 


```
➜  alpha git:(deputy) > git merge master -m 'b4'
Merge made by the 'recursive' strategy.
 data/number.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(deputy) >
```

Recordamos, el primer commit **receptor** es siempre en el que nos encontramos (`deputy`). El segundo commit es el **emisor**, aquel que indicamos en el comando git merge (`master`). 

En resumen, estamos pidiendo que el contenido de `master` (`a4`) se fusione dentro de `deputy` (`b3`). GIT descubre que están en linajes diferentes y ejecuta el merge siguiendo una estrategia "recursiva" que consiste en ocho pasos. 

<br/>

**Paso #1**: Git writes the hash of the giver commit to a file at
`alpha/.git/MERGE_HEAD`. The presence of this file
tells Git it is in the middle of merging.

<br/>

**Paso #2**: Git finds the base commit: the most recent ancestor that the
receiver and giver commits have in common.

| ![`a3` es el commit base de `a4` y `b3`](/assets/img/git/17-a4-b3-on-deputy.png) | 
|:--:| 
| *`a3` es el commit base de `a4` y `b3`* |


**Graph property**: commits have parents. This means that it is possible
to find the point at which two lineages diverged. Git traces backwards
from `b3` to find all its ancestors and backwards
from `a4` to find all its ancestors. It finds the
most recent ancestor shared by both lineages, `a3`.
This is the base commit.

<br/>

**Paso #3**: Git generates the indices for the base, receiver and giver
commits from their tree graphs.

<br/>

**Paso #4**: Git generates a diff that combines the changes made to the base
by the receiver commit and the giver commit. This diff is a list of file
paths that point to a change: add, remove, modify or conflict.

Git gets the list of all the files that appear in the base, receiver or
giver indices. For each one, it compares the index entries to decide the
change to make to the file. It writes a corresponding entry to the diff.
In this case, the diff has two entries.

The first entry is for `data/letter.txt`. The
content of this file is `a` in the base,
`b` in the receiver and `a` in
the giver. The content is different in the base and receiver. But it is
the same in the base and giver. Git sees that the content was modified
by the receiver, but not the giver. The diff entry for
`data/letter.txt` is a modification, not a conflict.

The second entry in the diff is for
`data/number.txt`. In this case, the content is the
same in the base and receiver, and different in the giver. The diff
entry for `data/letter.txt` is also a modification.

**Graph property**: it is possible to find the base commit of a merge.
This means that, if a file has changed from the base in just the
receiver or giver, Git can automatically resolve the merge of that file.
This reduces the work the user must do.

<br/>

**Paso #5**: the changes indicated by the entries in the diff are applied to
the working copy. The content of `data/letter.txt`
is set to `b` and the content of
`data/number.txt` is set to `4`.

<br/>

**Paso #6**: the changes indicated by the entries in the diff are applied to
the index. The entry for `data/letter.txt` is
pointed at the `b` blob and the entry for
`data/number.txt` is pointed at the
`4` blob.


<br/>

**Paso #7**: the updated index is committed:

```
    tree 20294508aea3fb6f05fcc49adaecc2e6d60f7e7d
    parent 982dffb20f8d6a25a8554cc8d765fb9f3ff1333b
    parent 7b7bd9a5253f47360d5787095afc5ba56591bfe7
    author Mary Rose Cook <mary@maryrosecook.com> 1425596551 -0500
    committer Mary Rose Cook <mary@maryrosecook.com> 1425596551 -0500

    b4
```

Notice that the commit has two parents.


<br/>

**Paso #8**: Git points the current branch, `deputy`, at
the new commit.


| ![`b4`: commit resultado de fusionar `a4` en `b3`](/assets/img/git/18-b4-on-deputy.png) | 
|:--:| 
| *`b4`: commit resultado de fusionar `a4` en `b3`* |

<br/>

## Merge desde dos linajes con conflicto.

Vamos a complicarlo un poco más, ahora vamos a intentar un merge desde dos commits de diferentes linajes donde ambos han modificado el mismo fichero. 


```
    ~/alpha $ git checkout master
              Switched to branch 'master'
    ~/alpha $ git merge deputy
              Fast-forward
```

The user checks out `master`. They merge
`deputy` into `master`. This
fast-forwards `master` to the
`b4` commit. `master` and
`deputy` now point at the same commit.

<br/>

| ![`deputy` merged into `master` to bring `master` up to the latest commit `b4`](/assets/img/git/19-b4-master-deputy-on-b4.png) | 
|:--:| 
| *`deputy` merged into `master` to bring `master` up to the latest commit `b4`* |

<br/>

```
    ~/alpha $ git checkout deputy
              Switched to branch 'deputy'
    ~/alpha $ echo '5' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m 'b5'
              [deputy bd797c2] b5
```

The user checks out `deputy`. They set the content
of `data/number.txt` to `5` and
commit the change to `deputy`.

```
    ~/alpha $ git checkout master
              Switched to branch 'master'
    ~/alpha $ echo '6' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m 'b6'
              [master 4c3ce18] b6
```

The user checks out `master`. They set the content
of `data/number.txt` to `6` and
commit the change to `master`.

<br/>

| ![`b5` commit on `deputy` and `b6` commit on `master`](/assets/img/git/20-b5-on-deputy-b6-on-master.png) | 
|:--:| 
| *`b5` commit on `deputy` and `b6` commit on `master`* |

<br/>

```
    ~/alpha $ git merge deputy
              CONFLICT in data/number.txt
              Automatic merge failed; fix conflicts and
              commit the result.
```

The user merges `deputy` into
`master`. There is a conflict and the merge is
paused. The process for a conflicted merge follows the same first six
steps as the process for an unconflicted merge: set
`.git/MERGE_HEAD`, find the base commit, generate
the indices of the base, receiver and giver commits, create a diff,
update the working copy and update the index. Because of the conflict,
the seventh commit step and eighth ref update step are never taken.
Let's go through the steps again and see what happens.

First, Git writes the hash of the giver commit to a file at
`.git/MERGE_HEAD`.

<br/>

| ![`MERGE_HEAD` written during merge of `b5` into `b6`](/assets/img/git/21-b6-on-master-with-merge-head.png) | 
|:--:| 
| *`MERGE_HEAD` written during merge of `b5` into `b6`* |

<br/>

Second, Git finds the base commit, `b4`.

Third, Git generates the indices for the base, receiver and giver
commits.

Fourth, Git generates a diff that combines the changes made to the base
by the receiver commit and the giver commit. This diff is a list of file
paths that point to a change: add, remove, modify or conflict.

In this case, the diff contains only one entry:
`data/number.txt`. The entry is marked as a conflict
because the content for `data/number.txt` is
different in the receiver, giver and base.

Fifth, the changes indicated by the entries in the diff are applied to
the working copy. For a conflicted area, Git writes both versions to the
file in the working copy. The content of
`data/number.txt` is set to:

```
    <<<<<<< HEAD
    6
    =======
    5
    >>>>>>> deputy
```

Sixth, the changes indicated by the entries in the diff are applied to
the index. Entries in the index are uniquely identified by a combination
of their file path and stage. The entry for an unconflicted file has a
stage of `0`. Before this merge, the index looked
like this, where the `0`s are stage values:

```
    0 data/letter.txt 63d8dbd40c23542e740659a7168a0ce3138ea748
    0 data/number.txt 62f9457511f879886bb7728c986fe10b0ece6bcb
```

After the merge diff is written to the index, the index looks like this:

```
    0 data/letter.txt 63d8dbd40c23542e740659a7168a0ce3138ea748
    1 data/number.txt bf0d87ab1b2b0ec1a11a3973d2845b42413d9767
    2 data/number.txt 62f9457511f879886bb7728c986fe10b0ece6bcb
    3 data/number.txt 7813681f5b41c028345ca62a2be376bae70b7f61
```

The entry for `data/letter.txt` at stage
`0` is the same as it was before the merge. The
entry for `data/number.txt` at stage
`0` is gone. There are three new entries in its
place. The entry for stage `1` has the hash of the
base `data/number.txt` content. The entry for stage
`2` has the hash of the receiver
`data/number.txt` content. The entry for stage
`3` has the hash of the giver
`data/number.txt` content. The presence of these
three entries tells Git that `data/number.txt` is in
conflict.

The merge pauses.

```
    ~/alpha $ echo '11' > data/number.txt
    ~/alpha $ git add data/number.txt
```

The user integrates the content of the two conflicting versions by
setting the content of `data/number.txt` to
`11`. They add the file to the index. Git adds a
blob containing `11`. Adding a conflicted file tells
Git that the conflict is resolved. Git removes the
`data/number.txt` entries for stages
`1`, `2` and
`3` from the index. It adds an entry for
`data/number.txt` at stage `0`
with the hash of the new blob. The index now reads:

```
    0 data/letter.txt 63d8dbd40c23542e740659a7168a0ce3138ea748
    0 data/number.txt 9d607966b721abde8931ddd052181fae905db503
```

```
    ~/alpha $ git commit -m 'b11'
              [master 251a513] b11
```

Seventh, the user commits. Git sees
`.git/MERGE_HEAD` in the repository, which tells it
that a merge is in progress. It checks the index and finds there are no
conflicts. It creates a new commit, `b11`, to record
the content of the resolved merge. It deletes the file at
`.git/MERGE_HEAD`. This completes the merge.

Eighth, Git points the current branch, `master`, at
the new commit.

<br/>

| ![`b11`, the merge commit resulting from the conflicted, recursive merge of `b5` into `b6`](/assets/img/git/22-b11-on-master.png) | 
|:--:| 
| *`b11`, the merge commit resulting from the conflicted, recursive merge of `b5` into `b6`* |

<br/>

## Remove a file

This diagram of the Git graph includes the commit history, the trees and
blobs for the latest commit, and the working copy and index:

<br/>

| ![The working copy, index, `b11` commit and its tree graph](/assets/img/git/23-b11-with-objects-wc-and-index.png) | 
|:--:| 
| *The working copy, index, `b11` commit and its tree graph* |

<br/>

```
    ~/alpha $ git rm data/letter.txt
              rm 'data/letter.txt'
```

The user tells Git to remove `data/letter.txt`. The
file is deleted from the working copy. The entry is deleted from the
index.

<br/>

| ![After `data/letter.txt` `rm`ed from working copy and index](/assets/img/git/24-b11-letter-removed-from-wc-and-index.png) | 
|:--:| 
| *After `data/letter.txt` `rm`ed from working copy and index* |

<br/>


```
    ~/alpha $ git commit -m '11'
              [master d14c7d2] 11
```

The user commits. As part of the commit, as always, Git builds a tree
graph that represents the content of the index.
`data/letter.txt` is not included in the tree graph
because it is not in the index.

<br/>

| ![`11` commit made after `data/letter.txt rm`ed](/assets/img/git/25-11.png) | 
|:--:| 
| *`11` commit made after `data/letter.txt rm`ed* |

<br/>

## Copy a repository

```
    ~/alpha $ cd ..
          ~ $ cp -R alpha bravo
```

The user copies the contents of the `alpha/`
repository to the `bravo/` directory. This produces
the following directory structure:

```
    ~
    ├── alpha
    |   └── data
    |       └── number.txt
    └── bravo
        └── data
            └── number.txt
```

There is now another Git graph in the `bravo` directory:

<br/>

| ![New graph created when `alpha` `cp`ed to `bravo`](/assets/img/git/26-11-cp-alpha-to-bravo.png) | 
|:--:| 
| *New graph created when `alpha` `cp`ed to `bravo`* |

<br/>

## Link a repository to another repository

```
          ~ $ cd alpha
    ~/alpha $ git remote add bravo ../bravo
```

The user moves back into the `alpha` repository.
They set up `bravo` as a remote repository on
`alpha`. This adds some lines to the file at
`alpha/.git/config`:

```
    [remote "bravo"]
        url = ../bravo/
```

These lines specify that there is a remote repository called
`bravo` in the directory at
`../bravo`.

<br/>

## Fetch a branch from a remote

```
    ~/alpha $ cd ../bravo
    ~/bravo $ echo '12' > data/number.txt
    ~/bravo $ git add data/number.txt
    ~/bravo $ git commit -m '12'
              [master 94cd04d] 12
```

The user goes into the `bravo` repository. They set
the content of `data/number.txt` to
`12` and commit the change to
`master` on `bravo`.

<br/>

| ![`12` commit on `bravo` repository](/assets/img/git/27-12-bravo.png) | 
|:--:| 
| *`12` commit on `bravo` repository* |

<br/>


```
    ~/bravo $ cd ../alpha
    ~/alpha $ git fetch bravo master
              Unpacking objects: 100%
              From ../bravo
                * branch master -> FETCH_HEAD
```

The user goes into the `alpha` repository. They
fetch `master` from `bravo` into
`alpha`. This process has four steps.

First, Git gets the hash of the commit that master is pointing at on
`bravo`. This is the hash of the
`12` commit.

Second, Git makes a list of all the objects that the
`12` commit depends on: the commit object itself,
the objects in its tree graph, the ancestor commits of the
`12` commit and the objects in their tree graphs. It
removes from this list any objects that the `alpha`
object database already has. It copies the rest to
`alpha/.git/objects/`.

Third, the content of the concrete ref file at
`alpha/.git/refs/remotes/bravo/master` is set to the
hash of the `12` commit.

Fourth, the content of `alpha/.git/FETCH_HEAD` is
set to:

```
    94cd04d93ae88a1f53a4646532b1e8cdfbc0977f branch 'master' of ../bravo
```

This indicates that the most recent fetch command fetched the
`12` commit of `master` from `bravo`.

<br/>

| ![`alpha` after `bravo/master` fetched](/assets/img/git/28-12-fetched-to-alpha.png) | 
|:--:| 
| *`alpha` after `bravo/master` fetched* |

<br/>

**Graph property**: objects can be copied. This means that history can
be shared between repositories.

**Graph property**: a repository can store remote branch refs like
`alpha/.git/refs/remotes/bravo/master`. This means
that a repository can record locally the state of a branch on a remote
repository. It is correct at the time it is fetched but will go out of
date if the remote branch changes.

<br/>

## Merge FETCH_HEAD

```
    ~/alpha $ git merge FETCH_HEAD
              Updating d14c7d2..94cd04d
              Fast-forward
```

The user merges `FETCH_HEAD`.
`FETCH_HEAD` is just another ref. It resolves to the
`12` commit, the giver. `HEAD`
points at the `11` commit, the receiver. Git does a
fast-forward merge and points `master` at the
`12` commit.

<br/>

| ![`alpha` after `FETCH_HEAD` merged](/assets/img/git/29-12-merged-to-alpha.png) | 
|:--:| 
| *`alpha` after `FETCH_HEAD` merged* |

<br/>

## Pull a branch from a remote

```
    ~/alpha $ git pull bravo master
              Already up-to-date.
```

The user pulls `master` from
`bravo` into `alpha`. Pull is
shorthand for "fetch and merge `FETCH_HEAD`". Git
does these two commands and reports that `master` is
`Already up-to-date`.

<br/>

## Clone a repository

```
    ~/alpha $ cd ..
          ~ $ git clone alpha charlie
              Cloning into 'charlie'
```

The user moves into the directory above. They clone
`alpha` to `charlie`. Cloning to
`charlie` has similar results to the
`cp` the user did to produce the
`bravo` repository. Git creates a new directory
called `charlie`. It inits
`charlie` as a Git repo, adds
`alpha` as a remote called
`origin`, fetches `origin` and
merges `FETCH_HEAD`.

<br/>

## Push a branch to a checked-out branch on a remote

```
          ~ $ cd alpha
    ~/alpha $ echo '13' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m '13'
              [master 3238468] 13
```

The user goes back into the `alpha` repository. They
set the content of `data/number.txt` to
`13` and commit the change to
`master` on `alpha`.

```
    ~/alpha $ git remote add charlie ../charlie
```

They set up `charlie` as a remote repository on
`alpha`.

```
    ~/alpha $ git push charlie master
              Writing objects: 100%
              remote error: refusing to update checked out
              branch: refs/heads/master because it will make
              the index and work tree inconsistent
```

They push `master` to `charlie`.

All the objects required for the `13` commit are
copied to `charlie`.

At this point, the push process stops. Git, as ever, tells the user what
went wrong. It refuses to push to a branch that is checked out on the
remote. This makes sense. A push would update the remote index and
`HEAD`. This would cause confusion if someone were
editing the working copy on the remote.

At this point, the user could make a new branch, merge the
`13` commit into it and push that branch to
`charlie`. But, really, they want a repository that
they can push to whenever they want. They want a central repository that
they can push to and pull from, but that no one commits to directly.
They want something like a GitHub remote. They want a bare repository.

<br/>

## Clone a bare repository

```
    ~/alpha $ cd ..
          ~ $ git clone alpha delta --bare
              Cloning into bare repository 'delta'
```

The user moves into the directory above. They clone
`delta` as a bare repository. This is an ordinary
clone with two differences. The `config` file
indicates that the repository is bare. And the files that are normally
stored in the `.git` directory are stored in the
root of the repository:

```
    delta
    ├── HEAD
    ├── config
    ├── objects
    └── refs
```

<br/>

| ![`alpha` and `delta` graphs after `alpha` cloned to `delta`](/assets/img/git/30-13-alpha-cloned-to-delta-bare.png) | 
|:--:| 
| *`alpha` and `delta` graphs after `alpha` cloned to `delta`* |

<br/>

## Push a branch to a bare repository

```
          ~ $ cd alpha
    ~/alpha $ git remote add delta ../delta
```

The user goes back into the `alpha` repository. They
set up `delta` as a remote repository on
`alpha`.

```
    ~/alpha $ echo '14' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m '14'
              [master cb51da8] 14
```

They set the content of `data/number.txt` to
`14` and commit the change to
`master` on `alpha`.

<br/>

| ![`14` commit on `alpha`](/assets/img/git/31-14-alpha.png) | 
|:--:| 
| *`14` commit on `alpha`* |

<br/>

```
    ~/alpha $ git push delta master
              Writing objects: 100%
              To ../delta
                3238468..cb51da8 master -> master
```

They push `master` to `delta`.
Pushing has three steps.

First, all the objects required for the `14` commit
on the `master` branch are copied from
`alpha/.git/objects/` to
`delta/objects/`.

Second, `delta/refs/heads/master` is updated to
point at the `14` commit.

Third, `alpha/.git/refs/remotes/delta/master` is set
to point at the `14` commit.
`alpha` has an up-to-date record of the state of
`delta`.

<br/>

| ![`14` commit pushed from `alpha` to `delta`](/assets/img/git/32-14-pushed-to-delta.png) | 
|:--:| 
| *`14` commit pushed from `alpha` to `delta`* |

<br/>

## Resumen

GIT se estructura alrededor de un árbol gráfico y casi todos sus comandos lo manipulan. Para entenderlo en profundidad céntrate en las propiedades de dicho gráfico, no en los flujos de trabajo o los comandos.

Para aprender más sobre Git, investiga el directorio `.git`, que no te asuste, mira dentro, cambia el contenido de los archivos a ver qué pasa. Crea un commit, intenta estropear el repositorio para luego arregarlo. 

<br/>

---

<br/>

[^1]:
    <sup>*En este caso, el hash es más largo que el contenido original, pero este método unifica
    la forma en la que GIT va a nombrar los archivos, de manera mucho más concisa que 
    usando sus nombres originales.*</sup>

[^2]:
    <sup>*Existe la posibilidad de que dos piezas de contenido diferentes tengan el mismo
    valor, pero la probabilidad de que ocurra es realmente [insignificante](http://crypto.stackexchange.com/a/2584)*</sup>

[^3]:
    <sup>*El comando `git prune` permite borrar objetos huérfanos (aquellos que están siendo 
    apuntados por ninguna referencia). Solo debe usarse para tareas de mantenimiento. 
    Si usas este comando sin saber lo que estás haciendo podrías llegar a perder contenido.*</sup>

[^4]:
    <sup>*El comando `git stash` almacena todas las diferencias entre la copia de trabajo y 
    el commit `HEAD` en un lugar seguro. Puede ser recuperado más tarde con `git stash pop`.*</sup>

[^5]:
    <sup>*El comando `git rebase` puede utilizarse para añadir, editar y borrar commits en el
    historial. Nos puede ayudar a evitar conflictos, aunque hay que entender bien cómo funciona
    y mejor aplicarlo sobre sobre commits que están en local y no han sido subidos a ningún 
    repositorio remoto*</sup>
    