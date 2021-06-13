## Pull Requests al Blog

Este repositorio es un Blog personal, para mis notas o apuntes técnicos y sobre todo para devolver y contribuir, a través de documentación, a la comunidad de Internet. Si te gusta y quieres contribuir sigue las pautas que describo más abajo.


<br/>

### Pautas para los pull-requests

Un Pull-Reuqest es una petición para que yo valide código (apuntes en este caso) que quieras publicar. En este [artículo](https://help.github.com/articles/using-pull-requests) de GitHub tienes información general sobre el tema. A continuación tienes los pasos y más adelante un pequeño tutorial a modo de ejemplo.

* **Issue**: Antes de trabajar en una nueva funcionalidad o documento, por favor [busca o crea un **Issue** en el repositorio original](https://github.com/LuisPalacios/LuisPalacios.github.io/issues) sobre el que vas a colaborar. Opcionalmente asígnatelo a ti mismo o a algún colaborador. 
* **Fork**: Haz un [Fork](https://help.github.com/articles/fork-a-repo/) de mi [repositorio LuisPalacios/LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io) y recuerda que el Blog está en la Branch `gh-pages`.
* **Clone**: Desde tu ordenador de trabajo, haz un Clone de tu propio Fork. 
* **Branch**: Crea una *Branch* específica para el *Issue* en tu *Clone* para que los cambios se independicen del resto de ramas. 
* **Modifica**: Trabaja sobre tu rama, haz **commits, push, etc...** en tu propio repositorio. Asegúrate de ejecutar tests y de que las páginas se ven bien y funcionan en todos los navegadores. 
* **Squash**. Si has hecho varios commits en tu Branch, intenta por favor agregarlos (squash) en un número menor de commits. 
* **Pull Request**: Realiza un [Pull Request](https://docs.github.com/es/github/collaborating-with-issues-and-pull-requests/about-pull-requests) contra la Branch `gh-pages`, que es donde están mis **apuntes técnicos**.
* **Revisión**: Revisaré el código/documentación y podría opcionalmente pedirte conformidad con el estilo general o algún otro cambio. 
* **Publicación**: Una vez aceptado haré un *merge* y pasará a estar disponible. 

<br/>

## Tutorial ejemplo

En este pequeño tutorial vemos al usuario `Agorastis Messaio` que va a contribuir a mi blog. 

<br/>

### Fork y Clone (sólo una vez)

* **Fork**: 
  * `Agorastis` se dió de alta e hizo Login en GitHub. 
  * Lo primero que tiene que hacer es un Fork del proyecto original: 
    * https://github.com/LuisPalacios/LuisPalacios.github.io
    * Se dirige al él y hace click en **FORK**
  * Obtiene **su propia copia**
    * https://github.com/AgorastisMesaio/LuisPalacios.github.io

* **Clone**:
  * `Agorastis` clona dicho Fork en su ordenador. 
  
```console
$ cd /home/agorastis
$ git clone git@github.com-agorastis:AgorastisMesaio/LuisPalacios.github.io.git
$ cd LuisPalacios.github.io
```

* Si listamos las Branch's, vemos que por defecto sólo se baja la `master`: 

```console
$ git branch
* master
```

* Por lo tanto cambio a la Branch `gh-pages`, de modo que la primera vez se la baja entera.

```console
$ git checkout gh-pages
Updating files: 100% (977/977), done.
Branch 'gh-pages' set up to track remote branch 'gh-pages' from 'origin'.
Switched to a new branch 'gh-pages'
```

| El **Fork y Clone** solo es necesario hacerlo una única vez. |
|:---:|

<br/>

### Contribuir 

* `Agorastis` entra en su Clone y cambia a `gh-pages` (se asegura que parte de la Branch correcta)

```console
$ cd /home/agorastis/LuisPalacios.github.io
$ git checkout gh-pages
```

* **Elije un Issue**: El siguiente paso consiste en decidir (o incluso crear) sobre qué [Issue en el repositorio original](https://github.com/LuisPalacios/LuisPalacios.github.io/issues) va a colaborar. En este ejemplo pensó en el [Issue "GDPR: Cookie consent #13"](https://github.com/LuisPalacios/LuisPalacios.github.io/issues/13). 

* **Crea una Branch Nueva**
  * En su Clone crea una rama nueva y le asigna un nombre donde se incluye el número del Issue. Este nombre puede ser cualquiera.
   
```console
$ git checkout -b 13-cookies
Switched to a new branch '13-cookies'
```

| Convención de Nombres (nombre de la Branch): "#-descripción", (`# == número de Issue`) |
|:---:|

* **Realiza las modificaciones/contribuciones** 
  * Editar ficheros, etc. En el ejemplo modificó el fichero `PR.md`

```console
$ vi PR.md
```

* **Hace commits**
  * Como en cualquier proyecto, opcionalmente hace uno o más `commit`'s. 
  
```console
$ git add PR.md
$ git commit -m "#13 Mejoro el fichero PR.md"
```

| Convención de Nombres (mensaje del commit): "#nn descripción", (`#nn` es el número de Issue) |
|:---:|

* **Sincroniza con su Fork**
  * Como en cualquier proyecto, puede hacer `push` a [su Fork en GitHub](https://github.com/AgorastisMesaio/LuisPalacios.github.io). El **primer `push`** es un poco diferente, solicita que se cree la branch `13.cookies` en su Fork y la marca como tracking-branch. 

```console
$ git push --set-upstream origin 13-cookies
```

| Nota: La primera vez que se hace el `push` nos invita a hacer el Pull Request, mostrando el enlace directo, aunque no es necesario hacerlo ahora... |
|:---:|


  * Si necesitas modificar más veces podrá hacer más `commits` y en **futuros `push`** ya no tendrás que usar la opción `--set-upstream`. A partir de ahora bastaría con `git push` a secas (git ya sabe quién es su tracking-branch)

```console
$ git push
```

* **Solicita un Pull Request**
  * Ha llegado el momento de pedir que se incorporen las modificaciones. 
  * `Agorastis` se dirige a [su Fork en GitHub](https://github.com/AgorastisMesaio/LuisPalacios.github.io), selecciona la Branch `13-cookies` que contiene las modificaciones.
  * Click en `Compare & Pull Request`
  * Selecciona: 
    * Repositorio BASE: `LuisPalacios/LuisPalacios.github.io`
    * Referencia BASE: Branch `gh-pages`
    * Repositorio HEAD: `AgorastisMesaio/LuisPalacios.github.io`
    * Ref. HEAD: Branch `13-cookies`
  * En el título el mismo mensaje que puso en el commit. 
  * Deja un mensaje explicativo con las modificaciones realizadas. 
  * Click en **CREATE A PULL REQUEST**

* **Revisiones a la Pull Request**
  * Podrá ocurrir que solicito revisiones o modificaciones extra desde el propio GitHub. A partir de ese momento tanto el usuario `Agorastis` como `Luis` podrán comunicarse sobre el `Issue #13` hasta que finalmente se acepte el Pull Request. 

  * El usuario `Agorastis` puede añadir más commits a su Branch `13-cookies` en `AgorastisMesaio/LuisPalacios.github.io`

```console
$ git add PR.md
$ git commit -m "#13 revisión PR.md"
$ git push
```

<br/>

### ¿Qué hago si el Repositorio original cambia?

Si durante el proceso el repo original cambia, querremos sincronizar con él.

* **Añadimos como remoto al original**
  * Para `bajarnos` las modificaciones que se puedan ir hadiendo en **upstream** (Mi repositorio original [LuisPalacios/LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io)) lo añadimos como `remote`

```console
git remote add upstream https://github.com/LuisPalacios/LuisPalacios.github.io.git
```

* **Merge de las modificaciones** que se hayan podido hacer en **upstream**

```console
$ git checkout 13-cookies
$ git fetch --all
$ git merge upstream/gh-pages
```

* **Seguimos trabajando en nuestro Branch** (ya actualizado), y si tengo más modificaciones las sigo suviendo a mi Fork:

```console
$ git add . 
$ git commit -m "#13 Cambios en PR.md"
$ git push
```


