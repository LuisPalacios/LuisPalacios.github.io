# Python Script Guidelines

## Core Rule

**Zero-footprint dependency management**: Use `uv run` with PEP 723 inline metadata. Never create `.venv/`, `requirements.txt`, or run `pip install`.

## Requirements

- `uv` — [docs.astral.sh/uv](https://docs.astral.sh/uv/)

## PEP 723 Format (Required)

```python
#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "package-name>=version",  # List external packages
# ]
# ///
"""Script description and usage."""

import sys
from pathlib import Path

def main():
    pass

if __name__ == '__main__':
    main()
```

**Critical**: Metadata header must be at top, before docstring. Use `dependencies = []` if no external packages needed.

## Execution

```bash
uv run path/to/script.py [args]
```

## Key Rules

- **Location**: Metadata header before docstring (PEP 723 requirement)
- **Syntax**: Exact format with `# ///` markers (three slashes)
- **Encoding**: Always `encoding='utf-8'` for text file operations
- **Paths**: Use `pathlib.Path` for cross-platform compatibility
- **Exit codes**: Provide clear error messages with `sys.exit(1)` on failure

## Troubleshooting

| Issue | Solution |
| --- | --- |
| `uv: command not found` | Install: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| First run is slow | Expected. uv caches deps on first execution. |
| `ImportError` at runtime | Check PEP 723 metadata: delimiters must be exact |

**Cache location:** `~/.cache/uv/` — shared across all projects.
