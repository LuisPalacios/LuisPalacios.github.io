# Blog Hugo — Agent Instructions

## Workflow Orchestration

**Priority order when rules conflict**: Correctness > Simplicity > Elegance.

### 1. Plan First

- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy

- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- One tack per subagent for focused execution

### 3. Verify Before Done

- Never mark a task complete without proving it works
- Verify compilation: `mkb build` (debug)
- Diff behavior between main and your changes when relevant
- For C++ changes: check for RAII violations, const-correctness, and no-exception compliance

### 4. Autonomous Bug Fixing

- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user

### 5. Learn from Corrections

- After corrections from the user: save a `feedback` memory via the memory system
- Do NOT maintain a separate lessons file — use `.claude/projects/.../memory/` exclusively

## Task Management

1. **Plan First**: Write plan to "tasks/todo.md" with checkable items
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Add review section to "tasks/todo.md"

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **Skills first**: Check if a skill exists before manual work
- **Self-improve**: When a skill fails, update its SKILL.md with the fix
- **Zero entropy**: Never create files outside defined structure

## Guidelines (Read Only When Needed)

**IMPORTANT**: Only read these guidelines when actively working on skills or scripts. Do NOT read them for general documentation tasks.

| Guideline | When to Read |
| --- | --- |
| `.claude/context/guideline_skills.md` | Creating, reviewing, or updating a skill |
| `.claude/context/guideline_python.md` | Creating or modifying Python scripts (`.py` files) |
| `.claude/context/guideline_js.md` | Creating or modifying JavaScript/TypeScript (`.ts`, `.js`, `.mjs` files) |

## Context Files (Read Only When Needed)

| Context | When to Read |
| --- | --- |
| `.claude/context/post-conventions.md` | Creating/editing blog posts |
| `.claude/context/shortcodes.md` | Using Hugo shortcodes |

## Repository Purpose

Personal technical blog at **[https://www.luispa.com](https://www.luispa.com)** (Hugo + PaperMod). Spanish content, CC BY-NC-SA 4.0.

## Quick Reference

| Item | Value |
| --- | --- |
| Branch | `gh-pages` (rama única: fuentes + deploy via GitHub Actions) |
| Hugo root | `src/` |
| Posts | `src/content/posts/YYYY-MM-DD-slug.md` |
| Images | `src/static/img/posts/` |
| Snippets | `src/assets/snippets/YYYY-MM-DD-slug/` |
| Theme | PaperMod (submodule, don't edit) |

## Commands

```bash
cd src && hugo server -D              # Dev server with drafts
hugo new posts/2025-12-25-slug.md     # New post from archetype
```

## Content Structure

- All content in `src/` only
- Images in `src/static/img/posts/`
- Code snippets in `src/assets/snippets/`
- Custom CSS → `src/assets/css/extended/custom.css`
- Custom JS → `src/assets/js/`
- Don't modify `themes/PaperMod/` (it's a submodule)

## Writing Posts

1. **Spanish-first**: always edit `YYYY-MM-DD-slug.md`. English technical terms are OK inside Spanish prose.
2. Structure: Problem → Solution → Examples
3. Float-left SVG logo (150px) at start
4. `<!--more-->` separates intro from body
5. Use `{{< relref >}}` for internal links

## Bilingual Posts (ES + EN)

Most posts have a Spanish source (`YYYY-MM-DD-slug.md`) and an English translation (`YYYY-MM-DD-slug.en.md`). **The Spanish file is the source of truth**; the English file is a derivative translation.

### Rules

- **Edit only the Spanish version** during iteration. Do **NOT** touch `*.en.md` — the user may make several commits/pushes to the Spanish file before deciding to re-sync English.
- The English counterpart is updated **on demand**, not per commit. The user explicitly signals "finalized" / "actualiza el inglés" / "translate now" when it's time.
- Use `/translating-apunte <slug>` to re-sync the English file from the Spanish source.

### Pre-push reminder (IMPORTANT)

**Before every `git push` that touches a Spanish post**, remind the user:

> "El `.en.md` de `<slug>` está ahora desincronizado con el español. ¿Quieres que lo actualice con `/translating-apunte <slug>` antes de hacer push, o prefieres dejarlo para más adelante?"

The user will answer "yes, translate now" (run the skill, commit, then push) or "no, later" (push as-is). Either answer is valid — the reminder exists so the decision is explicit, not forgotten.

## Available Skills

| Skill | Description | Usage |
| --- | --- | --- |
| `/creating-apunte` | Generate Spanish blog posts (apuntes) | `/creating-apunte [topic]` |
| `/translating-apunte` | Translate a Spanish post to English | `/translating-apunte <slug>` |
| `/fixing-markdown` | Validate and fix markdown formatting | `/fixing-markdown <target>` |
| `/removing-notebooklm` | Remove NotebookLM watermark from PDFs/images | `/removing-notebooklm <file>` |

Skills use `uv run` (Python) and `pnpm dlx` (JS CLI tools). See guidelines above when creating/modifying scripts.

## PaperMod Template Overrides (pendiente de limpieza)

Hugo v0.158.0 deprecó `.Language.LanguageDirection`, `.Language.LanguageName` y `.Language.LanguageCode`.
PaperMod (commit 1cf5327, oct 2025) aún usa esas APIs, así que se crearon **overrides locales** con los reemplazos:

| Override local | Qué se cambió |
| --- | --- |
| `src/layouts/_default/baseof.html` | `.Language.LanguageDirection` → `.Language.Direction` |
| `src/layouts/_default/rss.xml` | `.Language.LanguageCode` → `.Language.Locale` + eliminados fallbacks `site.Author` |
| `src/layouts/partials/header.html` | `.Language.LanguageName` → `.Language.Label` |
| `src/layouts/partials/templates/opengraph.html` | `.Language.LanguageCode` → `.Language.Locale` |
| `src/layouts/partials/translation_list.html` | `.Language.LanguageName` → `.Language.Label` |

También se migró `hugo.toml`: `languageCode` → `locale`, `languageName` → `label`, y se añadió `[params.author]`.

### Cómo comprobar si ya se pueden borrar

```bash
# 1. Actualizar PaperMod
git submodule update --remote --merge src/themes/PaperMod

# 2. Borrar los overrides
rm src/layouts/_default/baseof.html src/layouts/_default/rss.xml
rm src/layouts/partials/header.html src/layouts/partials/translation_list.html
rm src/layouts/partials/templates/opengraph.html

# 3. Probar el build
cd src && hugo --logLevel debug 2>&1 | grep -i deprecated

# Si no hay output → PaperMod ya incorporó los fixes, hacer commit.
# Si sigue habiendo warnings → restaurar los overrides con: git checkout -- src/layouts/
```

**Al iniciar una sesión**: recordar al usuario que estos overrides existen y ofrecerle ejecutar la comprobación.

## CI/CD

Push to `gh-pages` → GitHub Actions builds → deploys to GitHub Pages.

## Constraints

- **Never** edit theme submodule
- **Always** use existing CSS/JS patterns
- **Prefer** SVG for logos
