# Hugo Shortcodes Reference

## codefile — Collapsible Code from File

```markdown
{{< codefile path="snippets/hello.cpp" lang="cpp" title="hello.cpp" open="1" linenos="inline" >}}
{{< codefile path="snippets/config.yaml" lang="yaml" from="5" to="18" >}}
```

| Param | Required | Description |
| --- | --- | --- |
| `path` | Yes | Relative to `assets/` |
| `lang` | No | cpp, bash, yaml, python, etc. |
| `title` | No | Display title (default: path) |
| `open` | No | "1" to expand by default |
| `linenos` | No | "table" \| "inline" \| "false" |
| `from`/`to` | No | Line range |

## admonition — Callout Boxes

```markdown
{{< admonition "note" "Nota" >}}
Text in **Markdown** inside the block.
{{< /admonition >}}
```

Types: `note`, `warning`, `tip`, `info`

## relref — Internal Links

```markdown
[Link text]({{< relref "2023-04-15-mac-desarrollo.md" >}})
```

## Mermaid Diagrams

```markdown
` ` `mermaid
graph TB
    A[Node A] --> B[Node B]
` ` `
```
