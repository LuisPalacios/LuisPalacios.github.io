---
title: "MAC para desarrollo"
date: "2023-04-15"
categories: ["desarrollo"]
tags: ["macos","homebrew","desarrollo","python","git","gem","ruby","iterm","ohmyposh","zsh","xcode","vscode"]
draft: false
cover:
  image: "/img/posts/logo-mac-desarrollo.svg"
  hidden: true
---

<img src="/img/posts/logo-mac-desarrollo.svg" alt="logo mac desarrollo" width="150px" height="150px" style="float:left; padding-right:25px"  />

En este apunte describo mi bitácora de configuración de un Mac (INTEL o ARM) como equipo de desarrollo. Instalo varias aplicaciones gráficas y de línea de comando, importantes para usar un mac como equipo de desarrollo

El orden de instalación puede variarse, pero es el que recomiendo desde una instalación reciente de macOS.

<br clear="left"/>
<!--more-->

> Nota: Mis apuntes para preparar cada S.O. para desarrollo de software: [macOS]({{< relref "2023-04-15-mac-desarrollo.md" >}}), [linux]({{< relref "2024-07-25-linux-desarrollo.md" >}}) y [Windows]({{< relref "2024-08-25-win-desarrollo.md" >}}).

## Primeros pasos

Trabajaré desd el CLI con **Terminal.app** durante la instalación inicial, aunque rápidamente instalaré **iTerm2**.

---

## Xcode o Xcode command line tools

<img src="/img/posts/logo-xcode.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Es obligatorio, instala las **Apple command line tools** (también conocidas como *Xcode command line tools*) porque algunas herramientas te lo van a pedir más adelante.

La instalación de Xcode es opcional, solo si vas a desarrollar para macOS, iOS, watchOS y tvOS. Dependiendo de qué decidas, las opciones son:

- Opción 1: Instalar Xcode junto con las Apple command line tools:
  - Instalar Xcode desde el Apple Store. Abrirlo una vez e instalar lo que necesites
  - Luego desde el CLI: `xcode-select --install` y `sudo xcodebuild -license accept`

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-01.png" alt="Pantalla de inicio de Xcode." width="500px" />
  <div class="image-caption">Pantalla de inicio de Xcode.</div>
</div>

- Opción 2: Solo las Apple command line tools:
  - Instalarlas desde el CLI: `xcode-select --install` y `sudo xcodebuild -license accept`

---

## iTerm2

<img src="/img/posts/logo-iterm2.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Mucho mejor que el *Terminal.app*, transparencia de ventanas, modo pantalla completa, paneles divididos, pestañas Exposé, notificaciones Growl y atajos de teclado, perfiles personalizables, etc. Para instalarlo:

