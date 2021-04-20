---
title: "GIT en detalle"
date: "2021-04-20"
categories: apuntes git linux
---

![GIT Logo](/assets/img/Git-Logo-1788C-300x125.png){: width="150px" style="float:left; padding-right:20px" } 

En pocas palabras, [GIT] es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia.

No depende de un repositorio central, múltiples usuarios pueden instalarse GIT y comunicarse entre ellos sin necesidad de conectar con un servidor central. Lo que pasa es que sería inmanejable, así que los "servidores o repositorios centrales (remotos)" son muy útiles y necesarios. 

Podrías montarte el tuyo propio con [Gitolite] por ejemplo, o mejor todavía con [GitLab] (auto-gestionado). Ahora bien, **lo más sensato es usar los que están disponibles en internet como los famosos [GitHub] o [GitLab]**. 

[Git]: https://git-scm.com
[GitHub]: https://www.github.com
[GitLab]: https://www.gitlab.com
[Gitolite]: https://gitolite.com

<br/>

## Introducción

Empezamos por algunos enlaces. Muy útil, la [Cheatsheet en Español](https://training.github.com/downloads/es_ES/github-git-cheat-sheet/) o la [Visual Git Cheat Sheet](https://ndpsoftware.com/git-cheatsheet.html) o este pequeño [Guía burros](https://rogerdudler.github.io/git-guide/index.es.html) o si quieres algo más oficial, tienes la [documentación oficial](https://git-scm.com/doc) o si te vas a cualqueir buscador en internet vas a encontrar cientos de videos, tutoriales, documentos, etc. 

¿Porqué mola GIT?. Hay muchos motivos, como su velocidad, que lo hizo Linus Torvals, que es libre, que nos permite movernos, como si tuviéramos un puntero en el tiempo, por todas las revisiones de código y desplazarnos una manera muy ágil.

Tiene un sistema de trabajo con ramas (branches) que lo hace especialmente potente. Están destinadas a provocar proyectos divergentes de un proyecto principal, para hacer experimentos o para probar nuevas funcionalidades.

Antes de entrar en harina, tenemos dos formas de trabajar con Git. Una es con el cliente (programa) `git` para la línea de comandos. La otra es usar un cliente gráfico, muchísimo más sencillo y agradable. Aún así te recomiendo empezar por la línea de comandos (`git` a secas) y cuando entiendas cuatro cosillas importantes te pases a un cliente GUI. Te recomiendo los primeros de esta lista, ojo que hay muchísimos.

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

Uno de los mejores artículos técnicos **con detalle** que me encontré en el pasado para aprender GIT fue [Git from the inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out) **(GIT desde el interior)**. De hecho me gustó tanto que me he tomado la libertad de traducirlo y crear esta versión a medida con mis propias palabras. Por supuesto todo el crédito va para su Autora [Mary Rose Cook](https://maryrosecook.com), muchas gracias desde aquí!.

<br/>

---

<br/>

## GIT desde el interior


Este apunte explica cómo funciona Git. Asume que has dedicado algo de tiempo a entender más o menos de qué va y quieres usarlo para el control de versiones de tus proyectos. Puede ser fácil de aprender pero hay que dedicarle algo de tiempo y merece mucho la pena. 

Supera a otras herramientas de control de versiones (SCM-Source code management) como Subversion, CVS, Perforce y ClearCase por sus características como la **ramificación local (ramas/branches)**, las **áreas de preparación (staging)** y los **múltiples flujos de trabajo**.

El apunte se centra en la estructura de grafos que sustenta a Git y en la forma en que
sus propiedades dictan su comportamiento. Vas a ver una serie de comandos Git ejecutados en un único proyecto, con observaciones sobre la estructura gráfica para ilustrar una propiedad
y el comportamiento que esta propiedad produce.

<br/>

### Creación de un proyecto

Vamos al lío, pezar este tutorial directamente en la línea de comandos, con la creación de un proyecto. Cada proyecto debería tener su propio sub

```zsh
➜  ~ > clear
➜  ~ > mkdir alpha
```

El usuario crea el directorio `alpha` para contener su proyecto. 

```zsh
➜  ~ > cd alpha
➜  alpha > mkdir data
➜  alpha > echo 'a' > data/letter.txt
```

Cambia al directorio `alpha` y se crea un directorio llamado "data". Dentro, crea un archivo
llamado `letter.txt` que contiene el caracter `a`. El directorio tiene este aspecto:

```zsh
alpha
└── data
    └── letter.txt        
```

<br/>

### Inicializamos el repositorio

Un **repositorio** es como una carpeta dedicada para un proyecto. El repositorio de tu proyecto contiene todos los archivos del mismo y almacena el historial de cada una de las revisiones (versiones) de cada uno de los archivos.


```zsh
➜  alpha > git init
Initialized empty Git repository
```

`git init` convierte el directorio actual en un repositorio Git. Para ello, crea un directorio `.git` y crea algunos archivos dentro él. Estos archivos definen la configuración de Git y la historia del proyecto. Son archivos ordinarios, sin ninguna magia, el usuario puede leerlos y editarlos con un editor de texto o un shell. Es decir: el usuario puede leer y editar
la historia de su proyecto simplemente mirando esos ficheros (aunque casi nunca vas a hacerlo).

El directorio `alpha` tiene ahora este aspecto:

```zsh
alpha
├── .git
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── fsmonitor-watchman.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-merge-commit.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── prepare-commit-msg.sample
│   │   └── update.sample
│   ├── info
│   │   └── exclude
│   ├── objects
│   │   ├── info
│   │   └── pack
│   └── refs
│       ├── heads
│       └── tags
└── data
    └── letter.txt
```

TODO lo que hay dentro del directorio `.git` es propiedad de GIT (ahí van a estar todas las versiones del proyecto). El resto de ficheros se han convertido en la COPIA DE TRABAJO (WORKING COPY) y son propiedad del usuario. 

<br/>

### Añadimos algunos ficheros

Quiero decir que vamos a <ins>añadir ficheros **a GIT!!!**</ins> desde la Working Copy.

<br/>

**Añadimos el fichero letter.txt a GIT**

```zsh
➜  alpha git:(master) ✗ > git add data/letter.txt
```

Al ejecutar `git add` sobre `data/letter.txt` tiene dos efectos

<br/>

**PRIMERO**, se crea un fichero "blob" (binary large object) en el directorio `.git/objects/`. Este fichero blob contiene el contenido comprimido (con la librearía zlib) de `data/letter.txt`. El blob se nombra con la suma de comprobación SHA-1 del contenido y su cabecera. Lo sitúa en una subcarpeta con los primeros 2 caracteres del SHA-1 (`.git/objects/2e/`) y dentro está el archivo con los restantes 38 caracteres.

```zsh
alpha
├── .git
:   :
│   ├── objects
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e
```

Fíjate en que al añadir un archivo a Git se guarda su contenido en el directorio directorio `objects`, por lo tanto podrías incluso borrar tu "WORKING COPY" `data/carta.txt`. 

<br/>

**SEGUNDO**, `git add` añade el archivo al índice `.git/index`. El índice es una lista que contiene todos los archivos a los que hemos pedido hacer seguimiento. 

El índice se utiliza como un área de espera (stage) entre tu directorio de trabajo y tu repositorio. Puedes usar el índice para construir un conjunto de cambios que quieras confirmar (commit) juntos. Cuando hagas la confirmación (commit), lo que se confirma es lo que está actualmente en el índice, no lo que está en tu directorio de trabajo.

En cada línea del archivo índice (`.git/index`) tienes un archivo rastreado, con la información del hash de su contenido. Así que ahora nuestro indice es así: 

````zsh
➜  ~ > cat alpha/.git/index
DIRC`~ٳ���`~ٳ���	��}���.e��Eݧ�Q�t��H�u.data/letter.txt���;V��JަI�(7/7�%
````

¿Pero qué es eso?. Ojo, ten en cuenta que el formato del archivo es binario, así que tenemos que usar otro tipo de comandos para ver su contenido. 

```zsh
➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt

➜  alpha git:(master) ✗ > git status
:
Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   data/letter.txt
```

<br/>

**Creamos el fichero number.txt**

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

Como vimos antes, de nuevo, el comando `git add` crea un objeto blob que contiene el contenido de `data/number.txt`. Añade una entrada de índice para `datos/número.txt` que apunta al blob. Este es el índice después de que el comando `git add` se ejecute por segunda vez:


```zsh
➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt
100644 274c0052dd5408f8ae2bc8440029ff67d79bc5c3 0	data/number.txt
```

Observa que sólo los archivos del directorio `data` aparecen en el índice, aunque el usuario haya ejecutado `git add data`. El directorio `data`
no aparece por separado.

Cuando el usuario creó originalmente `datos/número.txt`, quería escribir "1", no
`1234`. 

```zsh
➜  alpha git:(master) ✗ > echo '1' > data/number.txt
➜  alpha git:(master) ✗ > git add data
```

Ahora bien, fíjate que tenemos 3 blobs... ¿podrías decirme porqué?. Además, en el índice solo aparecen dos ficheros ¿Podrías decirme porqué?

```zsh
alpha
├── .git
│   ├── objects
│   │   ├── 27
│   │   │   └── 4c0052dd5408f8ae2bc8440029ff67d79bc5c3
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e
│   │   ├── 56
│   │   │   └── a6051ca2b02b04ef92d5150c9ef600403cb1de
:
└── data
    ├── letter.txt
    └── number.txt


➜  alpha git:(master) ✗ > git ls-files --stage
100644 2e65efe2a145dda7ee51d1741299f848e5bf752e 0	data/letter.txt
100644 56a6051ca2b02b04ef92d5150c9ef600403cb1de 0	data/number.txt
```

Respuesta: 

Al cambiar el contenido `datos/número.txt` con un "1" y añadirlo a GIT realmentes estamos 1) añadiendo el "nuevo" archivo al índice de nuevo y eso significa crear un nuevo blob con el nuevo contenido y además actualizar la entrada del índice "datos/número.txt" para que **apunte al nuevo blob**.

<br/>

### Hacemos un COMMIT (Confirmamos)

Me adelanto un poco, es importante RECORDAR SIEMPRE que `git commit` trabaja en tu repositorio local (no en GitHub o similar), es algo que ocurre LOCALMENTE.

Vamos a por ello, hacer un commit es "confirmar" todo lo que tenemos en el STAGING AREA (área de espera), **capturando una instantánea de los cambios preparados en ese momento del proyecto** y llevándola (guardándola como una versión) en tu repositorio LOCAL. Las instantáneas confirmadas pueden considerarse como versiones "seguras" de un proyecto. 


```zsh
➜  alpha git:(master) ✗ > git commit -m 'a1'
[master (root-commit) 8c80d78] a1
 2 files changed, 2 insertions(+)
 create mode 100644 data/letter.txt
 create mode 100644 data/number.txt
 ```

El usuario hace el commit `a1`. Git imprime algunos datos sobre la confirmación. Estos datos tendrán sentido en breve.

 ```zsh
 alpha
├── .git
│   ├── COMMIT_EDITMSG
│   ├── HEAD
│   ├── description
│   ├── hooks
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       └── heads
│   │           └── master
│   ├── objects
│   │   ├── 0e
│   │   │   └── ed1217a2947f4930583229987d90fe5e8e0b74
│   │   ├── 27
│   │   │   └── 4c0052dd5408f8ae2bc8440029ff67d79bc5c3
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e
│   │   ├── 56
│   │   │   └── a6051ca2b02b04ef92d5150c9ef600403cb1de
│   │   ├── 8c
│   │   │   └── 80d787e43ca98d7a3f8465a5f323684899784c
│   │   ├── ff
│   │   │   └── e298c3ce8bb07326f888907996eaa48d266db4
│   │   ├── info
│   │   └── pack
│   └── refs
│       ├── heads
│       │   └── master
│       └── tags
└── data
    ├── letter.txt
    └── number.txt
```

<br/>

## Los tres pasos de un "Commit"

El comando COMMIT (de confirmación) hace 3 cosas (tiene tres pasos):

* Crea un **"tree graph"** (gráfico de árbol) para representar el contenido de la versión del proyecto que se está confirmando. 
* Crea un **objeto commit**
* Hace que la **rama actual apunte al nuevo objeto commit**.

```zsh
│   ├── objects
│   │   ├── 0e
│   │   │   └── ed1217a2947f4930583229987d90fe5e8e0b74    <- Tree Graph
│   │   ├── 27
│   │   │   └── 4c0052dd5408f8ae2bc8440029ff67d79bc5c3    <- number.txt con 1234
│   │   ├── 2e
│   │   │   └── 65efe2a145dda7ee51d1741299f848e5bf752e    <- letter.txt con a
│   │   ├── 56
│   │   │   └── a6051ca2b02b04ef92d5150c9ef600403cb1de    <- number.txt con 1
│   │   ├── 8c
│   │   │   └── 80d787e43ca98d7a3f8465a5f323684899784c    <- Objeto COMMIT
│   │   ├── ff
│   │   │   └── e298c3ce8bb07326f888907996eaa48d266db4    <- ???
```

<br/>

### Crea un "tree graph"

Git registra el estado actual del proyecto creando un gráfico de árbol a partir del índice. Este tree graph registra la ubicación y el contenido de cada archivo del proyecto. El "tree graph" se compone de dos tipos de objetos: blobs y trees (árboles).

* Los blobs son los que se almacenaron mediante `git add` y como ya vimos representan el contenido de los archivos. 
* Los trees (árboles) se crean y guardan cuando se hace un commit. Un árbol representa un directorio en la Working Copy (copia de trabajo).

Primero veamos el contenido del objeto Tree Graph (`0eed...`), que contiene las referencias con la ubicación y el contenido de cada archivo respecto al directorio `data` para el commit nuevo que acabamos de realizar:

```zsh
➜  alpha git:(master) > git --no-pager show 0eed
tree 0eed

letter.txt
number.txt
```

```
➜  alpha git:(master) > git --no-pager cat-file -p 0eed
100644 blob 2e65efe2a145dda7ee51d1741299f848e5bf752e	letter.txt
100644 blob 56a6051ca2b02b04ef92d5150c9ef600403cb1de	number.txt
```
La primera línea registra todo lo necesario para reproducir `data/letter.txt`. La primera parte establece los permisos del archivo. La segunda parte indica que el contenido de esta entrada está
representado por un blob, en lugar de un árbol. La tercera parte indica el hash del blob. La cuarta parte indica el nombre del archivo. La segunda línea es lo mismo pero para reproducir `data/number.txt`.

A continuación tenemos el objeto Tree (`0eed...`), árbol para `alpha`, que es el directorio raiz del proyecto. 

```zsh
➜  alpha git:(master) > git --no-pager cat-file -p ffe2
040000 tree 0eed1217a2947f4930583229987d90fe5e8e0b74	data
```

```zsh
➜  alpha git:(master) > git --no-pager show  ffe2
tree ffe2

data/
```

La única línea de este tree apunta al directorio `data`.

| ![Tree graph para el commit `a1`](/assets/img/git/1-a1-tree-graph.png) | 
|:--:| 
| *Tree graph para el commit `a1`* |

En el gráfico anterior, el árbol `raíz` apunta al árbol `data`. El árbol `data` apunta a los blobs de `data/letter.txt` y `datos/número.txt`.

<br/>


### Create a commit object

`git commit` creates a commit object after creating
the tree graph. The commit object is just another text file in
`.git/objects/`:

```zsh
    tree ffe298c3ce8bb07326f888907996eaa48d266db4
    author Mary Rose Cook <mary@maryrosecook.com> 1424798436 -0500
    committer Mary Rose Cook <mary@maryrosecook.com> 1424798436 -0500

    a1
```

The first line points at the tree graph. The hash is for the tree object
that represents the root of the working copy. That is: the
`alpha` directory. The last line is the commit
message.


| ![objeto commit ˋa1ˋ apuntando a su tree graph](/assets/img/git/2-a1-commit.png) | 
|:--:| 
| *objeto commit ˋa1ˋ apuntando a su tree graph* |


### Point the current branch at the new commit

Finally, the commit command points the current branch at the new commit
object.

Which is the current branch? Git goes to the `HEAD`
file at `.git/HEAD` and finds:

```zsh
    ref: refs/heads/master
```

This says that `HEAD` is pointing at
`master`. `master` is the
current branch.

`HEAD` and `master` are both
refs. A ref is a label used by Git or the user to identify a specific
commit.

The file that represents the `master` ref does not
exist, because this is the first commit to the repository. Git creates
the file at `.git/refs/heads/master` and sets its
content to the hash of the commit object:

```
    74ac3ad9cde0b265d2b4f1c778b283a6e2ffbafd
```

(If you are typing in these Git commands as you read, the hash of your
`a1` commit will be different from the hash of mine.
Content objects like blobs and trees always hash to the same value.
Commits do not, because they include dates and the names of their
creators.)

Let's add `HEAD` and `master` to
the Git graph:

![\`master\` pointing at the \`a1\`
commit](/assets/img/git/3-a1-refs.png)

::: {.image-caption}
\`HEAD\` pointing at \`master\` and \`master\` pointing at the \`a1\`
commit
```

`HEAD` points at `master`, as it
did before the commit. But `master` now exists and
points at the new commit object.

## Make a commit that is not the first commit

Below is the Git graph after the `a1` commit. The
working copy and index are included.

![\`a1\` commit shown with the working copy and
index](/assets/img/git/4-a1-wc-and-index.png)

::: {.image-caption}
\`a1\` commit shown with the working copy and index
```

Notice that the working copy, index, and `a1` commit
all have the same content for `data/letter.txt` and
`data/number.txt`. The index and
`HEAD` commit both use hashes to refer to blob
objects, but the working copy content is stored as text in a different
place.

```
    ~/alpha $ echo '2' > data/number.txt
```

The user sets the content of `data/number.txt` to
`2`. This updates the working copy, but leaves the
index and `HEAD` commit as they are.

![\`data/number.txt\` set to \`2\` in the working
copy](/assets/img/git/5-a1-wc-number-set-to-2.png)

::: {.image-caption}
\`data/number.txt\` set to \`2\` in the working copy
```

```
    ~/alpha $ git add data/number.txt
```

The user adds the file to Git. This adds a blob containing
`2` to the `objects` directory.
It points the index entry for `data/number.txt` at
the new blob.

![\`data/number.txt\` set to \`2\` in the working copy and
index](/assets/img/git/6-a1-wc-and-index-number-set-to-2.png)

::: {.image-caption}
\`data/number.txt\` set to \`2\` in the working copy and index
```

```
    ~/alpha $ git commit -m 'a2'
              [master f0af7e6] a2
```

The user commits. The steps for the commit are the same as before.

First, a new tree graph is created to represent the content of the
index.

The index entry for `data/number.txt` has changed.
The old `data` tree no longer reflects the indexed
state of the `data` directory. A new
`data` tree object must be created:

```
    100664 blob 2e65efe2a145dda7ee51d1741299f848e5bf752e letter.txt
    100664 blob d8263ee9860594d2806b0dfd1bfd17528b0ba2a4 number.txt
```

The new `data` tree hashes to a different value from
the old `data` tree. A new
`root` tree must be created to record this hash:

```
    040000 tree 40b0318811470aaacc577485777d7a6780e51f0b data
```

Second, a new commit object is created.

```
    tree ce72afb5ff229a39f6cce47b00d1b0ed60fe3556
    parent 774b54a193d6cfdd081e581a007d2e11f784b9fe
    author Mary Rose Cook <mary@maryrosecook.com> 1424813101 -0500
    committer Mary Rose Cook <mary@maryrosecook.com> 1424813101 -0500

    a2
```

The first line of the commit object points at the new
`root` tree object. The second line points at
`a1`: the commit's parent. To find the parent
commit, Git went to `HEAD`, followed it to
`master` and found the commit hash of
`a1`.

Third, the content of the `master` branch file is
set to the hash of the new commit.

![\`a2\` commit](/assets/img/git/7-a2.png)

::: {.image-caption}
\`a2\` commit
```

![Git graph without the working copy and
index](/assets/img/git/8-a2-just-objects-commits-and-refs.png)

::: {.image-caption}
Git graph without the working copy and index
```

**Graph property**: content is stored as a tree of objects. This means
that only diffs are stored in the objects database. Look at the graph
above. The `a2` commit reuses the
`a` blob that was made before the
`a1` commit. Similarly, if a whole directory doesn't
change from commit to commit, its tree and all the blobs and trees below
it can be reused. Generally, there are few content changes from commit
to commit. This means that Git can store large commit histories in a
small amount of space.

**Graph property**: each commit has a parent. This means that a
repository can store the history of a project.

**Graph property**: refs are entry points to one part of the commit
history or another. This means that commits can be given meaningful
names. The user organizes their work into lineages that are meaningful
to their project with concrete refs like
`fix-for-bug-376`. Git uses symbolic refs like
`HEAD`, `MERGE_HEAD` and
`FETCH_HEAD` to support commands that manipulate the
commit history.

**Graph property**: the nodes in the `objects/`
directory are immutable. This means that content is edited, not deleted.
Every piece of content ever added and every commit ever made is
somewhere in the `objects`
directory^[3](git-from-the-inside-out.html#fn:3){.footnote}^.

**Graph property**: refs are mutable. Therefore, the meaning of a ref
can change. The commit that `master` points at might
be the best version of a project at the moment, but, soon enough, it
will be superseded by a newer and better commit.

**Graph property**: the working copy and the commits pointed at by refs
are readily available, but other commits are not. This means that recent
history is easier to recall, but that it also changes more often. Or:
Git has a fading memory that must be jogged with increasingly vicious
prods.

The working copy is the easiest point in history to recall because it is
in the root of the repository. Recalling it doesn't even require a Git
command. It is also the least permanent point in history. The user can
make a dozen versions of a file but Git won't record any of them unless
they are added.

The commit that `HEAD` points at is very easy to
recall. It is at the tip of the branch that is checked out. To see its
content, the user can just
stash^[4](git-from-the-inside-out.html#fn:4){.footnote}^ and then
examine the working copy. At the same time, `HEAD`
is the most frequently changing ref.

The commit that a concrete ref points at is easy to recall. The user can
simply check out that branch. The tip of a branch changes less often
than `HEAD`, but often enough for the meaning of a
branch name to be changeable.

It is difficult to recall a commit that is not pointed at by any ref.
The further the user goes from a ref, the harder it will be for them to
construct the meaning of a commit. But the further back they go, the
less likely it is that someone will have changed history since they last
looked^[5](git-from-the-inside-out.html#fn:5){.footnote}^.

## Check out a commit

```
    ~/alpha $ git checkout 37888c2
              You are in 'detached HEAD' state...
```

The user checks out the `a2` commit using its hash.
(If you are running these Git commands, this one won't work. Use
`git log` to find the hash of your
`a2` commit.)

Checking out has four steps.

First, Git gets the `a2` commit and gets the tree
graph it points at.

Second, it writes the file entries in the tree graph to the working
copy. This results in no changes. The working copy already has the
content of the tree graph being written to it because
`HEAD` was already pointing via
`master` at the `a2` commit.

Third, Git writes the file entries in the tree graph to the index. This,
too, results in no changes. The index already has the content of the
`a2` commit.

Fourth, the content of `HEAD` is set to the hash of
the `a2` commit:

```
    f0af7e62679e144bb28c627ee3e8f7bdb235eee9
```

Setting the content of `HEAD` to a hash puts the
repository in the detached `HEAD` state. Notice in
the graph below that `HEAD` points directly at the
`a2` commit, rather than pointing at
`master`.

![Detached \`HEAD\` on \`a2\`
commit](/assets/img/git/9-a2-detached-head.png)

::: {.image-caption}
Detached \`HEAD\` on \`a2\` commit
```

```
    ~/alpha $ echo '3' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m 'a3'
              [detached HEAD 3645a0e] a3
```

The user sets the content of `data/number.txt` to
`3` and commits the change. Git goes to
`HEAD` to get the parent of the
`a3` commit. Instead of finding and following a
branch ref, it finds and returns the hash of the
`a2` commit.

Git updates `HEAD` to point directly at the hash of
the new `a3` commit. The repository is still in the
detached `HEAD` state. It is not on a branch because
no commit points at either `a3` or one of its
descendants. This means it is easy to lose.

From now on, trees and blobs will mostly be omitted from the graph
diagrams.

![\`a3\` commit that is not on a
branch](/assets/img/git/10-a3-detached-head.png)

::: {.image-caption}
\`a3\` commit that is not on a branch
```

## Create a branch

```
    ~/alpha $ git branch deputy
```

The user creates a new branch called `deputy`. This
just creates a new file at `.git/refs/heads/deputy`
that contains the hash that `HEAD` is pointing at:
the hash of the `a3` commit.

**Graph property**: branches are just refs and refs are just files. This
means that Git branches are lightweight.

The creation of the `deputy` branch puts the new
`a3` commit safely on a branch.
`HEAD` is still detached because it still points
directly at a commit.

![\`a3\` commit now on the \`deputy\`
branch](/assets/img/git/11-a3-on-deputy.png)

::: {.image-caption}
\`a3\` commit now on the \`deputy\` branch
```

## Check out a branch

```
    ~/alpha $ git checkout master
              Switched to branch 'master'
```

The user checks out the `master` branch.

First, Git gets the `a2` commit that
`master` points at and gets the tree graph the
commit points at.

Second, Git writes the file entries in the tree graph to the files of
the working copy. This sets the content of
`data/number.txt` to `2`.

Third, Git writes the file entries in the tree graph to the index. This
updates the entry for `data/number.txt` to the hash
of the `2` blob.

Fourth, Git points `HEAD` at
`master` by changing its content from a hash to:

```
    ref: refs/heads/master
```

![\`master\` checked out and pointing at the \`a2\`
commit](/assets/img/git/12-a3-on-master-on-a2.png)

::: {.image-caption}
\`master\` checked out and pointing at the \`a2\` commit
```

## Check out a branch that is incompatible with the working copy

```
    ~/alpha $ echo '789' > data/number.txt
    ~/alpha $ git checkout deputy
              Your changes to these files would be overwritten
              by checkout:
                data/number.txt
              Commit your changes or stash them before you
              switch branches.
```

The user accidentally sets the content of
`data/number.txt` to `789`. They
try to check out `deputy`. Git prevents the check
out.

`HEAD` points at `master` which
points at `a2` where
`data/number.txt` reads `2`.
`deputy` points at `a3` where
`data/number.txt` reads `3`. The
working copy version of `data/number.txt` reads
`789`. All these versions are different and the
differences must be resolved.

Git could replace the working copy version of
`data/number.txt` with the version in the commit
being checked out. But it avoids data loss at all costs.

Git could merge the working copy version with the version being checked
out. But this is complicated.

So, Git aborts the check out.

```
    ~/alpha $ echo '2' > data/number.txt
    ~/alpha $ git checkout deputy
              Switched to branch 'deputy'
```

The user notices that they accidentally edited
`data/number.txt` and sets the content back to
`2`. They check out `deputy`
successfully.

![\`deputy\` checked
out](/assets/img/git/13-a3ondeputy.png)

::: {.image-caption}
\`deputy\` checked out
```

## Merge an ancestor

```
    ~/alpha $ git merge master
              Already up-to-date.
```

The user merges `master` into
`deputy`. Merging two branches means merging two
commits. The first commit is the one that `deputy`
points at: the receiver. The second commit is the one that
`master` points at: the giver. For this merge, Git
does nothing. It reports it is
`Already up-to-date.`.

**Graph property**: the series of commits in the graph are interpreted
as a series of changes made to the content of the repository. This means
that, in a merge, if the giver commit is an ancestor of the receiver
commit, Git will do nothing. Those changes have already been
incorporated.

## Merge a descendent

```
    ~/alpha $ git checkout master
              Switched to branch 'master'
```

The user checks out `master`.

![\`master\` checked out and pointing at the \`a2\`
commit](/assets/img/git/14-a3-on-master-on-a2.png)

::: {.image-caption}
\`master\` checked out and pointing at the \`a2\` commit
```

```
    ~/alpha $ git merge deputy
              Fast-forward
```

They merge `deputy` into
`master`. Git discovers that the receiver commit,
`a2`, is an ancestor of the giver commit,
`a3`. It can do a fast-forward merge.

It gets the giver commit and gets the tree graph that it points at. It
writes the file entries in the tree graph to the working copy and the
index. It "fast-forwards" `master` to point at
`a3`.

![\`a3\` commit from \`deputy\` fast-forward merged into
\`master\`](/assets/img/git/15-a3-on-master.png)

::: {.image-caption}
\`a3\` commit from \`deputy\` fast-forward merged into \`master\`
```

**Graph property**: the series of commits in the graph are interpreted
as a series of changes made to the content of the repository. This means
that, in a merge, if the giver is a descendent of the receiver, history
is not changed. There is already a sequence of commits that describe the
change to make: the sequence of commits between the receiver and the
giver. But, though the Git history doesn't change, the Git graph does
change. The concrete ref that `HEAD` points at is
updated to point at the giver commit.

## Merge two commits from different lineages

```
    ~/alpha $ echo '4' > data/number.txt
    ~/alpha $ git add data/number.txt
    ~/alpha $ git commit -m 'a4'
              [master 7b7bd9a] a4
```

The user sets the content of `number.txt` to
`4` and commits the change to
`master`.

```
    ~/alpha $ git checkout deputy
              Switched to branch 'deputy'
    ~/alpha $ echo 'b' > data/letter.txt
    ~/alpha $ git add data/letter.txt
    ~/alpha $ git commit -m 'b3'
              [deputy 982dffb] b3
```

The user checks out `deputy`. They set the content
of `data/letter.txt` to `b` and
commit the change to `deputy`.

![\`a4\` committed to \`master\`, \`b3\` committed to \`deputy\` and
\`deputy\` checked
out](/assets/img/git/16-a4-b3-on-deputy.png)

::: {.image-caption}
\`a4\` committed to \`master\`, \`b3\` committed to \`deputy\` and
\`deputy\` checked out
```

**Graph property**: commits can share parents. This means that new
lineages can be created in the commit history.

**Graph property**: commits can have multiple parents. This means that
separate lineages can be joined by a commit with two parents: a merge
commit.

```
    ~/alpha $ git merge master -m 'b4'
              Merge made by the 'recursive' strategy.
```

The user merges `master` into
`deputy`.

Git discovers that the receiver, `b3`, and the
giver, `a4`, are in different lineages. It makes a
merge commit. This process has eight steps.

First, Git writes the hash of the giver commit to a file at
`alpha/.git/MERGE_HEAD`. The presence of this file
tells Git it is in the middle of merging.

Second, Git finds the base commit: the most recent ancestor that the
receiver and giver commits have in common.

![\`a3\`, the base commit of \`a4\` and
\`b3\`](/assets/img/git/17-a4-b3-on-deputy.png)

::: {.image-caption}
\`a3\`, the base commit of \`a4\` and \`b3\`
```

**Graph property**: commits have parents. This means that it is possible
to find the point at which two lineages diverged. Git traces backwards
from `b3` to find all its ancestors and backwards
from `a4` to find all its ancestors. It finds the
most recent ancestor shared by both lineages, `a3`.
This is the base commit.

Third, Git generates the indices for the base, receiver and giver
commits from their tree graphs.

Fourth, Git generates a diff that combines the changes made to the base
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

Fifth, the changes indicated by the entries in the diff are applied to
the working copy. The content of `data/letter.txt`
is set to `b` and the content of
`data/number.txt` is set to `4`.

Sixth, the changes indicated by the entries in the diff are applied to
the index. The entry for `data/letter.txt` is
pointed at the `b` blob and the entry for
`data/number.txt` is pointed at the
`4` blob.

Seventh, the updated index is committed:

```
    tree 20294508aea3fb6f05fcc49adaecc2e6d60f7e7d
    parent 982dffb20f8d6a25a8554cc8d765fb9f3ff1333b
    parent 7b7bd9a5253f47360d5787095afc5ba56591bfe7
    author Mary Rose Cook <mary@maryrosecook.com> 1425596551 -0500
    committer Mary Rose Cook <mary@maryrosecook.com> 1425596551 -0500

    b4
```

Notice that the commit has two parents.

Eighth, Git points the current branch, `deputy`, at
the new commit.

![\`b4\`, the merge commit resulting from the recursive merge of \`a4\`
into
\`b3\`](/assets/img/git/18-b4-on-deputy.png)

::: {.image-caption}
\`b4\`, the merge commit resulting from the recursive merge of \`a4\`
into \`b3\`
```

## Merge two commits from different lineages that both modify the same file

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

![\`deputy\` merged into \`master\` to bring \`master\` up to the latest
commit,
\`b4\`](/assets/img/git/19-b4-master-deputy-on-b4.png)

::: {.image-caption}
\`deputy\` merged into \`master\` to bring \`master\` up to the latest
commit, \`b4\`
```

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

![\`b5\` commit on \`deputy\` and \`b6\` commit on
\`master\`](/assets/img/git/20-b5-on-deputy-b6-on-master.png)

::: {.image-caption}
\`b5\` commit on \`deputy\` and \`b6\` commit on \`master\`
```

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

![\`MERGE_HEAD\` written during merge of \`b5\` into
\`b6\`](/assets/img/git/21-b6-on-master-with-merge-head.png)

::: {.image-caption}
\`MERGE_HEAD\` written during merge of \`b5\` into \`b6\`
```

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

![\`b11\`, the merge commit resulting from the conflicted, recursive
merge of \`b5\` into
\`b6\`](/assets/img/git/22-b11-on-master.png)

::: {.image-caption}
\`b11\`, the merge commit resulting from the conflicted, recursive merge
of \`b5\` into \`b6\`
```

## Remove a file

This diagram of the Git graph includes the commit history, the trees and
blobs for the latest commit, and the working copy and index:

![The working copy, index, \`b11\` commit and its tree
graph](/assets/img/git/23-b11-with-objects-wc-and-index.png)

::: {.image-caption}
The working copy, index, \`b11\` commit and its tree graph
```

```
    ~/alpha $ git rm data/letter.txt
              rm 'data/letter.txt'
```

The user tells Git to remove `data/letter.txt`. The
file is deleted from the working copy. The entry is deleted from the
index.

![After \`data/letter.txt\` \`rm\`ed from working copy and
index](/assets/img/git/24-b11-letter-removed-from-wc-and-index.png)

::: {.image-caption}
After \`data/letter.txt\` \`rm\`ed from working copy and index
```

```
    ~/alpha $ git commit -m '11'
              [master d14c7d2] 11
```

The user commits. As part of the commit, as always, Git builds a tree
graph that represents the content of the index.
`data/letter.txt` is not included in the tree graph
because it is not in the index.

![\`11\` commit made after \`data/letter.txt\`
\`rm\`ed](/assets/img/git/25-11.png)

::: {.image-caption}
\`11\` commit made after \`data/letter.txt\` \`rm\`ed
```

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

There is now another Git graph in the `bravo`
directory:

![New graph created when \`alpha\` \`cp\`ed to
\`bravo\`](/assets/img/git/26-11-cp-alpha-to-bravo.png)

::: {.image-caption}
New graph created when \`alpha\` \`cp\`ed to \`bravo\`
```

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

![\`12\` commit on \`bravo\`
repository](/assets/img/git/27-12-bravo.png)

::: {.image-caption}
\`12\` commit on \`bravo\` repository
```

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
`12` commit of `master` from
`bravo`.

![\`alpha\` after \`bravo/master\`
fetched](/assets/img/git/28-12-fetched-to-alpha.png)

::: {.image-caption}
\`alpha\` after \`bravo/master\` fetched
```

**Graph property**: objects can be copied. This means that history can
be shared between repositories.

**Graph property**: a repository can store remote branch refs like
`alpha/.git/refs/remotes/bravo/master`. This means
that a repository can record locally the state of a branch on a remote
repository. It is correct at the time it is fetched but will go out of
date if the remote branch changes.

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

![\`alpha\` after \`FETCH_HEAD\`
merged](/assets/img/git/29-12-merged-to-alpha.png)

::: {.image-caption}
\`alpha\` after \`FETCH_HEAD\` merged
```

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

![\`alpha\` and \`delta\` graphs after \`alpha\` cloned to
\`delta\`](/assets/img/git/30-13-alpha-cloned-to-delta-bare.png)

::: {.image-caption}
\`alpha\` and \`delta\` graphs after \`alpha\` cloned to \`delta\`
```

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

![\`14\` commit on
\`alpha\`](/assets/img/git/31-14-alpha.png)

::: {.image-caption}
\`14\` commit on \`alpha\`
```

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

![\`14\` commit pushed from \`alpha\` to
\`delta\`](/assets/img/git/32-14-pushed-to-delta.png)

::: {.image-caption}
\`14\` commit pushed from \`alpha\` to \`delta\`
```

## Summary

Git is built on a graph. Almost every Git command manipulates this
graph. To understand Git deeply, focus on the properties of this graph,
not workflows or commands.

To learn more about Git, investigate the `.git`
directory. It's not scary. Look inside. Change the content of files and
see what happens. Create a commit by hand. Try and see how badly you can
mess up a repo. Then repair it.

::: {.footnotes}
1.  ::: {#fn:1}
    In this case, the hash is longer than the original content. But, all
    pieces of content longer than the number of characters in a hash
    will be expressed more concisely than the
    original. [↩](git-from-the-inside-out.html#fnref:1){.reversefootnote}
    ```

2.  ::: {#fn:2}
    There is a chance that two different pieces of content will hash to
    the same value. But this chance [is
    low](http://crypto.stackexchange.com/a/2584). [↩](git-from-the-inside-out.html#fnref:2){.reversefootnote}
    ```

3.  ::: {#fn:3}
    `git prune` deletes all objects that cannot be
    reached from a ref. If the user runs this command, they may lose
    content. [↩](git-from-the-inside-out.html#fnref:3){.reversefootnote}
    ```

4.  ::: {#fn:4}
    `git stash` stores all the differences between
    the working copy and the `HEAD` commit in a safe
    place. They can be retrieved
    later. [↩](git-from-the-inside-out.html#fnref:4){.reversefootnote}
    ```

5.  ::: {#fn:5}
    The `rebase` command can be used to add, edit
    and delete commits in the
    history. [↩](git-from-the-inside-out.html#fnref:5){.reversefootnote}
    ```
```

::: {.tweet-link}
[ tweet this
post](https://twitter.com/intent/tweet?text=Git%20from%20the%20inside%20out&url=https://codewords.recurse.com/issues/two/git-from-the-inside-out&via=recursecenter)

------------------------------------------------------------------------

::: {.next-post}
Next: [How I learned to (stop worrying and) love
HTTP](https://codewords.recurse.com/issues/two/how-i-learned-to-stop-worrying-and-love-http)
```
```
```
```
```

::: {.container}
A publication from the [Recurse Center](https://www.recurse.com/)

-   ::: {#list-signup-container}
    ```

-   [[Twitter]{.icon .twitter}](https://twitter.com/recursecenter)

-   [Past Issues](https://codewords.recurse.com/issues)

-   [About](https://codewords.recurse.com/about){.page-link}
```
