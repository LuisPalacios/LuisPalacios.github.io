# Post Conventions

## Frontmatter (Required)

```yaml
---
title: "Título del Post"
date: "YYYY-MM-DD"
categories: ["categoria"]
tags: ["tag1", "tag2", "tag3"]
draft: true
cover:
  image: "/img/posts/logo-xxx.svg"
  hidden: true
---
```

## Post Body Structure

```markdown
<img src="/img/posts/logo-xxx.svg" alt="Logo" width="150px" height="150px" style="float:left; padding-right:25px" />

Brief introduction paragraph.

<br clear="left"/>
<!--more-->

## First Section

Content...
```

## Naming

- Posts: `YYYY-MM-DD-slug-in-lowercase.md`
- Images: `YYYY-MM-DD-slug-NN.ext` (NN = sequence)
- Location: `src/static/img/posts/`

## Image Box (with caption)

```html
<div class="image-box">
  <img src="/img/posts/2025-11-29-example-01.png" alt="Description" width="800px" />
  <div class="image-caption">Caption text</div>
</div>
```

## Code Snippets

For longer code blocks that would clutter the post, use snippets:

**Location:** `src/assets/snippets/<post-slug>/`

**Usage in post:**

```markdown
{{</* codefile
     path="snippets/<post-slug>/filename.ext"
     lang="bash"
     title="Title shown in the collapsible header"
*/>}}
```

**Example:**

```markdown
{{</* codefile
     path="snippets/2014-10-19-bridge-ethernet/norte_access_server.conf"
     lang="conf"
     title="/etc/openvpn/server/norte_access_server.conf"
*/>}}
```

**When to use:**

- Config files (`.conf`, `.yaml`, `.json`)
- Shell scripts longer than 20 lines
- Code templates users should copy
- Any file that would make the post harder to read inline

## Categories in Use

- `infraestructura` — servers, networking, homelab
- `tv` — media center, streaming
- `linux` / `macos` / `windows` — OS administration
- `docker` — containers
- `desarrollo` — software development
