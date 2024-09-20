---
title: "Git Credential Manager"
date: "2023-11-11"
categories: desarrollo
tags: git ssh multicuenta github software
excerpt_separator: <!--more-->
---

![Logo GIT Cheatsheet](/assets/img/posts/logo-git-gcm-multi.svg){: width="150px" style="float:left; padding-right:25px" }

En el desarrollo de software, especialmente en entornos multiplataforma (Linux, macOS y Windows), es común trabajar con múltiples repositorios que requieren diferentes cuentas y credenciales. Para gestionar estas credenciales de manera eficiente y segura, utilizamos Git Credential Manager (GCM). Este asistente de credenciales basado en .NET se ejecuta en Windows, macOS y Linux, proporcionando una solución unificada para la gestión de credenciales en GitHub, GitLab y Gitea.

Voy a trabajar con todos los repositorios utilizando la `HTTPS`, por lo tanto no voy a usar los pares de claves SSH, lo cual es muy cómodo. La primera vez que te conectas abre un navegador, usas tus credenciales y las guarda en tu ordenador de forma segurar (algo parecido al keychain de OSX).

<br clear="left"/>
<!--more-->

## Instalación

Git Credential Manager (GCM) es una herramienta que facilita la gestión de credenciales para Git. Permite almacenar y recuperar credenciales de manera segura, evitando la necesidad de ingresar las credenciales repetidamente. GCM soporta múltiples proveedores de autenticación, incluyendo GitHub, GitLab y Gitea.

**Windows**:

