---
title: "Varios 'Servicios' en contenedores Docker"
date: "2014-11-12"
categories: apuntes
tags: docker multicontenedor
excerpt_separator: <!--more-->
---

Empecé [instalando un servidor "gitolite" con Docker](https://www.luispa.com/?p=184) para llegar al verdadero reto, migrar mis web's, git privado y correo desde un servidor único a múltiples contenedores Docker. He actualizado este apunte después de terminar, **dejo más abajo los fuentes en ![Docker](https://hub.docker.com/u/luispa/)/[GitHub](/assets/img/original/LuisPalacios)** y para entenderlos qué mejor que una imagen (click para ampliar){: width="730px" padding:10px }

![docker](/assets/img/original/docker1-1024x908.png){: width="730px" padding:10px }

Si estás empezando con Docker no te pierdas [¿qué es Docker?](https://www.docker.com/whatisdocker/), continúa con su ![documentación](/assets/img/original/){: width="730px" padding:10px } y aprovecha todos estos ejemplos reales:

- Agregador de Log's (fig.yml [servicio-log](https://github.com/LuisPalacios/servicio-log)) -- GitHub [base-fluentd](https://github.com/LuisPalacios/base-fluentd) - Docker [luispa/base-fluentd](https://registry.hub.docker.com/u/luispa/base-fluentd/) -- GitHub [base-eskibana](https://github.com/LuisPalacios/base-eskibana) - Docker ![luispa/base-eskibana](/assets/img/original/){: width="730px" padding:10px }
- Servidor GIT privado con Gitolite (fig.yml [servicio-gitolite](https://github.com/LuisPalacios/servicio-gitolite)) -- GitHub [base-gitolite](https://github.com/LuisPalacios/base-gitolite) - Docker ![luispa/base-gitolite](/assets/img/original/){: width="730px" padding:10px }
- Servicio BD para Blog WordPress (fig.yml [servicio-db-blog](https://github.com/LuisPalacios/servicio-db-blog)) -- GitHub [base-mysql](https://github.com/LuisPalacios/base-mysql) - Docker ![luispa/base-mysql](/assets/img/original/){: width="730px" padding:10px }
- Servicio BD para Correo (fig.yml [servicio-db-correo](https://github.com/LuisPalacios/servicio-db-correo)) -- GitHub [base-mysql](https://github.com/LuisPalacios/base-mysql) - Docker ![luispa/base-mysql](/assets/img/original/){: width="730px" padding:10px }
- Servicio de Correo Electrónico (fig.yml [servicio-correo](https://github.com/LuisPalacios/servicio-correo)) -- GitHub [base-postfix](https://github.com/LuisPalacios/base-postfix) - Docker [luispa/base-postfix](https://registry.hub.docker.com/u/luispa/base-postfix/) -- GitHub [base-chatarrero](https://github.com/LuisPalacios/base-chatarrero) - Docker [luispa/base-chatarrero](https://registry.hub.docker.com/u/luispa/base-chatarrero/) -- GitHub [base-courierimap](https://github.com/LuisPalacios/base-courierimap) - Docker ![luispa/base-courierimap](/assets/img/original/){: width="730px" padding:10px }
- Serivio Web (fig.yml [servicio-web](https://github.com/LuisPalacios/servicio-web)) -- GitHub [base-squid](https://github.com/LuisPalacios/base-squid) - Docker [luispa/base-squid](https://registry.hub.docker.com/u/luispa/base-squid/) -- GitHub [base-wordpress](https://github.com/LuisPalacios/base-wordpress) - Docker [luispa/base-wordpress](https://registry.hub.docker.com/u/luispa/base-wordpress/) -- GitHub [base-roundcube](https://github.com/LuisPalacios/base-roundcube) - Docker [luispa/base-roundcube](https://registry.hub.docker.com/u/luispa/base-roundcube/) -- GitHub [base-postfixadmin](https://github.com/LuisPalacios/base-postfixadmin) - Docker ![luispa/base-postfixadmin](/assets/img/original/){: width="730px" padding:10px }

## Persistencia

Todos los contenedores se apoyan en una estructura persitente de datos en el Host:

 
/Apps/
     +--/data    <== Datos, repositorios, webs, ...
     |
     +--/docker  <== scripts, ficheros yml, ficheros para docker, etc... 
 

### Ejemplo

Veamos un ejemplo concreto para entender la filosofía de Docker. En este caso necesitaba entregar el servicio GIT y varios servidores Web. La idea es que cada contenedor ejecute un único proceso. Encontrarás varios retos, por ejemplo ¿cómo montar varios Web's si solo tienes una única IP pública?. La solución tradicional son los “vhosts”, ahora bien, como la filosofía de Docker es distinta entonces usamos balanceadores (en mi caso “squid” un “proxy inverso con soporte de virtual hosts”, otros posibles serían [haproxy](http://www.haproxy.org/) o ![nginx](/assets/img/original/)){: width="730px" padding:10px }

En la figura puedes ver a lo que me refiero, para resolverlo tendríamos un contenedor con "gitolite" y otros (tres en el gráfico) para dar los servicios "web"

![docker1](/assets/img/original/docker1-1024x848.png){: width="730px" padding:10px }

Espero que este apunte junto con los proyectos en el registry de Docker y en GitHub te sirvan de ayuda para tus própias instalaciones.
