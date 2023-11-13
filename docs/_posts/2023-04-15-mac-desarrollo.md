---
title: "MAC para desarrollo"
date: "2023-04-15"
categories: desarrollo
tags: macos homebrew desarrollo python git gem ruby ror iterm ohmyzsh zsh xcode code vscode visual studio
excerpt_separator: <!--more-->
---


![logo linux router](/assets/img/posts/logo-mac-desarrollo.svg){: width="150px" height="150px" style="float:left; padding-right:25px" }

En este apunte describo mi bitácora de configuración de un Mac (INTEL o ARM) como equipo de desarrollo. Instalo varias aplicaciones gráficas y de línea de comando que para mi son fundamentales para trabajar con el equipo. 

Está documentado **partiendo de una instalación nueva de Ventura**, desde cero. El orden de instalación puede variarse, pero te recomiendo (si tu MacOS está recién instalado) que sigas el mismo orden para ver los mismos resultados. 

<br clear="left"/>
<!--more-->



## Instalación

Empezamos con la instalación, si estás buscando cómo **actualizar o reparar**, ve al final del apunte. 

<br/>

### Xcode command line tools [+ Xcode]

![logo linux router](/assets/img/posts/logo-xcode.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Es obligatorio instalar las **Apple command line tools** (también conocidas como *Xcode command line tools*) porque algunas herramientas te lo van a pedir más adelante. 

La instalación de Xcode es opcional, solo si vas a desarrollar para macOS, iOS, watchOS y tvOS. Dependiendo de qué decidas, el orden sería este: 

- Instalo Xcode: 
  - Instalar Xcode desde el Apple Store. Abrirlo una vez e instalar lo que necesites (por ejemplo la poder desarrollar para iOS)
  - Ejecutar desde el CLI: `xcode-select --install` 
  - Ejecutar desde el CLI: `sudo xcodebuild -license accept`

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-01.png"
    caption="Pantalla de inicio de Xcode."
    width="500px"
    %}

- No instalo Xcode: 
  - Ejecutar desde el CLI: `xcode-select --install` 


<br/>


### iTerm2