Descargo y ejecuto el instalador `gcm-win-x86-2.5.1.exe` desde el [repositorio oficial](https://github.com/git-ecosystem/git-credential-manager/releases).

El ejecutable queda en: `C:\Program Files (x86)\Git Credential Manager\git-credential-manager.exe`

***MacOS**:

Utilizo Homebrew

```bash
brew update
brew upgrade
brew tap microsoft/git
brew install --cask git-credential-manager-core
```

El ejecutable queda en: `/usr/local/bin/git-credential-manager`

**Linux**:

Descargo e instalo desde el paquete correspondiente (en mi caso para ubuntu `gcm-linux_amd64.2.5.1.deb` desde el [repositorio oficial](https://github.com/git-ecosystem/git-credential-manager/releases).

```bash
sudo dpkg -i gcm-linux_amd64.2.5.1.deb
```

El ejecutable queda en: `/usr/local/bin/git-credential-manager`

## Configuración Global

Una vez instalado GCM, es necesario configurarlo para que gestione las credenciales de nuestros repositorios.

**Establezco el `credential.helper`**:

Nota: Al terminar la instalación, en MacOS y en Windows, se configura automáticamente que el credential.helper sea GCM, excepto en linux.

- Windows:
  - `git config credential.helper` devuelve `C:/Program\ Files\ \(x86\)/Git\ Credential\ Manager/git-credential-manager.exe`
  - `git config --list --show-origin` indica que se configura en `C:/Program Files/Git/etc/gitconfig`
- MacOS:
  - `git config credential.helper` devuelve `/usr/local/share/gcm-core/git-credential-manager`
  - `git config --list --show-origin` indica que se configura en `/Users/luis/.gitconfig`
- Linux:
  - `git config credential.helper` no devuelve nada. No lo configura.

Lo primero que hago es poner en todos los SO's el mismo valor:

- A nivel global:

```bash
git config --global credential.helper manager
```

- Lo compruebo:
  - `git config --list --show-origin | grep -i credential.helper | tail -1`

**Establezco el `credential.github.com`**:

Especificamos que CGM almacene almacena y recupera las credenciales para GitHub utilizando la URL completa del repositorio, incluyendo la ruta del repositorio (es decir, el “path” después del dominio). Necesario si usas diferentes cuentas de GitHub para distintos repositorios o si necesitas manejar autenticaciones separadas por cada repositorio.

```bash
git config --global credential.github.com.useHttpPath true
```

## Ejemplos

### Repositorio (público) Personal

Es un repositorio público que me pertenece y necesito poder hacer push sobre él.

Clono el repositorio utilizando la URL HTTPS:

```bash
❯ git clone https://github.com/LuisPalacios/LuisPalacios.github.io
❯ git config user.name "Luis Palacios"
❯ git config user.email "mi.correo@personal.com"

❯ git config credential.https://github.com/LuisPalacios/LuisPalacios.github.io.username LuisPalacios
```

El motivo por el que añado `credential "http...`? es para asegurarme que el comando `git` identifica a qué cuenta pertenece este repositorio y que no se vuelva loco (cosa que pasará en uanto empieces a añadir otras cuentas). Además, si estás trabajando con un repositorio "invisible" privado en internet, podría pasarte que el pull no te funcione. Al añadir el credential se resuelve, [más información aquí](https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/multiple-users.md)

El fichero `.git/config` incorporará estas entradas:

```conf
[remote "origin"]
  url = https://github.com/LuisPalacios/LuisPalacios.github.io

[user]
  name = Luis Palacios
  email = luis.palacios.derqui@gmail.com

[credential "https://github.com/LuisPalacios/LuisPalacios.github.io"]
  username = LuisPalacios
```

En cuanto vaya a hacer cualquier operación que necesite autenticación, GCM solicitará las credenciales y las almacenará de manera segura.

```bash
❯ touch fichero.txt
❯ git add .
❯ git commit -m "Añadí un fichero"
❯ git push
```

En este instante abre el navegador y pide credenciales para asociar el repositorio. Aquí es muy importante que **tu navegador esté autenticado en la cuenta adecuada (o que no esté autenticado)**. Te pedirá que hagas Signin y Autorices. Cuando termina volverá a la línea de comando

{% include showImagen.html
      src="/assets/img/posts/2023-11-11-gcm-01.png"
      caption="Credenciales bajo demanda"
      width="650px"
      %}

```bash
 ❯ git push
2023-11-11 18:12:42.289 git-credential-manager[9516:48883] +[IMKClient subclass]: chose IMKClient_Legacy
2023-11-11 18:12:42.289 git-credential-manager[9516:48883] +[IMKInputSession subclass]: chose IMKInputSession_Legacy
info: please complete authentication in your browser...
Enumerando objetos: 3, listo.
:
To https://github.com/LuisPalacios/LuisPalacios.github.io.git
   e8411a6..46f38aa  main -> main
```

### Repositorio (privado) Profesional

No cambia nada, es siempre lo mismo, de todas formas pongo un ejemplo. Se trata de un repositorio privado en el que estoy trabajando, pertenece a una Organización. Necesito poder hacer push sobre él.

Clono el repositorio utilizando la URL HTTPS:

```bash
❯ git clone https://github.com/RenuevaConsulting/repo.profesional
❯ git config user.name "Luis Renueva"
❯ git config user.email "mi.correo-profesional@renueva.com"

❯ git config credential.https://github.com/RenuevaConsulting/repo.profesional.username LuisRenueva
```

El fichero `.git/config` incorporará estas entradas:

```conf
[remote "origin"]
  url = https://github.com/RenuevaConsulting/repo.profesional

[user]
  name = Luis Renueva
  email = mi.correo-profesional@renueva.com

[credential "https://github.com/RenuevaConsulting/repo.profesional"]
  username = LuisRenueva
```

En cuanto vaya a hacer cualquier operación que necesite autenticación, GCM solicitará las credenciales y las almacenará de manera segura.

```bash
❯ touch fichero-profesional.txt
❯ git add .
❯ git commit -m "Toqué un fichero en mi repo profesional"
❯ git push
```

En este instante abre el navegador de nuevo, pide credenciales para asociar el repositorio. Aquí es muy importante que **tu navegador esté autenticado en la cuenta adecuada (o que no esté autenticado)**. Se repite el proceso como antes: Signin, Autorización !!

#### Repositorio Personal en Gitea

De nuevo, no cambia nada, siempre funcina igual. La primera vez que quieres hacer un `push` o algo que requiere autenticación, se arranca el proceso. Si cambia la URL, como en este ejemplo, en una Gitea casero, con HTTPS, ...

```bash
git clone
❯ git clone https://gitea.luiscasa.com/LuisCasa/mi-repo-casa
❯ git config user.name "Luis Casa"
❯ git config user.email "mi.correo-casa@yahoo.com"

❯ git config credential.https://gitea.luiscasa.com/LuisCasa/mi-repo-casa.username LuisCasa
:
:
git push
:
: En cuanto intento el push requerirá autenticación, signin, autorización...
```

## Mostrar la credenciales

Git Credential Manager (GCM) no tiene un comando directo para listar todas las credenciales que tiene guardadas, ya que maneja las credenciales a través de los sistemas de almacenamiento seguros del sistema operativo. GCM **usa Keychain en macOS, el almacén de credenciales de Windows o el Gnome Keyring en Linux**.

Si quieres encontrar qué credenciales tiene guardadas tu sistema operativo, debes ir a esos almacenes. Te muestro un ejemplo en MacOS. Arranqué el App "Acceso a llaveros o Keychain" y busqué por `github` en inicio de sesión. Encontré esta entrada:

{% include showImagen.html
      src="/assets/img/posts/2023-11-11-gcm-02.png"
      caption="Credenciales en los almacenes seguros"
      width="400px"
      %}

## Resolución de problemas

Cuando hice este documento me encontré en los alamacenes seguros credenciales antiguas. Es importante limpiarlas.

- **Windows**: WIN+R busca por `control` > User Accounts > Credential Manager > Windows Credentials
  - Eliminar los credenciales que aparezcan de github.com

- **MacOS**:
  - Comprueba y limpia lo que encuentres en keychain.
  - Una vez tuve un problema con `homebrew` y su fichero de config, que borré !!
    - `rm /opt/homebrew/etc/gitconfig`

- Al hacer un `pull` de un repositorio privado no abre el navegador.
  - Usa la opción `git config credential.https://...`

## Conclusión

Git Credential Manager (GCM) es una herramienta poderosa y versátil para gestionar credenciales en múltiples repositorios y plataformas. Su instalación y configuración son sencillas, y proporciona una solución segura para manejar diferentes cuentas y credenciales en entornos de desarrollo complejos. Con GCM, puedes centrarte en el desarrollo de software sin preocuparte por la gestión de credenciales.
