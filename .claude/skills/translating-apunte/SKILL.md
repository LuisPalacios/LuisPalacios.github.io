---
name: translating-apunte
description: Translate a Spanish blog post (apunte) to English. Use when user wants to translate a post, traducir un apunte, translate to english, crear versión en inglés, or add English translation.
---

# /translating-apunte — Translate Post to English

Translate a Spanish Hugo blog post into natural technical English, creating the `.en.md` sibling file.

## Usage

```
/translating-apunte <post-path-or-slug>
```

Examples:
- `/translating-apunte 2026-04-03-gitbox`
- `/translating-apunte src/content/posts/2026-04-03-gitbox.md`

## Workflow

### Step 1: Locate the source post

- If a slug is given, resolve to `src/content/posts/YYYY-MM-DD-slug.md`
- Verify the file exists
- Check if `.en.md` already exists — warn if overwriting

### Step 2: Read the Spanish post

- For large posts (>500 lines), read in chunks using `offset`/`limit`
- Identify all prose sections vs code blocks

### Step 3: Translate

Create `src/content/posts/YYYY-MM-DD-slug.en.md` with these rules:

**Translate:**
- Front matter `title` to English
- Front matter `categories` to English equivalents (see mapping below)
- Front matter `tags` to English equivalents where applicable
- All body prose (paragraphs, lists, descriptions)
- Image `alt` text and `<div class="image-caption">` content
- Text inside Hugo shortcode parameters (e.g., admonition titles)
- Section headers (`##`, `###`, etc.)

**Preserve EXACTLY as-is:**
- All code blocks (` ``` ` fenced content) — never translate code, commands, paths, or configs
- All HTML tags and structure
- All Hugo shortcodes (`{{< relref >}}`, `{{< admonition >}}`, `{{< codefile >}}`, etc.)
- All image paths (`/img/posts/...`)
- All URLs and links
- `<!--more-->` marker in the same position
- Front matter: `date`, `draft`, `cover` (image path and hidden flag)
- The float-left logo `<img>` tag (translate only its `alt` attribute)

**Category mapping:**

| Spanish | English |
|---------|---------|
| administración | sysadmin |
| desarrollo | development |
| herramientas | tools |
| infraestructura | infrastructure |
| productividad | productivity |
| software | software |
| domótica | home automation |
| linux | linux |

**Tag translation:** Translate where a clear English equivalent exists. Keep technical terms as-is (docker, git, ssh, kubernetes, etc.).

**Tone:** Natural technical English — not robotic machine translation. Write as if the author wrote it in English originally.

### Step 4: Verify

1. Confirm the `.en.md` file was created alongside the `.md` file
2. Run `cd src && hugo` to verify no build errors
3. Report the English URL: `/en/posts/YYYY-MM-DD-slug/`

## Large Posts (>500 lines)

For very large posts:
1. Copy the Spanish file as the base: `cp slug.md slug.en.md`
2. Use targeted `Edit` replacements on prose sections
3. Or use a Python script for bulk string replacements
4. Code blocks stay untouched automatically since you only replace prose

## Notes

- The blog uses Hugo multilingual with filename-based organization
- Spanish (default) at `/posts/slug/`, English at `/en/posts/slug/`
- Hugo auto-links translations via the shared filename stem
- The PaperMod theme handles the language switcher automatically
