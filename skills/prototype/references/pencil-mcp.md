# Pencil (pen.dev) MCP — operating reference

Everything below was verified against the live `pencil` MCP server and its own
`pen-dev` skill on 2026-09-09 (VS Code extension `highagency.pencildev-0.6.71`).
Anything marked **TO VERIFY** was not confirmed and must not be relied on.

**Never invent a tool or function signature.** If you need something that is not
listed here, call `read_skill` and read the current documentation instead of
guessing.

## Session preconditions

- The pen.dev app must be running **with a `.pen` file open in the editor**.
  Every tool — including `get_app_state` and `read_skill` — fails with
  `Failed to access file ""` when nothing is open. This is the single most
  common cause of a dead pipeline run; check it first.
- `.pen` files are encrypted. **Never use Read, Grep, or any shell tool on a
  `.pen` file.** The MCP tools are the only way in.
- **The canvas for a project is always `design/prototype.pen`.** Fixed name and
  place, so every round and every agent finds it without being told.
- **`execute` cannot create a file, and a `filePath` that does not exist is not
  an error — it silently redirects to whatever canvas is active.** Verified on
  the live server (2026-09-10): an `execute` against a non-existent path returned
  `OK`, and the `Insert` inside it landed in the file that happened to be open in
  the editor. No warning, no failure. The only defense is to read the active
  path from `get_app_state` and compare it to the target **before every write
  session** — at the start of each `designer` task, and again at the first
  canvas write of the pipeline.
- Opening a file from the shell with `code <path>` is **not reliable** for this:
  it can land in a different VS Code window than the one the MCP is attached to,
  and it triggers a trust prompt the user must click through. Whether the file
  then became the active canvas cannot be observed from here. Ask the user to
  open it, then verify with `get_app_state`.
- When the `pencil` server is declared in a project-scoped `.mcp.json`, Claude
  Code asks for per-server approval before the tools become available. This
  plugin does not ship an `.mcp.json`; see `docs/development.md`.

## The four tools

| Tool | Purpose |
|---|---|
| `get_app_state` | Active canvas file, current selection, top-level nodes, existing reusable components, integrated-browser state. Call it first in a session, and **again before every write session** to confirm the active file is `design/prototype.pen`. |
| `read_skill` | `read_skill()` returns the pen-dev SKILL.md; `read_skill({path})` reads a referenced file (`"pen-schema.md"`, `"execute.md"`, `"guide/web-app.md"`, `"guide/design-system.md"`, `"guide/mobile-app.md"`, `"guide/landing-page.md"`, `"guide/table.md"`, `"guide/components.md"`, `"guide/code.md"`, `"guide/tailwind.md"`, `"scripts-and-shaders.md"`, `"slides.md"`). **Read `pen-schema.md` and `execute.md` before the first `execute` call of a session.** |
| `get_style` | Ready-made visual style archetypes. `get_style()` lists them; `get_style({name})` loads one or returns its required params. **This plugin does not use style archetypes** — they are for when the user has no direction, and this pipeline always produces its own. See `anti-generic.md`. |
| `execute` | Runs a JavaScript snippet against the document. This is where all reading and writing happens. |

### `execute` inputs

- `filePath` (required) — path to the `.pen` file. **Always pass the absolute
  path of `design/prototype.pen`.** A path that does not exist does not fail; it
  silently targets the active canvas (see Session preconditions).
- `input` — the JavaScript snippet.
- `edits` + `editId` — **when an `execute` call fails, always retry with `edits`
  against the failed call's `editId`; never resend the whole snippet in
  `input`.** Each edit is a `find`/`replace` pair applied in order to the failed
  snippet, which then re-runs from scratch. Keep patching under the same
  `editId` if it fails again.

## `execute` API surface (verified)

