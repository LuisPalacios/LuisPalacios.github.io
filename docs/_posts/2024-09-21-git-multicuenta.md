---
title: "Git multicuenta"
date: "2024-09-21"
categories: desarrollo
tags: git ssh gcm credenciales credential manager multicuenta github software
excerpt_separator: <!--more-->
---

![Logo GIT multicuenta](/assets/img/posts/logo-git-multi.svg){: width="150px" style="float:left; padding-right:25px" }

Este apunte te llevará a través del proceso de configurar y usar múltiples cuentas con uno o más proveedores Git (GitHub, GitLab, Gitea). Describo las dos opciones que recomiendo: **HTTPS + Git Credential Manager** y **SSH multicuenta**.

La primera, HTTPS + Git Credential Manager, es la que más uso, porque es compatible con el CLI y/o herramientas GUI tipo Visual Studio, VSCode, Git Desktop, Gitkraken, etc. La segunda opción, SSH multicuenta, la delego a equipos "headless", servidores a los que conecto en remoto vía (CLI o VSCode remote) y necesito que clonen repositorios y trabajen sobre ellos.

<br clear="left"/>
<!--more-->

## Introducción

1. **HTTPS + Git Credential Manager**:

   - **Descripción**: Ideal para los que prefieren gestionar múltiples cuentas a través de HTTPS (la opción de por defecto de toda la vida). El **Git Credential Manager (GCM)** se encarga de almacenar y gestionar de forma segura las credenciales. Es compatible con Windows, MacOS y Linux, y facilita el manejo de credenciales sin necesidad de introducirlas cada vez que se realiza una operación Git. Se encarga de recordar y aplicar la credencial correcta para cada repositorio.

   - **Ventajas**:
     - Fácil de configurar y utilizar, incluso en linux Desktop.
     - Menos configuración manual, ya que el GCM gestiona automáticamente las credenciales.
     - Compatible con plataformas populares como GitHub, Bitbucket, Gitlab, Gitea, Azure DevOps.

   - **Desventajas**:
     - Menos flexible para gestionar múltiples identidades para un mismo servidor Git en comparación con SSH, aunque se puede hacer sin problemas.
     - Requiere del Git Credential Manager instalado y configurado. Tampoco es para tanto !

