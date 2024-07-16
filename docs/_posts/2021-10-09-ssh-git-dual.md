---
title: "Git y SSH multicuenta"
date: "2021-10-09"
categories: desarrollo
tags: git ssh multicuenta github software
excerpt_separator: <!--more-->
---

![Logo GIT Cheatsheet](/assets/img/posts/logo-git-multicuenta.svg){: width="150px" style="float:left; padding-right:25px" }

Este apunte te llevará a través del proceso de configurar y usar dos cuentas en GitHub, GitLab o cualquier otro servidor con claves SSH. Aprenderás cómo crear claves para cada cuenta y usar las adecuadas con cada repositorio. Es muy habitual tener que trabajar con una cuenta personal y una profesional desde el mismo ordenador y cambiar entre ellas puede ser confuso. Lo lógico es tener cada repositorio bien configurado para que use los credenciales y el host (github, gitlab, etc) correcto en cada caso.

<br clear="left"/>
<!--more-->

Voy a usar mi caso a modo de ejemplo, supongamos que tengo el usuario **Personal** `LuisPalacios` en GitHub y el usuario **Profesional** `EMPRESA-Luis-Palacios` también en GitHub (con derechos de trabajo en una Organización llamada EMPRESA dentro de GitHub).

### Instalar SSH

Los pasos son ligeramente diferentes para sistemas basados en Windows y Unix (Linux/MacOS). En Linux/MacOS openssh viene instalado (en casi todas las distros de Linux), así que lo siguiente solo aplica a Windows (lo he probado en Windows 11).

En windows se necesita Instalar y Configurar `ssh-agent`. Comprueba desde PowerShell o el Símbolo del sistema **como administrador** si tienes el **Cliente y el Servidor OpenSSH** instalados.

```cmd
C:\Users\Luis> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
:
C:\Users\Luis> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
```

En caso contrario, instálalos y arranca el servicio `ssh-agent`

```cmd
C:\Users\Luis> Add-WindowsCapability -Online -Name OpenSSH.Client
:
C:\Users\Luis> Add-WindowsCapability -Online -Name OpenSSH.Server
:
C:\Users\Luis> Start-Service ssh-agent
:
C:\Users\Luis> Set-Service -Name ssh-agent -StartupType Automatic
```

### Generar Claves SSH

Asumiendo que tengo SSH instalado, ya podemos genera claves SSH que usaré más adelante en GitHub en ambas, la personal y la profesional.

```zsh
# Linux/Mac
ssh-keygen -t ed25519 -C "mi_correo_personal@personal.com" -f ~/.ssh/id_ed25519_git_personal_luispa
:
ssh-keygen -t ed25519 -C "mi_correo_profesional@empresa.com" -f ~/.ssh/id_ed25519_git_empresa_luispa

# Windows
ssh-keygen -t ed25519 -C "mi_correo_personal@personal.com" -f C:\Users\TuUsuario\.ssh\id_ed25519_git_personal_luispa
:
ssh-keygen -t ed25519 -C "mi_correo_profesional@empresa.com" -f C:\Users\TuUsuario\.ssh\id_ed25519_git_empresa_luispa
```

Sigue las indicaciones y presiona Enter para **aceptar la ubicación predeterminada del archivo y dejar la frase de contraseña vacía**.

### Agregar claves SSH a `ssh-agent`

Si estás en Linux/Mac, abre un Terminal (shell). En el caso de Windows abre PowerShell o el Símbolo del sistema (CMD) como **administrador**.

```zsh
# Linux/MacOS
ssh-add -D
ssh-add id_ed25519_git_personal_luispa
ssh-add id_ed25519_git_empresa_luispa
ssh-add -l
  256 SHA256:BJXWgT1234897p0jhlasjdhfaasdfasdf12345 id_ed25519_git_personal_luispa (ED25519)
  256 SHA256:ABCDEFGHIJKasdflkjasñdhfaasdfasdf12345 id_ed25519_git_empresa_luispa (ED25519)

# Windows
ssh-add C:\Users\TuUsuario\.ssh\id_ed25519_git_personal_luispa
ssh-add C:\Users\TuUsuario\.ssh\id_ed25519_git_empresa_luispa
```

### Agregar Claves SSH Públicas a GitHub

