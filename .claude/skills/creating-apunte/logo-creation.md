# Logo Creation Guide

Instructions for creating SVG logos for blog posts.

## When to Create a Logo

Create a logo when the user:

- Does NOT provide a logo path
- Does NOT explicitly say "skip for now" or similar

## Step 1: Search for Existing Logo

Check `src/static/img/posts/logo-*.svg` for a relevant match.

```bash
# Example: if post is about Obsidian
ls src/static/img/posts/logo-obsidian*.svg
```

If found, reuse the existing logo.

## Step 2: Create New Logo

If no existing logo matches:

1. **Become an artist/designer expert**
2. **Study the post content** to understand its core purpose
3. **Design a simple, clean logo** that represents the topic
4. **Use the template** as base

## Template

**Path:** `src/static/img/posts/logo-template.svg`

```svg
<?xml version="1.0" encoding="utf-8"?>
<svg height="100%" width="100%" version="1.1" viewBox="0 0 150 150"
     xmlns="http://www.w3.org/2000/svg">
  <!-- Your design here -->
</svg>
```

## Template Constraints

| Property | Value |
| --- | --- |
| ViewBox | 150x150 |
| Content area | 120x120 |
| Content position | x=15, y=15 |
| Boundary rectangle | "Rectángulo límites" (hidden, for alignment) |

**Visual guide:**

```text
┌─────────────────────────────┐
│ (0,0)              150x150  │
│   ┌───────────────────┐     │
│   │ (15,15)           │     │
│   │                   │     │
│   │   CONTENT AREA    │     │
│   │     120x120       │     │
│   │                   │     │
│   └───────────────────┘     │
│                      (135,135)
└─────────────────────────────┘
```

## Design Principles

- **Monochrome or limited palette** — 2-3 colors max
- **Works in light and dark themes** — avoid pure white/black backgrounds
- **Recognizable at 150px** — simple shapes, no fine details
- **Represents the core concept** — not decorative, meaningful
- **Geometric shapes preferred** — circles, squares, simple paths
- **No gradients** — use solid fills
- **No text** — unless it's a logo wordmark

## Color Guidelines

For theme compatibility:

| Use case | Recommended |
| --- | --- |
| Primary fill | `#333` or `#666` (works on light bg) |
| Accent color | Topic-specific (e.g., Docker blue, Git orange) |
| Background | Transparent or very light |

## Output

**Save to:** `src/static/img/posts/logo-{slug}.svg`

Where `{slug}` is the post slug without date (e.g., `logo-tailscale.svg`).

## Examples of Good Logos

Check existing logos for reference:

- `logo-docker.svg` — Simple whale icon
- `logo-git.svg` — Git branch symbol
- `logo-proxmox.svg` — Cube/server shape
- `logo-hass.svg` — Home Assistant icon

## Checklist

Before saving:

```text
[ ] Content fits within 120x120 area at (15,15)
[ ] Works on both light and dark backgrounds
[ ] Recognizable at small size
[ ] No gradients or complex effects
[ ] Saved as logo-{slug}.svg
```
