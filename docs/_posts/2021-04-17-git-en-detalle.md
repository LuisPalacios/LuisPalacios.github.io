---
title: "GIT en detalle"
date: "2021-04-17"
categories: desarrollo
tags: git
excerpt_separator: <!--more-->
---

![Logo GIT](/assets/img/posts/logo-git.svg){: style="float:left; padding-right:20px" } 

[GIT] es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia.

<br clear="left"/>
<!--more-->

No depende de un repositorio central, múltiples usuarios pueden instalarse GIT y comunicarse entre ellos sin pasar por dicho servidor central. Lo que pasa es que sería inmanejable, así que los "servidores o repositorios centrales (remotos)" son muy útiles y necesarios, **los más famosos son [GitHub] y [GitLab]**. 

[Git]: https://git-scm.com
[GitHub]: https://www.github.com
[GitLab]: https://www.gitlab.com
[Gitolite]: https://gitolite.com

<br/>

## Introducción

Muy útiles, la [Cheatsheet en Español](https://training.github.com/downloads/es_ES/github-git-cheat-sheet/) o la [Visual Git Cheat Sheet](https://ndpsoftware.com/git-cheatsheet.html) o este pequeño [Guía burros](https://rogerdudler.github.io/git-guide/index.es.html) o la [documentación oficial](https://git-scm.com/doc) o si te vas a cualqueir buscador en internet vas a encontrar cientos de videos, tutoriales y documentos. 

¿Porqué mola GIT?. Hay muchos motivos, como su velocidad, que lo hizo Linus Torvals, que es libre, que nos permite movernos, como si tuviéramos un puntero en el tiempo, por todas las revisiones de código y desplazarnos de una manera muy ágil.

Tiene un sistema de trabajo con ramas (branches) que lo hace especialmente potente. Permiten poder tener proyectos divergentes de un principal, hacer experimentos o para probar nuevas funcionalidades, entre otras cosas.

Antes de entrar en harina, tenemos dos formas de trabajar, con el cliente (programa) `git` para la línea de comandos o con un cliente gráfico, muchísimo más sencillo y agradable. Aún así te recomiendo empezar por la línea de comandos (`git` a secas) y cuando entiendas cuatro cosillas importantes te pases a un cliente GUI.

* Cliente `git`, programa para línea de comandos
* Cliente GUI [GitKraken](https://www.gitkraken.com) <- Este es el que uso yo 🤗
* Cliente GUI [GitHub Desktop](https://desktop.github.com) desarrollado por GitHub.
* Cliente GUI [SourceTree](https://www.sourcetreeapp.com)
* Aquí tienes más.. [clientes GUI](https://git-scm.com/downloads/guis)

<br/>

### Instalación de Git

Para empezar, te recomiendo que siempre te instales la versión de la línea de comandos (programa `git`) y que apuestes por uno de los **clientes GUI anteriores**, el que más te guste, lo descargues y lo instales en tu ordenador. 

* Aquí tienes una pequeña guía para [instalar](https://git-scm.com/book/es/v2/Inicio---Sobre-el-Control-de-Versiones-Instalación-de-Git) `git` en línea de comandos en Linux, Windows y Mac.

Una vez que lo tengas instalado, comprueba que funciona:

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

Ahora al lio, este apunte (post) nace desde otro en inglés que me gustó mucho. Se trata de [Git from the inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out) **(GIT desde el interior)**. Me gustó tanto que me he tomado la libertad de traducirlo y crear esta versión a medida con mis propias palabras, revisado y en algunos puntos mejorado para que se entienda mejor. Por supuesto todo el crédito va para su Autora [Mary Rose Cook](https://maryrosecook.com), muchas gracias desde aquí!.

<br/>

---

<br/>

## GIT desde el interior

A partir de aquí vamos a explica cómo funciona, asumiendo que has dedicado algo de tiempo a entender más o menos de qué va y quieres usarlo para el control de versiones de tus proyectos. Git será fácil una vez que le hayas dedicado algo de tiempo.

Ha quedado patente después de unos añitos que supera a otras herramientas de control de versiones (SCM-Source code management) como Subversion, CVS, Perforce y ClearCase por sus características como la **ramificación local (ramas/branches)**, las **áreas de preparación (staging)** y los **múltiples flujos de trabajo**.

Veremos el **tree graph**, la estructura gráfica que refleja el árbol de conexiones entre ficheros que sustenta a Git. Vamos a empezar creando un único proyecto en local y cómo los comandos van afectando a dicha estructura gráfica.

<br/>

### Creación de un proyecto

Desde la línea de comandos creamos el directorio `alpha`, porque cada proyecto debe estar en un directorio distinto.

```zsh
➜  ~ > clear
➜  ~ > mkdir alpha
```

Nos metemos en `alpha` y creamos un (sub)directorio `data`. Dentro creamos un archivo llamado `letter.txt` que contiene el caracter `a`:

```zsh
➜  ~ > cd alpha
➜  alpha > mkdir data
➜  alpha > echo 'a' > data/letter.txt
```
Aquí tenemos el resultado final: 

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

### Primer commit 

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
| ![Commit a1 apuntando a su tree graph](/assets/img/git/2-a1-commit-gg.jpg) | 
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
author Luis Palacios <luis@gmail.com> 1619459710 +0200
committer Luis Palacios <luis@gmail.com> 1619459710 +0200
a2
```

La primera línea del commit apunta al nuevo objeto tree `root`, la segunda línea apunta al commit anterior `a1` (para poder encontrar el commit padre GIT se fue a `HEAD` y lo siguió hasta que dió con el hash del commit de `a1`)

**Tercero**, el contenido de la rama (brancho) `master` pasa a apuntar al hash del nuevo commit (`a2`)

<br/>

| ![commit `a2`](/assets/img/git/7-a2.png) | 
| ![commit `a2`](/assets/img/git/7-a2-gitgraph.jpg) | 
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

#### Características sobre el histórico

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
| ![Commit `a3` que NO está en ninguna rama (branch)](/assets/img/git/10-a3-detached-head-gitgraph.jpg) | 
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
| ![Commit `a3` ahora en rama `deputy`](/assets/img/git/11-a3-on-deputy-gitgraph.jpg) | 
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
| ![Checkout de `deputy`](/assets/img/git/13-a3ondeputy-gitgraph.jpg) | 
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

El intento consiste en hacer una fusión (merge) de algo del pasado, `master`, dentro de `deputy`. El merge de dos ramas significa fusionar dos commits. El primer commit **receptor** es siempre en el que nos encontramos (`deputy`). El segundo commit es el **emisor**, aquel que indicamos en el comando git merge (`master`). En resumen, pedimos que el contenido de `master` se fusione dentro de `deputy`. 

En este caso GIT no hace nada, nos dice `Already up-to-date.` (ya estoy al día).

Lógico, el commit emisor (dador) es un antepasado del commit receptor, GIT no tiene que hacer nada porque el commit de `deputy` venía de `master (a2)`, nació desde él, por lo tanto no necesita que le incorporemos nada, porque no hay nada nuevo a incorporar. 

<br/>

## Merge de un descendiente

¿Pero qué pasa si intentamos hacer lo contrario?, por ejemplo fusionar algo del futuro (algo que se ha hecho un commit en el futuro y quiero llevarlo a una copia del pasado). Para provocarlo, vámonos a la otra rama, cambiamos a `master`.

```zsh
➜  alpha git:(deputy) > git checkout master
Switched to branch 'master'
➜  alpha git:(master) >
```

<br/>

| ![Checkout de `master` que apunta al commit `a2`](/assets/img/git/14-a3-on-master-on-a2.png) | 
|:--:| 
| *Checkout de `master` que apunta al commit `a2`* |

<br/>

Ahora vamos a intentar fusionar algo que se hizo en el futuro (desde) `deputy` dentro de `master`. El commit **receptor** es en el que nos encontramos (`master`). El commit **emisor** es (`deputy`) (indicado en el comando), pedimos que el contenido de `deputy` se fusione dentro de `master`. 

```zsh
➜  alpha git:(master) > git merge deputy
Updating 850918e..92ffe65
Fast-forward
 data/number.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(master) >
```

Se hace una fusión de `deputy` en `master`. GIT se da cuenta de que el **commit receptor** `a2`, es más viejo que el **commit emisor**, `a3`, por lo tanto acepta la fusión, y provoca el `fast-forward merge` (avanzamos msater hacia el futuro, provocamos que `master` se ponga a la altura temporal de `a3` con las modificaciones que este commit contenga). Tan sencillo como que ahora `master` apunta a `a3`: Obtiene el commit del emisor (dador) y el tree graph al que apunta. Se sacan y escriben las entradas de los archivos desde el tree graph, se copian al working copy y al índice y se hace que `master` se "adelante" aapuntando a `a3`.


| ![El commit `a3` de `deputy` se fusiona en `master` con un fast-forward](/assets/img/git/15-a3-on-master.png) | 
| ![El commit `a3` de `deputy` se fusiona en `master` con un fast-forward](/assets/img/git/15-a3-on-master-gitgraph.jpg) | 
|:--:| 
| *El commit `a3` de `deputy` se fusiona en `master` con un fast-forward* |

<br/>

Las series de commits en el gráfico se interpretan como una serie de cambios realizados en el contenido del repositorio. Esto significa que, en una fusión, si el dador es un descendiente del receptor, la historia
no se modifica. Ya existe una secuencia de commits que describen el cambio a realizar: la secuencia de commits entre el receptor y el dador. Pero, aunque el historial de Git no cambia, el gráfico de Git sí cambia. La referencia concreta a la que apunta `HEAD` se se actualiza para apuntar al commit del dador (en este caso `a3`).

<br/>

## Merge desde linajes distintos

Vamos a ver otro caso, ahora vamos a intentar hacer una fusión de dos commits que están en linajes distintos.  Empezamos preparando un nuevo commit, ponemos un `4` en `number.txt` y hacemos un commit `a4` en `master`.

```zsh
➜  alpha git:(master) > echo '4' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ > git commit -m 'a4'
[master 3a8599e] a4
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(master) >
```

| ![commit `a4` en `master`](/assets/img/git/15.1-a4-gitgraph.jpg) | 
|:--:| 
| *commit `a4` en `master`* |


<br/>

Cambiamos a `deputy` (checkout, ponemos una `b` en `data/letter.txt` y hacemos un commit `b3`.

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
| ![commit `a4` en master y `b3` en deputy, checkout de `deputy`](/assets/img/git/16-a4-b3-on-deputy-gitgraph.jpg) | 
|:--:| 
| *commit `a4` en master y `b3` en deputy, checkout de `deputy`* |

<br/>

Fíjate que ambos commits (`a4` y `b3`) parten del contenido del commit padre `a3`, por lo tanto: 

- Los commits pueden compartir "padres". Eso significa que los nuevos linajes se crearon desde la misma historia (en este caso partían desde `a3`)

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

- **Paso #1**: Git escribe el hash de la confirmación del dador (`master`) en `.git/MERGE_HEAD`. La presencia de este archivo indica a Git que está en medio de una fusión.

<br/>

- **Paso #2**: Git encuentra el `commit base` (del que partir, `a3`): el ancestro más reciente que tanto receptor (`deputy`) como dador (`master`) tienen en común. 

| ![`a3` es el commit base de `a4` y `b3`](/assets/img/git/17-a4-b3-on-deputy.png) | 
|:--:| 
| *`a3` es el commit base de `a4` y `b3`* |


Dado que los commits tienen padres es posible encontrar el punto en el que dos linajes divergen. Git rastrea hacia atrás desde `b3` para encontrar todos sus ancestros y hacia atrás desde `a4` para encontrar todos sus ancestros. Encuentra el ancestro más reciente compartido por ambos linajes, `a3`. Ese es el `commit base`

<br/>

- **Paso #3**: Git genera los índices de los commits base, receptor y dador a partir de sus tree graphs.

<br/>

- **Paso #4**: GIT genera un diff que combina los cambios realizados en la base por el commit receptor y el commit dador. Este diff es una lista de rutas de archivos que apuntan a un cambio: añadir, eliminar, modificar o entrar en conflicto. Git obtiene la lista de todos los archivos que aparecen en los índices base, receptor o
giver. Para cada uno, compara las entradas del índice para decidir el para decidir el cambio a realizar en el archivo. Escribe una entrada correspondiente en el diff. En este caso, el diff tiene dos entradas.

- La primera entrada es para `data/letter.txt`. El contenido es `a` en la base, `b` en el receptor y `a` en
el dador. El contenido es diferente en la base y en el receptor. Pero es el mismo en la base y en el dador. Git ve que el contenido fue modificado por el receptor, pero no por el dador. La entrada diff para `data/letter.txt` es una modificación, no un conflicto. La última en modificarse fue `deputy b3` con una `b` que se queda con versión final en el nuevo commit.

- La segunda entrada en el diff es para `data/number.txt`. En este caso, el contenido es el mismo en la base y el receptor, y diferente en el dador. La entrada del diff para `data/number.txt` también es una modificación. La última en modificarse fue en el commit de `master a4` con una `4` que se queda como versión final en el nuevo commit.

Nota: Dado que es posible encontrar el commit base de una fusión, si si un archivo ha cambiado desde la base sólo en el receptor o dador, Git puede resolver automáticamente la fusión de ese archivo. Esto reduce el trabajo que debe hacer el usuario.

<br/>

- **Paso #5**: Los cambios indicados por las entradas en el diff se aplican a
la copia de trabajo. El contenido de `data/letter.txt` se establece como `b` (apunta al blob existente) y el contenido de `data/number.txt` se establece como `4` (apunta al blob existente).

<br/>

- **Paso #6**: Los cambios indicados por las entradas en el diff se aplican a el índice. La entrada de `data/letter.txt` está apunta al blob `b` y la entrada de `data/number.txt` apunta al blob `4`.

<br/>

- **Paso #7**: Se hace un commit al índice actualizado

```zsh
➜  alpha git:(deputy) > git --no-pager cat-file -p 7f66
tree f2b663c0472703180d775c4d0f2559973ccf8503
parent 674c90926211d71b54d2651ec80b65cd20eae30d
parent cdfa1d525ef6807aa3eb9c64746dcdfac7a130d7
author Luis Palacios <luis@gmail.com> 1619523895 +0200
committer Luis Palacios <luis@gmail.com> 1619523895 +0200

b4
```

Aquí te tienes que fijar que este commit tiene dos padres. 

<br/>

- **Paso #8**: Git hace que la rama actual apunte a `deputy`, al último commit.


| ![`b4` es el resultado de fusionar `a4` en `b3`](/assets/img/git/18-b4-on-deputy.png) | 
| ![`b4` es el resultado de fusionar `a4` en `b3`](/assets/img/git/18-b4-on-deputy-gitgraph.jpg) | 
|:--:| 
| *`b4` es el resultado de fusionar `a4` en `b3`* |

<br/>

## Merge desde dos linajes con conflicto.

Vamos a complicarlo un poco más, ahora vamos a intentar un merge desde dos commits de diferentes linajes donde ambos han modificado el mismo fichero. 


```
➜  alpha git:(deputy) > git checkout master
Switched to branch 'master'
➜  alpha git:(master) > git merge deputy
Updating cdfa1d5..7f66932
Fast-forward
 data/letter.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(master) >
```

Cambiamos a `master` y fusiono`deputy` en `master`. Esto
adelanta a "master" al "commit" de `b4`. `master` y
`deputy` apuntan ahora al mismo commit.

<br/>

| ![`master` y `deputy` apuntan ahora al mismo commit `b4`](/assets/img/git/19-b4-master-deputy-on-b4.png) | 
| ![`master` y `deputy` apuntan ahora al mismo commit `b4`](/assets/img/git/19-b4-master-deputy-on-b4-gitgraph.jpg) | 
|:--:| 
| *`master` y `deputy` apuntan ahora al mismo commit `b4`* |

<br/>

Vamos a provocar un conflicto. Primero nos cambiamos a `deputy` y le ponemos un `5` a `data/number.txt`, hacemos el commit `b5`

```
➜  alpha git:(master) > git checkout deputy
Switched to branch 'deputy'
➜  alpha git:(deputy) > echo '5' > data/number.txt
➜  alpha git:(deputy) ✗ > git add data/number.txt
➜  alpha git:(deputy) ✗ > git commit -m 'b5'
[deputy 84675ba] b5
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  alpha git:(deputy) >
```

Después cambiamos a `master`, le ponemos un `6` a `data/number.txt`, hacemos el commit `b6`

```
➜  alpha git:(deputy) > git checkout master
Switched to branch 'master'
➜  alpha git:(master) > echo '6' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ > git commit -m 'b6'
[master 871d9b4] b6
 1 file changed, 1 insertion(+), 1 deletion(-)
```

<br/>

| ![`b5` en `deputy` y `b6` en `master`](/assets/img/git/20-b5-on-deputy-b6-on-master.png) | 
| ![`b5` en `deputy` y `b6` en `master`](/assets/img/git/20-b5-on-deputy-b6-on-master-gitgraph.jpg) | 
|:--:| 
| *`b5` en `deputy` y `b6` en `master`* |

<br/>

Intentamos fusiona `deputy` (emisor) en `master` (receptor). Hay un conflicto y la fusión se pone en pausa. El proceso para una fusión conflictiva sigue los mismos seis pasos: establecer `git/MERGE_HEAD`, encontrar el commit base, generar los índices de los commits base, receptor y dador, crear un diff, actualizar la copia de trabajo y actualizar el índice. Pero debido al conflicto, el séptimo paso de commit y el octavo de actualización de referencia nunca se realizan.

```
➜  alpha git:(master) > git merge deputy
Auto-merging data/number.txt
CONFLICT (content): Merge conflict in data/number.txt
Automatic merge failed; fix conflicts and then commit the result.
➜  alpha git:(master) ✗ >
```

<br/>

**Repasemos los pasos de nuevo y veamos qué ocurre**

<br/>

- **Paso #1**: Git escribe el hash de la confirmación del dador (`deputy`) en `.git/MERGE_HEAD`. 

```zsh
➜  alpha git:(master) ✗ > cat .git/MERGE_HEAD
84675baa2ee8e52a49c5a6b1b95885173a8aef42
```

<br/>

| ![Se crea el `MERGE_HEAD` durante el merge de `b5` en `b6`](/assets/img/git/21-b6-on-master-with-merge-head.png) | 
|:--:| 
| *Se crea el `MERGE_HEAD` durante el merge de `b5` en `b6`* |

<br/>

- **Paso #2**: Git encuentra el `commit base`: `b4`
- **Paso #3**: Git genera los índices de los commits base, receptor y dador. 
- **Paso #4**: GIT genera un diff que combina los cambios realizados en la base por el commit receptor y el commit dador. Este diff es una lista de rutas de archivos que apuntan a un cambio: añadir, eliminar, modificar o entrar en conflicto. En este caso, el diff contiene sólo una entrada: `data/number.txt`. La entrada está marcada como un conflicto porque el contenido de `data/number.txt` es diferente en el receptor, el dador y la base.
- **Paso #5**: Los cambios indicados por las entradas en el diff se aplican a la copia de trabajo. 
Cuando hay un conflicto GIT Git escribe ambas versiones en el archivo en la copia de trabajo. El contenido de
`data/number.txt` es: 

<br/>

```zsh
➜  alpha git:(master) ✗ > cat data/number.txt
<<<<<<< HEAD
6
=======
5
>>>>>>> deputy
```

<br/>

- **Paso #6**: En sexto lugar, los cambios indicados por las entradas en el diff se aplican al índice. Las entradas en el índice se identifican de forma única por una combinación de su ruta de archivo y etapa. La entrada de un fichero no conflictivo tiene un etapa `0`. Antes de esta fusión, el índice tenía el siguiente aspecto (con un "0" como valor de etapa):

<br/>

```
100644 61780798228d17af2d34fce4cfbdf35556832472 0	data/letter.txt
100644 b8626c4cff2849624fb67f87cd0ad72b163671ad 0	data/number.txt
```

<br/>

Después del merge y en mitad del conflicto, vemos la nueva situación: 

<br/>

```
➜  alpha git:(master) ✗ > git ls-files --stage
100644 61780798228d17af2d34fce4cfbdf35556832472 0	data/letter.txt   <-- No tiene problema
100644 b8626c4cff2849624fb67f87cd0ad72b163671ad 1	data/number.txt   <== '4' anterior
100644 1e8b314962144c26d5e0e50fd29d2ca327864913 2	data/number.txt   <== '6' conflicto <-+
100644 7ed6ff82de6bcc2a78243fc9c54d3ef5ac14da69 3	data/number.txt   <== '5' conflicto <-+
```

<br/>

El fichero number.txt ahora tiene tres entradas, la que está marcada con un `1` es el hash a la versión "base". La que tiene un `2` es la versión del receptor y la que tiene un `3` la versión del emisor. 

El merge se queda en pausa. Vamos a resolverlo escribiendo el valor que queremos que tenga number.txt. 

<br/>

```
➜  alpha git:(master) ✗ > echo '11' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ >
```

<br/>

Resuelvo poniendo el contenido a mano del fichero `data/number.txt`, en este caso un `11` y lo añado al índice. GIT genera un nuevo blob para el fichero con el `11` y por el hecho de añadir un fichero nuevo que era el conflictivo le estamos diciendo que el conflicto se ha resuelto. GIT elimina las entradas con etapa `1`, `2` y `3` del índice y añade una nueva con etapa '0':

<br/>

```
➜  alpha git:(master) ✗ > git ls-files --stage
100644 61780798228d17af2d34fce4cfbdf35556832472 0	data/letter.txt
100644 b4de3947675361a7770d29b8982c407b0ec6b2a0 0	data/number.txt  <-- Resuelto, versión con `11`
```

<br/>

- **Paso #7**: Se hace un commit. GIT se da cuenta de que tiene `.git/MERGE_HEAD` en el repositorio, lo que le indica que hay una fusión en curso. Comprueba el índice y encuentra que no hay conflictos. Crea una nueva confirmación, `b11`, para registrar el contenido de la fusión resuelta. Elimina el archivo en `.git/MERGE_HEAD`. Esto completa la fusión.

<br/>

```zsh
➜  alpha git:(master) ✗ > git commit -m 'b11'
[master 819e4c1] b11

➜  alpha git:(master) > git --no-pager cat-file -p 819e4c1
tree fcc4f168c1345d8c15f31acd4f34df732997a474
parent 871d9b4e8ffa2855b71b934cd77dde340901036a
parent 84675baa2ee8e52a49c5a6b1b95885173a8aef42
author Luis Palacios <luis@gmail.com> 1619532160 +0200
committer Luis Palacios <luis@gmail.com> 1619532160 +0200

b11
```

<br/>

- **Paso #8**: Git hace que la rama actual, `master` apunte al nuevo commit. 

<br/>

| ![commit `b11` tras resolver el conflicto](/assets/img/git/22-b11-on-master.png) | 
| ![commit `b11` tras resolver el conflicto](/assets/img/git/22-b11-on-master-gitgraph.jpg) | 
|:--:| 
| *commit `b11` tras resolver el conflicto* |

<br/>

## Eliminar un fichero

En el diagrama siguiente podemos ver el histórico de commits. Los trees y blobs de la última confirmación, así como la working copy (copia de trabajo) y el índice:

<br/>

| ![working copy, índice, commit `b11` y tree graph](/assets/img/git/23-b11-with-objects-wc-and-index.png) | 
|:--:| 
| *La working copy, índice, commit `b11` y tree graph* |

<br/>

El usuario le dice a Git que elimine `data/letter.txt`. El archivo se elimina de la WORKING COPY y del ÍNDICE.

```zsh
➜  alpha git:(master) > git rm data/letter.txt
rm 'data/letter.txt'
```

<br/>

| ![Después de borrar `data/letter.txt` de la working copy y el índice](/assets/img/git/24-b11-letter-removed-from-wc-and-index.png) | 
|:--:| 
| *Después de borrar `data/letter.txt` de la working copy y el índice* |

<br/>

Hacemos un commit. Como parte del mismo, como siempre, GIT construye un árbol que representa el contenido del índice. El archivo `data/letter.txt` no se incluye en el tree graph porque no está en el índice.

```
➜  alpha git:(master) ✗ > git commit -m '11'
[master cb09056] 11
 1 file changed, 1 deletion(-)
 delete mode 100644 data/letter.txt
```

<br/>

| ![commit `11` después de borrar `data/letter.txt`](/assets/img/git/25-11.png) | 
| ![commit `11` después de borrar `data/letter.txt`](/assets/img/git/25-11-gitgraph.jpg) | 
|:--:| 
| *commit `11` después de borrar `data/letter.txt`* |

<br/>

## Copiar un repositorio

Vamos a cambiar de tercio. Ahora vamos a copiar el contenido del repositorio `alpha/` a un nuevo directorio `bravo/` directory. Esto provoca la siguiente estructura: 

```
➜  alpha git:(master) > cd ..
➜  ~ > cp -R alpha bravo

.
├── alpha
│   └── data
│       └── number.txt
└── bravo
    └── data
        └── number.txt
```

Tenemos otro GIT graph en el directorio `bravo`:

<br/>

| ![Vista de ambos `alpha` copiado a `bravo`](/assets/img/git/26-11-cp-alpha-to-bravo.png) | 
|:--:| 
| *Vista de ambos `alpha` copiado a `bravo`* |

<br/>

## Enlazar un repositorio con otro

Nos volvemos al repositorio `alpha` y configuramos como repositorio remoto a `bravo`. 


```
➜  > cd alpha
➜  alpha git:(master) > git remote add bravo ../bravo
```

Esto va a suponer que se añaden algunas líneas al fichero `alpha/.git/config`:

```
[remote "bravo"]
	url = ../bravo
	fetch = +refs/heads/*:refs/remotes/bravo/*
```

Estas líneas especifican que hay un repositorio remoto llamado `bravo` en el directorio `../bravo`.

<br/>

## Fetch (traer) una branch (rama) desde un remoto

Entramos en el repositorio `bravo`, cambio el contenido de `data/number.txt` a `12` y hago un commit en la rama `master` en `bravo`.

The user goes into the `bravo` repository. They set
the content of `data/number.txt` to
`12` and commit the change to
`master` on `bravo`.

```
➜  alpha git:(master) > cd ../bravo
➜  bravo git:(master) > echo '12' > data/number.txt
➜  bravo git:(master) ✗ > git add data/number.txt
➜  bravo git:(master) ✗ > git commit -m '12'
[master b3f3fca] 12
 1 file changed, 1 insertion(+), 1 deletion(-)
➜  bravo git:(master) >
```

<br/>

| ![Commit `12` en el repositorio `bravo`](/assets/img/git/27-12-bravo.png) | 
|:--:| 
| *Commit `12` en el repositorio `bravo`* |

<br/>

El usuario entra en el repositorio `alpha` y se trae (fetch) el `master` desde `bravo`. Se trata de un proceso con cuatro pasos.

```
➜  alpha git:(master) > git fetch bravo master
remote: Enumerating objects: 7, done.
remote: Counting objects: 100% (7/7), done.
remote: Total 4 (delta 0), reused 0 (delta 0)
Unpacking objects: 100% (4/4), done.
From ../bravo
 * branch            master     -> FETCH_HEAD
 * [new branch]      master     -> bravo/master
```

 - **Paso #1**: Git obtiene el hash del commit `12` al que está apuntando `master` en `bravo`.
 - **Paso #2**: Git hace una lista de todos los objetos de los que depende el commit `12`, el objeto commit en si mismo, los objetos del tree graph, los ancestros a dicho commit y los objetos en sus tree graphs. Elimina de su lista cualquier objeto que `alpha`ya tenga por si mismo y copia el resto de objetos a `.git/objects/`.
 - **Paso #3**: El contenido del archivo de referencia concreto en `alpha/.git/refs/remotes/bravo/master` se ajusta al hash del commit `12`.
 - **Paso #4**: El contenido de `alpha/.git/FETCH_HEAD` se se establece en:

```
➜  alpha git:(master) > cat .git/FETCH_HEAD
b3f3fca9a5f40c6ff21dddec1657d5d0c435ec61		branch 'master' of ../bravo
```

Esto indica que el comando fetch más reciente obtuvo el `12` de `master` de `bravo`.

<br/>

| ![`alpha` after `bravo/master` fetched](/assets/img/git/28-12-fetched-to-alpha.png) | 
|:--:| 
| *`alpha` after `bravo/master` fetched* |

<br/>

- Los objetos se pueden copiar, significa que la historia se puede compartir entre repositorios. 
- Un repositorio puede almacenar referencias de ramas remotas como `git/refs/remotes/bravo/master`. Esto significa que un repositorio puede registrar localmente el estado de una rama en un repositorio
remoto. Es correcto en el momento en que se obtiene, pero se desactualiza si la rama remota cambia.

<br/>

## Merge FETCH_HEAD

Si fusionamos `FETCH_HEAD`, que es una referencia más, resolverá siendo el **emisor/dador** el commit `12` y el **receptor** la `HEAD`con el commit `11`. Git hace una fusión rápida y apunta a `master` al commit `12`.

```
➜  alpha git:(master) > git merge FETCH_HEAD
Updating cb09056..b3f3fca
Fast-forward
 data/number.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

<br/>

| ![`alpha` after `FETCH_HEAD` merged](/assets/img/git/29-12-merged-to-alpha.png) | 
|:--:| 
| *`alpha` after `FETCH_HEAD` merged* |

<br/>

## Pull (tirar) de una branch (rama) desde un remoto

Tiramos de `master` desde `bravo`. Pull es la abreviación de `fetch & merge the FETCH_HEAD` (traer y fusionar) el `FETCH_HEAD`. 

En el ejemplo GIT realiza estos dos comandos e informa de que `master` está `Ya está actualizado`; porque en los pasos anteriores ya habíamos hecho el `fetch`y el `merge`.


```
➜  alpha git:(master) > git pull bravo master
From ../bravo
 * branch            master     -> FETCH_HEAD
Already up to date.
```

<br/>

## Clone (clonar) un repositorio. 

Si deseas obtener una copia de un repositorio Git existente — por ejemplo, un proyecto en el que te gustaría contribuir — el comando que necesitas aprender es `git clone`. GIT recibirá una copia de casi todos los datos que tiene el servidor (o el repositorio remoto). Cada versión de cada archivo de la historia del proyecto es descargada (o se copia) cuando ejecutas git clone. 

Subimos un directorio y "clonamos" alpha en un nuevo directorio llamado "charlie".

```zsh
➜  rep > git clone alpha charlie
Cloning into 'charlie'...
done.
```

Cambiamos al directorio anterior. Se clona `alpha` a `charlie`. La clonación tiene resultados similares a los de que el usuario hizo para producir el repositorio `bravo`. Git crea un nuevo directorio llamado `charlie`. Lo inicializa como un repositorio Git, añade `alpha` como un remoto llamado `origin`, hace un fetch desde `origin` y fusiona `FETCH_HEAD`.

<br/>

## Push (empujar) una branch (rama) a una rama checked-out en un remoto

A continuación vamos a hacer un Push (empujar) de un branch (rama) a una rama checked-out en un remoto

```
➜  > cd alpha
➜  alpha git:(master) > echo '13' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ > git commit -m '13'
[master 102bd7d] 13
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Vuelvo a entrar en el repositorio `alpha`. Establece el contenido de `data/number.txt` con un `13` y hago un commit en `master`de `alpha`.

Añado a `charlie` como un repositorio remoto de `alpha`.

```
➜  alpha git:(master) > git remote add charlie ../charlie
```

Empuja `master` a `charlie`. Todos los objetos requeridos para el commit `13` se copian dentro de `charlie`

```
➜  alpha git:(master) > git push charlie master
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Writing objects: 100% (4/4), 289 bytes | 289.00 KiB/s, done.
Total 4 (delta 0), reused 0 (delta 0)
remote: error: refusing to update checked out branch: refs/heads/master
remote: error: By default, updating the current branch in a non-bare repository
remote: is denied, because it will make the index and work tree inconsistent
remote: with what you pushed, and will require 'git reset --hard' to match
remote: the work tree to HEAD.
```

En este punto, el proceso de Push se detiene. Git, como siempre, le dice al usuario lo que
salió mal. Se niega a empujar una rama que se hizo commit en el remoto. Esto tiene sentido. Un push actualizaría el índice remoto y `HEAD`. Esto causaría confusión si alguien estuviera
editando la copia de trabajo en el remoto.

En este punto, el usuario podría hacer una nueva rama, fusionar el `13` y empujar esa rama a `charlie`. Pero, realmente, ¿queremos un repositorio al que puedan empujar cuando quieran?. En realidad queremos un repositorio central al que se pueda hacer push y pull, pero que no acepte commits directamente. Una especie de GitHub remoto. Eso tiene un nombre, se conoce como un **bare repository** (repositorio vacío).

<br/>

## Clonar un Bare Repository (repositorio vacío)

Nos cambiamos al directorio anterior. Clono `delta`como un repositorio vacío (bare). 

```zsh
➜  alpha git:(master) > cd ..
➜  rep > git clone alpha delta --bare
Cloning into bare repository 'delta'...
done.
```

En realidad es un clonado ordinario pero con dos diferencias: El fichero `config` nos dice que es un `bare` y los ficheros que normalmente se guardarían bajo `.git` se guardan en la raíz del repositorio: 

```zsh
delta
├── HEAD
├── config
├── description
├── hooks
├── info
├── objects
├── packed-refs
└── refs
```

<br/>

| ![`alpha` and `delta` graphs after `alpha` cloned to `delta`](/assets/img/git/30-13-alpha-cloned-to-delta-bare.png) | 
|:--:| 
| *`alpha` and `delta` graphs after `alpha` cloned to `delta`* |

<br/>

## Push (empujar) una branch (rama) a un bare repository

Vamos a repetir lo que antes nos fallo. Volvemos al repositorio `alpha`. Configuro a `delta` (repositorio vacío) como un repositorio remoto de `alfa`.

```
➜  > cd alpha
➜  alpha git:(master) > git remote add delta ../delta
```

Modifico alpha, cambio el contenido de `data/number.txt` a un `14` y realizo un commit en `master`en `alpha`.

```
➜  alpha git:(master) > git remote add delta ../delta
➜  alpha git:(master) > echo '14' > data/number.txt
➜  alpha git:(master) ✗ > git add data/number.txt
➜  alpha git:(master) ✗ >  git commit -m '14'
[master af337b6] 14
 1 file changed, 1 insertion(+), 1 deletion(-)
```

<br/>

| ![`14` commit on `alpha`](/assets/img/git/31-14-alpha.png) | 
|:--:| 
| *`14` commit on `alpha`* |

<br/>

```
➜  alpha git:(master) > git push delta master
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Writing objects: 100% (4/4), 291 bytes | 291.00 KiB/s, done.
Total 4 (delta 0), reused 0 (delta 0)
To ../delta
   102bd7d..af337b6  master -> master
➜  alpha git:(master) >
```

Empujo (push) `master` hacia el repositorio remoto (vacío) `delta`. El push tiene tres pasos: 

- **Paso #1**: Se copian todos los objetos necesarios para el commit `14` en la rama `master` en `.git/objects/` hacia `delta/objects/`.
- **Paso #2**: Se actualiza `delta/refs/heads/master` para apuntar al commit `14`.
- **Paso #3**: Se establece `alpha/.git/refs/remotes/delta/master` se establece para que apunte al commit `14` El `alpha` tiene un registro actualizado del estado de `delta`.

<br/>

| ![commit `14` empujado desde `alpha` a `delta`](/assets/img/git/32-14-pushed-to-delta.png) | 
| ![commit `14` empujado desde `alpha` a `delta`](/assets/img/git/32-14-pushed-to-delta-gitgraph.jpg) | 
|:--:| 
| *commit `14` empujado desde `alpha` a `delta`* |

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
    