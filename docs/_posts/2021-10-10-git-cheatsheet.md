---
title: "Chuleta sobre GIT"
date: "2021-10-10"
categories: desarrollo
tags: git
excerpt_separator: <!--more-->
---

![Logo GIT Cheatsheet](/assets/img/posts/logo-git-cheatsheet.svg){: width="150px" style="float:left; padding-right:25px" }

Este apunte contiene **mi ficha de ayuda sobre GIT**: Es mi hoja recordatorio que utilizo como programador, donde tengo las comando que más utilizo. Viene bien por ejemplo cuando borro accidentalmente un fichero, quiero consultar una versión anterior de código o quiero ignorar una modificación en un archivo concreto.

<br clear="left"/>
<!--more-->

| **Importante**: Este apunte lo uso como *referencia*, por lo tanto asume que conoces GIT. Si necesitas saber más te recomiendo este otro [apunte sobre GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}) |

### Básico

```zsh
git config --global user.name "Don Quijote"
git config --global user.email "donquijote@email.com"

mkdir -p /home/proyectos/miproyecto
cd /home/proyectos/miproyecto
git init

cd /home/proyectos
git clone https://github.com/LuisPalacios/LuisPalacios.github.io

cd /home/proyectos/miproyecto
git status
```

<br/>

### Tags

```zsh
$ git log --pretty=oneline
a7a05..d9114 (HEAD -> master, origin/master, origin/HEAD) Nueva versión
:
3f64b..37101 Versión terminada
ce5d4..1e621 Primer commit
$ git tag 1.0 3f64b           <== Aplicada al commit con hash 3f64b
$ git tag -d 1.0              <== La borro para añadirla de nuvo con anotación
$ git tag -a 1.0 -m "Primera versión operativa" 3f64b
$ git tag 2.0                 <== Aplica al último commit
$ git push origin 1.0         <== Envío tag o tags al origen.
$ git push origin --tags
```

<br/>

### Alias

```zsh
$ git config --global alias.lo '!git --no-pager log --graph --decorate --pretty=oneline --abbrev-commit'
$ git config --global alias.lg '!git lg1'
$ git config --global alias.lg1 '!git lg1-specific --all'
$ git config --global alias.lg1-specific "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %s - %an %C(blue)%d%C(reset)'"
```

```zsh
$ git lo
$ git lg
```

<br/>

### Deshacer

Técnicamente consiste en *Volver a la versión anterior de un archivo de la working copy*. Muy útil cuando hemos borrado o  modificado un archivo por error y queremos deshacer por completo y volver a su versión anterior (la del último commit).  Ojo que es destructivo, vuelve a dejar el contenido anterior del fichero y lo que hayamos modificado se pierde...

```zsh
$ git restore Capstone/dataset/0.dataclean/datos.ipynb
```

<br/>

## Importar un repositorio GIT local a GitHub

Está [aquí documentado](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github), hay dos formas de hacerlo y voy a describir la primera, con el GitHub CLI.

- "[Adding a local repository to GitHub with GitHub CLI](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github#adding-a-local-repository-to-github-with-github-cli)" - Lo puedes hacer todo desde tu ordenador, previa instalación del comando `gh`
- "[Adding a local repository to GitHub using Git](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github#adding-a-local-repository-to-github-using-git)" - Necesitas trabajar en tu ordenador y en GitHub.

- Instalo **GitHub CLI (`gh`)**

```shell
brew install gh  (MacOS)
apt install gh (Ubuntu)
```

- Creo un repositorio local `mirepo` con `git init`

```shell
mkdir -p /home/luis/prog/github-luispa/mirepo
cd /home/luis/prog/github-luispa/mirepo
git init
e README.md
git add .
git commit -m "primer commit"
```