El siguiente proceso recomiendo repetirlo para cada ordenador donde creas tus claves Pública/Privada, ya sean personales como profesionales.

#### Claves ssh personales a GitHub

En mi caso que he creado claves personales en un Linux, un Mac y un Windows, repitor el proceso tres veces, **pegando mi clave PÚBLICA tres veces en GitHub, en mi cuenta personal**. Haz **Login en GitHub con tu cuenta Personal**, entra en [Configuración de GitHub para claves SSH](https://github.com/settings/keys) y entra en “New SSH key”, proporcionando un título (por ejemplo, “Clave Personal en Windows”) y pega tu clave pública, que puedes sacar de aquí:

```zsh
# Linux/MacOS
cat ~/.ssh/id_ed25519_git_personal_luispa.pub

# Windows
type C:\Users\TuUsuario\.ssh\id_ed25519_git_personal_luispa.pub
```

#### Claves ssh profesional a GitHub

En la cuenta profesional hacemos lo mismo. En este caso se trata de un usuario de GitHub que tiene derecho sobre una Organización. El proceso es idéntico, lo primero es hacer **Login en GitHub con tu cuenta Profesional** y luego copiar las claves públicas "profesionales" generadas, entrando de nuevo en [Configuración de GitHub para claves SSH](https://github.com/settings/keys), “New SSH key”, proporcionando un título (por ejemplo, “Clave Profesional en Windows”) y pegando la clave pública correspondiente.

```zsh
# Linux/MacOS
cat ~/.ssh/id_ed25519_git_empresa_luispa.pub

# Windows
type C:\Users\TuUsuario\.ssh\id_ed25519_git_empresa_luispa.pub
```

### Configurar SSH con Múltiples Cuentas

Ha llegado el momento de usar un truco en SSH para discernir, más adelante en los repositorios, qué clave pública usar, la personal o la profesional. Para conseguirlo edita tu archivo de configuración de SSH para manejar múltiples cuentas de GitHub.

En Linux/MacOS abre o crea el archivo el fichero `~/.ssh/config` y añade lo siguiente

```conf
# Cuenta Personal
Host gh-personal-luispa
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_git_personal_luispa

# Cuenta Profesional
Host gh-empresa-luispa
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_git_empresa_luispa
```

En Windows abre o crea el archivo el fichero `C:\Users\TuUsuario\.ssh\config` y añade lo siguiente

```conf
# Cuenta Personal
Host gh-personal-luispa
    HostName github.com
    User git
    IdentityFile C:\Users\TuUsuario\.ssh\id_ed25519_git_personal_luispa

# Cuenta Profesional
Host gh-empresa-luispa
    HostName github.com
    User git
    IdentityFile C:\Users\TuUsuario\.ssh\id_ed25519_git_empresa_luispa
```

## Clonar Repositorios

Ahora puedes clonar repositorios utilizando la configuración SSH adecuada para cada caso (personal/profesional), fíjate que **no usamos git@github.com** como nombre de host, sino que usamos los nombres de host que dimos de alta antes en [Configurar SSH con Múltiples Cuentas](#configurar-ssh-con-múltiples-cuentas).

### Repositorio Personal

```zsh
git clone git@gh-personal-luispa:LuisPalacios/MiProyectoPersonal.git
```

### Repositorio Profesional

```zsh
git clone git@gh-empresa-luispa:EMPRESA-Luis-Palacios/MiProyectoProfesional.git
```

## Resumen

Siguiendo los pasos anteriores puedes gestionar múltiples cuentas de GitHub con claves SSH en un mismo ordenador. Esta forma de trabajar te permite cambiar sin problemas entre diferentes cuentas y repositorios sin conflictos, dado que cada repositorio tendrá el [remote "origin"] correcto.

```conf
cat MiProyectoProfesional/.git/config
:
[remote "origin"]
  url = gh-empresa-luispa:EMPRESA-Luis-Palacios/MiProyectoProfesional.git
  fetch = +refs/heads/*:refs/remotes/origin/*
:
```

Recuerda mantener tus claves SSH privadas seguras y no compartirlas con nadie. Si tienes algún problema, consulta la documentación de GitHub o usa `ssh -v` para obtener una salida detallada de SSH y depurar problemas de conexión.
