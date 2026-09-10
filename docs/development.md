# Development

Everything needed to run, load, and hack on the plugin itself. The README is the
project's presentation; this is the operational detail behind it.

## Prerequisites

1. **pen.dev running, with a `.pen` file open in the editor.** Every Pencil MCP
   tool — including the ones that only read state — fails with
   `Failed to access file ""` when nothing is open. This is the most common
   cause of a run that dies at phase 5, and the first thing to check.
2. **The `pencil` MCP server configured and connected.** This plugin
   deliberately ships no `.mcp.json`: the server is registered by the pen.dev
   editor extension itself, its launch command is an absolute, platform- and
   version-pinned path, and duplicating it in project scope would only add a
   per-server approval prompt. Verify with `/mcp`. Reasoning in
   [decisions.md](decisions.md).
3. **A git repository** in the project being designed. The pipeline commits
   after every phase, and that is what makes phase rollback possible.

## Loading during development

```bash
cd ~/projects/my-product
claude --plugin-dir /home/leandro/projects/personal/prototypen-plugin
```

Two skills become available, both invocable by name and both able to trigger
from a plain request:

| | |
|---|---|
| `/prototypen:discover` | interactive, collects requirements, writes `design/product-spec.md`, stops |
| `/prototypen:prototype` | the unattended pipeline, phases 1–10 |

Plus four agents: `prototypen:researcher`, `prototypen:brand-designer`,
`prototypen:designer`, `prototypen:auditor`.

## Reloading after edits

`skills/*/SKILL.md` and everything under `references/` is read fresh on each use
— **edits apply immediately**.

Changes to `agents/*.md`, `.claude-plugin/plugin.json`, or `.mcp.json` are
cached. Run **`/reload-plugins`** after touching those.

## Validating

```bash
claude plugin validate .
```

**Expect exactly one warning, and no more:**

```
⚠ version: No version specified. Consider adding a version following semver
✔ Validation passed with warnings
```

That warning is the intended state — the plugin defines no `version`, so the
version is derived from the commit SHA, which is the right mode while it changes
daily. `--strict` promotes warnings to errors and therefore fails by design.
Do not "fix" it by adding a version; see [decisions.md](decisions.md) for when a
real semver becomes appropriate. **If a second warning ever appears, that one is
real.**

## Repository layout

```
.claude-plugin/plugin.json   the manifest — the only file that belongs in here
skills/
  discover/SKILL.md          optional interactive intake — the only step that asks
  prototype/SKILL.md         the pipeline: phases, delegation, commits, limits
    references/*.md          the detail, loaded per phase rather than up front
agents/*.md                  researcher, brand-designer, designer, auditor
templates/*.md               the skeleton of every artifact the pipeline writes
evals/README.md              reference cases to run after any significant change
docs/*.md                    this documentation
```

## Structural rules that cannot be violated

From the Claude Code plugin reference. Breaking one produces a plugin that works
today via `--plugin-dir` and breaks on marketplace install — a failure mode that
does not show up in local testing.

1. **Only `plugin.json` lives inside `.claude-plugin/`.** `skills/`, `agents/`,
   `hooks/`, and `.mcp.json` live at the plugin root.
2. **Every SKILL.md has `name` in its frontmatter.** Without it, Claude Code
   falls back to the installation directory name — which for a marketplace
   plugin is a version string that changes on every update.
3. **No absolute paths.** Component paths are relative to the plugin root and
   start with `./`. Packaged files are referenced through `${CLAUDE_PLUGIN_ROOT}`.
4. **Nothing outside the plugin root.** No `../`, no symlink pointing out.
5. **No `version` in `plugin.json`.** See Validating, above.
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
