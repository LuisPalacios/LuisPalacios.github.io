# Diagram Creation

Guidelines for generating a `.drawio` concept diagram for each post.

## When to Create

Always. Every post gets a concept diagram unless the user explicitly skips it.

## Goal

The diagram captures the **principal idea, architecture, or concept** of the post — not a decorative filler. It should help the reader understand the post at a glance.

## Process

### Step 1: Analyze the finished post

Read the completed post deeply. Identify the single most important concept to visualize:

- **Infrastructure posts** → topology, network layout, component relationships
- **Tool/software posts** → workflow, data flow, integration diagram
- **Development posts** → architecture, class relationships, pipeline
- **How-to posts** → step sequence, before/after, decision flow

### Step 2: Choose diagram type

Pick the type that best communicates the concept:

| Type | Mermaid equivalent | When to use |
| --- | --- | --- |
| Topology | `graph TD` | Network layouts, infrastructure |
| Flow | `flowchart LR` | Processes, pipelines, data flow |
| Sequence | `sequenceDiagram` | Request/response, protocol steps |
| Block | `block-beta` | Component architecture, layers |

### Step 3: Create the drawio XML

Use this base template:

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Diagram" id="diagram-1">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="850" pageHeight="600" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <!-- nodes and edges here -->
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

### Step 4: Design rules

**Canvas:**

- Page size: 850x600 (landscape)
- Keep content centered with reasonable margins

**Node styles:**

| Element | Fill | Stroke | Font |
| --- | --- | --- | --- |
| Primary nodes | `#dae8fc` | `#6c8ebf` | 12px |
| Groups/containers | `#fff2cc` | `#d6b656` | 13px bold |
| External/input | `#d5e8d4` | `#82b366` | 13px bold |
| Danger/warning | `#f8cecc` | `#b85450` | 12px |
| Labels on edges | inline `edgeLabel` | — | 12px |

**General:**

- Use `rounded=1` on all nodes
- Use `whiteSpace=wrap;html=1` for multi-line labels
- Use `edgeStyle=orthogonalEdgeStyle;rounded=1;strokeWidth=2` for edges
- Subgraph titles via separate text cells (`style="text;..."`) placed above the container — this gives full control over spacing
- Keep node count under 15 for clarity
- Use `<br>` or `&#xa;` for line breaks in labels

**What NOT to do:**

- Don't create decorative diagrams — every element must convey information
- Don't overcrowd — fewer nodes with clear labels beat many tiny boxes
- Don't use gradients or complex styling
- Don't include implementation details (IPs, ports) unless they are the point of the post

### Step 5: Save the file

Save to: `src/static/img/posts/YYYY-MM-DD-slug-01.drawio`

Use the **same date-slug as the post**, with suffix `-01`.

## Post Integration

After saving the `.drawio`, edit the post to insert the image reference. Place it after the introduction (after `<!--more-->`) and before or between the first sections — wherever it best aids comprehension.

```html
<div class="image-box">
  <img src="/img/posts/YYYY-MM-DD-slug-01.png" alt="Short description" width="800px" />
  <div class="image-caption">Short description of the concept.</div>
</div>
```

**Important:** The `src` points to a `.png`, not the `.drawio`. The user is responsible for opening the `.drawio` in draw.io, reviewing/adjusting it, and exporting the `.png`.

## Checklist

```text
[ ] Diagram represents the core concept of the post (not filler)
[ ] File saved as YYYY-MM-DD-slug-01.drawio
[ ] Fewer than 15 nodes
[ ] Consistent color palette (blue nodes, yellow groups, green inputs)
[ ] image-box HTML inserted in the post at the right location
[ ] Alt text and caption describe the concept
```
