---
title: "Herramientas CLI multiplataforma"
date: 2025-07-19
tags: ["cli", "multiplataforma", "linux", "macos", "windows", "powershell", "zsh", "bash"]
categories: ["terminal", "herramientas", "productividad"]
cover:
  image: "/img/posts/logo-cli-multi.svg"
  hidden: true
---

<img src="/img/posts/logo-cli-multi.svg" alt="Logo multiplataforma" width="150px" style="float:left; padding-right:25px"  />

En este post comparto una selección de herramientas de línea de comandos **multiplataforma**, que puedes utilizar indistintamente en **PowerShell, CMD, WSL2, macOS y Linux**. Son utilidades modernas, rápidas y ligeras que sustituyen o mejoran ampliamente herramientas clásicas como `ls`, `cd`, `find` o incluso el historial de comandos.

No solo aceleran tareas cotidianas, sino que también ofrecen una experiencia de uso más coherente entre sistemas. No dependen de shells concretos como Bash o Zsh, y funcionan igual si usas PowerShell, Terminal, Alacritty, VSCode o cualquier entorno moderno. A medida que descubra nuevas utilidades CLI que cumplan con este enfoque multiplataforma y sin dependencias pesadas, las iré incorporando.

<!--more-->

{{< admonition note "Ventajas">}}

Este post se ha quedado un poco anticuado nada mas nacer, lo dejo a modo de referencia, pero te recomiendo encarecidamente que le eches un ojo a este repositorio en GitHub:

> [devcli](https://github.com/LuisPalacios/devcli) - Automatiza la instalación y configuración de tu entorno CLI en Linux, macOS, WSL2 y Windows.

{{< /admonition >}}

## Introducción

Estas son las herramientas que vamos a explorar:

- **`lsd`** → reemplazo moderno de `ls`, con colores, iconos y formato elegante.
- **`zoxide`** → alternativa inteligente a `cd`, basada en frecuencia (cuánto tiempo ha pasado desde la última vez que visitaste un directorio)
- **`fd`** → sustituto de `find`, mucho más simple y rápido.
- **`fzf`** → fuzzy finder interactivo para navegar cualquier lista (archivos, historial, procesos…).

---

## lsd: `ls` potenciado

**lsd** [LSDeluxe](https://github.com/lsd-rs/lsd)** es una versión moderna y estilizada del clásico comando `ls` de Unix/Linux, con soporte para colores, iconos Nerd Font, y visualización en árbol.

En macOS (Homebrew) o en Linux con Debian/Ubuntu:

```sh
# En macOS
brew install lsd

# En Linux
sudo apt install lsd
```

En Windows:

```powershell
winget install lsd-rs.lsd
```

Tras la instalación siempreañado un alias a `ls`, tanto para PowerShell como CMD. Échale un ojo a cómo lo hago en este otro apunte, busca por [PowerShell/LSDeluxe]({{< relref "2024-08-25-win-desarrollo.md" >}}).

Ejemplo de uso

```sh
lsd -l --group-dirs=first
```

---

## zoxide: el nuevo `cd`

**[zoxide](https://github.com/ajeetdsouza/zoxide)** reemplaza `cd` con un sistema de navegación inteligente basado en tus hábitos. Recuerda los directorios a los que accedes con más frecuencia y te permite saltar con un simple comando.

En macOS / Linux (Homebrew):

```sh
brew install zoxide
```

En Debian/Ubuntu:

```sh
sudo apt install zoxide
```

En Windows:

```powershell
winget install ajeetdsouza.zoxide
```

Inicialización por shell

PowerShell:

```powershell
zoxide init pwsh | Invoke-Expression
```

Zsh:

```sh
eval "$(zoxide init zsh)"
```

Bash:

```sh
eval "$(zoxide init bash)"
```

Ejemplo de uso de zoxide

```sh
z proyectos
```

---

## fd: reemplazo para `find`

**[fd](https://github.com/sharkdp/fd)** es una alternativa más intuitiva y rápida a `find`. Tiene una sintaxis minimalista y sensible al color, con búsqueda por nombre, extensión, contenido y más.

En macOS / Linux:

```sh
brew install fd
```

En Debian/Ubuntu:

```sh
sudo apt install fd-find
```

En Windows:

```powershell
winget install sharkdp.fd
```

Ejemplo de uso

```sh
fd main -e cpp
```

---

## fzf: fuzzy finder universal

**[fzf](https://github.com/junegunn/fzf)** es una herramienta de búsqueda interactiva que permite seleccionar elementos de una lista con búsqueda difusa (fuzzy). Ideal para navegar archivos, historial, procesos, buffers de Git, etc.

En macOS / Linux:

```sh
brew install fzf
```

En Debian/Ubuntu:

```sh
sudo apt install fzf
```

En Windows:

```powershell
winget install sharkdp.fd
```

Ejemplo de uso

```sh
cat $(fd . -t f | fzf)
```

---

## Conclusión

Estas herramientas transforman la experiencia de la terminal en todos tus sistemas operativos. Son rápidas, coherentes y multiplataforma. Puedes usarlas en tus scripts, tus perfiles de PowerShell, `.zshrc`, o incluso dentro de WSL2 o CMD.

La combinación de `zoxide`, `lsd`, `fd` y `fzf` ofrece una base sólida para una shell moderna, productiva y portátil. Iré ampliando esta lista con nuevas herramientas recomendadas a medida que las incorpore a mi flujo de trabajo.