- Antes de seguir, es bueno tener un Authentication Token. Puedes crear uno en [tu usuario de GitHub -> Token](https://github.com/settings/tokens). El token necesita los permisos de 'repo', 'read:org', 'admin:public_key'.

```shell
$ gh auth login
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations on this host? SSH
? Upload your SSH public key to your GitHub account? /Users/luis/.ssh/id_ed25519.pub
? Title for your SSH key: GitHub CLI
? How would you like to authenticate GitHub CLI? Paste an authentication token
? Paste your authentication token: ****************************************
:
```

- A continuación uso `gh` para "subir" mi repositorio local `mirepo` a GitHub, prefiero hacerlo de golpe en un solo comando:

```shell
cd /home/luis/prog/github-luispa/mirepo

gh repo create --description "Composición sobre Herencia en C++" --remote "CompositionOverInheritance" --source=. --public --push

✓ Created repository LuisPalacios/testLuisPa on GitHub
  https://github.com/LuisPalacios/testLuisPa
✓ Added remote git@github.com:LuisPalacios/testLuisPa.git
:
rama 'master' configurada para rastrear 'CompositionOverInheritance/master'.
✓ Pushed commits to git@github.com:LuisPalacios/testLuisPa.git
```

<br/>

## Github y Visual Studio Code basado en Web*

Si quieres trabajar con [VSCode desde tu navegador](https://docs.github.com/en/codespaces/the-githubdev-web-based-editor), directamente conectado culaquier repositorio alojado en GitHub, solo tienes que reemplazar `.com` por `.dev`. Si el repositorio es tuyo (has hecho login en GitHub) entonces tendrás derechos de edición y podrás hacer commits directamente. Un par de ejemplos:

- [https://github.dev/CiscoDevNet/netprog_basics](https://github.dev/CiscoDevNet/netprog_basics)
- [https://github.dev/LuisPalacios/LuisPalacios.github.io/tree/gh-pages](https://github.dev/LuisPalacios/LuisPalacios.github.io/tree/gh-pages)

<br/>

## Agrupar commits en ORIGIN/main

Esto es PELIGROSO, DESACONSEJADO y solo recomendado SI TIENES MUY CLARO LO QUE ESTÁS HACIENDO. De hecho solo lo aconsejo en repo's tuyos donde no estás colaborando, para limpiarlos (de muchos commits). A veces nos puede interesar.

El caso de uso es cuando tengo una única rama `main` en GitHub y solo estoy yo como desarrollador, he hecho muchos, pero que muchos commits con pequeñas modificaciones, mal documentados y quiero "limpiar" porque me encuentro con una rama `main` bastante sucia.

- Voy a coger como ejemplo mi rama `main` de un proyecto llamado `refrescar`. Mi situación original es que mi repo tiene 48 commits y quiero hacer un `squash` de los últimos 45 commits (fusionar los últimos 45 commits en uno solo).

- Lo curioso del tema es que esos commits están ya en ORIGIN (es decir en GitHub).

- El primer paso es hacer un clone o asegurarme de que mi copia local está a la última, completamente sincronizada y sobre todo que NO HAYA NADIE (ningún otro desarrollador haciendo push a origin/main).

```zsh
🍏 luis@asterix:refrescar (main) % git pull
🍏 luis@asterix:refrescar (main) % git rev-parse --short HEAD
28f5b2d
🍏 luis@asterix:refrescar (main) % git ls-remote --quiet | grep HEAD | cut -c 1-7
28f5b2d

Estos son los hash de los 48 commits...

28f5b2d  oop                 48  <== último commit
:
483583a  update gitignore    4
86dc978  update readme       3
ddea7e7  Update README.md    2
326d415  Initial commit      1er commit
```

- Preparo el editor que usa `git`. Lo vamos a necesitar a continuación, durante la operación de `rebase`.

  `git config --global core.editor code`

- IMPORTANTE. Una vez que inicias el `rebase`, si ves problemas, aborta con: `git rebase --abort`

- Empieza la fiesta, hago un `rebase` de los últimos 45 commits

```zsh
🍏 luis@asterix:refrescar (main) % git rebase -i origin/main~45 main
```

- Se abrirá el editor automáticamente y mostrará todos los commits, desde el tercero #86dc978 (48-45=3) hasta el último #28f5b2d.

```txt
pick   86dc978 update readme     <== 3er commit (48-45)    \
squash 483583a update gitignore                            |
:                                                           > Fusionar
squash fe1dd07 oop                                         |
squash 28f5b2d oop               <== ÚLTIMO COMMIT         /
````

- En el editor aparecen todos los commits con la palabra `pick`. Ahora tengo que decidir, entre estas opciones:
  - pick: Mantiene el commit tal como está.
  - reword: Permite cambiar el mensaje del commit.
  - edit: Permite editar el contenido del commit.
  - squash: Combina este commit con el anterior, conservando ambos mensajes de commit.
  - fixup: Similar a squash, pero solo guarda el mensaje del commit anterior.
  - drop: Elimina el commit de la lista.

- Dejo la primera línea (3er commit histórico) con `pick 86dc978` y cambio todos los otros *pick's* a `squash`. Salvo el fichero y salgo del editor. Automáticamente intenta hacer lo que le hemos pedido, pero en mi caso detecta un conflicto (esto es normal y viene bien para que veas cómo resolverlo):

```zsh
🍏 luis@asterix:refrescar (main) % git rebase -i origin/main~45 main
Auto-fusionando 29-oop-rpg/src/programa.cpp
CONFLICTO (contenido): Conflicto de fusión en 29-oop-rpg/src/programa.cpp
error: no se pudo aplicar 357d14f... oop
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
hint: You can instead skip this commit: run "git rebase --skip".
hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
hint: Disable this message with "git config advice.mergeConflict false"
No se pudo aplicar 357d14f... oop
```

- Edito el fichero con el conflicto en cuestión, resuelvo los conflictos y lo salvo.

```zsh
🍏 luis@asterix:refrescarA ● ●(main) rebase-i +?) % e 29-oop-rpg/src/programa.cpp
```

- Los marco como resueltos añadiendolos y continúo con el rebase

```zsh
🍏 luis@asterix:refrescarA ● ●(main) rebase-i +?) % git add .
🍏 luis@asterix:refrescarA ● ●(main) rebase-i +?) % git rebase --continue
```

- Podriá volver a ocurrir que hay conflictos, repito los pasos...

```zsh
🍏 luis@asterix:refrescar (main) % e fichero-con-conflicto...
🍏 luis@asterix:refrescar (main) % git add .
🍏 luis@asterix:refrescar (main) % git rebase --continue

Irá mostrando el editor y este proceso puede tardar un rato, depende de cuantos conflictos tengas...

```

- Llegará un momento donde dejas de tener conflictos, verás el mensaje `Rebase aplicado satisfactoriamente y actualizado refs/heads/main.`

```zsh
Rebase aplicado satisfactoriamente y actualizado refs/heads/main.
🍏 luis@asterix:refrescar (● main ↕) % git status
En la rama main
Tu rama y 'origin/main' han divergido,
y tienen 1 y 46 commits diferentes cada una respectivamente.
  (use "git pull" if you want to integrate the remote branch with yours)

nada para hacer commit, el árbol de trabajo está limpio
```

- Ahora llegamos al punto crítico. Vamos a mandar a ORIGIN/main nuestra copia haciendo un FORCE PUSH

```zsh
🍏 luis@asterix:refrescar (● main ↕) % git push origin +main
Enumerando objetos: 117, listo.
Contando objetos: 100% (117/117), listo.
Compresión delta usando hasta 12 hilos
Comprimiendo objetos: 100% (105/105), listo.
Escribiendo objetos: 100% (114/114), 30.13 KiB | 10.04 MiB/s, listo.
Total 114 (delta 19), reused 82 (delta 8), pack-reused 0 (from 0)
remote: Resolving deltas: 100% (19/19), completed with 1 local object.
To github.com-LuisPalacios:LuisPalacios/refrescar.git
 + 5a42ca6...96b4c8d main -> main (forced update)
```

- Muestro el log de mis commits

```zsh
🍏 luis@asterix:refrescar (main) % git log --all --decorate --oneline --graph
* 96b4c8d (HEAD -> main, origin/main, origin/HEAD) Commit agregado de 45 commits final
* ddea7e7 Update README.md
* 326d415 Initial commit
```

- El repo queda ya con solo 3 commits !!

{% include showImagen.html
      src="/assets/img/posts/2021-10-10-git-cheatsheet-00.png"
      caption="Repositorio final"
      width="800px"
      %}

- Los commits que han quedado son:

```zsh
96b4c8d  Commit agregado de 45 commits     3er  <== COMMIT que agrega todo
ddea7e7  Update README.md                  2o
326d415  Initial commit                    1er commit
```

<br/>

||
|-|
| Nota: **ATENCIÓN !!!! Es muy importante que el resto de desarrolladores borren su copia local o hagan un reset de su clone actual** |
||

Si otro desarrollador hace un push (--force) desde una rama local (antigua) volverán a aparecer todos los commits. La recomendación es volver a hacer una de las opciones siguientes:

1. Borrar el repositorio local y volver a hacer un clone

2. Reset del respositorio local y pull. A continuación muestro un ejemplo, tenía el repositorio ANTIGUO copiado en "refrescar.old"

```zsh
🍏 luis@asterix:refrescar.old (● main ↕) % git reset --hard origin/main
HEAD está ahora en 96b4c8d Commit agregado de 45 commits final
🍏 luis@asterix:refrescar.old (main) % git clean -xdf
🍏 luis@asterix:refrescar.old (main) % git pull
Ya está actualizado.

🍏 luis@asterix:refrescar.old (main) % git log --all --decorate --oneline --graph
* 96b4c8d (HEAD -> main, origin/main, origin/HEAD) Commit agregado de 45 commits final
* ddea7e7 Update README.md
* 326d415 Initial commit
```

<br/>

## Cambiar Autor de commits

Esto es PELIGROSO, DESACONSEJADO y solo recomendado SI TIENES MUY CLARO LO QUE ESTÁS HACIENDO. El caso de uso es cuando tenemos muy claro que el nombre (y/o email) del autor de commits es erroneo.

Usaremos el comando `git filter-branch` que reescribe el historial del repositorio, por lo que debes tener cuidado y hacer un respaldo del repositorio antes de realizar estos cambios.

### Repasar commit

Para averiguar el mail con el que se hizo un determinado commit:

```zsh
git show -s --format='%ae' <HASH corto del commit>
```

Para repasar quién hizo los commits:

```zsh
git log --pretty=format:"%h %ce %ae"| grep -i <nombre o email>
```

### Renombrar autor/email de los commit

Navega a tu repositorio y asegúrate que lo tienes actualizado

```zsh
cd /ruta/al/repositorio/mirepo
git pull
```

Te recomiendo que hagas una copia de seguridad

```zsh
cp -r /ruta/al/repositorio/mirepo /ruta/al/respaldo/mirepo.bak
```

Utiliza `git filter-branch` para cambiar el nombre + email del autor en todos los commits:

```zsh
git filter-branch --env-filter '
OLD_EMAIL="email_incorrecto@ejemplo.com"
CORRECT_NAME="Nombre Correcto"
CORRECT_EMAIL="email_correcto@ejemplo.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```

El comando anterior crea una copia de seguridad bajo `.git/refs/original/*`. Es muy buena idea tenerla para el caso de que hayas hecho algo mal. Recomiendo inspeccionar que todo ha ido bien, con el comando siguiente:

```zsh
git log
```

Una vez revisado, haz push de los cambios al repositorio remoto

```zsh
git push --force --tags origin 'refs/heads/*'
```

Cuando terminas y estas seguro de que todo está bien puedes eliminar la copia de seguridad de la referencia (en mi caso, en este ejemplo el nombre de la rama es `main`)

```zsh
git update-ref -d refs/original/refs/heads/main
```
