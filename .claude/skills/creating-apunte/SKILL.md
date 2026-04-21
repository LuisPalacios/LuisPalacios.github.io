---
name: creating-apunte
description: Generate Spanish blog posts (apuntes) for Hugo blog. Use when user wants to create a new post, write an article, crear un apunte, escribir un post, nueva entrada, or document a topic.
---

# /creating-apunte — Generate Blog Post

Create Spanish technical blog posts matching the established writing style.

## Phase 1: Gather Input

Ask user for:

| Field | Required | Default |
| --- | --- | --- |
| Topic/Title | Yes | - |
| Context sources | Yes | URLs, docs, snippets |
| Category | Yes | See list below |
| Tags | No | Auto-generated from content |
| Post type | No | `short`, `long`, or `cheatsheet` |
| Logo SVG path | No | Auto-created if not provided |
| Focus areas | No | Sections to emphasize |
| Contexto adicional | No | Notes, drafts, extensive text |
| Repo path | No | Local repo to use as context source |

**Categories:** `administración`, `desarrollo`, `herramientas`, `infraestructura`, `productividad`, `software`

## Phase 2: Research & Outline

1. Read provided sources (URLs, docs, snippets)
2. **If repo path provided:** spawn a subagent to explore the repository (see below)
3. Read [tone-reference.md](tone-reference.md) for writing style
4. Create outline with proposed sections
5. Estimate read time (~200 words/min)
6. **Present outline to user for approval before drafting**

### Repo Exploration (when repo path is provided)

Spawn a subagent to deeply explore the local repository. The subagent should:

1. Read `README.md`, `CHANGELOG.md`, `doc/` or `docs/` if they exist
2. Identify the project's purpose, architecture, and key technologies
3. Read key source files (entrypoints, config, main modules) — not every file
4. Check `git log --oneline -20` for recent activity and project maturity
5. Return a structured summary: **what it is**, **how it works**, **key features**, **tech stack**

This summary becomes the primary source material for drafting. Combine it with any URLs or notes the user also provided.

## Phase 3: Generate Draft

1. Read [template.md](template.md) for Hugo structure
2. Generate filename: `YYYY-MM-DD-slug.md` (kebab-case, no accents)
3. Write post following template structure
4. Save to `src/content/posts/YYYY-MM-DD-slug.md`
5. Create logo (see Phase 3.5)

### Phase 3.5: Logo Creation

**If user did NOT provide a logo path or explicitly skip:**

Read [logo-creation.md](logo-creation.md) for detailed instructions.

1. Search `src/static/img/posts/logo-*.svg` for existing match
2. If none, create new using template `src/static/img/posts/logo-template.svg`
3. Content must fit in 120x120 area at position (15,15)
4. Save to `src/static/img/posts/logo-{slug}.svg`

### Phase 3.6: Concept Diagram

**Always runs** unless user explicitly skips.

Read [diagram-creation.md](diagram-creation.md) for detailed instructions.

1. **Spawn a subagent** to deeply analyze the finished post and identify the core concept
2. Generate a `.drawio` diagram representing the principal idea/architecture/design
3. Save to `src/static/img/posts/YYYY-MM-DD-slug-01.drawio`
4. Edit the post to insert the `image-box` reference (pointing to the `.png` version) after the introduction, before or between the first sections

**Note:** The `.png` does not exist yet — the user will review the `.drawio` in draw.io and export it manually.

## Phase 4: Validate & Polish

1. Run `/fixing-markdown src/content/posts/YYYY-MM-DD-slug.md`
2. Self-check against criteria below
3. Present summary: file path, read time, sections, any TODOs

## Phase 5: Test locally

**Ask user**: "¿Quieres que arranque Hugo para probar el post? (puede que ya lo tengas corriendo)"

If yes, start Hugo dev server:

```bash
cd src && hugo server -D --disableFastRender --noHTTPCache --ignoreCache --cleanDestinationDir --logLevel debug
```

Note: `-D` flag is required to show draft posts.

Check the post at `http://localhost:1313/` and verify:

- Logo displays correctly (float-left)
- Content renders as expected
- No Hugo errors in console

## Phase 6: Request feedback

After the user reviews the post, ask for feedback:

```text
Cuando hayas revisado el post, dame feedback sobre:

| Aspecto | Pregunta |
| --- | --- |
| **Tono** | ¿Suena como mis otros posts? |
| **Estructura** | ¿Faltan o sobran secciones? |
| **Workflow** | ¿El proceso fue útil o molesto? |
| **Output** | ¿Qué necesitó corrección manual? |
```

Use feedback to improve the post and/or update the skill for future use.

## Self-Check Criteria

```text
[ ] Spanish language (English tech terms OK)
[ ] Filename: YYYY-MM-DD-slug.md
[ ] Logo float-left at start (150px)
[ ] <br clear="left"/> before <!--more-->
[ ] 1-2 paragraph intro before <!--more-->
[ ] Heading structure: ## main, ### sub
[ ] Heading capitalization: only first word, NOT Title Case
[ ] Headings short and direct (no "Mi X:" prefixes)
[ ] Gender: "las Skills" (feminine), not "los Skills"
[ ] Code blocks have language specified
[ ] Internal links use {{< relref >}}
[ ] Concept diagram .drawio created (or skipped by user)
[ ] image-box HTML inserted in post pointing to .png
[ ] Frontmatter has draft: true
```

## File Locations

| Type | Path | Naming |
| --- | --- | --- |
| Posts | `src/content/posts/` | `YYYY-MM-DD-slug.md` |
| Logos | `src/static/img/posts/` | `logo-{concept}.svg` |
| Images | `src/static/img/posts/` | `YYYY-MM-DD-slug-NN.png` |
| Diagrams | `src/static/img/posts/` | `YYYY-MM-DD-slug-01.drawio` |
| Snippets | `src/assets/snippets/YYYY-MM-DD-slug/` | `filename.ext` |

### Snippets (Code Templates)

For long config files or code that users should copy, use snippets:

```markdown
{{</* codefile
     path="snippets/YYYY-MM-DD-slug/filename.ext"
     lang="bash"
     title="Title for the collapsible section"
*/>}}
```

Use snippets when: config files, scripts > 20 lines, or templates.

## Reference Files

| File | Content |
| --- | --- |
| [tone-reference.md](tone-reference.md) | Writing patterns, voice, phrases |
| [workflow.md](workflow.md) | Detailed step-by-step process |
| [template.md](template.md) | Hugo frontmatter, body structure |
| [logo-creation.md](logo-creation.md) | SVG logo design guidelines |
| [diagram-creation.md](diagram-creation.md) | Concept diagram (.drawio) guidelines |

## Notes

- Post output in Spanish, skill docs in English
- Always start with `draft: true`