2. **SSH Multicuenta (configurando el fichero `.ssh/config` con host alias)**:

   - **Descripción**: Esta opción permite gestionar múltiples cuentas SSH configurando el archivo `~/.ssh/config` con alias de host. En este archivo, se pueden definir diferentes identidades (pares de claves SSH) asociadas a diferentes alias, que corresponden a las distintas cuentas en un mismo servidor Git. Por ejemplo, se pueden tener dos alias para `github.com`, cada uno apuntando a una cuenta diferente y usando un par de claves distinto.

   - **Ventajas**:
     - Muy flexible para gestionar múltiples identidades o cuentas en un mismo servidor.
     - Ofrece un mayor control sobre las conexiones y configuraciones SSH.
     - No requiere credenciales de usuario y contraseña en cada operación, solo la clave SSH correspondiente.

   - **Desventajas**:
     - Requiere una configuración manual más compleja, especialmente para usuarios menos experimentados.
     - Es necesario gestionar y proteger las claves SSH, lo que puede añadir complejidad.
     - En algunos casos, puede ser más difícil de mantener si se utilizan muchas cuentas.
     - No todos los clientes Git GUI soportan SSH Multicuenta, como [GitHub Desktop](https://desktop.github.com/) y [Gitkraken](https://www.gitkraken.com/). Otros parece que sí, como [Sourcetree](https://www.sourcetreeapp.com/), [Fork](https://git-fork.com/) o [Tower](https://www.git-tower.com/).

Para los ejemplos de este apunte uso una mezcla de cuentas simuladas y reales: usuario **Personal** `LuisPalacios` en `github.com`, usuario **personal** en un servidor *Gitea* privado en casa (`parchis.org`), otro usuario **Profesional** `LuispaRenueva` en GitHub (con derechos de push en una Organización llamada Renueva dentro de GitHub), etc...

## Opción 1: HTTPS + Git Credential Manager

### Instalación de Git Credential Manager

Hay que instalarlo, un programita del que existen versiones para Windows, Mac y Linux. Su función es hacer de intermediario entre tu cliente Git, el servior Git y un almacén local. Se encarga de almacenar y recuperar credenciales de manera segura, evitando la necesidad de ingresar las credenciales cada dos por tres.

**Windows**: Instalo desde el [repositorio oficial](https://github.com/git-ecosystem/git-credential-manager/releases). En mi caso escogí `gcm-win-x86-2.5.1.exe`.

El ejecutable queda en: `C:\Program Files (x86)\Git Credential Manager\git-credential-manager.exe`

**MacOS**: Utilizo Homebrew

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

### Configuración de `~/.gitconfig`

Una vez instalado GCM, es necesario configurarlo para que gestione las credenciales de nuestros repositorios. Antes de nada repaso el fichero `~/.gitconfig` para quitar la entrada [user] (el usuario/email lo configuro por repositorio), elimino entradas de tipo "insteadOf" que suelen usarse con SSH.

El parámetro más importante es el `credential.helper`. Con él se le dice a Git que use CGM. Podemos comprobar con los comandos siguientes que en MacOS y en Windows, se configura automáticamente el path, excepto en linux.

- Windows:
  - `git config credential.helper` devuelve `C:/Program\ Files\ \(x86\)/Git\ Credential\ Manager/git-credential-manager.exe`
  - `git config --list --show-origin` indica que se configura en `C:/Program Files/Git/etc/gitconfig`
- MacOS:
  - `git config credential.helper` devuelve `/usr/local/share/gcm-core/git-credential-manager`
  - `git config --list --show-origin` indica que se configura en `/Users/luis/.gitconfig`
- Linux: Aquí vemos que no devuelve nada, y eso es porque no lo configura.
  - `git config credential.helper`

Configuro el mismo **credential.helper** para todos los sistemas operativos (al poner `manager` buscará `git-credential-manager.exe` o `git-credential-manager` en el PATH.

- `git config --global credential.helper manager`
- Compruebo que queda bien configurado:
  - `git config --list --show-origin | grep -i credential.helper | tail -1`

Especifico cómo quiero que se almacenen los credenciales a mis dos proveedores de Git (`github.com` y `parchis.org`). Es posible indicarle a CGM que la credenciales para GitHub usen URL completa del repositorio. En mi caso no lo necesito. Si quieres lo puedes poner a `true` para llevar un control exahustivo si necesitas manejar autenticaciones separadas por cada repositorio.

- `git config --global credential.https://github.com.useHttpPath false`
- `git config --global credential.https://git.parchis.org.useHttpPath false`

Establezco el tipo de proveedor para cada uno de ellos (acelera un poco el trabajo posterior)

- `git config --global credential.https://github.com.provider github`
- `git config --global credential.https://git.parchis.org.provider generic`

Configuro el tipo de Almacén donde guardar los credenciales. Cada Sistema Operativo proporciona **un almacén seguro en el que GCM puede guardar y recuperar las credenciales automáticamente**. En Windows y en MacOS no hay duda, se deben usar sus almacenes **nativos**, `wincredman` (Windows Credential Manager) y `keychain` (macOS Keychain) respectivamente. En Linux tenemos varias opciones y la que recomiento es `secretservice`, que usa el servicios de *Secret Service API*, respaldado por herramientas como GNOME Keyring o KWallet en KDE.

- `git config --global credential.credentialStore keychain` (MacOS)
- `git config --global credential.credentialStore secretservice` (Linux)
- `git config --global credential.credentialStore wincredman` (Windows)

Así es como queda mi fichero `~/.gitconfig` (en un mac)

```conf
[credential]
  helper = manager
  credentialStore = keychain
[credential "https://github.com"]
  provider = github
  useHttpPath = false
[credential "https://git.parchis.org"]
  provider = generic
  useHttpPath = false
```

### Cómo se guardan las credenciales

Lo comenté antes, el parámetro `useHttpPath` especifica cómo quieres que se almacenen los credenciales. Veamos un ejemplo con el repositorio `https://github.com/LuisPalacios/MyRepoPrivado.io.git` y el usuario GitHub `LuisPalacios`:

- `true`: Guardará una credencial en el almacén por cada repositorio y usuario. Por ejemplo guardaría `git:https://github.com/LuisPalacios/MyRepoPrivado.git` y usuario `LuisPalacios`. Cada vez que intentes hacer un `clone` o un `push` de o hacia dicho repositorio, sabrá perfectamente qué credencial usar.

- `false`: Guardará una credencial en el almacén por el dominio del servidor y el usuario. Por ejemplo, `git:https://github.com` y `LuisPalacios`. De esta forma se reutiliza dicha credencial para todos los repos de este usuario en GitHub.

**IMPORTANTE**. Un par de recomendaciones **si usas `..useHttpPath=false`** y tienes repos privados:

- Durante el clone pon el nombre del usuario (ejemplo `LuisPalacios@`) si es un repo privado:
  - `git clone https://LuisPalacios@github.com/LuisPalacios/MyRepoPrivado.git`
- Tras el clone, añade `username` al `credential`, además de nombre y correo en el `.git/config`
  - `git config credential.https://github.com.username LuisPalacios`
  - `git config user.name "Luis Palacios"`
  - `git config user.mail "mi.correo@midominio.com"`

```conf
[remote "origin"]
  url = https://github.com/LuisPalacios/MyRepoPrivado.git
[user]
  name = Luis Palacios
  email = mi.correo@midominio.com
[credential "https://github.com"]
  username = LuisPalacios
```

### Cuándo abre el navegador

Solo la primera vez que lo necesita (clone de repos privados o push) y se da cuenta que no tiene credenciales en el Almacen, abrirá el Navegador, te pedirá que te autentiques con la cuenta y se guardará la credencial en el almacén seguro. Es importante que **tu navegador esté autenticado en la cuenta adecuada (o que no esté autenticado)**. Te pedirá que hagas Signin y Autorices, soporta MFA y cuando termina volverá a la línea de comando

{% include showImagen.html
      src="/assets/img/posts/2024-09-21-gcm-01.png"
      caption="Credenciales bajo demanda"
      width="650px"
      %}

Si te está abriendo constántemente el navegador es porque tienes una incogruencia en algún sitio o porque no está identificando bien el conjunto "url" y "usuario". Por eso recomendaba añadir el usuario durante el clone y luego configurar el usuario en la sección `credential` de `.git/config` de cada repositorio clonado.

- `git clone https://LuisPalacios@github.com/LuisPalacios/MyRepoPrivado.git`
- `git config credential.github.com.username LuisPalacios`

La apertura del navegador desencadena con `clone` (en repos privados) o `push` porque no encuentra en el Almacen la combinación de URL/Usuario.

### Cómo ver las credenciales en el Almacén

Si tienes problemas o quieres automatizar, es muy útil echar un ojo a lo que se ha guardado en el almacén. Git Credential Manager (GCM) no tiene un comando directo para listar todas las credenciales que tiene guardadas, ya que maneja las credenciales a través de los sistemas de almacenamiento seguros del sistema operativo. Puedes usar el GUI correspondiente o desde el CLI, muy útil si quieres hacer scripts que verifiquen si tienes las credenciales guardadas.

**Windows**:

- GUI: **Windows Credentials**, accede con WIN+R busca por `control` > User Accounts > Credential Manager

- CLI: `cmd.exe /c "cmdkey /list" | tr -d '\r'`. Con ese comando puedes ver las credenciales que están en el Windows Credential.

**MacOS**:

- GUI: **Acceso a llaveros.app (Keychain Access.app)**, busca en inicio de sesión por `github`. Verás varias, ve entrando en ellas.

{% include showImagen.html
      src="/assets/img/posts/2024-09-21-gcm-02.png"
      caption="Credenciales en los almacenes seguros"
      width="400px"
      %}

- CLI: `security find-generic-password -s "git:https://github.com" -a "LuisPalacios"`. Sensible a mayúsculas/minúsculas y no soporta expresiones reguales, es decir, tienes que poner lo que busca de forma exacta.

Para borrar credenciales:

- CLI: `security delete-generic-password -s "git:https://github.com" -a "LuisPalacios"`.

**Linux**:

- GUI: **`GNome Keyring`+ Seahorse**, en mi caso con Ubuntu.

{% include showImagen.html
      src="/assets/img/posts/2024-09-21-gcm-03.jpg"
      caption="App Seahorse para acceder al GNOME Keyring"
      width="800px"
      %}

Para el CLI necesitas instalar las `libsecret-tools`:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y
sudo apt install libsecret-tools
```

- CLI:
  - `secret-tool search service "git:https://github.com" account "LuisPalacios"`. (sensible a mayúsculas/minúsculas y no soporta expresiones reguales)
  - `secret-tool search --all service "git:https://github.com"`.

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

### Script de apoyo `git-config-repos`

He hecho un script que funciona en MacOS, Linux y Windows (WSL2) que te permite tener configurados todos los repositorios en un json y que él se encargue de hacerte todas las modificaciones, incluso el clone. Está diseñado para trabajar con esta primera Opción 1: HTTPS + Git Credential Manager.

Échale un ojo: [git-config-repos](https://github.com/LuisPalacios/git-config-repos)

---
<br/>

## Opción 2: SSH Multicuenta

Esta opción permite gestionar múltiples cuentas SSH configurando el archivo ~/.ssh/config con alias de host. En este archivo, se pueden definir diferentes identidades (pares de claves SSH) asociadas a diferentes alias, que corresponden a las distintas cuentas en un mismo servidor Git. Por ejemplo, se pueden tener dos alias para github.com, cada uno apuntando a una cuenta diferente y usando un par de claves distinto.

### Instalar SSH

Los pasos son ligeramente diferentes para sistemas basados en Windows y Unix (Linux/MacOS). En Linux/MacOS openssh viene pre-instalado (en casi todas las distros de Linux), así que lo siguiente solo aplica a Windows (probado en la versión 11).

Primero voy a instalar y configurar `ssh-agent`. Compruebo desde PowerShell o el Símbolo del sistema **como administrador** si **Cliente y el Servidor OpenSSH** están instalados.

```cmd
C:\Users\Luis> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
:
C:\Users\Luis> Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
```

De no estarlo, los instalo y arranco el servicio `ssh-agent`

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

Asumiendo que tengo SSH instalado, ya podemos genera claves SSH, la personal y la profesional.

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

**Agregar la clave pública personales a GitHub**: En mi caso que he creado claves personales en un Linux, un Mac y un Windows, repitor el proceso tres veces, **pegando mi clave PÚBLICA tres veces en GitHub, en mi cuenta personal**. Entro en [Configuración de GitHub para claves SSH](https://github.com/settings/keys), “New SSH key”, proporcionando un título (por ejemplo, “Clave Personal en Windows”) y peggo la clave pública, que puedes sacar de aquí:

```zsh
# Linux/MacOS
cat ~/.ssh/id_ed25519_git_personal_luispa.pub

# Windows
type C:\Users\TuUsuario\.ssh\id_ed25519_git_personal_luispa.pub
```

**Agregar la clave pública profesional a GitHub**: En la cuenta profesional hacemos lo mismo. En este caso se trata de un usuario de GitHub que tiene derecho sobre una Organización. El proceso es idéntico, lo primero es hacer **Login en GitHub con tu cuenta Profesional** y luego copiar las claves públicas "profesionales" generadas, entrando de nuevo en [Configuración de GitHub para claves SSH](https://github.com/settings/keys), “New SSH key”, proporcionando un título (por ejemplo, “Clave Profesional en Windows”) y pegando la clave pública correspondiente.

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

### Clonar Repositorios

Ahora puedes clonar repositorios utilizando la configuración SSH adecuada para cada caso (personal/profesional), fíjate que **no usamos git@github.com** como nombre de host, sino que usamos los nombres de host que dimos de alta antes en [Configurar SSH con Múltiples Cuentas](#configurar-ssh-con-múltiples-cuentas).

**Repositorio Personal**:

```zsh
git clone git@gh-personal-luispa:LuisPalacios/MiProyectoPersonal.git
```

**Repositorio Profesional**:

```zsh
git clone git@gh-empresa-luispa:EMPRESA-Luis-Palacios/MiProyectoProfesional.git
```

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

## Conclusión

Cada opción tiene sus ventajas y se adapta a diferentes necesidades y entornos de trabajo. La elección entre HTTPS + GCM o SSH multicuenta dependerá del nivel de control que se desee y de la plataforma en la que se esté trabajando.

Repasa en [la introducción](#introducción) las ventajas y desventajas de cada opción.
