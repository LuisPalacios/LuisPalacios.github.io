---
title: "Terminal in AI Mode"
date: "2026-04-25"
categories: ["tools"]
tags: ["WezTerm", "iTerm2", "CLI", "productivity", "cross-platform", "lua", "python", "automation", "terminal"]
draft: false
cover:
  image: "/img/posts/logo-term-modo-ia.svg"
  hidden: true
---

<img src="/img/posts/logo-term-modo-ia.svg" alt="AI mode terminal logo" width="150px" height="150px" style="float:left; padding-right:25px" />

When you work with an AI harness (Claude Code, Gemini CLI, Codex, ...) you end up spinning up several instances over and over. I wanted a keyboard shortcut that opened my most typical setup with multiple panes in a single window.

I called it the terminal "AI mode": four panes, three running `claude` (each with a different model: opus, sonnet, haiku) and a fourth with a clean shell for auxiliary commands. The _non-negotiable_ requirement is that all four panes start in the directory I pressed the shortcut from, with zero manual steps.

This post covers two paths to set it up: **WezTerm** (recommended, cross-platform — Windows / macOS / Linux) and **iTerm2** (fallback for those who already live in iTerm on macOS and don't want to switch terminals).

<br clear="left"/>
<!--more-->

<div class="image-box">
  <img src="/img/posts/2026-04-25-modo-ia-en-la-terminal-01.png" alt="AI mode: 4 panes with opus, sonnet, haiku and shell" width="800px" />
  <div class="image-caption">Final look of AI mode — the layout is essentially the same in WezTerm and iTerm2.</div>
</div>

## The problem

My first instinct was to look for a "simple" approach that leveraged what the terminal already provides out of the box:

**iTerm2 Window Arrangements.** The "official" way to save a pane layout. The problem is threefold: you can't invoke them on demand with parameters, the associated Profiles are rigid, and the Profile's _Working Directory_ directive has no "use the `$PWD` of the shell that launched me" option.

**tmux or Zellij.** Hyper-configurable, beautiful declarative layouts, and native support for "open in `$PWD`". But they introduce a layer between the terminal and the shell: their own keyboard prefix, copy/paste with its own quirks, shell integrations to maintain. For my flow — where the terminal already does the multiplexer's job — that meant trading a small problem for a medium one.

**The solution that worked for me.** Embed the layout directly in the terminal's own configuration and bind it to a shortcut. The recipe changes per terminal: in WezTerm it's Lua, in iTerm2 it's Python on top of its Python API.

## WezTerm or iTerm2

| Criterion | WezTerm | iTerm2 |
| --- | --- | --- |
| Supported OS | Windows / macOS / Linux | macOS only |
| Configuration | Lua | Python API + GUI |
| Distribution | One config = all three OS | Only applies if you live in macOS |
| Learning curve | Minimal Lua (lightweight syntax) | Familiar if you already use iTerm |
| Recommended for | New setup or cross-platform | If you only use Mac and don't want to move |

If you work across more than one OS or you're picking a terminal from scratch, I recommend the **WezTerm path**. If you're on macOS, know iTerm by heart and don't want to touch your setup, jump to the **iTerm2 path**.

## WezTerm path (cross-platform) ⭐

[WezTerm](https://wezterm.org) is a modern emulator written in Rust with Lua-based configuration and GPU acceleration. The key thing is that it uses a single config file `~/.config/wezterm/wezterm.lua` that works identically on Windows, macOS and Linux.

### Quick install

Take a look at my [devcli](https://github.com/LuisPalacios/devcli) project, which (among many other things) installs WezTerm and adds my full configuration (shell picker, size persistence, theme picker, AI mode, etc.) which you can always adapt:

- [WezTerm with devcli](https://github.com/LuisPalacios/devcli/blob/main/docs/wezterm.md) — general guide.
- [AI Mode — four Claudes in one window](https://github.com/LuisPalacios/devcli/blob/main/docs/wezterm-ai-mode.md) — a guide on what this post is about.

If you'd rather skip devcli, install WezTerm by hand following [wezterm.org](https://wezterm.org) and check out my [`wezterm.lua`](https://github.com/LuisPalacios/devcli/blob/main/dotfiles/wezterm.lua).

### AI mode in WezTerm

From any window, switch to the directory you want to work on and hit the shortcut — a new window opens with the four panes.

| Platform | Shortcut | Why |
| --- | --- | --- |
| Windows | `CTRL+ALT+N` | `WIN+N` is reserved for the Notification Center. |
| macOS / Linux | `⌃⌘N` or `CTRL+SUPER+N` | `ALT+N` produces the dead-key `~` on Spanish layouts. |

Behavior:

- Inherits the `cwd` (current directory) from where you were — the four Claudes and the shell start in that directory.
- Layout: `opus` top-left (large), `sonnet` top-right, `haiku` bottom-right, clean shell bottom-left.

### How it's implemented (high level)

The super-config is a single `wezterm.lua` split into sections (§0 customization, §1 helpers, §2 shell, §3 appearance, §4 AI Mode, §5 shell picker, §6 window state, §7 keybindings, §8 mouse). Only §4 implements AI mode — everything else is orthogonal features.

- **Each Claude is launched as the pane's _foreground_ process** (`args = { 'claude', '--model', X }`), with no intermediate shell. This avoids the "wait for the shell to be ready" race condition that the iTerm/Python version does need to solve with `READY_TIMEOUT` and `SEND_GAP`. Explicit trade-off: when Claude exits (via `/exit` or a crash), the pane closes with it — there's no shell to fall back to. I prefer it that way.
- **`find_claude_bin()`** tries absolute paths on macOS because apps launched from Finder/Spotlight inherit a minimal PATH (`/usr/bin:/bin:/usr/sbin:/sbin`) that excludes Homebrew and `~/.local/bin`. On Windows and Linux it trusts the inherited PATH.
- **Layout** = percentages in `AI.LAYOUT_X/Y/W/H` (origin + size relative to the screen). The internal proportions are `AI.LEFT_RATIO`, `AI.LEFT_TOP_RATIO`, `AI.RIGHT_TOP_RATIO`. All tunable at the start of the §4 block.

The code lives in my [devcli](https://github.com/LuisPalacios/devcli) project: the implementation is in [`dotfiles/wezterm.lua`](https://github.com/LuisPalacios/devcli/blob/main/dotfiles/wezterm.lua) (always the latest version). AI mode is section §4 of that file; the rest are orthogonal features you can read in the same file.

### Main tunables

By tweaking the values in `AI = { ... }` (at the top of §4) you adjust the layout without touching logic:

- `AI.LEFT_RATIO` — what percentage of the width the left column takes (`0.65` = 65% for opus).
- `AI.LEFT_TOP_RATIO` — within the left column, how much the top pane takes (opus vs shell).
- `AI.RIGHT_TOP_RATIO` — same for the right column (sonnet vs haiku).
- `AI.LAYOUT_X / Y / W / H` — origin (X, Y) and size (W, H) of the window relative to the main screen, as fractions from 0 to 1.
- `AI.MODELS` — which model goes in each corner (`tl` top-left, `tr` top-right, `br` bottom-right).

These are the Lua equivalents of the `LEFT_RATIO`/`LEFT_TOP_RATIO`/`RIGHT_TOP_RATIO` you'll see further down in the iTerm `aimode.py`.

## iTerm2 path (macOS only)

The solution is to use the embedded Python runtime that ships with the application itself. The [Python API](https://iterm2.com/python-api/) lets you create windows, split panes, set sizes, read variables from each session and send text.

Scripts live in `~/Library/Application Support/iTerm2/Scripts/` and, if you put them in the `AutoLaunch` subfolder, they start as daemons every time iTerm2 opens. Once a script is registered, you can assign it a keyboard shortcut from iTerm2 itself.

### Setup

- **Enable the Python API in iTerm2**

  `iTerm2 → Settings → General → Magic → Enable Python API`. Tick the box and confirm the security dialog.

- **Create the AutoLaunch folder**

  Any script inside `AutoLaunch` runs automatically when iTerm2 starts:

  ```bash
  mkdir -p ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch
  ```

- **Create the script file** (example with vscode):

  ```bash
  code ~/Library/Application\ Support/iTerm2/Scripts/AutoLaunch/aimode.py
  ```

- **Paste the following content**:

  {{< codefile path="snippets/2026-04-25-modo-ia-en-la-terminal/aimode.py" lang="python" title="aimode.py" >}}

- **Start the daemon**

  Once the file is saved, you have two options:

  - Run it once now from `Scripts → AutoLaunch → aimode.py` in the menu bar.
  - Restart iTerm2 — since it's in `AutoLaunch` it'll start on every launch.

  The first time iTerm2 runs a script it may ask for permission. Accept. To verify the daemon is running, open `Scripts → Manage → Console`: you should see `aimode` in the list with no errors.

- **Assign the keyboard shortcut**

  `Settings → Keys → Key Bindings → +`:

  - **Keyboard Shortcut**: whichever you prefer (I use `⌃⌘N`, but any free combo works).
  - **Action**: _Invoke Script Function_.
  - **Function**: `aimode()` — the parentheses are mandatory.

### Using it in iTerm2

From any iTerm2 session, in any directory, hit the shortcut. You end up with a window with four panes in the directory you were in, and the three Claude panes launch opus, sonnet and haiku automatically.

You can tune the script by tweaking the `CONFIG` block at the top:

- `LEFT_RATIO` — percentage of the width the left column takes (`0.65` = 65%).
- `LEFT_TOP_RATIO` — within the left column, how much the top pane takes (opus).
- `RIGHT_TOP_RATIO` — same for the right column (sonnet vs haiku).
- `READY_TIMEOUT` — how long to wait for each shell to finish initializing before sending commands. Bump it if your `~/.zshrc` is slow (mise, nvm, heavy completions).
- `SEND_GAP` — pause between consecutive commands. Bump it to `0.1` if you ever see a truncated command.

When you edit the script:

`Scripts → Manage → Console` → find `aimode` → _Stop_ → `Scripts → AutoLaunch → aimode.py` to restart. Or close and reopen iTerm2 — either works.

## Next steps / extensions

Once you have the base, you can build your own layouts. Some ideas:

- **`aimode plan`** — the three Claudes starting with `--permission-mode plan` for planning sessions.
- **`aimode review <PR>`** — open the shell pane with a `gh pr checkout <PR>` and the Claudes in review mode.
- **Alternative layouts** — an `aireview.py` with three vertical panes to compare diffs side-by-side, or an `aiops.py` with shells on different servers via SSH.

Since each layout is a Python script in `AutoLaunch` and each one registers as its own RPC, you can have several shortcuts — `⌃⌥⌘A`, `⌃⌥⌘P`, `⌃⌥⌘R` — invoking different layouts without stepping on each other.

In WezTerm the parallel is to duplicate the §4 block with different `AI.MODELS` and bind more shortcuts (e.g. `CTRL+ALT+P`, `CTRL+ALT+R`) on the same functions — all without touching Python or the iTerm API.

## Useful links

| Type | Links |
| --- | --- |
| Project | [devcli](https://github.com/LuisPalacios/devcli) |
| Official | [WezTerm](https://wezterm.org) |
| Official | [iTerm2 Python API](https://iterm2.com/python-api/) |
| Reference | [Claude CLI documentation](https://github.com/anthropics/claude-code) |
