---
title: "iTerm in AI Mode"
date: "2026-04-25"
categories: ["tools"]
tags: ["iTerm2", "CLI", "productivity", "python", "automation", "terminal"]
draft: false
cover:
  image: "/img/posts/logo-iterm-modo-ia.svg"
  hidden: true
---

<img src="/img/posts/logo-iterm-modo-ia.svg" alt="iTerm2 AI Mode Logo" width="150px" height="150px" style="float:left; padding-right:25px" />

When you work with an AI harness (Claude Code, Gemini CLI, Codex, ...) you end up launching multiple instances over and over. I wanted a keyboard shortcut that would open my typical configuration using panels within a single window.

I call it the terminal in "AI Mode" and I've configured it in my MacOS with iTerm. I launch four panels: three with `claude` (each running a different model) and a fourth with a clean shell for auxiliary commands.

The _non-negotiable_ requirement is that all four panels start in the directory where I used the shortcut and that there are no manual steps.

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2026-04-25-iterm-modo-ia-01.png" alt="Flow: from keystroke to unified workspace" width="800px" />
  <div class="image-caption">Final appearance.</div>
</div>

## The Problem

I instinctively started looking for a "simple" way that would leverage what [iTerm2](https://iterm2.com/) already comes with out of the box. The options I explored before reaching the final solution were:

**iTerm2 Window Arrangements.** The "official" way to save a panel layout. The problem is threefold: you can't invoke it on-demand with parameters, the associated Profiles are rigid, and the _Working Directory_ directive of the Profile has no option to "use the `$PWD` of the shell that launched me".

**tmux or Zellij.** Highly configurable, beautiful declarative layouts, and native support for "open in `$PWD`". But they introduce a layer between iTerm2 and the terminal: their own keyboard prefix, copy/paste quirks, shell integrations you have to maintain. For my workflow—where iTerm2 already does the multiplexer's job—it was trading a small problem for a medium-sized one.

## iTerm2 [Python API](https://iterm2.com/python-api/)

The solution was to use the embedded Python runtime that comes with iTerm2. It includes a complete API with which you can create windows, split panels, set sizes, read variables from each session, and send text.

The scripts live in `~/Library/Application Support/iTerm2/Scripts/` and, if you put them in the `AutoLaunch` subfolder, they run as daemons each time iTerm2 opens. Once you register a script (as a named RPC), you can assign it a keyboard shortcut from iTerm2 itself.

## Setup Phase

- Enable the Python API in iTerm2

`iTerm2 → Settings → General → Magic → Enable Python API`. Check the box and confirm the security dialog.

- Create the AutoLaunch folder

Any script inside `AutoLaunch` executes automatically when iTerm2 starts. This is what we want so the shortcut is always available:

```bash
mkdir -p ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch
```

- Create the script file with your preferred editor, here's an example with VSCode:

```bash
code ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/aimode.py
```

- **Paste the following content**:

{{< codefile path="snippets/2026-04-25-iterm-modo-ia/aimode.py" lang="python" title="aimode.py" >}}

- Start the daemon

Once you've saved the file above, you need to tell iTerm2 to read it. You have two options:

- Run it once now from `Scripts → AutoLaunch → aimode.py` in the menu bar.
- Restart iTerm2 — Since we saved it under `AutoLaunch` it will start automatically on each launch.

The first time iTerm2 runs a script it may ask for permission. Accept it. To verify that the daemon is running, open `Scripts → Manage → Console`: you should see `aimode` in the list with no errors.

- Assign the keyboard shortcut

`Settings → Keys → Key Bindings → +`:

- **Keyboard Shortcut**: whichever you prefer (I use `⌃⌥⌘A`, but any free one works).
- **Action**: _Invoke Script Function_.
- **Function**: `aimode()` — the parentheses are mandatory.

## How to Use

From any iTerm2 session, in any directory, press the shortcut. You end up with a window with four panels that start in the directory you were in, and the three Claude panels launch opus, sonnet, and haiku automatically.

You can tune the script, it has a `CONFIG` block:

- `LEFT_RATIO` — what percentage of the width the left column takes (`0.65` = 65%).
- `LEFT_TOP_RATIO` — within the left column, how much height the top panel (opus) takes.
- `RIGHT_TOP_RATIO` — same for the right column (sonnet vs haiku).
- `READY_TIMEOUT` — how long to wait for each shell to initialize before sending commands. Increase it if your `~/.zshrc` is slow (mise, nvm, heavy completions).
- `SEND_GAP` — pause between consecutive commands. Increase to `0.1` if you ever see a command truncated.

And a `commands(cwd)` function that maps each panel (`tl`, `tr`, `bl`, `br`) to its shell command. Changing which model goes where, adding flags like `--permission-mode plan`, or replacing the shell panel with a `git status && git log --oneline -10` is editing one line.

When you edit the script:

`Scripts → Manage → Console` → search for `aimode` → _Stop_ → `Scripts → AutoLaunch → aimode.py` to restart. Or close and reopen iTerm2, it's the same.

## Next Steps

Once you have the foundation, you can create your own scripts. Here are some ideas to experiment with:

- **`aimode plan`** — the three Claudes starting with `--permission-mode plan` for planning sessions.
- **`aimode review <PR>`** — open the shell panel with a `gh pr checkout <PR>` and the Claudes in review mode.
- **Alternative layouts** — an `aireview.py` script with three vertical panels to compare diffs in parallel, another `aiops.py` with shells on different servers via SSH.

Since each layout is a Python script in `AutoLaunch` and each registers as its own RPC, you can have multiple shortcuts—`⌃⌥⌘A`, `⌃⌥⌘P`, `⌃⌥⌘R`—invoking different layouts without stepping on each other.

## Interesting Links

| Type      | Links                                                        |
| --------- | ------------------------------------------------------------ |
| Official  | [iTerm2 Python API](https://iterm2.com/python-api/)          |
| Reference | [claude CLI docs](https://github.com/anthropics/claude-code) |
