---
title: "Wordpress: notificaciones vía SMTP"
date: "2015-06-14"
categories: apuntes
tags: afp linux
excerpt_separator: <!--more-->
---

La instalación original de Wordpress permite que el propietario de la instalación reciba un mail cuando se dejan comentarios en los post. Wordpress utilizar "mail" en vez de "smtp" así que podría pasarte que nunca te lleguen dichos avisos. Ten en cuenta que el "mail" de linux deja el correo en el equipo donde se ejecuta, es decir, no emplea ningún servidor SMTP externo.

{% include showImagen.html
    src="/assets/img/original/smtpwp.jpg"
    caption="smtpwp"
    width="600px"
    %}

 

Para cambiar a SMTP tienes dos opciones, una es instalar un plugin y la otra modificar un par de ficheros de tu instalación de WP

 

### Utilizar un Plugin

Es la opción fácil, dejo varias referencias:

{% include showImagen.html
    src="/assets/img/original/"
    caption="WP MAIL SMTP"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="Webriti SMTP Mail"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="WP SMTP"
    width="600px"
    %}
{% include showImagen.html
    src="/assets/img/original/"
    caption="Easy WP SMTP"
    width="600px"
    %}

La que más me ha gustado es la primera: **WP MAIL SMTP**

 

### Modificar manualmente

La segunda opción es más complicada, necesitas acceso al directorio de instalación de Wordpress vía línea de comandos porque supone editar un par de ficheros.

{% include showImagen.html
    src="/assets/img/original/?p=172"
    caption="contenedores"
    width="600px"
    %}

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
