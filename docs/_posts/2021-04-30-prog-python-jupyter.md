---
title: "Entorno JupyterLab con Python"
date: "2021-04-30"
categories: herramientas
tags: macos
excerpt_separator: <!--more-->
---

![logo md](/assets/img/post/prog-python-jupyter-0.png){: width="150px" style="float:left; padding-right:10px" } 

Jupyter Notebook es una aplicación web que sirve a modo de puente constante entre el código y los textos explicativos. Es decir, una plataforma para documentar y codificar (los llama notebooks). Permite trabajar con múltiples lenguajes de programación.

<br clear="left"/>
<!--more-->

Este apunte trata sobre cómo crear un entorno con JupyterLab en MacOS para trabajar principalmente con Python, así que empezamos por el principio. 

## (1) Instalar Python 3 en MacOS

MacOS trae versiones antiguas (Python 2 y 3) así que lo primero es instalarnos la última versión. 

1. Descargar la última versión para [Mac OS X](https://www.python.org/downloads/mac-osx/)

2. Ejecutar "Install Certificates.command" desde /Applications/Python 3.9, usando el Finder

3. Abrir la línea de comandos (Terminal.app o iTerm) y ejecutar `/Applications/Python 3.9/Update/Shell Profile.command`.

4. Modificar la línea de comandos para anticipar el nuevo Python3 en el $PATH: `export PATH=/usr/local/bin:/usr/local/sbin:$PATH`.

5. Para evitar ejecutar "python" con la versión antigua, en tu .zshrc: `alias python=/usr/local/bin/python3" >> ~/.zshrc`

6. Nunca borres el Python original que trae OSX.

7. A partir de ahora utiliza: `/usr/local/bin/python3`


## (2) Instalar PIP

Un indispensable, `pip` es el sistema de gestión de paquetes utilizado para instalar y administrar los paquetes desde PyPi. El [Python Package Index](https://pypi.org) o **PyPI** es el repositorio de software oficial para aplicaciones de terceros en el lenguaje de programación Python. 

Instalamos PIP desde la linea de comandos

```zsh
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ python3 get-pip.py
```

Estas son las versiones que yo tenía el día que hice esta instalación

```zsh
➜  ~ > python --version
Python 3.9.2
➜  ~ > pip --version
pip 21.0.1 from /Library/Frameworks/Python.framework/Versions/3.9/lib/python3.9/site-packages/pip (python 3.9)
```

### Entornos aislados de Python

Las aplicaciones en Python hacen uso de paquetes y módulos que no forman parte de la librería estándar. La gestión de qué versiones y librerías instalo y dónde puede llegar a ser inmanejable si quiero ejecutar distintos programas en Python en el mismo ordenador. 

La solución consiste en crear un entorno virtual, que me ofrezca la capacidad de ejecutar mi aplicación de forma aislada con acceso las librerías con las versiones necesarias, sin conflictos. 

Python tiene tres formas populares de crear entornos virtuales:

- [Virtualenv](https://virtualenv.pypa.io/en/latest/): Virtualenv fue la forma por defecto de crear un entorno virtual durante muchos años. Todavía es usado por muchos aunque la gente se está moviendo a `pipenv` o a conda.

- [Conda](https://docs.conda.io/projects/conda/en/latest/index.html): Facilita mucho la instalación de los paquetes, está muy vinculado a Anaconda, ahora bien, quizá es demasiado grande. Por mi lado me quedo con el siguiente.

- [PipEnv](https://pipenv.pypa.io/en/latest/): Pipenv fue creado debido a muchas deficiencias de virtualenv y es mi método preferido. Pipenv funciona en Windows, Linux y Mac; y en todos los sistemas operativos funciona exactamente igual (cambiando la ruta donde se guardan las cosas). Su mejor baza es que crea (y gestiona) entornos virtuales exclusivos en una carpeta separada del proyecto en el que estamos trabajando.


## (3) Instalar PipEnv

Mi preferencia personal es **PipEnv**, una herramienta que pretende traer lo mejor de varios mundos del empaquetado (bundler, composer, npm, cargo, yarn, etc.) al mundo de Python. 

Ejecuta lo siguiente: 

```zsh
$ pip install pipenv
```

Se preparar una instalación de usuario para prevenir romper cualquier paquete de sistema. Si `pipenv` no esta disponible en tu shell después de la instalación, vas a necesitar modificar la variable PATH.

Configuración para `zsh`. Desde hace tiempo Apple cambió desde `bash` a `zsh`. Verifica qué shell tienes configurada en Preferencias del Sistema > Usuarios y Grupos > (botón derecho) 
```zsh
➜  ~ grep PATH .zshrc
export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/Users/lpalacio/Library/Python/3.9/bin:$PATH
launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/Users/lpalacio/Library/Python/3.9/bin:$PATH"
```

#### Prueba de concepto: Crear un mini proyecto.

Voy a crear un mini proyecto en python, con un único fuente llamado `main.py` bajo un entorno virtual preparado con `pipenv`

```zsh
➜  ~ > mkdir myproject
➜  ~ > cd myproject
➜  myproject > pipenv install requests
Creating a virtualenv for this project...
Pipfile: /Users/luis/myproject/Pipfile
:
Pipfile.lock not found, creating...
Updated Pipfile.lock (fe5a22)!
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
```

Cuando ejecutas `Pipenv` te configura tu entorno virtual y creará un archivo llamado `Pipfile` que contiene una lista de todos las bibliotecas necesarias para tu proyecto. 

Vamos a echarle un ojo al fichero `Pipfile` que se ha creado. 

```zsh
➜  myproject > cat Pipfile
[[source]]
url = "https://pypi.org/simple"
verify_ssl = true
name = "pypi"

[packages]
requests = "*"

[dev-packages]

[requires]
python_version = "3.9"
```

Nota: Generalmente, mantén ambos ficheros `Pipfile` y `Pipfile.lock` en tu sistema de control de versiones (p.e. GIT). Solo si estas usando multiples versiones de Python es mejor que excluyas `Pipfile.lock`


```zsh
➜  myproject > pipenv lock
➜  myproject > pipenv lock -r
➜  myproject > pipenv shell
Launching subshell in virtual environment...
 . /Users/luis/.local/share/virtualenvs/myproject-8mgVbunj/bin/activate
➜  myproject >  . /Users/luis/.local/share/virtualenvs/myproject-8mgVbunj/bin/activate
(myproject) ➜  myproject > pip freeze
certifi==2020.12.5
chardet==4.0.0
idna==2.10
requests==2.25.1
urllib3==1.26.4
(myproject) ➜  myproject > cat > main.py
import requests
response = requests.get('https://httpbin.org/ip')
print('Your IP is {0}'.format(response.json()['origin']))

(myproject) ➜  myproject > python main.py
Your IP is 83.34.4.11
(myproject) ➜  myproject > exit

➜  myproject > pipenv run python main.py
Your IP is 83.34.4.11

```

### Prepare Jupyter lab environment

In this example I'm going to create a Jupyter Lab environment. First of all create the project (in the example python-regex`), then cd into it, install jupyterlab and run the lab. From your browser you can play in your new jupyterlab environment.

```
~ > mkdir python-regex
➜  ~ > cd python-regex
➜  python-regex >
➜  python-regex > pipenv install jupyterlab
➜  python-regex > pipenv run jupyter lab
```

Connect to my localhost at [http://localhost:8888/lab](http://localhost:8888/lab)
Create a new notebook

You can work from the browser or even from Visual Studio Code. 


### Other examples (Pandas environment)

For example, to create a Pandas environment run:

```
pipenv install pandas tabulate openpyxl lxml html5lib beautifulsoup4 sqlalchemy feather-format matplotlib xlrd scipy ipykernel jupyterlab pexpect ipython-sql Faker
```

### Remove PipEnv Enrironment

```
pipenv --rm
```

## Updates and Upgrades

Periodically run updates/upgrades of your installation: 

```
➜  ~ > pip install --upgrade pip
```

To update all installed packages with PIP there isn't a built-in flag yet, but you can use

```
➜  ~ > pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
```
