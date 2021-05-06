---
title: "Wordpress: notificaciones vía SMTP"
date: "2015-06-14"
categories: apuntes
tags: afp linux
excerpt_separator: <!--more-->
---

La instalación original de Wordpress permite que el propietario de la instalación reciba un mail cuando se dejan comentarios en los post. Wordpress utilizar "mail" en vez de "smtp" así que podría pasarte que nunca te lleguen dichos avisos. Ten en cuenta que el "mail" de linux deja el correo en el equipo donde se ejecuta, es decir, no emplea ningún servidor SMTP externo.

![smtpwp](/assets/img/original/smtpwp.jpg){: width="730px" padding:10px }

 

Para cambiar a SMTP tienes dos opciones, una es instalar un plugin y la otra modificar un par de ficheros de tu instalación de WP

 

### Utilizar un Plugin

Es la opción fácil, dejo varias referencias:

- ![WP MAIL SMTP](/assets/img/original/){: width="730px" padding:10px }
- ![Webriti SMTP Mail](/assets/img/original/){: width="730px" padding:10px }
- ![WP SMTP](/assets/img/original/){: width="730px" padding:10px }
- ![Easy WP SMTP](/assets/img/original/){: width="730px" padding:10px }

La que más me ha gustado es la primera: **WP MAIL SMTP**

 

### Modificar manualmente

La segunda opción es más complicada, necesitas acceso al directorio de instalación de Wordpress vía línea de comandos porque supone editar un par de ficheros.

Sitúate en el subdirectorio wp-includes de tu instalación de Wordpress. En mi caso, una instalación basada en ![contenedores](/assets/img/original/?p=172){: width="730px" padding:10px }, los datos persistentes están alojados en:

$ cd /Apps/data/web/www.luispa.com/wordpress/wp-includes/

Editar el fichero "pluggable.php", buscar "$phpmailer->IsMail();" y cambiarlo por "$phpmailer->IsSMTP();"

- ../wordpress/wp-includes/pluggable.php

        // Set to use PHP's mail()
        $phpmailer->IsSMTP();

Editar el fichero "class-phpmailer.php", buscar "public $Host = 'localhost';" y cambiarlo por "public $Host = 'tu-servidor-smtp.tu-dominio.com';"

- ../wordpress/wp-includes/class-phpmailer.php"

    /**
     * SMTP hosts.
     * Either a single hostname or multiple semicolon-delimited hostnames.
     * You can also specify a different port
     * for each host by using this format: [hostname:port]
     * (e.g. "smtp1.example.com:25;smtp2.example.com").
     * Hosts will be tried in order.
     * @type string
     */
    public $Host = 'tu-servidor-smtp.tu-dominio.com';
