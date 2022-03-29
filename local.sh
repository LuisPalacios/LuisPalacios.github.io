#!/bin/zsh
#
# SCRIPT pare ejecutar JEKYLL en local y servir las páginas de mi blog 
# durante su desarrollo. 
#

# Averiguo el directorio desde el que se ejecuta este script.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Cambio al directorio raíz de mi blog
cd ${SCRIPT_DIR}/docs

# Ejecuto el servidor en localhost, incluyendo los posts bajo ./docs/_drafts
# Nota: Los archivos .md que están bajo ./docs/_drafts no se mostrarán en producción.
JEKYLL_ENV=development bundle exec jekyll serve --drafts --port 4001 #--host=192.168.100.3

# Ejecuto el servidor en mi hostname en mi LAN para poder probarlo 
# desde otros clientes (por ejemplo una tablet o un móvil)
#JEKYLL_ENV=development bundle exec jekyll serve --drafts --host idefix.parchis.org --port 4001

