---
title: "MAC para desarrollo"
date: "2023-04-15"
categories: desarrollo
tags: macos homebrew python git gem ruby ror iterm ohmyzsh zsh xcode code vscode visual studio
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-mac-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo mi bitácora de configuración de un Mac (Ventura) como equipo de desarrollo. Instalo varias aplicaciones gráficas y de línea de comando que para mi son fundamentales para trabajar con el equipo. 

Parto de una instalación nueva de Ventura y el orden de instalación y configuración es el del apunte. Empiezo por Visual Studio Code, continúo con iTerm, Oh My Zsh, Homebrew, etc. 


<br clear="left"/>
<!--more-->


#### Xcode command line tools

En algún momento vas a tener que instalar las "Apple command line tools" que también se conocen como "Xcode command line tools" y además tienes que aceptar la licencia. Ahora es un buen momento.

```zsh
xcode-select --install
sudo xcodebuild -license accept
```

<br/>

#### Fichero `~/.zshrc`

Durante la preparación lo voy a modificar varias veces. Dejo aquí la copia final de este fichero ya completa y compatible con **Oh My Zsh** (aunque este lo instalo dentro de un par de pasos). Te recomiendo que uses mi versión, está bastante probada. En los siguientes puntos explicaré que se configura relacionado en este fichero. 

