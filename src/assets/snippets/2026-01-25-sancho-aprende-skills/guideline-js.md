# JavaScript/TypeScript Script Guidelines

## Core Rule

**Zero-footprint dependency management**: Use `pnpm dlx` to execute tools and scripts. Never create `node_modules/` or `package.json` in project root.

## Requirements

- `pnpm` — [pnpm.io](https://pnpm.io/)

## Two Use Cases

### 1. CLI Tools (e.g., markdownlint, prettier)

```bash
pnpm dlx tool-name [args]
```

Configuration files (`.prettierrc`, `.markdownlint-cli2.jsonc`) belong in skill directory.

### 2. Custom Scripts (TypeScript/JavaScript)

```bash
pnpm dlx tsx path/to/script.ts [args]
```

## Script Template

```typescript
#!/usr/bin/env node
/**
 * Brief description.
 * Usage: pnpm dlx tsx script.ts <args>
 */

import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { exit } from 'node:process';

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    console.log('Usage: ...');
    exit(1);
  }
  // Implementation
}

main().catch((error) => {
  console.error('Error:', error.message);
  exit(1);
});
```

## Key Rules

- **File extensions**: `.ts` (TypeScript) or `.mjs` (ES modules)
- **Imports**: Use `node:` prefix for built-ins (`node:fs/promises`, `node:path`)
- **Async**: Use async/await for file operations
- **Execution**: Always via `pnpm dlx tsx`, never `node` directly
- **No project pollution**: Dependencies only in skill directory if needed

## Troubleshooting

| Issue | Solution |
| --- | --- |
| `pnpm: command not found` | Install: `curl -fsSL https://get.pnpm.io/install.sh \| sh` |
| First run is slow | Expected. pnpm caches tools on first execution. |
| Config file not found | Ensure `--config` flag points to skill path |
| TypeScript errors | Use `pnpm dlx tsx` (not `node`) |

**Cache location:** pnpm global store — shared across all projects.
