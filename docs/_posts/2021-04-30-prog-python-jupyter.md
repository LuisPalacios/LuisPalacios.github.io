---
title: "Python y JupyterLab en MacOS"
date: "2021-04-30"
categories: desarrollo
tags: macos python jupyter
excerpt_separator: <!--more-->
---

![logo python](/assets/img/posts/logo-python.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


[Python](https://www.python.org) es un lenguaje de programación interpretado multiparadigma. [`pip`](https://pypi.org/project/pip/) permite gestionar paquetes desde PyPi (el [Python Package Index](https://pypi.org)). [PipEnv](https://pipenv.pypa.io/en/latest/) permite crear un entorno virtual para ejecutar tu aplicación de forma aislada con las librerías necesarias. [Jupyter Lab](https://jupyter.org) es una aplicación web que sirve a modo de puente entre el código y los textos explicativos. 

<br clear="left"/>
<!--more-->

En este apunte técnico voy a mostrar como instalar **Python, Pip y PipEnv** para poder ejecutar aplicaciones hechas en Python y además cómo crear un entorno de desarrollo, pruebas y documentación con **JupyterLab**, todo en MacOS, así que empezamos por el principio. 

<br/>

## I. Instalar Python 3 en MacOS

[Python](https://www.python.org) es un lenguaje de programación interpretado cuya filosofía hace hincapié en la legibilidad de su código.​ Se trata de un lenguaje de programación multiparadigma, ya que soporta parcialmente la orientación a objetos, programación imperativa y, en menor medida, programación funcional


MacOS trae versiones antiguas (Python 2 y 3) así que lo primero es instalarnos la última versión. 

1. Descargar la última versión para [Mac OS X](https://www.python.org/downloads/mac-osx/)

2. Ejecutar "Install Certificates.command" desde /Applications/Python 3.9, usando el Finder

3. Abrir la línea de comandos (Terminal.app o iTerm) y ejecutar `/Applications/Python 3.9/Update/Shell Profile.command`.

4. Modificar la línea de comandos para anticipar el nuevo Python3 en el $PATH: `export PATH=/usr/local/bin:/usr/local/sbin:$PATH`.

5. Para evitar ejecutar "python" o "pip" con la versión antigua, en tu .zshrc:
   -  `alias python=/usr/local/bin/python3" >> ~/.zshrc`
   -  `alias pip=/usr/local/bin/pip3" >> ~/.zshrc`

6. Nunca borres el Python original que trae OSX.

7. A partir de ahora utiliza: `/usr/local/bin/python3`


<br/>

## II. Instalar PIP

Un indispensable, `pip` es el sistema de gestión de paquetes utilizado para instalar y administrar los paquetes desde **PyPI**, el [Python Package Index](https://pypi.org), el repositorio de software oficial para aplicaciones de terceros en el lenguaje de programación Python. 

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

<br>

### Entornos aislados de Python

Las aplicaciones en Python hacen uso de paquetes y módulos que no forman parte de la librería estándar. La gestión de qué versiones y librerías instalo puede llegar a ser inmanejable. La solución consiste en crear un entorno virtual, que me ofrezca la capacidad de ejecutar mi aplicación de forma aislada con acceso a las librerías con las versiones necesarias, sin conflictos. 

Python tiene varias formas populares de crear entornos virtuales, por ejemplo:

- [Virtualenv](https://virtualenv.pypa.io/en/latest/): Virtualenv fue la forma por defecto de crear un entorno virtual durante muchos años. Todavía es usado por muchos aunque la gente se está moviendo a `pipenv` o a conda.

- [Conda](https://docs.conda.io/projects/conda/en/latest/index.html): Facilita mucho la instalación de los paquetes, está muy vinculado a Anaconda, ahora bien, quizá es demasiado grande. Por mi lado me quedo con el siguiente.

- [PipEnv](https://pipenv.pypa.io/en/latest/): Pipenv fue creado debido a muchas deficiencias de virtualenv y es mi método preferido. Pipenv funciona en Windows, Linux y Mac; y en todos los sistemas operativos funciona exactamente igual (cambiando la ruta donde se guardan las cosas). Su mejor baza es que crea (y gestiona) entornos virtuales exclusivos en una carpeta separada del proyecto en el que estamos trabajando.

<br/>

## III. Instalar PipEnv

Mi preferencia personal es **PipEnv**, una herramienta que pretende traer lo mejor de varios mundos del empaquetado (bundler, composer, npm, cargo, yarn, etc.) al mundo de Python. 

Ejecuta lo siguiente: 

```zsh
$ pip install pipenv
```

Preparar la instalación de `pipenv` para tu usuario previene romper cualquier paquete de sistema. Una vez que lo instales, confirma si `pipenv` está disponible.

```zsh
$ pipenv --version
pipenv, version 2020.11.15
```


Si no puedes ejecutar `pipenv`significa que necesitas corregir tu variable PATH. Tendrás que modificar tu fichero `.bashrc`o `.zsh`, según qué shell ejecutas. Desde el 2019 Apple recomienda `zsh`. Verifica qué shell tienes configurada en Preferencias del Sistema > Usuarios y Grupos > (botón derecho sobre tu usuario) Opciones Avanzadas > Shell de inicio de sesión (cambia a `zsh`). Después modifica `$HOME/.zsh`

```zsh
➜  ~ grep PATH .zshrc
export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/Users/lpalacio/Library/Python/3.9/bin:$PATH
launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:/Users/lpalacio/Library/Python/3.9/bin:$PATH"
```

<br/>

### Prueba de concepto: Crear un mini proyecto.

Voy a crear un mini proyecto en Python, con un único fuente llamado `main.py` bajo un entorno virtual preparado con `pipenv`. Recuerda que **debes instalar las librerías necesarias con `pipenv` siempre desde el directorio de tu proyecto**. En este ejemplo uso la librería `requests`.

```zsh
➜  ~ > mkdir proyecto
➜  ~ > cd proyecto
➜  proyecto > pipenv install requests
:
```

Se configura tu entorno virtual y se creará el archivo `/Users/luis/myproject/Pipfile`, que contiene una lista de todos las bibliotecas necesarias para tu proyecto: 

```python
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

Nota: Si usas un sistema de control de versiones (por ejemplo GIT) te recomiendo mantener ambos ficheros `Pipfile` y `Pipfile.lock` dentro de GIT, solo si estas usando multiples versiones de Python debes excluir `Pipfile.lock`

Los tres comandos más típicos que usarás son `pipenv install`, `pipenv uninstall`y `pipenv lock`. Este último crea el fichero `Pipfile.lock` donde se declaran todas las dependencias (y subdependencias) de tu proyecto, sus ultimas versiones, y el actual hash de los archivos descargados. Esto asegura builds repetibles y determinísticos. 

Se recomienda siempre actualizar todas las dependencias antes de entrar en producción, así que siguiendo con esta prueba de concepto, vamos a "fijar" las dependencias para este mini proyecto: 

```zsh
➜  myproject > pipenv lock
```

Creamos el fichero fuente 

```python
➜  proyecto > cat > main.py
import requests
response = requests.get('https://httpbin.org/ip')
print('Tu dirección IP es: {0}'.format(response.json()['origin']))
```

y lo ejecutamos desde un entorno seguro (`pipenv run python main.py`)

```
(proyecto) ➜  proyecto > pipenv run python main.py
Tu dirección IP es: 80.31.238.6
```

<br/>

## IV. Preparar el entorno "Jupyter lab"

[Jupyter Lab](https://jupyter.org) es una aplicación web que permite codificar, ejecutar y "documentar". Esta última es una de las partes más interesante de este apunte. Vamos a por ello, creo un entorno **Jupyter Lab**; un editor online (que se ejecuta en tu browser) que te permite trabajar con documentos de texto llamados **Jupyter notebooks**, arrancar terminales u otros componentes personalizados. Lo mejor de estos notebookses que puedes incluir otros contenidos además del código fuente.

<br/>

### Prueba de concepto: Jupyter notebook "sencillo"

De nuevo vamos a crear un proyecto ficticio que permita sacar algún gráfico que se mostrará usando la librería `matplotlib` y `numpy`.

```zsh
➜  ~ > mkdir plot
➜  ~ > cd plot
➜  plot > pipenv install matplotlib numpy
:
```

Instalamos `jupyterlab` dentro del proyecto

```zsh
➜  plot > pipenv install jupyterlab
```

Arrancamos nuestro entorno de Jupyter Lab y seguimos desde el navegador: 

```
➜  plot > pipenv run jupyter lab
:
    To access the server, open this file in a browser:
        file:///Users/luis/Library/Jupyter/runtime/jpserver-15847-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/lab?token=b9eb71b1ee64adf9b199bf7a6f2fb7f9b2d5835d1914e3ab
        http://127.0.0.1:8888/lab?token=b9eb71b1ee64adf9b199bf7a6f2fb7f9b2d5835d1914e3ab
```

Nos prepara un servidor que se queda escuchando en el puerto `8888` y nos muestra una URL junto con un token para conectar con él. Normalmente nos arranca el navegador y conecta automáticamente, o bien hacemos CMD-click o copiamos/pegamos y conectamos con el entorno. 

{% include showImagen.html 
      src="/assets/img/posts/prog-python-jupyter-1.jpg" 
      caption="Pantalla inicial del Jupyter Lab" 
      width="600px"
      %}

* Creamos un notebook: File > New > Notebook (Python3)
* Lo renombramos: botón derecho, rename > `plot.ipynb`
* Añadimos una celda de texto markdown y una de código y lo ejecutamos

{% include showImagen.html 
      src="/assets/img/posts/prog-python-jupyter-2.jpg" 
      caption="Documentación, código y ejecución" 
      width="600px"
      %}

<br/>

### Prueba de concepto: Jupyter notebook Data Science

Si queremos algo más complejo, un entorno más complicado con múltiples librerías, a continuación verás como instalarlas. En este ejemplo queremos trabajar con pandas, matplotlib, seaborn, prophet... entramos en nuestro nuevo proyecto (lo he llamado `proyecto_pandas`) e instalamos las librerías. 

```zsh
➜  > mkdir proyecto_pandas
➜  > cd proyecto_pandas
➜  proyecto_pandas > 
➜  proyecto_pandas > pipenv install
➜  proyecto_pandas > pipenv check
➜  proyecto_pandas > pipenv install matplotlib numpy pandas
➜  proyecto_pandas > pipenv install tabulate
➜  proyecto_pandas > pipenv install openpyxl
➜  proyecto_pandas > pipenv install Cython convertdate lunarcalendar holidays
➜  proyecto_pandas > pipenv install pystan
➜  proyecto_pandas > pipenv install jupyterlab
➜  proyecto_pandas > pipenv install seaborn
➜  proyecto_pandas > pipenv install plotnine plotly
➜  proyecto_pandas > pipenv install ipywidgets
➜  proyecto_pandas > pipenv install jupyter_client # (para que croos_validation de fbprophet.diagnostics funcione)
➜  proyecto_pandas > pipenv run jupyter nbextension enable --py widgetsnbextension # (para que croos_validation de fbprophet.diagnostics funcione)
➜  proyecto_pandas > pipenv install prophet
➜  proyecto_pandas > pipenv install lxml html5lib beautifulsoup4 sqlalchemy feather-format matplotlib xlrd scipy ipykernel pexpect ipython-sql Faker
```
<br/>

### SQL con JupyterLab

Si queremos utilizar SQL con JupyterLab recomiendo usar la extensión hecha por Catherine Devlin, [IPython SQL Magic](https://github.com/catherinedevlin/ipython-sql).

La extensión IPython SQL magic hace posible escribir consultas SQL directamente en las celdas de código, así como leer los resultados directamente en pandas DataFrames ([Fuente](http://news.datascience.org.ua/2019/01/11/unleash-the-power-of-jupyter-notebooks/)). Esto funciona tanto para los cuadernos tradicionales como para los modernos Jupyter Labs.

Instalo IPython SQL Magic: 

```zsh
pipenv install ipython-sql
```

Además vamos a combinarlo con **los comandos mágicos**, un conjunto de funciones convenientes en Jupyter Notebooks que están diseñados para resolver algunos de los problemas comunes en el análisis de datos estándar. Puedes ver todas los comandos mágicos disponibles con la ayuda de %lsmagic

Por lo tanto, a partir de ahora podré cargar en mis cuadernos esta extesión: 

```
%load_ext cql
```

Cargamos la base de datos

```
%sql sqlite:///tarjetasblack.db
```

Mostrar el contenido de la tablas

```
%tables
```

Ejecutar comandos

```
%sql select * from movimiento;
```

{% include showImagen.html 
      src="/assets/img/posts/prog-python-jupyter-3.png" 
      caption="Habilitamos SQL en Jupyter Labsd" 
      width="400px"
      %}

<br/>

## Administración del entorno. 

Por último vamos a ver algunas acciones que vamos a necesitar

<br/>

### Eliminar el entorno PipEnv

Si queremos eliminar el entorno virtual de un proyecto concreto, nos cambiamos a su directorio y ejecutamos `pipenv --rm`

```zsh
➜  ~ > cd plot
➜  plot > pipenv --rm
Removing virtualenv (/Users/luis/.local/share/virtualenvs/plot-djKM4O4f)...
```

<br/>

## Actualizaciones

Instalar es relativamente fácil, pero con tantos programas y módulos en tu sistema es importante saber cómo actualizarlos.

- Actualiza **Python** en tu MacOS reinstalando la [última versión](https://www.python.org/downloads/mac-osx/).
- Actualiza **pip** ejecutando el comando `pip install --upgrade pip`
- Actualiza **todo lo que has instalado con `pip`** mediante: 

````
pip list --outdated --format=freeze |\
    grep -v '^\-e' |\
    cut -d = -f 1  |\
    xargs -n1 pip install -U
```
