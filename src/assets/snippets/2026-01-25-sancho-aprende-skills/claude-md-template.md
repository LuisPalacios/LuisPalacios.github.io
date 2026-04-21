# CLAUDE.md Template

Template for project instructions that Claude loads at the start of every conversation.

## Operating Principles

- **Skills first**: Check if a skill exists before manual work
- **Self-improve**: When a skill fails, update its SKILL.md with the fix
- **Zero entropy**: Never create files outside defined structure
- **Minimal change**: Smallest coherent change that satisfies the request

## Guidelines (Read Only When Needed)

**IMPORTANT**: Only read these guidelines when actively working on skills or scripts. Do NOT read them for general documentation tasks.

| Guideline | When to Read |
| --- | --- |
| `.claude/context/guideline_skills.md` | Creating, reviewing, or updating a skill |
| `.claude/context/guideline_python.md` | Creating or modifying Python scripts |
| `.claude/context/guideline_js.md` | Creating or modifying JavaScript/TypeScript |

## [Your Project Sections]

Add project-specific sections below. Examples:

### Quick Reference

| Item | Value |
| --- | --- |
| Main branch | `main` |
| Build command | `npm run build` |
| Test command | `npm test` |

### Available Skills

| Skill | Description | Usage |
| --- | --- | --- |
| `/your-skill` | What it does | `/your-skill <args>` |

### Constraints

- Never push directly to main
- Always run tests before committing
- [Add your project constraints]