```ts
const document: string;                                  // predefined root node id

// Mutations
Insert(parent, nodeData): string                          // returns new node id
Copy(path, parent, copyNodeData?): string                 // descendants get new ids
Update(path, updateData): void                            // cannot change id/type/ref, not for children
Replace(path, nodeData): string
Move(path, parent?, index?): void
Delete(path): void
Generate(nodeId, "ai" | "svg" | "stock", prompt): void
SetVariables(variables, replace?): void

// Reading
Get(path, options?): Child
Get(path, visit, options?): T[]
Get(visit, options?): T[]                                 // whole document, visitor required
GetVariables(): { variables, themes? }
FindEmptySpace({width, height, direction?, padding?, nodeId?}): {x, y, parentId?}
Print(...values): void
TakeScreenshot(nodeIds: string[]): void
Export(nodeIds, format, outputPath, options?): void
```

`Visit<T> = (node, ctx) => T | undefined`. `ctx` carries `node`, `parentCtx`,
`depth`, `index`, `bounds` (resolved, in the parent's coordinate space),
`problems` (`"partially clipped" | "fully clipped"`), and `skipChildren()`.

`GetOptions`: `depth`, `resolveVariables`, `resolveInstances`,
`includePathGeometry`.

### Rules that bite

- **Each `execute` runs in its own scope.** Locals do not survive between calls.
  To persist a node id across calls, assign without `const`/`let`:
  `flowBoxId = Insert(...)`.
- **Every node needs a human-readable `name`.** The call returns a name→id map;
  that map plus `Get` is how a later round finds anything. This plugin's whole
  organization strategy depends on it (`canvas-structure.md`).
- **Never set `id`.** pen.dev always generates its own.
- **No comments in `execute` snippets.** Keep input small; use loops, spreads,
  and helpers instead of long repetitive code.
- `path` is an id string, or `instanceId/childId` for nodes inside a component
  instance. Never pass a node object — pass `.id`.
- `Insert`/`Copy`/`Replace` return **plain id strings**. To reach a new node's
  children, `Get(id, {depth: 1}).children`.
- Warnings come back in the response. Fix them in the next call.
- On failure, **all modifications and globals from that call are reverted.**

### Reading the canvas (phases 8 and 9)

Structural checks are cheap and do not need a screenshot:

```js
Get(n => n.reusable && Print(n.id, n.name))                       // list components
Print(GetVariables())                                             // list tokens
Get(root, (n, c) => c.problems && Print(n.name, "|", c.parentCtx?.node.name, "|", c.problems))
Get(root, (n, c) => Print(n.id, n.name, c.depth, c.bounds.x, c.bounds.y, c.bounds.width, c.bounds.height))
```

`ctx.bounds` is directly comparable to a node's `x`/`y` and feeds straight back
into `Update`. `ctx.problems` is the clipping/overflow detector. Use these for
the organization review; use a screenshot only for what is genuinely visual.

### Variables = design tokens

```js
SetVariables({
  accent: {type: "color", value: "#A3B59A"},
  "spacing-unit": {type: "number", value: 16},
  "font-heading": {type: "string", value: "Playfair Display"},
  background: {type: "color", value: [
    {value: "#F8F5F0", theme: {mode: "light"}},
    {value: "#1A1A1A", theme: {mode: "dark"}}
  ]}
})
```

- Every value **must** be `{type, value}`. A bare `"#A3B59A"` or `16` fails.
- Types: `"color"`, `"number"`, `"string"`.
- Variable names must **not** start with `$`. The `$` prefix is only for
  *referencing*: `fill: "$accent"`, `gap: "$spacing-unit"`.
- `replace` defaults to `false` (merge). Read with `Print(GetVariables())`
  before writing so you never clobber an existing token — this is the
  incremental-mode guard.
- Theme axes are registered automatically from `{value, theme}` arrays.

### Screenshots

`TakeScreenshot(nodeIds)` attaches one image per node id to the response;
`"document"` screenshots everything. They reflect changes made earlier in the
same call, so end a section-completing `execute` with a screenshot rather than
issuing a separate call.

Screenshots are expensive. Take the **smallest meaningful node** — a screen
frame, not the whole document — and only when color, type, or alignment
fidelity is the question. Structure goes through `Get`.

### Generated artwork (logos)

`Generate(nodeId, "svg", prompt)` is the only way to produce freeform vector
artwork, and the slowest, most expensive operation in Pencil. The brand phase is
its legitimate use; almost nothing else is.

- Insert a **frame** with explicit width/height first, then `Generate` into it.
  No other node type is allowed as a target.
- `"ai"` and `"svg"` are **async and non-blocking**. The result lands after the
  `execute` call returns. The frame keeps `placeholder: true` until it finishes.
- Poll cheaply and rarely: `Print(Get(logoFrameId, {depth: 0}).placeholder)`.
  Never poll with screenshots, never back-to-back. Do other work in between.
- If the flag clears and the frame is still empty, the generation failed — that
  is the only case where re-running `Generate` on the same node is correct.
- Never hand-draw a logo out of paths. Never generate one SVG per variant —
  generate once, then build the variants from it (`canvas-structure.md`).
- Icons → `icon` nodes (`lucide`, `feather`, `Material Symbols`, `phosphor`).
  Photography → `Generate` with `"stock"` or `"ai"` as a **fill**. There is no
  `image` node type.

### Exporting the logo files

`Export(nodeIds, format, outputPath, options?)` writes to disk — image formats
take a directory and write `<nodeId>.<ext>`; HTML formats take a file path.
This is the delivery mechanism for `design/brand/logo/`, not a verification
tool. Verify with `TakeScreenshot`.

**TO VERIFY:** `Export` has no documented `"svg"` format — only `png`, `jpeg`,
`webp`, `pdf`, `html-tailwind`, `html-css`. Until this is confirmed, the brand
phase writes the logo SVG **source** to `design/brand/logo/*.svg` by hand from
the generated path geometry (`Get` with `includePathGeometry: true`), and uses
`Export` only for the PNG previews. Confirm before relying on either path.

**TO VERIFY:** whether a 0-byte `design/prototype.pen` opens correctly as a
Pencil canvas (so the skill could `touch` it and only ask the user to open it),
and whether `code -r` on a path inside the attached workspace opens in the right
window without a trust prompt. The out-of-workspace test did neither. Until
confirmed, the user creates and opens the file.

## Layout facts that cause most failures

- **No CSS.** pen.dev has its own layout engine. If a property is not in
  `pen-schema.md`, it does not exist — find another way.
- Unsupported and error-producing: `alignItems: "baseline" | "stretch"`,
  `margin`, percentage sizes (`"100%"`, `"50vh"`, `calc()`).
- `layout` and `padding` exist **only on `frame`**. Only `frame` and `group` can
  have children.
- Properties do **not** cascade. Every node declares everything it needs.
- **Text has no `fill` by default and is invisible without one.**
- `textGrowth`: `auto` (never wraps, ignores width/height), `fixed-width`
  (`width` required), `fixed-width-height` (both required). Wrapping requires
  one of the latter two. **Never guess text dimensions** — rely on wrapping and
  layout.
- Prefer `fill_container` / `fit_content` over repeating a pixel value.
  A `fit_content` parent whose children all `fill_container` collapses.
- `x`/`y` are ignored inside a layout unless the parent is `layout: "none"` or
  the child is `layoutPosition: "absolute"`.
- Flexbox is single-axis with **no wrapping**. Grids are built as explicit row
  frames.
- There is no scrolling. All content must be visible; resize frames to fit.
- Any new, copied, or modified root frame carries `placeholder: true` for the
  duration of work on it, cleared as soon as that frame is done.
- Use `FindEmptySpace` to place root-level frames; never pick random
  coordinates, never overlap root objects. Chain sequential screens with its
  `nodeId` anchor.

## Multiplayer

The document can change while you work — the user is in it. If a node is
missing or no longer matches, **re-read instead of recreating**, and never undo
a change the user made in the meantime.
