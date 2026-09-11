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

Verify with `claude plugin list`. The installed version reads as a commit SHA:

```
❯ prototypen@prototypen
  Version: 7ce29d3ac88b
```

That is the intended behavior of omitting `version` — see Validating, below.
`claude plugin update prototypen@prototypen` pulls the newer commit.

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

Two skills become available, both invocable by name and both able to trigger
from a plain request:

| | |
|---|---|
| `/prototypen:discover` | interactive, collects requirements, writes `design/product-spec.md`, stops |
| `/prototypen:prototype` | the unattended pipeline, phases 1–10 |

Plus five agents: `prototypen:researcher`, `prototypen:brand-designer`,
`prototypen:designer`, `prototypen:layout-reviewer`, `prototypen:auditor`.

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
daily. **This holds under marketplace install too**: an installed copy reports
its SHA as the version and `claude plugin update` pulls the newer commit, so
nothing about publishing forces a semver. `--strict` promotes warnings to errors and therefore fails by design.
Do not "fix" it by adding a version; see [decisions.md](decisions.md) for when a
real semver becomes appropriate. **If a second warning ever appears, that one is
real.**

## Repository layout

```
.claude-plugin/
  plugin.json                the plugin manifest
  marketplace.json           single-plugin marketplace, so the repo installs directly
skills/
  discover/SKILL.md          optional interactive intake — the only step that asks
  prototype/SKILL.md         the pipeline: phases, delegation, commits, limits
    references/*.md          the detail, loaded per phase rather than up front
agents/*.md                  researcher, brand-designer, designer, layout-reviewer, auditor
templates/*.md               the skeleton of every artifact the pipeline writes
evals/README.md              reference cases to run after any significant change
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
