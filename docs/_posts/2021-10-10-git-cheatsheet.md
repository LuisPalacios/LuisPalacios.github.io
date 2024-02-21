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


**Básico**

```zsh
$ git config --global user.name "Don Quijote"
$ git config --global user.email "donquijote@email.com"

$ mkdir -p /home/proyectos/miproyecto
$ cd /home/proyectos/miproyecto
$ git init

$ cd /home/proyectos
$ git clone https://github.com/LuisPalacios/LuisPalacios.github.io

$ cd /home/proyectos/miproyecto
$ git status
```

<br/>

**Tags**

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

**Alias**

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

**Deshacer**.

Técnicamente consiste en *Volver a la versión anterior de un archivo de la working copy*. Muy útil cuando hemos borrado o  modificado un archivo por error y queremos deshacer por completo y volver a su versión anterior (la del último commit).  Ojo que es destructivo, vuelve a dejar el contenido anterior del fichero y lo que hayamos modificado se pierde... 

```zsh
$ git restore Capstone/dataset/0.dataclean/datos.ipynb
```

<br/>

**Importar un repositorio GIT local a GitHub**

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

**Github y Visual Studio Code basado en Web**

Si quieres trabajar con [VSCode desde tu navegador](https://docs.github.com/en/codespaces/the-githubdev-web-based-editor), directamente conectado culaquier repositorio alojado en GitHub, solo tienes que reemplazar `.com` por `.dev`. Si el repositorio es tuyo (has hecho login en GitHub) entonces tendrás derechos de edición y podrás hacer commits directamente. Un par de ejemplos:

- [https://github.dev/CiscoDevNet/netprog_basics](https://github.dev/CiscoDevNet/netprog_basics)
- [https://github.dev/LuisPalacios/LuisPalacios.github.io/tree/gh-pages](https://github.dev/LuisPalacios/LuisPalacios.github.io/tree/gh-pages)

<br/>


---
