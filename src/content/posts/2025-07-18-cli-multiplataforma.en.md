---
title: "Cross-platform CLI Tools"
date: 2025-07-19
tags: ["cli", "cross-platform", "linux", "macos", "windows", "powershell", "zsh", "bash"]
categories: ["terminal", "tools", "productivity"]
cover:
  image: "/img/posts/logo-cli-multi.svg"
  hidden: true
---

<img src="/img/posts/logo-cli-multi.svg" alt="Cross-platform logo" width="150px" style="float:left; padding-right:25px"  />

In this post I share a selection of **cross-platform** command-line tools that you can use interchangeably on **PowerShell, CMD, WSL2, macOS and Linux**. These are modern, fast and lightweight utilities that replace or greatly improve classic tools like `ls`, `cd`, `find` or even command history.

They not only speed up everyday tasks, but also offer a more consistent user experience across systems. They don't depend on specific shells like Bash or Zsh, and work the same whether you use PowerShell, Terminal, Alacritty, VSCode or any modern environment. As I discover new CLI utilities that fit this cross-platform, no-heavy-dependencies approach, I'll keep adding them.

<!--more-->

{{< admonition note "Note">}}

This post became a bit outdated right after being written. I'm leaving it here as a reference, but I strongly recommend checking out this GitHub repository:

> [devcli](https://github.com/LuisPalacios/devcli) - Automates the installation and configuration of your CLI environment on Linux, macOS, WSL2 and Windows.

{{< /admonition >}}

## Introduction

These are the tools we'll explore:

- **`lsd`** → modern replacement for `ls`, with colors, icons and elegant formatting.
- **`zoxide`** → smart alternative to `cd`, based on frequency (how long since you last visited a directory)
- **`fd`** → replacement for `find`, much simpler and faster.
- **`fzf`** → interactive fuzzy finder for navigating any list (files, history, processes...).

---

## lsd: `ls` on steroids

**lsd** [LSDeluxe](https://github.com/lsd-rs/lsd)** is a modern, stylized version of the classic Unix/Linux `ls` command, with support for colors, Nerd Font icons, and tree view.

On macOS (Homebrew) or Linux with Debian/Ubuntu:

```sh
# On macOS
brew install lsd

# On Linux
sudo apt install lsd
```

On Windows:

```powershell
winget install lsd-rs.lsd
```

After installation I always add an alias to `ls`, both for PowerShell and CMD. Check out how I do it in this other post, search for [PowerShell/LSDeluxe]({{< relref "2024-08-25-win-desarrollo.md" >}}).

Usage example

```sh
lsd -l --group-dirs=first
```

---

## zoxide: the new `cd`

**[zoxide](https://github.com/ajeetdsouza/zoxide)** replaces `cd` with a smart navigation system based on your habits. It remembers the directories you visit most frequently and lets you jump to them with a simple command.

On macOS / Linux (Homebrew):

```sh
brew install zoxide
```

On Debian/Ubuntu:

```sh
sudo apt install zoxide
```

On Windows:

```powershell
winget install ajeetdsouza.zoxide
```

Shell initialization

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

zoxide usage example

```sh
z proyectos
```

---

## fd: replacement for `find`

**[fd](https://github.com/sharkdp/fd)** is a more intuitive and faster alternative to `find`. It has a minimalist, color-aware syntax with search by name, extension, content and more.

On macOS / Linux:

```sh
brew install fd
```

On Debian/Ubuntu:

```sh
sudo apt install fd-find
```

On Windows:

```powershell
winget install sharkdp.fd
```

Usage example

```sh
fd main -e cpp
```

---

## fzf: universal fuzzy finder

**[fzf](https://github.com/junegunn/fzf)** is an interactive search tool that lets you select items from a list with fuzzy search. Ideal for navigating files, history, processes, Git buffers, etc.

On macOS / Linux:

```sh
brew install fzf
```

On Debian/Ubuntu:

```sh
sudo apt install fzf
```

On Windows:

```powershell
winget install sharkdp.fd
```

Usage example

```sh
cat $(fd . -t f | fzf)
```

---

## Conclusion

These tools transform the terminal experience across all your operating systems. They're fast, consistent and cross-platform. You can use them in your scripts, your PowerShell profiles, `.zshrc`, or even inside WSL2 or CMD.

The combination of `zoxide`, `lsd`, `fd` and `fzf` provides a solid foundation for a modern, productive and portable shell. I'll keep expanding this list with new recommended tools as I incorporate them into my workflow.
