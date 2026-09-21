# Development

Everything needed to run, load, and hack on the plugin itself. The README is the
project's presentation; this is the operational detail behind it.

## Prerequisites

1. **pen.dev running, with `design/prototype.pen` open in the editor.** That is
   the fixed canvas path every project uses. Every Pencil MCP tool — including
   the ones that only read state — fails with `Failed to access file ""` when
   nothing is open, and `execute` against a non-existent path **silently writes
   to whichever canvas is active** instead of failing. The pipeline checks the
   active file before it starts and before every write session for this reason.
2. **The `pencil` MCP server configured and connected.** This plugin
   deliberately ships no `.mcp.json`: the server is registered by the pen.dev
   editor extension itself, its launch command is an absolute, platform- and
   version-pinned path, and duplicating it in project scope would only add a
   per-server approval prompt. Verify with `/mcp`. Reasoning in
   [decisions.md](decisions.md).
3. **A git repository** in the project being designed. The pipeline commits
   after every phase, and that is what makes phase rollback possible.
4. **Pre-approved permissions**, or auto mode — the allowlist is in
   [usage.md](usage.md). An unattended run that stops at a permission prompt is
   not unattended.
5. **The pen.dev CLI** (`npm install -g @pen.dev/cli`, `pen login`), which
   `scripts/pen-run.sh` and `scripts/pen-save.sh` call. Headless runs need
   nothing else; app mode still needs the MCP.
6. **`jq` or `python3`** on `PATH`, for the hooks. Without either, the guards
   log a warning and allow — the rules still hold, but only as instructions.

## Installing

The repository doubles as a **single-plugin marketplace**:
`.claude-plugin/marketplace.json` declares one entry whose `source` is `"./"`,
the repo root. This is what the VS Code extension and `claude plugin install`
look for — without it, either will report that no marketplace manifest exists.

```bash
claude plugin marketplace add ./prototypen-plugin   # a path, owner/repo, or https URL
claude plugin install prototypen@prototypen
```

The path form must look like a path — `./prototypen-plugin` or an absolute path.
A bare `.` is rejected. Once pushed to GitHub, `claude plugin marketplace add
<owner>/<repo>` works from anywhere and is the form to give other people.

Verify with `claude plugin list`; `claude plugin update prototypen@prototypen`
pulls the newer commit.

**Both manifests validate independently:**

```bash
claude plugin validate .                              # marketplace + the plugin it points to
claude plugin validate .claude-plugin/marketplace.json
```

Note that `marketplace.json` is the **one other file** that legitimately lives in
`.claude-plugin/`. The rule is that *components* — `skills/`, `agents/`,
`hooks/`, `.mcp.json` — stay at the plugin root; the two manifests do not.

## Loading during development

```bash
cd ~/projects/my-product
claude --plugin-dir /home/leandro/projects/personal/prototypen-plugin
```

Five skills become available, invocable by name and able to trigger from a
plain request:

| | |
|---|---|
| `/prototypen:discover` | interactive, collects requirements, writes `design/product-spec.md`, stops |
| `/prototypen:brand` | interactive, brand candidates side by side on the canvas, writes `design/brand.md`, stops |
| `/prototypen:prototype` | the unattended pipeline, phases 1–10 |
| `/prototypen:finalize` | consolidates `design/` after the last round, writes `design/README.md` |
| `/prototypen:roadmap` | the business roadmap under `docs/`, from a finalized design |

Plus five agents: `prototypen:researcher`, `prototypen:brand-designer`,
`prototypen:designer`, `prototypen:layout-reviewer`, `prototypen:auditor`.

## Reloading after edits

`skills/*/SKILL.md` and everything under `references/` is read fresh on each use
— **edits apply immediately**.

Changes to `agents/*.md`, `.claude-plugin/plugin.json`, `hooks/hooks.json`, or
`.mcp.json` are cached. Run **`/reload-plugins`** after touching those. The
hook *scripts* are executed fresh each time; only the manifest is cached.

## Hooks

`hooks/hooks.json` registers three `PreToolUse` guards, all plain shell
scripts that read the tool call as JSON on stdin (`jq`, with a `python3`
fallback) and exit 2 with a message to deny it:

| Script | Matcher | Denies |
|---|---|---|
| `guard-canvas-path.sh` | `mcp__pencil__execute` | any `filePath` that does not resolve to `<cwd>/design/prototype.pen`, or one that does not exist on disk |
| `guard-headless-path.sh` | `Bash` | a `scripts/pen-run.sh` or `scripts/pen-save.sh` call whose `.pen` argument does not resolve to `<cwd>/design/prototype.pen` |
| `guard-pen-read.sh` | `Read`, `Grep`, `Glob`, `Bash` | reading a `.pen` file with a file tool or a shell command (`cat`, `head`, `grep`, `jq`, …); git commands on `.pen` files pass |

