---
title: "Mi nuevo blog !!"
date: "2021-04-19"
categories: herramientas
tags: blog linux github jekyll
excerpt_separator: <!--more-->
---

![Logo Jekyll](/assets/img/posts/logo-jekyll.svg){: width="150px" height="150px" style="float:left; padding-right:25px" } 

En este apunte describo cómo he montado este blog estático "fabricado" con [jekyll](http://jekyllrb.com) y hospedado en las [GitHub Pages](https://pages.github.com). Los fuentes se encuentran a su vez en el repositorio [LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io). El sitio ha quedado finalmente configurado en mi dominio: [https://www.luispa.com](https://www.luispa.com)

<br clear="left"/>
<!--more-->

Seguro que conoces GitHub, una plataforma de colaboración y compartición de código (mediante el sistema de control de versiones `git`). Por cierto, más info [en mi apunte]({% post_url 2021-04-17-git-en-detalle %}) sobre GIT.

Bueno, pues tiene una característica muy útil llamada **GitHub Pages**, que te permite publicar tus propias páginas web para que las hospede el propio **GitHub**. Se integra perfectamente con el generador de sitios estáticos llamado **Jekyll**, que tiene capacidades de blog y es super adecuado para montarte blogs o sitios web personales. Por cierto, está escrito en Ruby y su creador es Tom Preston-Werner, el cofundador de GitHub.

{% include showImagen.html 
      src="/assets/img/posts/nuevo-blog.jpg" 
      caption="Arquitectura GitHub Pages" 
      width="730px"
      %}

El proceso que he seguido, muy, muy resumido:

* Preparar el Mac (instalarme: **Brew, Ruby, Jekyll, Bundler, GIT**),
* Crear un directorio dedicado nuevo y un repositorio local para el futuro LuisPalacios.github.io
* Escribir "apuntes" en formato **markdown** (nuevos o migrados desde mi blog antiguo) 
* Conectar con la versión local del sitio en mi ordenador e ir probando...
* Hacer un `git push` al repositorio remoto para crear [LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io)
* Ver cómo GitHub genera las páginas automáticamente.
* Conectar con la versión pública web del sitio

| Ah!, podrás encontrar trucos y documentación adicional sobre cómo he montado mi blog en los `issues` de GitHub, sobre todo en los haya [cerrado](https://github.com/LuisPalacios/LuisPalacios.github.io/issues?q=is%3Aissue+is%3Aclosed) y resuelto. |


<br/>

## Preparar el Mac

A continuación vemos paso a paso lo que he ido haciendo, pero para tener una visión global del proceso comentar que... uso la versión de Ruby que viene con [Homebrew](https://brew.sh/index_es) en vez de la que viene con el Mac para evitar problemas con SIP (Systems Integrity Protection - [fuente](https://jekyllrb.com/docs/troubleshooting/#jekyll--macos)). También he seguido un par de enlaces interesantes: [Jekyll Installation](https://jekyllrb.com/docs/installation/) o sobre [Git en GitHub](https://docs.github.com/en/articles/set-up-git) y también [Bundler](https://bundler.io). 

<br/>

### Homebrew

Si trabajas en un Mac y eres desarrollador o necesitas programas de bajo nivel o de línea de commandos es muy, pero que muy probable que tengas que instalarte [Homebrew](https://brew.sh/index_es) (o brew por resumir). Se trata de un sistema de gestión de paquetes que simplifica la instalación, actualización y eliminación de programas en los sistemas operativos Mac OS de Apple y GNU/Linux. Creado originalmente por Max Howell, el programa ha ganado popularidad en la comunidad de Ruby on Rails. Lo que más me gusta es que te permite acceder a las últimas versiones de un montón de software libre.

Instalación

```zsh
➜  ~ > /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Ver qué está instalado:

```zsh
➜  ~ > brew list
➜  ~ > brew cask list
```

Actualizar `brew`:

```zsh
➜  ~ > brew [-v] update
➜  ~ > brew [-v] upgrade
```

Ejemplos de instalaciones:

```zsh
➜  ~ > brew install wget
➜  ~ > brew install imagemagick
```

Me aseguro que *brew* está correctamente instalado y actulalizado

```zsh
➜  ~ > brew update
➜  ~ > brew doctor
➜  ~ > brew --version
Homebrew 3.1.2
➜  ~ > nano $HOME/.zshrc
	PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
    launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:$PATH"
```

<br/>

### Python

No es necesario instalar Python para lo que estamos discutiendo aquí, pero es un buen momento para hacerlo si lo vas a necesitar en el futuro. Aquí tienes un [apunte sobre Python en MacOS]({% post_url 2021-04-30-python-jupyter %})


<br/>

### Ruby

Ruby es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995. Necesitamos Ruby para ejecutar Jekyll, así que voy a instalarlo utilizando Homebrew:

```zsh
➜  ~ > brew install ruby
➜  ~ > nano $HOME/.zshrc
   export PATH=$HOME/0_priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:$PATH
   launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:$PATH"
```

Para poder instalar gem’s en mi directorio HOME (y evitar tener que hacer instalaciones a nivel de todo el sistema)

```zsh
➜  ~ > nano $HOME/.zshrc
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH
```

<br/>

### Bundler

Es un gestor de paquetes de software que va a facilitar el trabajo con Jekyll y sus dependencias. 

```zsh
➜  ~ > gem install jekyll bundler
```

Meses después, tras actualizar Homebrew, Ruby y el propio Macos, me encontré con problemas con el comando gem. Lo resolví ejecutando lo siguiente: 

```zsh
➜  ~ > gem cleanup && gem pristine --all
```


<br/>

### Jekyll

Jekyll es un generador simple para sitios web estáticos con capacidades de blog; está escrito en Ruby por Tom Preston-Werner (cofundador de GitHub) y es rapidísimo. 

Para instalarlo en mi Mac he seguido esta [fuente](https://jekyllrb.com/docs/troubleshooting/#jekyll--macos)

<br/>

### Prueba de concepto

Una vez que tengo todo lo anterior instalado, intento probar que todo va bien... 

```zsh
➜  ~ > jekyll new test
New jekyll site installed in /Users/luis/test.
➜  ~ > cd test
➜  ~ test > bundle add webrick
➜  ~ test > bundle exec jekyll serve
```

Desde un browser conecto (y funciona) con mi propio ordenador en: [http://127.0.0.1:4000/](http://127.0.0.1:4000/)

<br/>

## luispalacios.github.io 

Sigo las instrucciones de [pages.github.com](https://pages.github.com) y su [documentación oficial](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll) para crear mi [Mi repositorio LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io)

Realizo un clone en local y cambio al directorio.

```zsh
➜  ~ > cd github/LuisPalacios.github.io
➜  LuisPalacios.github.io git:(master) >
```

Creo la nueva rama, sin history ni contenido, con el nombre `gh-pages` y cambio (checkout) a dicha rama. **Decido que el directorio raiz ([GitHub sources](GitHub sources)) sea el “subdirectorio `./docs`**, así que tengo que crearlo y después crear la rama (branch) “gh-pages” y hacer un checkout hacia ella (cambiar a dicha rama). Github publicará desde dicha rama.

<br/>

### Mi directorio raíz está en: "./docs"

```zsh
➜  docs git:(master) > git checkout --orphan gh-pages
Switched to a new branch 'gh-pages'
➜  LuisPalacios.github.io git:(master) > mkdir docs 
➜  LuisPalacios.github.io git:(master) > cd docs 
```

Creo un nuevo “sitio” con jekyll

```zsh
➜  docs git:(gh-pages) ✗ > jekyll new .
```

Abro el fichero Gemfile que se ha creado y comento la línea que empieza por gem “Jekyll” y además Añado el gem “github-pages” en la línea que empieza por # gem "github-pages"

```zsh
#gem "jekyll", "~> 4.2.0"
gem "github-pages", "~> 214", group: :jekyll_plugins
```

Por último hago un bundle update

```zsh
➜  docs git:(gh-pages) ✗ > bundle update
```

<br/>

### Acceso en local

Una de las ventajas es que puedo activar un "web server" en local en el mismo ordenador donde estoy editanto los ficheros Markdown. Para conseguirlo, cambio al directorio de los posts (./docs) y ejecuto lo siguiente: 

```zsh
docs git:(gh-pages) ✗ > bundle add webrick             <== Esto solo una vez
docs git:(gh-pages) ✗ > bundle exec jekyll serve
```

Para actualizar las páginas en GitHub simplemente hago mi primer commit y empujo la rama actual (el branch “gh-pages”) al remoto (el que está en GitHub) como su upstream.

```zsh
➜  docs git:(gh-pages) ✗ > git commit -m "initial commit"
➜  docs git:(gh-pages) ✗ > git push --set-upstream origin 'gh-pages'
```

Añado doc y sincronizo (push)

```zsh
➜  docs git:(gh-pages) ✗ > cd ..
➜  LuisPalacios.github.io git:(gh-pages) ✗ > git add docs
➜  LuisPalacios.github.io git:(gh-pages) ✗ > git commit -m "añado docs"
➜  LuisPalacios.github.io git:(gh-pages) > git push
```

En GitHub configuro el “[publishing source for your GitHub Pages site](https://docs.github.com/en/articles/configuring-a-publishing-source-for-your-github-pages-site#choosing-a-publishing-source)"

- En GitHub, navego hasta el repositorio del sitio
- Bajo el nombre del repositorio, clic en Configuración
- En la barra lateral izquierda, clic en Páginas.
- En Source selecciono la Branch gh-pages y el directorio /docs y lo salvo



|Al cabo de unos minutos estará aquí disponible|
|:---:|
| [https://luispalacios.github.io](https://luispalacios.github.io) |


El siguiente paso es opcional. En mi caso tengo un dominio propio así que seguí la [guía para redirigir mi dominio](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site) a las páginas de GitHub (básicamente poner un CNAME en tu proveedor) y además activé SSL, por lo tanto mi sitio Blog ahora ya se encuentra aquí: 

| Documentación sobre [cómo redirigir tu dominio](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)| 
|:---:|
| [https://www.luispa.com](https://www.luispa.com) |

<br/>

<a id="paginate">

### Paginación

En muchos sitios web, especialmente en los blogs, es muy común dividir el listado principal de publicaciones en listas más pequeñas y mostrarlas en varias páginas. Jekyll ofrece un plugin de paginación, para que poder generar automáticamente un blog paginado, así que he seguido el manual de Jekyll sobre cómo [configurar la paginación](https://jekyllrb.com/docs/pagination/):

* Activo la paginación en el fichero `_config.yml`

```
paginate: 3
paginate_path: '/page-:num/'
```

* Elimino el fichero `index` original `./docs/index.markdown`

```
➜  docs git:(gh-pages) ✗ > mv index.markdown ..
```

* Creo el fichero `./docs/index.html` en la raíz del sitio.

```html
{% raw %}
---
layout: default
---

<!-- Loop sobre los diferentes apuntes -->
{% for post in paginator.posts %}
  <h1><a href="{{ post.url }}">{{ post.title }}</a></h1>
  <p class="author">
  <!-- Muestro la fecha en castellano -->
  <span class="date">{% assign m = post.date | date: "%-m" %}
                      {{ post.date | date: "%-d de" }}
                      {% case m %}
                      {% when '1' %}enero
                      {% when '2' %}febrero
                      {% when '3' %}marzo
                      {% when '4' %}abril
                      {% when '5' %}mayo
                      {% when '6' %}junio
                      {% when '7' %}julio
                      {% when '8' %}agosto
                      {% when '9' %}septiembre
                      {% when '10' %}octubre
                      {% when '11' %}noviembre
                      {% when '12' %}diciembre
                      {% endcase %}
                      {{ post.date | date: "de %Y" }}</span>
  </p>
  <div class="content">
    {{ post.excerpt }}
  </div>
{% endfor %}

<!-- Enlaces a la paginación -->
<div class="pagination">
    Página:
  {% if paginator.previous_page %}
    <a href="{{ paginator.previous_page_path }}" class="previous">
      Previa
    </a>
  {% else %}
    <span class="previous"></span>
  {% endif %}
  <span class="page_number ">
    ( {{ paginator.page }} de {{ paginator.total_pages }} )
  </span>
  {% if paginator.next_page %}
    <a href="{{ paginator.next_page_path }}" class="next">Siguiente</a>
  {% else %}
    <span class="next ">Siguiente</span>
  {% endif %}
</div>
{% endraw %}
```

<br/>

### Búsqueda

Una de las características más útiles de un blog es la posibilidad de buscar dentro de sus artículos pero por desgracia Jekyll no trae ni implementa dicha función. He encontrado una alternativa en este proyecto [Simple-Jekyll-Search](https://github.com/christian-fei/Simple-Jekyll-Search). 

* Me bajo los scripts a mi ordenador: 

```zsh
➜  ~ > npm install simple-jekyll-search
added 2 packages, and audited 3 packages in 708ms
found 0 vulnerabilities
```

* Copio los scripts a `docs/assets/js`

```
➜  > cd $HOME/prog.git/github-luispa/LuisPalacios.github.io
➜  > cp $HOME/node_modules/simple-jekyll-search/dest/simple-jekyll-search.* docs/assets/js

➜  > ls -al docs/assets/js
total 48
drwxr-xr-x  5 luis  staff   160  2 may 13:37 .
drwxr-xr-x@ 7 luis  staff   224  2 may 12:38 ..
-rw-r--r--  1 luis  staff  9854  2 may 13:37 simple-jekyll-search.js
-rw-r--r--  1 luis  staff  4379  2 may 13:37 simple-jekyll-search.min.js
-rw-r--r--  1 luis  staff  2491  2 may 07:49 vanilla-back-to-top.min.js
```

* Creo el fichero `search.json` en el directorio raíz de mi blog (recuerdo que es `docs`)

```
➜  ~ > cd prog.git/github-luispa/LuisPalacios.github.io/docs
➜  ✗ > cat > search.json
{% raw %}
---
layout: none
---
[
  {% for post in site.posts %}
    {
      "title"    : "{{ post.title | escape }}",
      "category" : "{{ post.category }}",
      "tags"     : "{{ post.tags | join: ', ' }}",
      "url"      : "{{ site.baseurl }}{{ post.url }}",
      "date"     : "{{ post.date }}"
    } {% unless forloop.last %},{% endunless %}
  {% endfor %}
]
{% endraw %}
```

Modifico mi fichero [./docs/_includes/footer.html](https://github.com/LuisPalacios/LuisPalacios.github.io/blob/gh-pages/docs/_includes/footer.html):


```
{% raw %}
<!-- Elemento HTML para realizar la búsqueda -->
<div id="search-container">
    <input type="text" id="search-input" placeholder="buscar...">
    <ul id="results-container"></ul>
</div>

<!-- Script apuntando al script JS que hará la búsqueda -->
<script src="/assets/js/simple-jekyll-search.js" type="text/javascript"></script>

<!-- Configuración -->
<script>
    SimpleJekyllSearch({
    searchInput: document.getElementById('search-input'),
    resultsContainer: document.getElementById('results-container'),
    json: '/search.json'
    })
</script>
{% endraw %}
```

<br/>

## Mejoras

### Issues

En vez de seguir ampliando este apunte lo que he hecho es crear `issues`en github con cada una de las modificaciones y mejoras que quería añadirle. 

Puedes encontrarlas entre mis [issues cerrados sobre este blog](https://github.com/LuisPalacios/LuisPalacios.github.io/issues?q=is%3Aissue+is%3Aclosed)


<br/>

### Actualizaciones

Actualizar Homebrew

```zsh
➜  ~ > brew update
➜  ~ > brew upgrade
```

Actualizar bundle

```zsh
➜  ~ > cd prog.git/github-luispa/LuisPalacios.github.io/docs
➜  docs git:(gh-pages) > bundle update
```

<br/>

### Enlaces interesantes

Para mejorar mi sitio de apuntes, algunos enlaces interesantes: 

- [Setup a blog using Jekyll](https://blog.codecut.de/2019/06/11/how-to-setup-a-blog-using-jekyll)
- [Setup tags](http://longqian.me/2017/02/09/github-jekyll-tag/)
