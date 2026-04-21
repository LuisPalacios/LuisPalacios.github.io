# Skill Authoring Guidelines

Quick reference for creating and reviewing Claude Code skills.

## Core Principles

### 1. Conciseness is Key

Context window is shared. Only add what Claude doesn't already know.

**Challenge each line:**

- "Does Claude need this explanation?"
- "Does this paragraph justify its token cost?"

### 2. Degrees of Freedom

| Freedom | When | Example |
| --- | --- | --- |
| **High** (text instructions) | Multiple approaches valid | Code review guidelines |
| **Medium** (pseudocode/params) | Preferred pattern exists | Report template with options |
| **Low** (exact script) | Operations are fragile | Database migrations |

## SKILL.md Structure

```markdown
---
name: skill-name
description: What it does and WHEN to use it. Third person only.
---

# Skill Title

## Quick start

[Minimal working example]

## Detailed instructions

[Step-by-step workflow]
```

### Frontmatter Rules

| Field | Rules |
| --- | --- |
| `name` | Max 64 chars, lowercase + numbers + hyphens only |
| `description` | Max 1024 chars, non-empty, third person |

## File Structure (CRITICAL)

**Each skill MUST be a directory with `SKILL.md` as the entrypoint:**

```text
# CORRECT
.claude/skills/lib-verify/SKILL.md

# WRONG - will NOT work
.claude/skills/lib-verify.md
```

Keep SKILL.md under **500 lines**. Split into separate files:

```text
skill-name/
├── SKILL.md              # Main instructions (REQUIRED entrypoint)
├── REFERENCE.md          # Detailed docs (loaded as needed)
└── scripts/
    └── helper.py         # Executed, not loaded into context
```

## Anti-Patterns

| Don't | Do Instead |
| --- | --- |
| Windows paths `scripts\helper.py` | Unix paths `scripts/helper.py` |
| Multiple options without default | One recommended approach + alternatives |
| Assuming packages installed | Explicit install instructions |
| Magic numbers | Document all constants |

## Quick Reference

| Element | Limit |
| --- | --- |
| `name` | 64 chars, lowercase/numbers/hyphens |
| `description` | 1024 chars, third person |
| SKILL.md body | < 500 lines |
| Token cost at scan | ~100 tokens (metadata only) |
| Token cost when active | < 5k tokens |