![logo linux router](/assets/img/posts/logo-iterm2.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

iTerm2 es un sustituto al **Terminal.app** del MacOS. Admite muchas más cosas que el Terminal como la transparencia de ventanas, modo de pantalla completa, paneles divididos, pestañas Exposé, notificaciones Growl y atajos de teclado, perfiles personalizables y reproducción instantánea de entradas/salidas de terminales anteriores. 

Instalación: 

- Descargo el programa desde [iTerm2](https://iterm2.com)
- Lo *copio a Aplicaciones* 

Un par de tips: 

- Si sufres el problema: "Cuando iTerm arranca tarda mucho en mostrar el prompt", se resuelve con `sudo xcodebuild -license accept`
- Activa un atajo en Finder, para poder abrir un `iTerm` cuando el cursor está en una carpeta de Finder. 
  * `Ajustes Sistema → Teclado → Funciones rápidas de teclado → Servicios`
  * `→ Archivos y carpetas → New iTerm2 Tab Here → Ctrl Shift T`

<br/> 


### Oh My Zsh

![logo linux router](/assets/img/posts/logo-ohmyzsh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[oh-my-zsh](https://ohmyz.sh) es un entorno de trabajo en línea de comando mucho más bonito para trabajar con **Zsh**. Viene con miles de funciones útiles, ayudantes, plugins, temas. Trae varios plugins que hacen la vida más fácil. [Lo mejor de Oh My Zsh son sus temas](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes).

Instalación:

```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

<br/>

### Fichero `~/.zshrc`

Una vez instalado iTerm + Oh My Zsh te recomiendo que te copies el contenido de mi fichero **`~/.zshrc`**. Tras instalar iTerm2 y Oh-My-Zsh se habrá creado ya uno e irás viendo que te pido hacer modificaciones en este fichero más adelante. 

Te dejo el mío, es una copia final completa, compatible con lo que acabamos de instalar y lo que instalaremos. Ahora bien, **es muy importante que una vez copiado lo revises y adaptes a tu caso**. El mío está preparado para un Mac sobre chip ARM. **Si tu Mac usa chip Intel revisa el fichero**, verás notas en las líneas para saber qué comentar/descomentar. 

* Salvo el que me acaba de crear Oh-My-Zsh y descargo una copia del mío.
```zsh
cd ~
cp .zshrc .zshrc.ORIGINAL
curl -s -O https://gist.githubusercontent.com/LuisPalacios/f66942b329af7920bebd4b95fa36cdb5/raw/52fe5b891b524bde6d315aab92a6b82d0dafa19e/.zshrc
```

<br/>

### Visual Studio Code 


![logo linux router](/assets/img/posts/logo-vscode.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Visual Studio Code es un editor de código fuente desarrollado por Microsoft para Windows, Linux, macOS y Web. Incluye soporte de tantas cosas que es imposible explicarlo aquí. Con la inmensa diversidad de características, plugins y lenguajes soportados puedes usarlo como IDE para cualquier proyecto.

Instalación:

- Descargarlo [desde aquí](https://code.visualstudio.com/docs/?dv=osx).
- Lo *copio a Aplicaciones* 

Un par de tips: 
- Para poder arrancarlo cómodamente desde iTerm2, con VSCode lanzado, pulsa CMD-SHIFT-P e instala el comando '**code**' en el PATH. 

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-06.png"
    caption="Instalar el comando `code` en el PATH"
    width="600px"
    %}

- Crea un alias en tu `~/.zshrc` para lanzar el programa de forma rápida desde el CLI. **Si te bajaste mi copia no hace falta que lo hagas**.

```conf
# Alias para llamar a VSCode desde CLI con "e"
alias e="/usr/local/bin/code"
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-07.jpg"
    caption="Arranque de VSCode muy rápido desde el CLI"
    width="600px"
    %}


- A partir de ahora, cuando estas en un directorio y quieres editar todo lo que cuelga de él, simplemente escribe `e .` 

<br/>

#### Consejos sobre VSCode

- Con VSCode puedes hacerlo todo desde el teclado. Ya trae un subconjunto de comandos mapeado a [Atajos de teclado](https://code.visualstudio.com/docs/getstarted/keybindings). Si quieres aprender estos atajos por defecto, imprime el PDF para [Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf), [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf) o [Linux](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) y déjalo cerca. 


<br/>

### Homebrew


![logo linux router](/assets/img/posts/logo-homebrew.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Siendo desarrollador con un Mac, quieres [Homebrew](https://brew.sh/index_es) (o `brew` por resumir) Aunque Mac OS trae de todo (al estar basado en FreeBSD) por desgracia no está a la última y le faltan cosas. 

Con `brew` vas a poder instalar (**en paralelo a tu Mac OS sin tocarlo ni estropearlo**) un montón de programas de software libre super interesantes, software de bajo nivel, herramientas para la línea de commandos, aplicaciones, compiladores, lenguajes, etc. podrás instalar hasta MongoDB (ver más adelante).

Instalación:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

source ~/.zshrc
```

Líneas relevantes en mi `~/.zshrc` 

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

### Git

![logo linux router](/assets/img/posts/logo-git.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[Git](https://git-scm.com) es un sistema de control de versiones distribuido, gratuito y de código abierto, diseñado para gestionar desde proyectos pequeños a muy grandes con rapidez y eficacia. Existen varias opciones de Instalación del cliente para la línea de comandos ([fuente original](https://git-scm.com/download/mac)), en mi caso utilizo la de Homebrew.

Instalación:

```zsh
brew update && brew upgrade
brew install git

source ~/.zshrc
```

Creo el fichero [~/.gitconfig](https://gist.github.com/LuisPalacios/0ee871ee236485d4a064179b16ada400) y [~/.gitignore_global](https://gist.github.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c), que te puedes bajar así: 

```zsh
curl -s -O https://gist.githubusercontent.com/LuisPalacios/0ee871ee236485d4a064179b16ada400/raw/348a8a448095a460756f85ef0362521b886b0a2e/.gitconfig
curl -s -O https://gist.githubusercontent.com/LuisPalacios/6923f8cc708ce10f3bd4a6772625fb0c/raw/65d0ed6acba83ece4db78228821589212b9f9f4b/.gitignore_global

# Edítalo para adaptarlo
e .gitconfig
```

Como cliente GUI uso [GitKraken](https://www.gitkraken.com). Tienes más información sobre git en esta [chuleta sobre GIT]({% post_url 2021-10-10-git-cheatsheet %}) y [GIT en detalle]({% post_url 2021-04-17-git-en-detalle %}). 

<br/>

### SSH clave pública-privada

![logo linux router](/assets/img/posts/logo-ssh.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Ahora es buen momento para configurar tu pareja de claves pública/privada para conectar con Hosts remotos y/o usarlo con servidor(es) Git. La clave pública-privada SSH es un sistema de autenticación y encriptación utilizado para la conexión entre un cliente y un servidor. Se utilizan un par de claves: una clave pública y una clave privada. Los dos casos de uso más típicos son: 

- Conectar desde mi Terminal con un servidor remoto. 
- Conectar mi cliente `git` con un servidor Git remoto (por ejemplo `github.com`) 

Creo mi clave pública-privada, crea dos archivos de texto bajo `~/.ssh`.

```zsh
➜  ~ ssh-keygen -t ed25519 -a 200 -C "luis@mihost" -f ~/.ssh/id_ed25519
:
Enter passphrase (empty for no passphrase):            <=== Pon una contraseña que usarás durante las futuras conexiones
Your identification has been saved in /Users/luis/.ssh/id_ed25519   <== Clave PRIVADA. NUNCA LO COMPARTAS
Your public key has been saved in /Users/luis/.ssh/id_ed25519.pub   <== Clave PÚBLICA. Este contenido es el que compartes !!
:
```

El contenido del fichero con la clave pública lo compartes con el servidor remoto (`github` o un linux para terminal remoto), mientras que la clave privada se mantiene en local. Simplificándolo muchísimo, mi clave *pública* que le paso a Github la va a usar para encriptar información que solo yo, que poseo la *privada equivalente*, puedo descifrar y así comunicarnos. 

En el caso de Github se puede usar este método (SSH pública-privada) para acceso directo a tu cuenta y modificar repositorios de forma segura, sin necesidad de hacer login (https con usuario y contraseña). Es importante destacar que debes mantener tu clave privada segura, ya que si alguien más la tiene, puede acceder a tu cuenta y repositorios.

El contenido de tu pública se comparte: 

* En equipo linux remotos con los que quiero conectar: añadiéndolo al final del fichero `~/.ssh/authorized_keys`
* En Servidores GIT, a través de su GUI, en la propiedades de mi cuenta. 

Tienes un par de apuntes adicionales en [SSH y X11]({% post_url 2017-02-11-x11-desde-root %}) y [SSH en Linux]({% post_url 2009-02-01-ssh %})


<br/>

### Java

![logo linux router](/assets/img/posts/logo-java.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Podemos instalar JRE (Java Runtime Environment) para ejecutar aplicaciones Java o el JDK (Java Development Kit), para desarrollar y ejecutar aplicaciones Java.

En mi caso obviamente me instalo JDK, trae herramientas como el compilador (javac), el desensamblador de binarios (javap), el debugger, etc. y toda instalación de JDK incluye JRE. Te recomiendo echar un ojo a esta [imagen sobre la estructura de componentes de Java](https://stackoverflow.com/a/29160633/1065197).

Instalación:

- Conecto con [Java SE Development Kit](https://www.oracle.com/java/technologies/downloads/) y me bajo la versión JDK 20 para macOS. En mi caso elegí la versión ARM64 DMG Installer

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-08.png"
    caption="Descargo e instalo el SDK de Java"
    width="800px"
    %}

Una vez instalado, hacemos nuestra prueba de concepto desde iTerm

```zsh
$ mkdir -p ~/Desktop/hola
$ cd ~/Desktop/hola
$ cat > HolaMundo.java << EOF
public class HolaMundo {
	public static void main(String[] args) {		
		System.out.println("Hola Mundo!");
	}
}
EOF

$ javac HolaMundo.java
$ ls -l
total 16
-rw-r--r--@ 1 luis  staff  423 22 abr 15:22 HolaMundo.class
-rw-r--r--@ 1 luis  staff  111 22 abr 15:21 HolaMundo.java

$ java HolaMundo
Hola Mundo!

```

Te dejo aquí algunas referencias interesantes: 

- Las [notas sobre la instalación del JDK](https://docs.oracle.com/en/java/javase/20/install/installation-jdk-macos.html#GUID-E8A251B6-D9A9-4276-ABC8-CC0DAD62EA33)
- [Información y requisitos del sistema](https://www.java.com/es/download/help/java_mac.html) para instalar y usar Oracle Java en Mac OS X
- Artículo sobre la [Actualización manual necesaria para Java 8 en macOS](https://www.java.com/es/download/help/java8_manual_update_macos.html).

<br/>

### Eclipse. 


![logo linux router](/assets/img/posts/logo-eclipse.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Podrías usar Visual Studio Code como IDE pero lo más normal es que te instales Eclipse, es **La plataforma** para trabajar con Java, y mucho más, en realidad con herramientas de programación de código abierto multiplataforma para desarrollar Aplicaciones. 

Típicamente se ha usado para desarrollar IDE's (entornos de desarrollo integrados), como el del propio Java (Java Development Toolkit - JDT). 

Instalación:

- Conecto con [Eclipse](https://www.eclipse.org/downloads/) y me bajo el **Eclipse Installer**.
- Lo copio a *Aplicaciones*, podré instalar ahora o en el futuro otras opciones
- Lo ejecuto desde *Aplicaciones*,
 
{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-09.png"
    caption="Descargo la versión ARM del Eclipse Installer para Mac"
    width="500px"
    %}

- Instalo «Eclipse IDE for Java Developers».

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-10.png"
    caption="Instalo Eclipse IDE for Java Developers"
    width="500px"
    %}

Un tip: 
- Un apunte que hice sobre cómo trabajar con [Eclipse + Java sobre repositorio Git]({% post_url 2022-10-27-quidomi %}).

<br/>

### Python, Pip y PipEnv

![logo linux router](/assets/img/posts/logo-python.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

**[Python](https://www.python.org)** es un lenguaje de programación interpretado cuya filosofía hace hincapié en la legibilidad de su código.​ Soporta parcialmente la orientación a objetos, programación imperativa y algo de programación funcional. MacOS trae versiones antiguas de Python 2 y 3 que NUNCA deben borrarse o sobreescribir. Uso Homebrew para hacer una instalación paralela. 

**[Pip](https://pypi.org/project/pip/)** es un indispensable, es el sistema de gestión de paquetes utilizado para instalar y administrar programas y paquetes hechos en Python desde el [Python Package Index (PyPI)](https://pypi.org), el repositorio de software oficial para aplicaciones de terceros en Python. 

**[PipEnv](https://pipenv.pypa.io/en/latest/)** es otro indispensable. Las aplicaciones en Python hacen uso de paquetes y módulos que no forman parte de la librería estándar. Gestionar todas las librerías que deben acompañar a mi programa es un infierno. Con **`PipEnv`** puedo "contener" todo dentro de un directorio, creando un entorno virtual, sin conflictos. Nota: hay dos paquetes equivalentes a **`PipEnv`**: [Virtualenv](https://virtualenv.pypa.io/en/latest/) y [Conda](https://docs.conda.io/projects/conda/en/latest/index.html) que no suelo utilizar. 
  
Instalación:

```zsh
brew install python     <--- (También nos instala pip)
brew install pipenv

source ~/.zshrc
```

Cuando instalamos Homebrew (en un paso anterior) ya habíamos modificado el PATH en `~/.zshrc`. Homebrew deja los ejecutables en `/usr/local/` en Mac's Intel y en `/opt/homebrew` en Mac's ARM. Creo un par de alias, de modo que al ejecutar `python` o `pip` en realidad se ejecuten las últimsa versiones de Homebrew.

```zsh
# Añado al final de ~/.zshrc
# Mac ARM
alias python="/opt/homebrew/bin/python3"
alias pip="/opt/homebrew/bin/pip3"
# Mac Intel
#alias python="/usr/local/bin/python3"
#alias pip="/usr/local/bin/pip3"
```

Compruebo las versiones

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

Ejecuta la prueba de concepto
```console
$ pipenv run python main.py
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

#### Integración con Visual Studio Code

Dejo aquí algunas recomendaciones para integrar Visual Studio Code y Python

- Instalar [Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)


| Recomendado: [Advanced Visual Studio Code for Python Developers](https://realpython.com/advanced-visual-studio-code-python/) |

<br/>

### Ruby

![logo linux router](/assets/img/posts/logo-ruby.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

MacOS ya trae Ruby, pero voy a instalar la última versión con Hombrew en paralelo. Necesito `Bundler` y `Jekyll` (ver más adelante) para trabajar en mi blog en local (más info [aquí]({% post_url 2021-04-19-nuevo-blog %})). **Ruby** es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995.

Instalación:

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

### Jekyll y Bundler

![logo linux router](/assets/img/posts/logo-jekyll.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

Los necesito para trabajar con mi blog en local. **Jekyll** es un generador simple para sitios web estáticos con capacidades de blog (creas ficheros markdown y él te genera el HTML). Está escrito en Ruby por Tom Preston-Werner (cofundador de GitHub) y es rapidísimo. **Bundler** es un gestor de paquetes de software que va a facilitar el trabajo con Jekyll y sus dependencias. 

Instalación:

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


<br/>

### Node-JS


![logo linux router](/assets/img/posts/logo-nodejs.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[Node.js](https://nodejs.org/es) es un entorno en tiempo de ejecución multiplataforma, de código abierto, para servidor, basado en JavaScript, asíncrono, con E/S de datos en una arquitectura orientada a eventos y basado en el motor V8 de Google. Fue creado con el enfoque de ser útil en la creación de programas de red altamente escalables, como por ejemplo, servidores web.

Podría instalar Node.js desde su sitio oficial, pero implica utilizar `sudo`. Si lo instalo con Homebrew lo tengo en el usuario, no tengo que tocar el PATH y además es más fácil instalar paquetes con NPM.

Instalación:

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

### MongoDB

![logo linux router](/assets/img/posts/logo-mongodb.svg){: width="150px" height="150px" style="float:right; padding-right:25px" }

[MongoDB](https://www.mongodb.com) es un sistema de base de datos NoSQL, orientado a documentos y de código abierto. En lugar de guardar los datos en tablas, tal y como se hace en las bases de datos relacionales, MongoDB guarda estructuras de datos BSON (una especificación similar a JSON) con un esquema dinámico, haciendo que la integración de los datos en ciertas aplicaciones sea más fácil y rápida

Instalo MongoDB 6.0 Community Edition en macOS utilizando Homebrew ([fuente](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/)). Uso un [`tap`](https://docs.brew.sh/Taps), solo se hace una vez. Consiste en añadir un repositorio (externo) a la lista de sitios desde donde instala Homebrew. 

Preparar la instalación:

```zsh
brew tap mongodb/brew
brew update
```

Instalación (incluye el servidor `mongod`, el `mongos sharded cluster query router` y la shell `mongosh`):

```zsh
brew install mongodb-community@7.0
```

|  | Intel | ARM |
| -- | -- | -- |
| Configuración | /usr/local/etc/mongod.conf | /opt/homebrew/etc/mongod.conf |
| Log | /usr/local/var/log/mongodb | /opt/homebrew/var/log/mongodb |
| Datos | /usr/local/var/mongodb | /opt/homebrew/var/mongodb |


**Ejecutar MongoDB** 

- Arrancar o Parar MongoDB como un servicio de macOS usando `brew`

```zsh
brew services start mongodb-community@7.0
```

{% include showImagen.html
    src="/assets/img/posts/2023-04-15-mac-desarrollo-04.png"
    caption="La primera vez que arrancamos"
    width="400px"
    %}

```zsh
brew services stop mongodb-community@7.0
```

Si Mac OS no deja abrir mongodb o mongosh por un tema de seguridad: Preferencias -> Security and Privacy pane > Gemeral > mongod Open Anyway or Allow Anyway 

Comprobar que arrancó y escucha en `localhost` en el puerto por defecto `127.0.0.1:27017`

```zsh
netstat -na|grep -i 27017
tcp6       0      0  ::1.27017              *.*                    LISTEN
tcp4       0      0  127.0.0.1.27017        *.*                    LISTEN
a3f97c9f1c2bb4f1 stream      0      0 a3f97cad866b9521                0  0 0 /tmp/mongodb-27017.sock
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

**Programa de ejemplo** 

Te dejo una referencia a un pequeño proyecto en GitHub para que puedas probar `npm` y `mongod`.

- [Proyecto Tienda](https://github.com/LuisJal/ProyectoTienda)
 

<br/>

### Jupyter Lab

[Jupyter Lab](https://jupyter.org) es una aplicación web que permite codificar, ejecutar y "documentar". Esta última es una de las partes más interesante del proyecto, puedes tener documentación y código a la vez y que se ejecute. 

He documentado el proceso en otro apunte, más antiguo. La parte de Python puedes ignorarla porque la de aquí es más moderna, pero el resto te puede valer: [Python y JupyterLab en MacOS]({% post_url 2021-04-30-python-jupyter %}).


<br/>

### VirtualBox y Vagrant

| Nota: Este punto solo me ha funcionado en un Mac on chip Intel, así que estás avisado, de momento no he encontrado cómo emular un Linux o Windows ARM con VirtualBox y Vagrant instalados en un Mac con Apple Silicon (ARM)  |

[VirtualBox](https://www.virtualbox.org) es un software de virtualización que permite isntalar sistemas operativos adicionales, conocidos como «sistemas invitados, guest o máquinas virtuales», dentro de tu sistema «anfitrión» (en mi caso el MacOS), cada uno con su propio ambiente virtual. Puedes crear máquinas virtuales basadas en FreeBSD, GNU/Linux, OpenBSD, OS/2 Warp, Windows, Solaris, MS-DOS, Genode y muchos otros.

[Vagrant](https://www.vagrantup.com/) permite crear y configurar entornos de desarrollo virtuales, ligeros y reproducibles, creando máquinas virtuales. Usa VirtualBox como virtualizador de forma nativa. 

Podemos instalar ambos para montarnos **Servidores** virtuales para acompañar a nuestros desarrollos de software. 

No dejes de leer el apunte [Vagrant para desarrollo]({% post_url 2023-04-23-mac-vagrant %}).

<br/>

### Otros

Dejo aquí una lista de programas que suelo instalar en mi portatil. Puedes instalar varios a la vez, poniendo más de uno en la lína de comandos (separados por espacio).

Instalación:

```zsh
brew install <programa(s)>
```

|  Programa | Descripción |
| -- | -- |
| ffmpeg | Una solución completa y multiplataforma para grabar, convertir y transmitir audio y vídeo. |
| iperf3 | Para hacer pruebas en redes. El caso de uso es crear flujos de datos TCP y UDP y medir el rendimiento de la red. |
| jq | Filtrar, buscar y mostrar de forma "bonita" el resultado de un JSON en lugar de en una sola línea. |
| knock | Cliente para hacer "Port Knocking" (llamar a la puerta), una técnica para aplicar seguridad a nuestro servidor. |


<br/>

## Mantenimiento

Normalmente nos olvidamos de mantener lo que instalamos, así que **saber cómo hacer actualizaciones y reparaciones** es interesante. Suelo actualizar periódicamente, mínimo una vez al mes, aunque no instale nada nuevo. Compruebo que está todo al día. Los programas que no menciono en esta sección se actualizan automáticamente desde AppStore o sus propias opciones GUI.

<br/>

#### Actualizaciones

* Homebrew

```zsh
brew update && brew upgrade            # Actualización estándar de homebrew
```

<br/>

#### Reparaciones

* Homebrew

```zsh
brew update && brew update
brew doctor                # Herramienta de autodiagnóstico de Homebrew.
brew --version             # Comprobar la versión
brew list                  # Ver que está instalado
brew cask list             # Ver que cask’s están instalados
brew leaves                # Top level instalados (es lo más interesante)
```

* Actualizar Homebrew


```zsh
gem cleanup && gem pristine --all      # Reparar problema con el comando gem
```

<br/>
