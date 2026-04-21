# Creating Apunte Workflow

Step-by-step process for generating Spanish blog posts.

## Phase 1: Gather Input

### Required Information

Ask user for:

| Field | Required | Description |
| --- | --- | --- |
| Topic/Title | Yes | Subject of the post |
| Context sources | Yes | URLs, documents, text snippets |
| Category | Yes | See categories below |
| Tags | No | Auto-generated from content if not provided |
| Post type | No | `short` (default), `long`, or `cheatsheet` |
| Logo SVG | No | Path or request to create |
| Focus areas | No | Specific sections to emphasize |
| Contexto adicional | No | Notes, drafts, extensive text to incorporate into the post |
| Repo path | No | Absolute path to a local cloned repository to use as context source |

### Valid Categories

- `administración` — system admin, server management
- `desarrollo` — software development, programming
- `herramientas` — tools, utilities, CLI apps
- `infraestructura` — networking, homelab, servers
- `productividad` — workflows, PKM, organization
- `software` — general software topics

### Post Types

| Type | Read Time | When to Use |
| --- | --- | --- |
| `short` | 5-10 min | Default. Quick tutorials, tool intros, tips |
| `long` | 15-30 min | Deep-dive tutorials, architecture guides |
| `cheatsheet` | 3-5 min | Minimal prose, command tables, quick reference |

## Phase 2: Research & Outline

### Step 2.1: Read Sources

- Extract key information from provided URLs/documents
- Note technical details, commands, configurations
- Identify the core problem and solution

### Step 2.1b: Explore Repo (if repo path provided)

Spawn a subagent to explore the local repository at the given path:

1. Read `README.md`, `CHANGELOG.md`, `doc/` or `docs/` if they exist
2. Identify purpose, architecture, key technologies
3. Read key source files (entrypoints, config, main modules) — not every file
4. Run `git log --oneline -20` for recent activity and project maturity
5. Return structured summary: **what it is**, **how it works**, **key features**, **tech stack**

This summary becomes the primary source material. Combine with any URLs/notes also provided.

### Step 2.2: Internalize Style

Read [tone-reference.md](tone-reference.md) before drafting.

### Step 2.3: Create Outline

Structure based on post type:

**Short post:**

```text
1. Introduction (1-2 paragraphs)
2. Installation/Setup
3. Usage/Examples
4. Conclusion (optional)
5. Links
```

**Long post:**

```text
1. Introduction (problem statement)
2. Background/Context
3. Step-by-step guide
4. Advanced usage
5. Troubleshooting (if needed)
6. Conclusion
7. Resources
```

### Step 2.4: Estimate Read Time

- ~200 words/minute average
- Short: aim for 1000-2000 words
- Long: 3000-6000 words
- Prefer shorter unless content demands more

### Step 2.5: Present Outline for Approval

Show user:

- Proposed sections
- Estimated read time
- Any missing information needed

**Wait for user approval before drafting.**

## Phase 3: Generate Draft

### Step 3.1: Read Template

See [template.md](template.md) for Hugo frontmatter structure.

### Step 3.2: Generate Filename

Format: `YYYY-MM-DD-slug.md`

Rules:

- Date: today's date or user-specified
- Slug: kebab-case, lowercase
- No accents, no special characters
- Max ~40 characters for slug

Examples:

| Title | Filename |
| --- | --- |
| La navaja suiza para PDF's | `2025-11-30-navaja-pdfly.md` |
| Personal Knowledge Management | `2026-01-24-obsidian-en-casa.md` |
| Terminales con tmux | `2024-04-25-tmux.md` |

### Step 3.3: Generate Post

Follow template structure:

1. Frontmatter with `draft: true`
2. Logo SVG float-left header (150px)
3. 1-2 paragraph intro
4. `<br clear="left"/>` + `<!--more-->`
5. Structured content sections
6. Code blocks, tables, links as appropriate

### Step 3.4: Save Files

- Post: `src/content/posts/YYYY-MM-DD-slug.md`
- Logo (if new): `src/static/img/posts/logo-{concept}.svg`

### Phase 3.6: Concept Diagram

**Always runs** unless user explicitly skips. See [diagram-creation.md](diagram-creation.md).

#### Step 3.6.1: Analyze Post

Spawn a subagent that reads the finished post deeply and identifies the single most important concept to visualize (topology, workflow, architecture, data flow, etc.).

#### Step 3.6.2: Generate Diagram

Create a `.drawio` XML file following the design rules in [diagram-creation.md](diagram-creation.md):

- Blue nodes for components, yellow for groups, green for external inputs
- Keep under 15 nodes
- Page size 850x600

#### Step 3.6.3: Save

Save to: `src/static/img/posts/YYYY-MM-DD-slug-01.drawio`

#### Step 3.6.4: Insert Reference in Post

Edit the post to add the image-box HTML after the introduction (after `<!--more-->`), before or between the first sections — wherever it best helps the reader:

```html
<div class="image-box">
  <img src="/img/posts/YYYY-MM-DD-slug-01.png" alt="Short description" width="800px" />
  <div class="image-caption">Short description of the concept.</div>
</div>
```

The `src` points to `.png` (not `.drawio`). The user will review the diagram in draw.io and export the `.png` manually.

## Phase 4: Validate & Polish

### Step 4.1: Run Markdown Linting

Execute: `/fixing-markdown src/content/posts/YYYY-MM-DD-slug.md`

### Step 4.2: Self-Check

Verify against checklist:

```text
[ ] Spanish language (English tech terms OK)
[ ] Filename follows YYYY-MM-DD-slug.md pattern
[ ] Logo SVG exists or noted as TODO
[ ] Logo float-left at start with <br clear="left"/> before <!--more-->
[ ] 1-2 paragraph intro before <!--more-->
[ ] Clear heading structure (## main, ### sub)
[ ] Code blocks have language specified
[ ] Tables for comparisons/commands where appropriate
[ ] Internal links use {{< relref >}}
[ ] Read time ≤10 min (unless long-form tutorial)
[ ] Conversational first-person tone
[ ] No placeholder text or TODOs in content
[ ] Concept diagram .drawio created (or skipped by user)
[ ] image-box HTML inserted in post pointing to .png
[ ] Frontmatter has draft: true
```

### Step 4.3: Present Final Draft

Report to user:

- File path created
- Estimated read time
- Summary of sections
- Diagram: `.drawio` path (remind user to review in draw.io and export `.png`)
- Any other TODOs (missing logo, images to add, etc.)
- Next steps (review diagram, add images, set draft: false)

## File Locations Summary

| Type | Location | Naming |
| --- | --- | --- |
| Posts | `src/content/posts/` | `YYYY-MM-DD-slug.md` |
| Logos | `src/static/img/posts/` | `logo-{concept}.svg` |
| Post images | `src/static/img/posts/` | `YYYY-MM-DD-slug-NN.png` |
| Diagrams | `src/static/img/posts/` | `YYYY-MM-DD-slug-01.drawio` |
| Snippets | `src/assets/snippets/` | `filename.ext` |
