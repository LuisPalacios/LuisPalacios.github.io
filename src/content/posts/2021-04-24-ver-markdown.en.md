---
title: "Preview Markdown on MacOS"
date: "2021-04-24"
categories: ["tools"]
tags: ["macos"]
draft: false
cover:
  image: "/img/posts/logo-mdview.svg"
  hidden: true
---

<img src="/img/posts/logo-mdview.svg" alt="mdview logo" width="150px" height="150px" style="float:left; padding-right:25px"  />

MacOS doesn't include an option in **Finder** to preview Markdown files (.md). There are several solutions available, and one of the quickest and simplest is to install `qlmarkdown`

<br clear="left"/>
<!--more-->

When faced with the question "how can I get Quick Look to show previews of Markdown (.md) files?", the answer is that there's a project called [qlmarkdown](https://github.com/toland/qlmarkdown) that can be installed with Homebrew and solves the problem.

```shell
brew install --cask qlmarkdown
```

From that point on, the association between `.md` files and the viewer is established

```shell
➜  ~ qlmanage -m | grep "md"
  com.unknown.md -> /Users/luis/Library/QuickLook/QLMarkdown.qlgenerator (1.3.5)
➜  ~
```

Note: In my case I had to restart the system for this to work; to allow me to validate its execution.
