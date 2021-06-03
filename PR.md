## Pull Requests al Blog

Si te gusta este repositorio y quieres contribuir hazte un `fork` (bifurcación) para poder trabajar de forma separada. Cuando quieras que las incorpore a mi repositorio original podrás hacerme un `Pull Request` (PR) solicitándolo.

Un PR es una petición para que valide el código (o documento en este caso) que se quiere fusionar. Lo lógico es que te apoyes en los `Issues` que voy creando para darle seguimiento. 

En este [artículo](https://help.github.com/articles/using-pull-requests) de GitHub tienes información general sobre los PR. A continuación describo una guía con los pasos necesarios y un pequeño tutorial a modo de ejemplo.

<br/>

### Pautas para los pull-requests

Lo primero y recomendado es hacer un Fork y un Clone, pasos que solo tienes que hacer la primera vez. 

* **Crea un Fork**: Haz un [Fork](https://help.github.com/articles/fork-a-repo/) de mi [repositorio LuisPalacios/LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io)
* **Haz un Clone**: Desde tu ordenador de trabajo, haz un Clone de tu propio Fork. 

Colaboración en el proyecto: 

* **Elije un Issue**: Busca o crea un [Issue en el repositorio original](https://github.com/LuisPalacios/LuisPalacios.github.io/issues) sobre el que vas a colaborar.
* **Créa una Branch dedicada a dicho issue** en tu Clone.
* **Modifica** los ficheros correspondientes, haz **commits, push, etc...** en tu propio repositorio mientras trabajas en dicha Branch.
* **Realiza un [Pull Request](https://docs.github.com/es/github/collaborating-with-issues-and-pull-requests/about-pull-requests)** a la rama donde están los **apuntes técnicos**, (`gh-pages`).

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
  * `Agorastis` clona dicho Fork en su ordendor. 
  
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

<br/>

### Contribuir 

Como decía, Fork y Clone sólo una vez. Esta parte se repite por cada modificación o contribución. 

* `Agorastis` entra en su Clone y cambia a `gh-pages` (se asegura que parte de la Branch correcta)

```console
$ cd /home/agorastis/LuisPalacios.github.io
$ git checkout gh-pages
```

* **Elije un Issue**: El siguiente paso consiste en decidir (o incluso crear) sobre qué [Issue en el repositorio original](https://github.com/LuisPalacios/LuisPalacios.github.io/issues) va a colaborar. En ete ejemplo pensó en el [Issue "GDPR: Cookie consent #13"](https://github.com/LuisPalacios/LuisPalacios.github.io/issues/13). 

* **Crea una Branch Nueva**
  * En su Clone crea una rama nueva y le asigna un nombre donde se incluye el número del Issue. Este nombre puede ser cualquiera.
   
```console
$ git checkout -b 13-cookies
Switched to a new branch '13-cookies'
```

| Convención de Nombres (nombre de la Branch): "#-descripción", (`# == número de Issue`) |

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

* **Sincroniza con su Fork**
  * Como en cualquier proyecto, puede hacer `push` a [su Fork en GitHub](https://github.com/AgorastisMesaio/LuisPalacios.github.io). El **primer `push`** es un poco diferente, solicita que se cree la branch `13.cookies` en su Fork y la marca como tracking-branch. 

```console
$ git push --set-upstream origin 13-cookies
```

| Nota: La primera vez que se hace el `push` nos invita a hacer el Pull Request, mostrando el enlace directo, aunque no es necesario hacerlo ahora... |

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
  * Para `bajarnos` las modificaciones que se hayan podido hacer en el Repositorio original [repositorio LuisPalacios/LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io) primero lo añadimos como `remote`

```console
git remote add upstream https://github.com/LuisPalacios/LuisPalacios.github.io.git
```

git checkout master
    git fetch --all
    git merge upstream/master

Then we can rebase our master onto our feature branch and then push the feature branch to our repo. Remember that changes pushed to a branch from wich we have already requested a pull will be integrated in the pull request. That's another reason why it is convenient to request the pull from our feature branch, and not from our master.