- Descargo el programa desde [iTerm2](https://iterm2.com) y lo *copio a Aplicaciones*

Un par de tips:

- Si estás pasando de otro mac a uno nuevo puedes copiarte la configuración del antiguo, está aquí:
  - `~/Library/Preferences/com.googlecode.iterm2.plist`
- Si sufres el problema: "Cuando iTerm arranca tarda mucho en mostrar el prompt", se resuelve con `sudo xcodebuild -license accept`
- Activa un atajo en Finder, para poder abrir un `iTerm` cuando el cursor está en una carpeta de Finder.
  - `Ajustes Sistema → Teclado → Funciones rápidas de teclado → Servicios`
  - `→ Archivos y carpetas → New iTerm2 Tab Here → Ctrl Shift T`

---

### Nerd Fonts

Super recomendado, es más, lo necesitas para Oh-My-Posh que lo instalo luego...

- Desde el repo de [Nerd Fonts](https://www.nerdfonts.com/) > `Fonts Downloads`. Busco y descargo `FiraCode Nerd Font` (es el que me gusta a mi, pero puedes poner el que quieras). Unzip del fichero, selecciono todos los `.ttf` > botón derecho > `Abrir` > Instalar todos.
- Lo configuro como fuente por defecto en iTerm: Settings -> Profiles -> Default -> Text -> Font `FiraCode Nerd Font`

---

## Homebrew

<img src="/img/posts/logo-homebrew.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Antes de seguir, importantísimo, siendo desarrollador y con un Mac, necesitas [Homebrew](https://brew.sh) (o `brew` por resumir). macOS trae todo tipo de comandos `Unix` (al estar basado en FreeBSD) y muchas utilidades, pero si quieres estar a la última y poder instalarte casi cualquier herramienta o software, necesitas Homebrew.

La ventaja es que puedes instalar de todo (**en paralelo, sin fastidiar macOS**). Un montón de programas de software libre super interesantes, software de bajo nivel, herramientas pra la línea de commandos, aplicaciones, compiladores, lenguajes, etc. podrás instalar hasta MongoDB (ver más adelante).

Instalación:

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

```

---

## devcli

He creado un repositorio en GitHub llamado [devcli](https://github.com/LuisPalacios/devcli) para automatizar la instalacion de algunas cositas, herramientas para CLI en sistemas tipo Unix como MacOS, Linux, WSL2 (y tambien Windows). Estaba ya cansado de perder un par de horas con sistemas nuevos, parametrizar, herramientas, fuentes, scripts de ayuda. Lo automatizo todo con un solo comando. Échale un ojo al respositorio y si te convence:

- Prepara tu usuario para que funcione `sudo` sin pedirte contraseña
  - Terminal.app > `id`   (apunta tu `<nombre-corto-usuario>`)
  - Terminal.app > `sudo su -`
  - Edita el fichero `nano /etc/sudoers.d/10-usuario` y añade una linea `<nombre-corto-usuario> ALL=(ALL) NOPASSWD:ALL`
  - Sal y vuelve a entrar en el Terminal y prueba a ver si funciona este comando `sudo cat /etc/sudoers`

Instalación:

```zsh
bash <(curl -fsSL https://raw.githubusercontent.com/LuisPalacios/devcli/main/bootstrap.sh)
```

---

## Zsh

Si has ejecutado `devcli` salta este punto.

MacOS incluye **Zsh** (abreviatura de "Z Shell"), mucho más potente que Bash. He dejado mis ficheros de configuración (que instalo siempre) en este repositorio en GitHUb: [Mis ficheros zsh](https://github.com/LuisPalacios/zsh-zshrc). Abro el `Terminal.app` y me bajo mi `.zshrc`.

```sh
curl -LJs -o ~/.zshrc https://raw.githubusercontent.com/LuisPalacios/zsh-zshrc/main/.zshrc
```

> Importante: Editarlo con `nano` y adáptalo a tu nombre de usuario, tus directorios, PATH's, etc. Está preparado por defecto para trabajar con **Oh My Posh**. Lo siguiente que hago es instalar Homebrew, iTerm2, Nerd Font y Oh My Posh.

---

### Oh My Posh

Si has ejecutado `devcli` salta este punto.

**[Oh My Posh](https://ohmyposh.dev/)** se anuncia como "un motor de Prompts para cualquier Shell". Permite renderizar el PROMPT de forma muy avanzada, pero lo que más me gusta es cómo gestiona Git, donde el mayor problema es la renderización del PROMPT. Ninguno de los renderizadores avanzados que he probado (incluido *Starship*) son tan eficientes como Oh My Posh. Solo por este motivo se ha convertido en mi elección, por encima de Starship.

```shell
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

Nota: Mira mis copias de `.zshrc` y `.oh-my-posh.yaml` que descargué automáticamente en la sección *devcli*. Las últimas versiones las subo siempre [aquí](https://github.com/LuisPalacios/devcli).

---

## Visual Studio Code

<img src="/img/posts/logo-vscode.svg" alt="logo vscode" width="150px" height="150px" style="float:right; padding-right:25px"  />

Visual Studio Code es un editor de código fuente desarrollado por Microsoft para Windows, Linux, macOS y Web. Incluye soporte de tantas cosas que es imposible explicarlo aquí. Con la inmensa diversidad de características, plugins y lenguajes soportados puedes usarlo como IDE para cualquier proyecto.

Instalación:

- Descargarlo [desde aquí](https://code.visualstudio.com/docs/?dv=osx).
- Lo *copio a Aplicaciones*

Un par de tips:

- Para poder arrancarlo cómodamente desde iTerm2, con VSCode lanzado, pulsa CMD-SHIFT-P e instala el comando '**code**' en el PATH.

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-06.png" alt="Instalar el comando `code` en el PATH" width="600px" />
  <div class="image-caption">Instalar el comando `code` en el PATH</div>
</div>

- Creo un alias en mi `~/.zshrc` para lanzar el programa de forma rápida desde el CLI.

```conf
# Alias para llamar a VSCode desde CLI con "e"
alias e="/usr/local/bin/code"
```

***Settigs y Sincronización***: Echa un ojo al apunte [VSCode settings y extensiones]({{< relref "2023-06-20-vscode.md" >}}) para más información.

---

### Git

Si has ejecutado `devcli` salta este punto.

<img src="/img/posts/logo-git.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

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

Como cliente GUI uso [GitKraken](https://www.gitkraken.com). Tienes más información sobre git en esta [chuleta sobre GIT]({{< relref "2021-10-10-git-cheatsheet.md" >}}) y [GIT en detalle]({{< relref "2021-04-17-git-en-detalle.md" >}}).

---

### SSH clave pública-privada

<img src="/img/posts/logo-ssh.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Ahora es buen momento para configurar tu pareja de claves pública/privada para conectar con Hosts remotos y/o usarlo con servidor(es) Git. La clave pública-privada SSH es un sistema de autenticación y encriptación utilizado para la conexión entre un cliente y un servidor. Se utilizan un par de claves: una clave pública y una clave privada. Los dos casos de uso más típicos son:

- Conectar desde mi Terminal con un servidor remoto.
- Conectar mi cliente `git` con un servidor Git remoto (por ejemplo `github.com`)

Creo mi clave pública-privada, crea dos archivos de texto bajo `~/.ssh`.

```zsh
➜  ~ ssh-keygen -t ed25519 -a 200 -C "luis@mihost" -f ~/.ssh/id_ed25519
:
Enter passphrase (empty for no passphrase):            <=== Si la pones, será la que te pedirá el host donde copies tu .pub
Your identification has been saved in /Users/luis/.ssh/id_ed25519   <== Clave PRIVADA. NUNCA LO COMPARTAS
Your public key has been saved in /Users/luis/.ssh/id_ed25519.pub   <== Clave PÚBLICA. Este contenido es el que compartes !!
:
```

El contenido del fichero con la clave pública lo compartes con el servidor remoto (`github` o un linux para terminal remoto), mientras que la clave privada se mantiene en local. Simplificándolo muchísimo, mi clave *pública* que le paso a Github la va a usar para encriptar información que solo yo, que poseo la *privada equivalente*, puedo descifrar y así comunicarnos.

En el caso de Github se puede usar este método (SSH pública-privada) para acceso directo a tu cuenta y modificar repositorios de forma segura, sin necesidad de hacer login (https con usuario y contraseña). Es importante destacar que debes mantener tu clave privada segura, ya que si alguien más la tiene, puede acceder a tu cuenta y repositorios.

El contenido de tu pública:

- Se suele poner en equipos linux remotos con los que quiero conectar: añadiéndolo al final del fichero `~/.ssh/authorized_keys`
- Si no le has puesto contraseña entonces esos equipos no te pedirán nada, entrarás directo, siempre que conectes desde un equipo con la Privada :-)
- En Servidores GIT, a través de su GUI, en la propiedades de mi cuenta.

Tienes un par de apuntes adicionales en [SSH y X11]({{< relref "2017-02-11-x11-desde-root.md" >}}) y [SSH en Linux]({{< relref "2009-02-01-ssh.md" >}})

## LLVM/CLANG

Si quieres desarrollar con C++ usando CLANG, después de instalar Xcode y homebrew, los pasos siguientes serían:

```zsh
brew install llvm       # Instalará la última versión.
brew install llvm@17    # Por si además quieres instalar una en concreto.
brew install cmake      # En el caso de que uses cmake.
brew install ninja      # En el caso de que uses ninja
```

## Java

<img src="/img/posts/logo-java.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Podemos instalar JRE (Java Runtime Environment) para ejecutar aplicaciones Java o el JDK (Java Development Kit), para desarrollar y ejecutar aplicaciones Java.

En mi caso obviamente me instalo JDK, trae herramientas como el compilador (javac), el desensamblador de binarios (javap), el debugger, etc. y toda instalación de JDK incluye JRE. Te recomiendo echar un ojo a esta [imagen sobre la estructura de componentes de Java](https://stackoverflow.com/a/29160633/1065197).

Instalación:

- Conecto con [Java SE Development Kit](https://www.oracle.com/java/technologies/downloads/) y me bajo la versión JDK 20 para macOS. En mi caso elegí la versión ARM64 DMG Installer

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-07.png" alt="Descargo e instalo el SDK de Java" width="800px" />
  <div class="image-caption">Descargo e instalo el SDK de Java</div>
</div>

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

---

## Eclipse

<img src="/img/posts/logo-eclipse.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

Podrías usar Visual Studio Code como IDE pero lo más normal es que te instales Eclipse, es **La plataforma** para trabajar con Java, y mucho más, en realidad con herramientas de programación de código abierto multiplataforma para desarrollar Aplicaciones.

Típicamente se ha usado para desarrollar IDE's (entornos de desarrollo integrados), como el del propio Java (Java Development Toolkit - JDT).

Instalación:

- Conecto con [Eclipse](https://www.eclipse.org/downloads/) y me bajo el **Eclipse Installer**.
- Lo copio a *Aplicaciones*, podré instalar ahora o en el futuro otras opciones
- Lo ejecuto desde *Aplicaciones*,

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-08.png" alt="Descargo la versión ARM del Eclipse Installer para Mac" width="500px" />
  <div class="image-caption">Descargo la versión ARM del Eclipse Installer para Mac</div>
</div>

- Instalo «Eclipse IDE for Java Developers».

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-09.png" alt="Instalo Eclipse IDE for Java Developers" width="500px" />
  <div class="image-caption">Instalo Eclipse IDE for Java Developers</div>
</div>

Un tip:

- Un apunte que hice sobre cómo trabajar con [Eclipse + Java sobre repositorio Git]({{< relref "2022-10-27-quidomi.md" >}}).

## Python

<img src="/img/posts/logo-python.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

**[Python](https://www.python.org)** es un lenguaje de programación interpretado, versátil y fácil de aprender, lo que más me gusta es que es muy legible y soporta múltiples paradigmas como la programación orientada a objetos, funcional e imperativa. Hay mucha herramienta que lo necesita y tiene muchos casos de uso. Aunque en mi caso no lo uso casi nunca, siempre lo instalo.

**[Pip](https://pypi.org/project/pip/)** es una herramienta fundamental para gestionar paquetes de Python. Es el sistema utilizado para instalar y manejar librerías de terceros desde el [Python Package Index (PyPI)](https://pypi.org), el repositorio oficial de Python.

**[venv](https://docs.python.org/3/library/venv.html)** venv es un módulo incluido en Python que permite crear entornos virtuales. Un entorno virtual es un espacio aislado en el sistema donde puedes instalar paquetes y bibliotecas de Python de manera independiente, sin que afecten ni sean afectados por otras instalaciones de Python en el sistema.

Instalación:

```zsh
brew install python     <--- (instala python3 y pip3)
```

Salir del Terminal y volver a entrar. Comprueba que cuando ejecutar `python3` y `pip3` se está ejecutando el de homebrew

```zsh
luis ❯ where python3
/opt/homebrew/bin/python3
/usr/bin/python3
luis ❯ where pip3
/opt/homebrew/bin/pip3
/usr/bin/pip3
luis ❯ python3 --version
Python 3.13.5
luis ❯ /opt/homebrew/bin/python3 --version
Python 3.13.5
luis ❯ pip3 --version
pip 25.1.1 from /opt/homebrew/lib/python3.13/site-packages/pip (python 3.13)
```

Aunque parezca un poco maniático, es importante. Ten en cuenta que MacOS trae Python3 pero una versión más antigua (3.9.x).

Homebrew deja los ejecutables en `/usr/local/` en Mac's Intel y en `/opt/homebrew` en Mac's ARM. Si lo necesitas puedes crearte alias.

```zsh
# Añado al final de ~/.zshrc
# Mac ARM
alias python="/opt/homebrew/bin/python3"
alias pip="/opt/homebrew/bin/pip3"
# Mac Intel
#alias python="/usr/local/bin/python3"
#alias pip="/usr/local/bin/pip3"
```

Te recopmiento usar siempre un entorno virtual (`venv`), para no llenar de librerías tu sistema a nivel global. Yo siempre hago una prueba de concepto cuando instalo python.

Preparo el directorio del proyecto y las librerías que va a usar:

```zsh
proyecto ❯ python3 -m venv myenvtest
proyecto ❯ source myenvtest/bin/activate
proyecto ❯ where python3  <== IMPORTANTE, COMPRUEBO QUE ME HA CAMBIADO EL PATH +---------------+
/Users/luis/Desktop/proyecto/myenvtest/bin/python3 <== Y ME PONE DELANTE EL DIRECTORIO VENV <--+
/opt/homebrew/bin/python3
/usr/bin/python3
proyecto ❯ python3 -m pip install requests idna
proyecto ❯ python3 -m pip freeze > requirements.txt
```

Creo un programa en python, que llamo `test.py`

```python
# test.py
# Script de prueba para comprobar la conexión a internet

import requests

try:
    response = requests.get('https://httpbin.org/ip', timeout=5)
    if response.status_code == 200:
        data = response.json()
        ip = data.get('origin', 'IP no encontrada')
        print(f'Tu dirección IP es: {ip}')
    else:
        print(f'Error: respuesta HTTP {response.status_code}')
except requests.exceptions.RequestException as e:
    print(f'Error de conexión: {e}')
```

Ejecuto el programa

```zsh
proyecto ❯ python3 ./test.py
Tu dirección IP es: 9.13.11.48
```

Ya tienes `python` instalado y funcionando. Podemos borrar el directorio de pruebas.

```zsh
cd ~/Desktop
rm -fr proyecto
```

### Integración con Visual Studio Code

Dejo aquí algunas recomendaciones para integrar Visual Studio Code y Python

- Instala esta extensión en tu VSCode -> [Python extension](https://marketplace.visualstudio.com/items?itemName=ms-python.python)

| |
|--|
| Si tienes mucho tiempo, un buen artículo: [Advanced Visual Studio Code for Python Developers](https://realpython.com/advanced-visual-studio-code-python/) |

---

## Ruby

<img src="/img/posts/logo-ruby.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

MacOS ya trae Ruby, pero voy a instalar la última versión con Hombrew en paralelo. Necesito `Bundler` y `Jekyll` (ver más adelante) para trabajar en mi blog en local (más info [aquí]({{< relref "2021-04-19-nuevo-blog.md" >}})). **Ruby** es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995.

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

- Añadir al final de `~/.zshrc`

```zsh
export GEM_HOME=~/.gems
export PATH=~/.gems/bin:$PATH
```

| Recuerda salir de iTerm y volver a entrar o ejecutar `source ~/.zshrc` para que encuentre los nuevos ejecutables |

---

## Jekyll y Bundler

<img src="/img/posts/logo-jekyll.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

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

---

## Node-JS

<img src="/img/posts/logo-nodejs.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

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

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-03.png" alt="Prueba rápida con Node.js." width="500px" />
  <div class="image-caption">Prueba rápida con Node.js.</div>
</div>

---

## MongoDB

<img src="/img/posts/logo-mongodb.svg" alt="logo linux router" width="150px" height="150px" style="float:right; padding-right:25px"  />

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

Ahora a **ejecutar MongoDB**

- Arrancar o Parar MongoDB como un servicio de macOS usando `brew`

```zsh
brew services start mongodb-community@7.0
```

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-04.png" alt="La primera vez que arrancamos" width="400px" />
  <div class="image-caption">La primera vez que arrancamos</div>
</div>

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

<div class="image-box">
  <img src="/img/posts/2023-04-15-mac-desarrollo-05.png" alt="Monitorizamos el fichero de Log del servidor" width="600px" />
  <div class="image-caption">Monitorizamos el fichero de Log del servidor</div>
</div>

Un **programa de ejemplo**

Te dejo una referencia a un pequeño proyecto en GitHub para que puedas probar `npm` y `mongod`.

- [Proyecto Tienda](https://github.com/LuisJal/ProyectoTienda)

---

## Jupyter Lab

[Jupyter Lab](https://jupyter.org) es una aplicación web que permite codificar, ejecutar y "documentar". Esta última es una de las partes más interesante del proyecto, puedes tener documentación y código a la vez y que se ejecute.

He documentado el proceso en otro apunte, más antiguo. La parte de Python puedes ignorarla porque la de aquí es más moderna, pero el resto te puede valer: [Python y JupyterLab en MacOS]({{< relref "2021-04-30-python-jupyter.md" >}}).

---

## VirtualBox y Vagrant

| Nota: Este punto solo me ha funcionado en un Mac on chip Intel, así que estás avisado, de momento no he encontrado cómo emular un Linux o Windows ARM con VirtualBox y Vagrant instalados en un Mac con Apple Silicon (ARM)  |

[VirtualBox](https://www.virtualbox.org) es un software de virtualización que permite isntalar sistemas operativos adicionales, conocidos como «sistemas invitados, guest o máquinas virtuales», dentro de tu sistema «anfitrión» (en mi caso el MacOS), cada uno con su propio ambiente virtual. Puedes crear máquinas virtuales basadas en FreeBSD, GNU/Linux, OpenBSD, OS/2 Warp, Windows, Solaris, MS-DOS, Genode y muchos otros.

[Vagrant](https://www.vagrantup.com/) permite crear y configurar entornos de desarrollo virtuales, ligeros y reproducibles, creando máquinas virtuales. Usa VirtualBox como virtualizador de forma nativa.

Podemos instalar ambos para montarnos **Servidores** virtuales para acompañar a nuestros desarrollos de software.

No dejes de leer el apunte [Vagrant para desarrollo]({{< relref "2023-04-23-mac-vagrant.md" >}}).

---

## HTTPie

Recomiendo la herramienta [HTTPie](https://httpie.io/) si vas a trabajar con API's. Te ayuda a trabajar con tus API's de forma sencilla e intuitiva. Tienen una versión gráfica y otra CLI.

El proceso para instalarlo en el Mac:

- Desde la página de [Descargas](https://httpie.io/download) accedo a Download for MAC y me instalo la versión GUI

Ejemplos:

- Hola Mundo
  - `https httpie.io/hello`
- Método HTTP personalizado, encabezados HTTP y datos JSON
  - `http PUT pie.dev/put X-API-Token:123 name=John`
- Envío de formularios
  - `http -f POST pie.dev/post hello=World`
- Ver la solicitud que se está enviando utilizando una de las opciones de salida
  - `http -v pie.dev/get`
- Construir e imprimir una solicitud sin enviarla utilizando el modo offline
  - `http --offline pie.dev/post hello=offline`
- Usar la API de Github para publicar un comentario en un issue con autenticación
  - `http -a USERNAME POST https://api.github.com/repos/httpie/cli/issues/83/comments body=HTTPie is awesome! :heart:`
- Subir un archivo utilizando entrada redirigida
  - `http pie.dev/post < files/data.json`
- Descargar un archivo y guardarlo mediante salida redirigida
  - `http pie.dev/image/png > image.png`
- Descargar un archivo al estilo wget
  - `http --download pie.dev/image/png`
- Usar sesiones nombradas para hacer persistentes ciertos aspectos de la comunicación entre solicitudes al mismo host
  - `http --session=logged-in -a username:password pie.dev/get API-Key:123`
  - `http --session=logged-in pie.dev/headers`
- Establecer un encabezado de host personalizado para evitar la falta de registros DNS
  - `http localhost:8000 Host:example.com`

---

## Otros

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

---

## Mantenimiento

Normalmente nos olvidamos de mantener lo que instalamos, así que **saber cómo hacer actualizaciones y reparaciones** es interesante. Suelo actualizar periódicamente, mínimo una vez al mes, aunque no instale nada nuevo. Compruebo que está todo al día. Los programas que no menciono en esta sección se actualizan automáticamente desde AppStore o sus propias opciones GUI.

### Actualizaciones

```zsh
brew update && brew upgrade            # Actualización estándar de homebrew
```

### Reparaciones

```zsh
brew update && brew update
brew doctor                # Herramienta de autodiagnóstico de Homebrew.
brew --version             # Comprobar la versión
brew list                  # Ver que está instalado
brew cask list             # Ver que cask’s están instalados
brew leaves                # Top level instalados (es lo más interesante)
```

```zsh
gem cleanup && gem pristine --all  # Actualizar hombrew cuado necesitas reparar problemas con el comando gem
```
