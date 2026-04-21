---
name: removing-notebooklm
description: Remove the NotebookLM watermark from PDFs (presentations) and images (infographics) automatically. Use when the user wants to remove the NotebookLM watermark, eliminar el watermark, quitar la marca de agua.
---

# /removing-notebooklm — Remove NotebookLM Watermark

**IMPORTANT:** Before starting execution, inform the user: "ESTOY EJECUTANDO EL SKILL `/removing-notebooklm`"

Remove the NotebookLM watermark from PDFs and images automatically.

## Usage

```text
/removing-notebooklm <file> [--output <path>]
```

**Arguments:**

- `file` (Required): Input file to process
  - **PDF**: Multi-page presentations (e.g., `presentation.pdf`)
  - **PNG/JPG**: Single images/infographics (e.g., `infographic.png`)
- `--output` (Optional): Custom output path (default: `{name}_clean.{ext}`)

**No argument = show this usage.**

## Environment Setup

This skill uses **zero-footprint dependency management**:

- **Python scripts**: Executed via `uv run` with PEP 723 inline metadata — no `requirements.txt` or `.venv` needed

**Prerequisites** (must be installed on the system):

- `uv` — [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)

No per-project setup required. Dependencies are cached globally and resolved on first run.

### Dependencies (declared inline in script)

- `Pillow` — Image processing
- `pymupdf` — PDF processing
- `opencv-python` — Inpainting algorithm
- `numpy` — Array operations

## Command

Replace `<plugin-path>` with the actual path to this plugin's installation directory.

```bash
# Default output (adds _clean suffix)
uv run <plugin-path>/skills/removing-notebooklm/scripts/removing-notebooklm.py "<file>"

# Custom output path
uv run <plugin-path>/skills/removing-notebooklm/scripts/removing-notebooklm.py "<file>" --output "<output>"
```

## Examples

```text
/removing-notebooklm presentation.pdf
-> Creates presentation_clean.pdf

/removing-notebooklm infographic.png
-> Creates infographic_clean.png

/removing-notebooklm input.pdf --output final.pdf
-> Creates final.pdf
```

## Output Format

```text
Processing PDF: presentation.pdf
Pages: 12
  Page 1/12
  Page 2/12
  ...
  Page 12/12
Saved: presentation_clean.pdf

Done
```

## How It Works

### Watermark Specifications

| Property      | Value                   |
| ------------- | ----------------------- |
| Size          | 194 x 28 pixels (at 2x) |
| Position      | Bottom-right corner     |
| PDF margins   | 18px right, 16px bottom |
| Image margins | 9px right, 10px bottom  |

### Inpainting Algorithm

Uses OpenCV's Telea inpainting algorithm to seamlessly reconstruct the background:

- Creates a mask over the watermark area
- Propagates surrounding pixels into the masked region
- Works with complex backgrounds (textures, patterns, gradients)

### Supported Formats

| Type  | Extensions     | Processing  |
| ----- | -------------- | ----------- |
| PDF   | `.pdf`         | All pages   |
| Image | `.png`, `.jpg` | Single file |

## Behavior

1. **Check argument**: If no file provided, show usage and exit
2. **Validate file**: Check file exists and format is supported
3. **Process file**: Remove watermark using appropriate method
4. **Save output**: `{original_name}_clean.{extension}`

## Notes

- Output file is saved in the same directory as input
- Original file is not modified
- Requires: `uv` installed on system
- No `.venv` created—dependencies cached globally by uv