`hooks/hooks.json` is loaded automatically; the manifest must not also
reference it (Claude Code reports a duplicate-hooks error when it does).

Test them without Claude Code by piping a fake call:

```bash
echo '{"cwd":"'$PWD'","tool_name":"mcp__pencil__execute","tool_input":{"filePath":"/tmp/x.pen"}}' \
  | hooks/guard-canvas-path.sh; echo "exit $?"     # expect a message and exit 2
```

The MCP path guard cannot see which file the editor has *active* — that is
what `get_app_state` is for, and the skill still checks it in app mode. In
headless mode the runner itself refuses to write while the file is the
active editor of a running app (`scripts/pen-run.sh`, exit 75). Together
they cover the failure recorded in `decisions.md`: a write that silently
lands in the wrong canvas, and its headless cousin, a write the app then
overwrites.

## Validating

```bash
claude plugin validate .
```

**Expect no warnings.** `plugin.json` carries a semver `version` since the
first public release (0.1.0, 2026-09-21); bump it in the same commit as any
change a user would notice (a skill's behavior, a question asked, a file
produced), and leave it alone for docs. Before that release the plugin
defined no version and one warning about it was the intended state. **Under
marketplace install**, `claude plugin update` pulls the newer commit
whatever the version says, so the number is for people reading a changelog,
not for the installer. `--strict` should pass too. **If a warning appears,
it is real.**

## Repository layout

```
.claude-plugin/
  plugin.json                the plugin manifest
  marketplace.json           single-plugin marketplace, so the repo installs directly
skills/
  discover/SKILL.md          optional interactive intake — asks, writes the spec
  brand/SKILL.md             optional interactive brand exploration — candidates side by side, asks
  prototype/SKILL.md         the pipeline: phases, delegation, commits, limits
    references/*.md          the detail, loaded per phase rather than up front (shared by every skill)
  finalize/SKILL.md          consolidates design/ after the last round, writes design/README.md
  roadmap/SKILL.md           the business roadmap under docs/, from a finalized design
agents/*.md                  researcher, brand-designer, designer, layout-reviewer, auditor
hooks/
  hooks.json                 three PreToolUse guards
scripts/
  pen-run.sh                 headless canvas access through the pen.dev CLI; saves at the end
  pen-save.sh                app-mode save through the CLI, run before every commit
  guard-canvas-path.sh       every Pencil write targets design/prototype.pen
  guard-pen-read.sh          no file tool reads a .pen
templates/*.md               the skeleton of every artifact the skills write
evals/README.md              reference cases to run after any significant change
  baselines/                 the exported screens of each case, per run, to diff against
docs/*.md                    this documentation
```

## Structural rules that cannot be violated

From the Claude Code plugin reference. Breaking one produces a plugin that works
today via `--plugin-dir` and breaks on marketplace install — a failure mode that
does not show up in local testing.

1. **Only manifests live inside `.claude-plugin/`** — `plugin.json` and, for a
   repo that is also a marketplace, `marketplace.json`. `skills/`, `agents/`,
   `hooks/`, and `.mcp.json` live at the plugin root.
2. **Every SKILL.md has `name` in its frontmatter.** Without it, Claude Code
   falls back to the installation directory name — which for a marketplace
   plugin is a version string that changes on every update.
3. **No absolute paths.** Component paths are relative to the plugin root and
   start with `./`. Packaged files are referenced through `${CLAUDE_PLUGIN_ROOT}`.
4. **Nothing outside the plugin root.** No `../`, no symlink pointing out.
5. **`version` in `plugin.json` is semver and bumped with behavior changes.** See Validating, above.
6. **Plugin agents accept only** `name`, `description`, `model`, `effort`,
   `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`,
   `isolation` — not `hooks`, `mcpServers`, or `permissionMode`.

## Language convention

The plugin's own content is **English**: skills, references, agent prompts,
templates, and this documentation. What the plugin *produces* follows the user's
language — the documents in `design/`, the audit reports, and every label,
heading and piece of microcopy inside the prototype.

Artifact filenames, canvas node names, region names, component names and token
names stay English always, so they are stable across rounds and across whoever
runs the plugin.

The README is the one deliberate exception: it is the GitHub presentation and is
written in Portuguese. See [decisions.md](decisions.md).

**The language instruction must appear in every agent file.** Subagents run in
isolated contexts and never see the user's original message; drop it from one
agent and that agent alone starts answering in English.

## Where to go next

| | |
|---|---|
| [architecture.md](architecture.md) | the pieces, what each decides, why the audit is isolated |
| [pipeline.md](pipeline.md) | the ten phases, artifacts, conditionals, commit points |
| [usage.md](usage.md) | running it, reading an audit, resuming an interrupted round |
| [contributing.md](contributing.md) | how to evolve it without making it worse |
| [decisions.md](decisions.md) | every judgment call made while building it |
| [../evals/README.md](../evals/README.md) | reference cases to run after a significant change |
