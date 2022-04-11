---
title: "Python y JupyterLab en MacOS"
date: "2021-04-30"
categories: desarrollo
tags: macos python pip pipenv jupyter jupyterlab
excerpt_separator: <!--more-->
---

![logo python-jupyter](/assets/img/posts/logo-python.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 


[Python](https://www.python.org) es un lenguaje de programación interpretado multiparadigma. [`pip`](https://pypi.org/project/pip/) permite gestionar paquetes desde PyPi (el [Python Package Index](https://pypi.org)). [PipEnv](https://pipenv.pypa.io/en/latest/) permite crear un entorno virtual para ejecutar tu aplicación de forma aislada con las librerías necesarias. [Jupyter Lab](https://jupyter.org) es una aplicación web que sirve a modo de puente entre el código y los textos explicativos. 

<br clear="left"/>
<!--more-->

En este apunte instalo **Python, Pip y PipEnv** para poder ejecutar aplicaciones hechas en Python. Muestro cómo crear un entorno de desarrollo, pruebas y documentación con **JupyterLab**, todo en MacOS, así que empezamos por el principio. 

<br/>

## Python 3, Pip, PipEnv en MacOS

**[Python](https://www.python.org)** es un lenguaje de programación interpretado cuya filosofía hace hincapié en la legibilidad de su código.​ Se trata de un lenguaje multiparadigma, ya que soporta parcialmente la orientación a objetos, programación imperativa y, en menor medida, programación funcional.

MacOS trae versiones muy antiguas de Python 2 y 3, que no vamos a usar, pero tampoco debemos borrarlas o sobreescribirlas. Lo que vamos a hacer es instalarnos las últimsa versiones de Python, Pip y PipEnv en un sitio diferente del disco. 

Para el principal, `Python`, tenemos dos opciones: 

  * **Instalar Homebrew y desde ahí instalar Python**  (preferido)
    * Si eres un desarrollador de sotware es muy probable que instales más herramientas desde Homebrew (mi caso), de hecho algunas puede que dependan de tener Python instalado desde él, así que mi recomendación es ir por la línea de Homebrew, aún así te dejo aquí documentado cómo instalarlo desde python.org
  * Instalar Python directamente desde https://www.python.org


**[Pip](https://pypi.org/project/pip/)** es un indispensable, es el sistema de gestión de paquetes utilizado para instalar y administrar paquetes hechos en Python desde **PyPI**, el [Python Package Index](https://pypi.org), el repositorio de software oficial para aplicaciones de terceros en el lenguaje de programación Python. 

**[PipEnv](https://pipenv.pypa.io/en/latest/)** es otro indispensable. Las aplicaciones en Python hacen uso de paquetes y módulos que no forman parte de la librería estándar y gestionar qué versiones y librerías puede llegar a ser inmanejable. La solución consiste en crear un entorno virtual, sin conflictos y tenemos tres formas de hacerlo: 

- [Virtualenv](https://virtualenv.pypa.io/en/latest/): Virtualenv fue la forma por defecto de crear un entorno virtual durante muchos años. Todavía es usado por muchos aunque la gente se está moviendo a `pipenv` o a conda.

- [Conda](https://docs.conda.io/projects/conda/en/latest/index.html): Facilita mucho la instalación de los paquetes, está muy vinculado a Anaconda, pero quizá es demasiado grande/pesado, así que en mi caso siempre me voy a PipEnv... 
  
- [PipEnv](https://pipenv.pypa.io/en/latest/) (mi preferido): Pipenv fue creado debido a muchas deficiencias de virtualenv y es mi método preferido. Funciona en Windows, Linux y Mac; y en todos funciona exactamente igual (cambiando la ruta donde se guardan las cosas). Su mejor baza es que crea (y gestiona) entornos virtuales exclusivos en una carpeta separada pero vinculada del proyecto en el que estamos trabajando.

| Nota: Tendrás que modificar tu fichero `.bashrc`o `.zshrc`, según qué shell ejecutas. Desde el 2019 Apple recomienda `zsh`. Verifica qué shell tienes configurada en Preferencias del Sistema > Usuarios y Grupos > (botón derecho sobre tu usuario) Opciones Avanzadas > Shell de inicio de sesión (cambia a `zsh`). |


<br/>

#### Instalación de Python desde python.org

| Nota: esta opción no es la que uso, la dejo aquí por si la prefieres |

1. Descargar la última versión [para MacOS desde aquí](https://www.python.org/downloads/mac-osx/)
2. Ejecutar usando el Finder
```
    "Install Certificates.command" desde /Applications/Python 3.9
```
3. Abrir la línea de comandos (Terminal.app o iTerm) y ejecutar
```zsh
/Applications/Python 3.9/Update/Shell Profile.command
```
4. Modificamos la línea de comandos para anticipar el nuevo Python3 en el $PATH y creo un par de alias, así evito ejecutar las versiones antiguos de Python/Pip que vienen con el MacOS. Recuerda, nunca borres el Python original que trae OSX.
```shell
# En el  fichero $HOME/.zshrc
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
echo "alias python=/usr/local/bin/python3" >> ~/.zshrc
echo "alias pip=/usr/local/bin/pip3" >> ~/.zshrc
```
5. Además de Python necesitamos el indispensable `pip`, el gestor de paquetes utilizado para instalar y administrar los paquetes de Python desde **PyPI**, el [Python Package Index](https://pypi.org).
    8.1. Instalación de PIP desde `bootstrap.pypa.io`
```zsh
$ curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
$ python3 get-pip.py
```
6. Instalación de PipEnv
```zsh
$ pip install pipenv
```
7. Comprobar las versiones
```
$ python --version
Python 3.9.2
```
```
$ pip --version
pip 21.0.1 ...
```
```      
$ pipenv --version
pipenv, version 2020.11.15
```

<br/>

### Instalación de Python vía Hombrebrew

Homebrew instala todo aquello que necesitas que Apple no instala de serie. Si no lo tienes, instálalo ejecutando un único comando, más info aquí ([Homebrew](https://brew.sh/index_es)). 

| Nota: Esta es mi opción favorita y la que uso siempre |

1. Con Homebrew preparado, iniciamos la instalación de Python
```shell
$ brew install python
```
    * No solo va a instalar Python sino que además nos instala el indispensable `pip`, sistema de gestión de paquetes utilizado para instalar y administrar los paquetes desde **PyPI**, el [Python Package Index](https://pypi.org). Es el repositorio de software oficial para aplicaciones de terceros en el lenguaje de programación Python. 
2. Instalamos PivEnv (usando `pip` o `brew`). En mi caso suelo usar `pip`
```zsh
$ pip install pipenv
[[$ brew install pipenv]]
```
1. Modificamos la línea de comandos para anticipar el nuevo Python3 en el $PATH y creo un par de alias, así evito ejecutar las versiones antiguos de Python/Pip que vienen con el MacOS. Recuerda, nunca borres el Python original que trae OSX.
```shell
# Es es un ejemplo de mi fichero $HOME/.zshrc
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
echo "alias python=/usr/local/bin/python3" >> ~/.zshrc
echo "alias pip=/usr/local/bin/pip3" >> ~/.zshrc
```
4. Comprobar las versiones
```
$ python --version
Python 3.9.2
```
```
$ pip --version
pip 21.0.1 ...
```
```      
$ pipenv --version
pipenv, version 2020.11.15
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

## Preparar el entorno "Jupyter lab"

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

* Creamos un notebook: File > New > Notebook (Python3)
* Lo renombramos: botón derecho, rename > `plot.ipynb`
* Añadimos una celda de texto markdown y una de código y lo ejecutamos

```markdown
# Ejemplo de notebook

Este es un fichero de tipo notebook donde convino documentación en formato markdown junto con código y el resultado de su ejecución
```
```python
# Importar los paquetes y módulos necesarios
import matplotlib.pyplot as plt
import numpy as np

# Preparo unos cuantos datos
x = np.linspace(0, 10, 100)

# A dibujar...
plt.plot(x, x, label="lineal")

# Añado la leyenda
plt.legend()

# Muestro el dibu
plt.show()
```
{% include showImagen.html 
      src="/assets/img/posts/2021-04-30-python-jupyter-1.png" 
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
      src="/assets/img/posts/2021-04-30-python-jupyter-2.png" 
      caption="Habilitamos SQL en Jupyter Labsd" 
      width="400px"
      %}

<br/>

## Administración del entorno. 


### Eliminar el entorno PipEnv

Si queremos eliminar el entorno virtual de un proyecto concreto, nos cambiamos a su directorio y ejecutamos `pipenv --rm`

```zsh
➜  ~ > cd plot
➜  plot > pipenv --rm
Removing virtualenv (/Users/luis/.local/share/virtualenvs/plot-djKM4O4f)...
```

<br/>

### Hacer actualizaciones

Instalar es relativamente fácil, pero con tantos programas y módulos en tu sistema es importante saber cómo actualizarlos.

#### Si instalaste Python con Hombrebrew

Ejecuta los comandos siguientes

```
$ export HOMEBREW_VERBOSE=1
$ brew update
```
```
$ brew upgrade 
```
```
$ pip list --outdated --format=freeze |\
    grep -v '^\-e' |\
    cut -d = -f 1  |\
    xargs -n1 pip install -U
```

<br/>

#### Si instalaste Python de forma nativa

- Actualiza **Python** en tu MacOS reinstalando la [última versión](https://www.python.org/downloads/mac-osx/).
- Actualiza **pip** ejecutando el comando `pip install --upgrade pip`
- Actualiza **todo lo que has instalado con `pip`** mediante: 


