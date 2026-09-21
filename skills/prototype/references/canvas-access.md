# Canvas access

Read this at Step 0 of every skill that touches the canvas, and pass the
chosen mode into every agent prompt. Two ways exist to read and write
`design/prototype.pen`; they produce identical results (same engine, same
renderer, same fonts) and differ only in who saves, who can watch, and what
must be open.

## The two modes

| | **App mode** (MCP) | **Headless mode** (CLI) |
|---|---|---|
| What runs | pen.dev desktop or the VS Code extension, with the file open | `pen interactive` in headless mode, no editor |
| Tools | `mcp__pencil__execute`, `get_app_state`, `read_skill` | `scripts/pen-run.sh <file.pen> <snippet.js>…` via Bash |
| Saving | **not automatic**: `scripts/pen-save.sh` before every commit | automatic: every run ends with `save()` |
| Live view | yes, the user watches the canvas | no; the user opens the file when the run is done |
| Wrong file | possible; the hook checks the path, `get_app_state` checks the active editor | impossible; the path is an argument |
| Conflict | the document is multiplayer; re-read before assuming | the file **must not be open** in an app while the run writes |
| Screenshots | attached to the `execute` response | `Export` to PNG, then read the file |

The facts behind the table, verified 2026-09-20 on the desktop app:

- The desktop app **does not autosave** an existing `.pen` file. It keeps a
  recovery backup and writes the original only on File → Save. The VS Code
  extension appeared to autosave because VS Code did.
- The desktop app **does not reload** a file changed on disk. A headless
  write only shows after the tab is closed and reopened. Until then the app
  holds the old version, and a Ctrl+S there overwrites the new one.
- The MCP `execute` API has **no save function**. `pen interactive -a
  desktop` + `save()` saves the app's open document and the app shows no
  pending-changes marker afterward. That is what `pen-save.sh` does.
- The `pencil` binary in a user's PATH may be the desktop AppImage, not the
  CLI. The CLI is `pen` (`@pen.dev/cli`; `@pencil.dev/cli` is the deprecated
  name). Running the AppImage a second time deletes the running instance's
  socket; only a restart of the app brings it back.

## The question, asked once

Every skill that writes to the canvas asks this before anything else, with
`AskUserQuestion`, in the user's language, with the suggested default first:

- **`/prototypen:prototype`, full run** → suggest **headless**. Nobody
  watches twelve flows in parallel; the result and the commits are what
  matter, and nothing can land in the wrong file.
- **`/prototypen:prototype`, incremental round**, **`/prototypen:brand`**,
  **`/prototypen:finalize`** → suggest **app mode** when the user has the
  canvas open (they are looking at it), headless otherwise.

The message says, in two lines, what each mode implies for them: headless
means "close the file in Pencil now, reopen it when I say the run is done";
app mode means "keep `design/prototype.pen` as the active editor; I save
before every commit". Record the answer in `design/run.md` (`Access:`).

## Preconditions per mode

**Both:** the `pen` CLI installed and logged in (`pen status` prints the
account). App mode needs it for saving; headless needs it for everything.
If it is missing, say so with the two commands (`npm install -g
@pen.dev/cli`, `pen login`) and stop; there is no fallback that saves.

**App mode:** `get_app_state` must report `<project>/design/prototype.pen`
as the active editor. If not, ask the user to open it and check again; never
take their word for it, and never open it yourself with `code <path>`.
Every `execute` passes the file's absolute path; `hooks/guard-canvas-path.sh`
denies any other.

**Headless:** the file must exist (`pencil-mcp.md`, the empty document) and
must **not** be the active editor of a running app. `pen-run.sh` checks that
through the app's socket and refuses with exit 75 when it is; relay the
message and wait.

## Working headless

`scripts/pen-run.sh <abs path>/design/prototype.pen a.js b.js` sends each
file as one `execute()` call in a single session, then `save()`. Rules:

- Ids assigned without `const`/`let` in `a.js` are visible in `b.js`, as
  across `execute` calls in app mode. Nothing survives between two runs of
  the script except what is on the canvas: re-find nodes by name with a
  `Get` visitor at the start of each run.
- Group the snippets of one unit of work (a screen, a component section) in
  one run; each run pays a few seconds of startup.
- `TakeScreenshot` output is stripped. To look: `Export([id], "png",
  "<abs dir>")`, then read `<abs dir>/<id>.png`. Same cost in tokens as an
  attached screenshot, and only when you ask for it.
- A failed snippet reverts that `execute` only; the session continues and
  still saves what earlier snippets did. Read the error, fix the file, rerun
  that snippet.
- `get_app_state` in headless reports the file the session opened; the
  active-editor check does not apply.

## Working in app mode

As before (`pencil-mcp.md`), with one addition: **`scripts/pen-save.sh
<abs path>/design/prototype.pen [desktop|vscode]` before every commit**, and
at the end of every agent task that wrote to the canvas. The commit message
no longer says "canvas save pending"; a save that fails is an error to fix,
not a note.

## The notice

Whatever the mode, the last message of a run, and the end-of-phase note in
app mode when the user is not watching, states in one line where the canvas
stands: headless → "`design/prototype.pen` changed on disk; close and reopen
it in Pencil to see this round"; app mode → "saved and committed at <sha>".
A user who opens an unchanged canvas after a long run assumes the run failed.