- Copia de mi [`.zshrc`](https://gist.github.com/LuisPalacios/f66942b329af7920bebd4b95fa36cdb5)

<br/>

#### Visual Studio Code 


![logo linux router](/assets/img/posts/logo-vscode.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Visual Studio Code es un editor de código fuente desarrollado por Microsoft para Windows, Linux, macOS y Web. Incluye soporte para la depuración, control integrado de Git, resaltado de sintaxis, finalización inteligente de código, fragmentos y refactorización de código. Puedes editar, depurar, probar, controlar versiones e implementar en la nube. Con la diversidad de características, plugins y lenguajes soportados puedes usarlo como IDE para cualquier proyecto. 

Esta es fácil, descargo e instalo (versión Universal estable) [desde aquí](https://code.visualstudio.com/docs/?dv=osx).

<br/>

#### iTerm2

![logo linux router](/assets/img/posts/logo-iterm2.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[iTerm2](https://iterm2.com) es un sustituto al **Terminal.app** del MacOS. Admite muchas más cosas que el Terminal como la transparencia de ventanas, modo de pantalla completa, paneles divididos, pestañas Exposé, notificaciones Growl y atajos de teclado, perfiles personalizables y reproducción instantánea de entradas/salidas de terminales anteriores. 

Lo descargo, copio a Aplicaciones y lo ejecuto. Si no lo hiciste al principio, te pedirá que instales las "Apple Command Line Tools". 

| Nota: Si sufres el siguiente problema: "Cuando iTerm arranca tarda mucho en mostrar el prompt", se resuelve con `sudo xcodebuild -license accept` |

Activo un atajo en Finder, para poder abrir un `iTerm` cuando el cursor está en una carpeta. 

* `Ajustes Sistema → Teclado → Funciones rápidas de teclado → Servicios`
    * `Archivos y carpetas → Nueva pestaña Terminal en carpeta` → `Ctrl Shift T`

<br/> 

#### Oh My Zsh

![logo linux router](/assets/img/posts/logo-ohmyzsh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[oh-my-zsh](https://ohmyz.sh) es un entorno de trabajo en línea de comando mucho más bonito para trabajar con **Zsh**. Viene con miles de funciones útiles, ayudantes, plugins, temas. Trae varios plugins que hacen la vida más fácil. [Lo mejor de Oh My Zsh son sus temas](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes).

Ejecuto el proceso de instalación.

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

| Recordatorio: como dije al principio, una vez instalado iTerm + Oh My Zsh te recomiendo que copies el contenido de mi fichero [`.zshrc`](https://gist.github.com/LuisPalacios/f66942b329af7920bebd4b95fa36cdb5), salgas del terminal y vuelvas a arrancar *iTerm* |

<br/>

### Homebrew


![logo linux router](/assets/img/posts/logo-homebrew.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Diendo desarrollador con un Mac, quieres [Homebrew](https://brew.sh/index_es) (o `brew` por resumir) Aunque Mac OS trae de todo (al estar basado en FreeBSD) por desgracia no está a la última y le faltan cosas. 

Con `brew` vas a poder instalar (**en paralelo a tu Mac OS (sin tocarlo ni estropearlo)**) un montón de programas de software libre super interesantes, software de bajo nivel, herramientas para la línea de commandos, aplicaciones, compiladores, lenguajes, etc. podrás instalar hasta MongoDB (ver más adelante).

Ejecuto el script de instalación.

```zsh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

| Recuerda salir de iTerm y volver a entrar o ejecutar `source ~/.zshrc` para que encuentre los nuevos ejecutables |

Compruebo la versión

```zsh
brew --version
Homebrew 4.0.14
```

Las siguientes líneas son solo de referencia. 

Ver qué está instalado:

```zsh
brew list
brew cask list
```

Actualizar `brew`:

```zsh
brew [-v] update
brew [-v] upgrade
```

Ejemplos de instalaciones que puedes hacer:

```zsh
brew install wget
brew install imagemagick
```

Comprobar que está correctamente instalado y actualizado

```zsh
brew update && brew upgrade
brew doctor
brew --version
```

Estas son las líneas relevantes del `~/.zshrc` 

```zsh
# LuisPa: --------------------------------------------------------------
export PATH=$HOME/0_priv/bin:/usr/local/bin:/usr/local/sbin:$PATH
launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:$PATH"
# Homebrew
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/luis/.zprofile  # Homebrew en Mac ARM
eval "$(/opt/homebrew/bin/brew shellenv)"                                          # Homebrew en Mac ARM
#(echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> /Users/luis/.zprofile    # Homebrew en Mac Intel
#eval "$(/usr/local/bin/brew shellenv)"                                            # Homebrew en Mac Intel
# Ruby y Gems
export PATH="/opt/homebrew/opt/ruby/bin:~/.gems/bin:$PATH"   # Versión para Mac ARM
#export PATH="/usr/local/opt/ruby/bin:~/.gems/bin:$PATH"     # Versión para Mac Intel
# LuisPa: --------------------------------------------------------------
```

<br/>

#### Git

![logo linux router](/assets/img/posts/logo-git.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[GIT](https://git-scm.com) es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia. Existen varias opciones de Instalación del cliente para la línea de comandos ([fuente original](https://git-scm.com/download/mac)), en mi caso utilizo la de Homebrew.

Realizo la instalación de Git desde homebrew.  Recuerda salir de la sesión del terminal y volver a entrar o ejecutar `source ~/.zshrc` para que encuentre los nuevos ejecutables.

```zsh
brew update && brew upgrade
brew install git
```


Creo el fichero `~/.gitconfig` y `~/.gitignore_global`, dejo aquí copia de los míos:

```zsh
curl -s -O https://gist.githubusercontent.com/LuisPalacios/0ee871ee236485d4a064179b16ada400/raw/348a8a448095a460756f85ef0362521b886b0a2e/.gitconfig
curl -s -O https://gist.githubusercontent.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c/raw/65d0ed6acba83ece4db78228821589212b9f9f4b/.gitignore_global
e .gitconfig
```

Como cliente GUI instalo [GitKraken](https://www.gitkraken.com). 

Dejo más información sobre git en esta [chuleta sobre GIT]({% post_url 2021-10-10-git-cheatsheet %}) y [GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}). 

<br/>

#### SSH

![logo linux router](/assets/img/posts/logo-ssh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Ahora es buen momento para configurar tu pareja de clave pública/privada para conectar con Hosts remotos y/o usarlo con servidor(es) Git, GitHub, GitLab, Gitea. 

Una vez creado ya puedes añadir el contenido del fichero `.ssh/id_ed25519.pub` a aquellos sitios con los que quiera conectar, por ejemplo: 

* Linux remotos. Enviar tu clave pública y añadir a su fichero `~/.ssh/authorized_keys`
* Servidores GIT. Úsar tu clave pública para poder hacer commits. 


```zsh
➜  ~ ssh-keygen -t ed25519 -a 200 -C "luis@mihost" -f ~/.ssh/id_ed25519
Generating public/private ed25519 key pair.
Created directory '/Users/luis/.ssh'.
Enter passphrase (empty for no passphrase):            <=== Pon una contraseña que usarás para hacer login remoto.
Your identification has been saved in /Users/luis/.ssh/id_ed25519   <== NUNCA LO COMPARTAS
Your public key has been saved in /Users/luis/.ssh/id_ed25519.pub   <== ESTE es el que compartes !!
:
```


Tienes un par de apuntes adicionales en el blog, el de [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y el de [SSH en Linux]({% post_url 2009-02-01-ssh %})

<br/>

#### Xcode

![logo linux router](/assets/img/posts/logo-xcode.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Un clásico, Xcode es un entorno de desarrollo integrado para macOS que contiene un conjunto de herramientas creadas por Apple destinadas al desarrollo de software para macOS, iOS, watchOS y tvOS. Instalo Xcode directamente desde el App Store.

Lo dije al principio, en algún momento de todo este proceso vas a tener que instalar las "Apple command line tools" y además tienes que aceptar la licencia.

```zsh
xcode-select --install
sudo xcodebuild -license accept
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-01.png"
    caption="Pantalla de inicio de Xcode."
    width="500px"
    %}

<br/>

#### Python, Pip y PipEnv

![logo linux router](/assets/img/posts/logo-python.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

**[Python](https://www.python.org)** es un lenguaje de programación interpretado cuya filosofía hace hincapié en la legibilidad de su código.​ Soporta parcialmente la orientación a objetos, programación imperativa y algo de programación funcional. MacOS trae versiones antiguas de Python 2 y 3 que NUNCA deben borrarse o sobreescribir. Uso Homebrew para hacer una instalación paralela. 

**[Pip](https://pypi.org/project/pip/)** es un indispensable, es el sistema de gestión de paquetes utilizado para instalar y administrar programas y paquetes hechos en Python desde **PyPI**, el [Python Package Index](https://pypi.org), el repositorio de software oficial para aplicaciones de terceros en el lenguaje de programación Python. 

**[PipEnv](https://pipenv.pypa.io/en/latest/)** es otro indispensable. Las aplicaciones en Python hacen uso de paquetes y módulos que no forman parte de la librería estándar. Gestionar las librerías que deben acompañar a mi programa es un infierno. Con **`PipEnv`** puedo "contener" todo dentro de un directorio, creando un entorno virtual, sin conflictos. Nota: hay dos paquetes equivalentes a **`PipEnv`**, se trata de [Virtualenv](https://virtualenv.pypa.io/en/latest/): (obsoleto) y [Conda](https://docs.conda.io/projects/conda/en/latest/index.html) (demasiado pesado). En mi caso siempre uso **`PipEnv`**. 
  
Veamos el proceso de instalación vía Hombrebrew.

```zsh
brew install python     <--- (También nos instala pip)
brew install pipenv
```

| Recuerda salir de iTerm y volver a entrar o ejecutar `source ~/.zshrc` para que encuentre los nuevos ejecutables |

Cuando instalamos Homebrew (en un paso anterior) ya habíamos modificado el fichero `~/.zshrc` para modificar la variable `PATH`. Homebrew deja los ejecutables en `/usr/local/` en Mac's Intel y en `/opt/homebrew` en Mac's ARM. Creo un par de alias, de modo que al ejecutar `python` o `pip` en realidad se ejecuten las últimsa versiones de Homebrew

```zsh
# Añado al final de ~/.zshrc
# Mac ARM
alias python="/opt/homebrew/bin/python3"
alias pip="/opt/homebrew/bin/pip3"
# Mac Intel
#alias python="/usr/local/bin/python3"
#alias pip="/usr/local/bin/pip3"
```

Compruevo las versiones

```zsh
python --version
  Python 3.11.3
pip --version
  pip 23.0.1 from /opt/homebrew/lib/python3.11/site-packages/pip (python 3.11)
pipenv --version
  pipenv, version 2023.3.20
```

* Prueba de concepto: Crear un mini proyecto.

Voy a crear un mini proyecto en Python, con un único fuente llamado `main.py` bajo un entorno virtual preparado con `pipenv`. Recuerda que **debes instalar las librerías necesarias con `pipenv` siempre desde el directorio de tu proyecto**. En este ejemplo uso la librería `requests`.

```zsh
cd Desktop
mkdir proyecto
cd proyecto
pipenv install requests
pipenv lock
```

Copia el código siguiente, ejecuta `cat > main.py`, pégalo y sal: `⌘V, ⮐, ⌃D`
```python
import requests
response = requests.get('https://httpbin.org/ip')
print('Tu dirección IP es: {0}'.format(response.json()['origin']))
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-02.png"
    caption="Ejecuto desde el entorno seguro `pipenv` y funciona."
    width="500px"
    %}

Ya tienes `python` instalado y funcionando. Podemos borrar el directorio de pruebas. 

```zsh
cd ~/Desktop
rm -fr proyecto
```

<br/>

#### Ruby

![logo linux router](/assets/img/posts/logo-ruby.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

MacOS ya trae Ruby, pero voy a instalar la última versión con Hombrew en paralelo. Necesito `Bundler` y `Jekyll` (ver más adelante) para trabajar en mi blog en local (más info [aquí]({% post_url 2021-04-19-nuevo-blog %})). **Ruby** es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995.

```zsh
brew install ruby
```

Ruby no se asocia directamente al directorio de instalación de Homebrew al terminar de instalarlo y el motivo es que podría entrar en conflicto con la instalación de Ruby que trae el MacOS. En mi caso sí que quiero que se ejecute este nuevo Ruby así que añado su PATH en el fichero `.zshrc` y también el sitio donde voy a instalar las futuras "gemas" (`~/.gems/bin`).

```zsh
# LuisPa: Añado el path de Ruby y de las futuras Gemas a mi fichero .zshrc
# Versión para Mac ARM 
export PATH="/opt/homebrew/opt/ruby/bin:~/.gems/bin:$PATH"
# Versión para Mac Intel
#export PATH="/usr/local/opt/ruby/bin:~/.gems/bin:$PATH"
```

Para poder instalar gem’s sin necesidad de ser `root` (es decir sin `sudo`) y que se instale todo en un directorio de mi usuario, creo el directorio `~/.gems` y modifico `~/.zshrc`: 

```zsh
mkdir ~/.gems
```

* Añadir al final de `~/.zshrc`

```zsh
export GEM_HOME=~/.gems
export PATH=~/.gems/bin:$PATH
```

| Recuerda salir de iTerm y volver a entrar o ejecutar `source ~/.zshrc` para que encuentre los nuevos ejecutables |

<br/>

#### Jekyll y Bundler

![logo linux router](/assets/img/posts/logo-jekyll.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Los necesito para trabajar con mi blog en local. **Jekyll** es un generador simple para sitios web estáticos con capacidades de blog (creas ficheros markdown y él te genera el HTML). Está escrito en Ruby por Tom Preston-Werner (cofundador de GitHub) y es rapidísimo. 

**Bundler** es un gestor de paquetes de software que va a facilitar el trabajo con Jekyll y sus dependencias. 

```zsh
gem install jekyll bundler
```

| Nota1: Se instalan en `/Users/luis/.gems/bin/jekyll`, así que es muy importante que hayas actualizado tu PATH en el paso anterior. |

| Nota2: Al terminar la instalación me da un mensaje: A new release of RubyGems is available: 3.4.10 → 3.4.12 y propone que ejecute `gem update --system 3.4.12`. Lo ignoro, voy a seguir los procesos de actualización que haga `brew` cuando toque |

Una vez que tengo todo lo anterior instalado hago una prueba de concepto: 

```zsh
jekyll new test
  New jekyll site installed in /Users/luis/test.
cd test
bundle add webrick
bundle exec jekyll serve
```

Desde un browser conecto con [http://127.0.0.1:4000/](http://127.0.0.1:4000/) y veo que funciona!!

Referencia. Si tienes problemas con el comando gem prueba a ejecutar lo siguiente:

```zsh
gem cleanup && gem pristine --all
```

<br/>

#### Node-JS


![logo linux router](/assets/img/posts/logo-nodejs.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[Node.js](https://nodejs.org/es) es un entorno en tiempo de ejecución multiplataforma, de código abierto, para servidor, basado en JavaScript, asíncrono, con E/S de datos en una arquitectura orientada a eventos y basado en el motor V8 de Google. Fue creado con el enfoque de ser útil en la creación de programas de red altamente escalables, como por ejemplo, servidores web.

Podría instalar Node.js desde su sitio oficial, pero implica utilizar `sudo`. Si lo instalo con Homebrew lo tengo en el usuario, no tengo que tocar el PATH y además es más fácil instalar paquetes con NPM.

```zsh
brew install node
node -v
  v19.9.0
npm -v
  9.6.3
```

Vamos a hacer un ejemplo super sencillo: 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-03.png"
    caption="Prueba rápida con Node.js."
    width="500px"
    %}



<br/>

#### MongoDB

![logo linux router](/assets/img/posts/logo-mongodb.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[MongoDB](https://www.mongodb.com) es un sistema de base de datos NoSQL, orientado a documentos y de código abierto. En lugar de guardar los datos en tablas, tal y como se hace en las bases de datos relacionales, MongoDB guarda estructuras de datos BSON (una especificación similar a JSON) con un esquema dinámico, haciendo que la integración de los datos en ciertas aplicaciones sea más fácil y rápida

Instalo MongoDB 6.0 Community Edition en macOS utilizando Homebrew ([fuente](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/)). Uso un [`tap`](https://docs.brew.sh/Taps), solo se hace una vez. Consiste en añadir un repositorio (externo) a la lista de sitios desde donde instala Homebrew. 

```zsh
brew tap mongodb/brew
brew update
```

Instalo MongoDB. Incluye el servidor `mongod`, el `mongos sharded cluster query router` y la shell `mongosh`.

```zsh
brew install mongodb-community@6.0
```

|  | Intel | ARM |
| -- | -- | -- |
| Configuración | /usr/local/etc/mongod.conf | /opt/homebrew/etc/mongod.conf |
| Log | /usr/local/var/log/mongodb | /opt/homebrew/var/log/mongodb |
| Datos | /usr/local/var/mongodb | /opt/homebrew/var/mongodb |


**Ejecutar MongoDB** 

- Arrancar o Parar MongoDB como un servicio de macOS usando `brew`

```zsh
brew services start mongodb-community@6.0
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-04.png"
    caption="La primera vez que arrancamos"
    width="400px"
    %}

```zsh
brew services stop mongodb-community@6.0
```

- Arrancar o parar MongoDB manualmente:

```zsh
mongod --config /usr/local/etc/mongod.conf --fork   # Para macOS con procesadores Intel
mongod --config /opt/homebrew/etc/mongod.conf --fork  # Para macOS con procesadores ARM 
```

```zsh
mongosh
> shutdown 
```

Si Mac OS no deja abrir mongodb o mongosh por un tema de seguridad: Preferencias -> Security and Privacy pane > Gemeral > mongod Open Anyway or Allow Anyway 

Podemos ver que está escuchando en localhost en el puerto por defecto `127.0.0.1:27017`

```zsh
netstat -na|grep -i 27017
tcp6       0      0  ::1.27017              *.*                    LISTEN
tcp4       0      0  127.0.0.1.27017        *.*                    LISTEN
a3f97c9f1c2bb4f1 stream      0      0 a3f97cad866b9521                0                0                0 /tmp/mongodb-27017.sock
```

Y pdemos monitorizar el Log

```zsh
tail -f /opt/homebrew/var/log/mongodb/mongo.log
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-05.png"
    caption="Monitorizamos el fichero de Log del servidor"
    width="600px"
    %}

<br/>

#### Jupyter Lab

[Jupyter Lab](https://jupyter.org) es una aplicación web que permite codificar, ejecutar y "documentar". Esta última es una de las partes más interesante del proyecto, puedes tener documentación y código a la vez y que se ejecute !!. 

He documentado el proceso en otro apunte, más antiguo. La parte de Python puedes ignorarla porque la de aquí es más moderna, pero el resto te puede valer: [Python y JupyterLab en MacOS]({% post_url 2021-04-30-python-jupyter %}).
