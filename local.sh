#!/bin/zsh
#
# SCRIPT pare ejecutar JEKYLL en local y servir las páginas de mi blog 
# durante su desarrollo. 
#

# Averiguo el directorio desde el que se ejecuta este script.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Cambio al directorio raíz de mi blog
cd ${SCRIPT_DIR}/docs

# Ejecuto el servidor en localhost
JEKYLL_ENV=development bundle exec jekyll serve 

# Ejecuto el servidor en mi hostname en mi LAN para poder probarlo 
# desde otros clientes (por ejemplo una tablet o un móvil)
#JEKYLL_ENV=development bundle exec jekyll serve --host idefix.parchis.org --port 4000

