---
name: flow
description: "Render architectures, data flows, lifecycles, state machines or service interactions as Mermaid diagrams, derived from the actual code. Use when the user says 'flow', 'graph' or 'diagram', or asks to visualize how something works."
---

### Workflow: flow

1. Read the code the diagram describes. Nodes and edges must map to real functions, services, routes or states, named as they are in the code.
2. Pick the diagram type that fits: `sequenceDiagram` for requests between actors, `stateDiagram-v2` for lifecycles, `flowchart TD/LR` for data flow and architecture, `erDiagram` for schemas.
3. Keep it readable: roughly 15 nodes max per diagram. Split big systems into an overview plus detail diagrams instead of one wall.
4. Output plain ```mermaid blocks, with no extra wrapping. Quote labels that contain special characters (`A["load()"]`) so the diagram renders.
5. Add a short legend or notes below the diagram only for non-obvious edges (async, retries, failure paths).
