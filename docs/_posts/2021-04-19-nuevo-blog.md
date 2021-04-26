---
title: "Nuevo Blog con Jekyll"
date: "2021-04-19"
categories: apuntes github jekyll
---

![Logo Jekyll](/assets/img/post/logo-jekyll.png){: width="150px" style="float:left; padding-right:20px" } 

En este apunte describo cómo he hospedado mi nuevo blog en GitHub, generando las páginas con Jekyll. Los fuentes se encuentran en el repositorio [GitHub LuisPalacios/LuisPalacios.github.io](https://github.com/LuisPalacios/LuisPalacios.github.io). El blog es estático, basado en [jekyll](http://jekyllrb.com) y hospedado en las [GitHub Pages](https://pages.github.com). 

**Jekyll** es un generador simple para sitios web estáticos con capacidades de blog; adecuado para sitios web personales. Está escrito en Ruby (su creador es Tom Preston-Werner, el cofundador de GitHub).



<br/>

## Preparo Brew, Ruby, Jekyll y los Bundles en el MacOS

Utilizo [Homebrew](https://brew.sh/index_es) en vez del Ruby que viene con el Mac para evitar problemas con SIP (Systems Integrity Protection) [fuente](https://jekyllrb.com/docs/troubleshooting/#jekyll--macos). Otros enlaces interesantes: [Jekyll Installation](https://jekyllrb.com/docs/installation/), [Set up Git con GitHub](https://docs.github.com/en/articles/set-up-git) y [Bundler](https://bundler.io)

<br/>

## Homebrew brew

La instalación de Homebrew (o brew por resumir) es bastante sencilla. Homebrew es un sistema de gestión de paquetes que simplifica la instalación, actualización y eliminación de programas en los sistemas operativos Mac OS de Apple y GNU/Linux. Creado originalmente por Max Howell, el programa ha ganado popularidad en la comunidad de Ruby on Rails. Lo que más me gusta es que te permite acceder a las últimas versiones de un montón de software libre.

Instalación
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Ver qué está instalado:
```
brew list
brew cask list
```

Actualizar Brew
```
brew [-v] update
brew [-v] upgrade
```

Instalaciones
```
brew install wget
brew install imagemagick
```

Me aseguro que *brew* está correctamente instalado y actulalizado
```
~ brew update
~ brew doctor
~ brew --version
Homebrew 3.1.2
~ nano $HOME/.zshrc
	PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
    launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:$PATH"
```

<br/>

## Ruby

Ruby es un lenguaje de programación interpretado, reflexivo y orientado a objetos, creado por el programador japonés Yukihiro "Matz" Matsumoto, quien comenzó a trabajar en Ruby en 1993, y lo presentó públicamente en 1995. Necesitamos Ruby para ejecutar Jekyll, así que voy a instalarlo utilizando Homebrew:

```
~ brew install ruby
~ nano $HOME/.zshrc
   export PATH=$HOME/0_priv/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:$PATH
   launchctl setenv PATH "/usr/local/bin:/usr/local/sbin:/usr/local/opt/ruby/bin:$PATH"
```

Para poder instalar gem’s en mi HOME directory y no hacer system wide isntalls

```
~ nano $HOME/.zshrc
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH
```

## Bundler

Es un gestor de paquetes de software que va a facilitar el trabajo con Jekyll y sus dependencias. 

```
~ gem install jekyll bundler
```

## Jekyll

Jekyll es un generador simple para sitios web estáticos con capacidades de blog; está escrito en Ruby por Tom Preston-Werner (cofundador de GitHub) y es rapidísimo. 

Para instalarlo en mi Mac he seguido esta [fuente](https://jekyllrb.com/docs/troubleshooting/#jekyll--macos)


## Prueba de concepto

Una vez que tengo todo lo anterior instalado, intento probar que todo va bien... 

```
➜  ~ jekyll new test
New jekyll site installed in /Users/luis/test.
➜  ~ cd test
➜  test bundle add webrick
➜  test bundle exec jekyll serve
```

Desde un browser conecto (y funciona) con mi propio ordenador en: [http://127.0.0.1:4000/](http://127.0.0.1:4000/)

<br/>

## Creo mi sitio luispalacios.github.io 

Sigo las instrucciones de [pages.github.com](https://pages.github.com) y su [documentación oficial](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/creating-a-github-pages-site-with-jekyll) para crear mi sitio `luispalacios.github.io`

Realizo un clone en local y cambio al directorio.

```
➜  ~ > cd github/LuisPalacios.github.io
➜  LuisPalacios.github.io git:(master) >
````

Creo la nueva rama, sin history ni contenido, con el nombre `gh-pages` y cambio (checkout) a dicha rama. Decido que el directorio raiz ([GitHub sources](GitHub sources)) sea el “subdirectorio `./docs`”, así que tengo que crearlo y después crear la rama (branch) “gh-pages” y hacer un checkout hacia ella (cambiar a dicha rama). Github publicará desde dicha rama.

```
➜  docs git:(master) > git checkout --orphan gh-pages
Switched to a new branch 'gh-pages'
➜  LuisPalacios.github.io git:(master) > mkdir docs 
➜  LuisPalacios.github.io git:(master) > cd docs 
```

Creo un nuevo “sitio” con jekyll

```
➜  docs git:(gh-pages) ✗ > jekyll new .
```

Abro el fichero Gemfile que se ha creado y comento la línea que empieza por gem “Jekyll” y además Añado el gem “github-pages” en la línea que empieza por # gem "github-pages"

```
#gem "jekyll", "~> 4.2.0"
gem "github-pages", "~> 214", group: :jekyll_plugins
```

Por último hago un bundle update

```
➜  docs git:(gh-pages) ✗ > bundle update
```


## Acceso a mi blog en local

Una de las ventajas de todo esto es que puedo activar un "web server" en local en el mismo ordenador donde estoy editanto los ficheros Markdown. Para conseguirlo, cambio al directorio de los posts (./docs) y ejecuto lo siguiente: 

```
docs git:(gh-pages) ✗ > bundle add webrick             <== Esto solo una vez
docs git:(gh-pages) ✗ > bundle exec jekyll serve
```

Para actualizar las páginas en GitHub simplemente hago mi primer commit y empujo la rama actual (el branch “gh-pages”) al remoto (el que está en GitHub) como su upstream.

```
➜  docs git:(gh-pages) ✗ > git commit -m "initial commit"
➜  docs git:(gh-pages) ✗ > git push --set-upstream origin 'gh-pages'
```

Añado doc y sincronizo (push)

```
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

Al cabo de un rato debería estar disponible en

[https://luispalacios.github.io](https://luispalacios.github.io)


<br/>


## Futuros UPDATES

Actualizar Homebrew

```
➜  ~ > brew update
➜  ~ > brew upgrade
```

Actualizar bundle

```
➜  ~ > cd prog.git/github-luispa/LuisPalacios.github.io/docs
➜  docs git:(gh-pages) > bundle update
```
