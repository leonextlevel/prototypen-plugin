# Contributing

## Before you commit, always

```bash
claude plugin validate .
```

Several of this plugin's structural rules (only `plugin.json` inside
`.claude-plugin/`, no absolute paths, no `../`, every SKILL.md carrying a
`name`) are exactly the things that work under `--plugin-dir` and break when the
plugin is installed from a marketplace. The validator catches that gap before a
user does.

**Expect exactly one warning, and no more:**

```
⚠ version: No version specified. Consider adding a version following semver
✔ Validation passed with warnings
```

That warning is the intended state — rule 5 below requires no `version`, so the
version comes from the commit SHA. **Do not "fix" it by adding one.** It also
means `--strict` fails by design, since `--strict` promotes warnings to errors;
see `decisions.md`. If a *second* warning ever appears, that one is real.

## The rule that keeps this plugin from growing wrong

**Generic design that got past the audit becomes a new line in the rubric — not
a new subagent.**

The tempting response to a bad result is structural: add a "typography
specialist", add a "color reviewer", add a phase. It feels like progress because
it produces a visible artifact. It is almost always wrong.

If a design came out generic and the audit passed it, exactly one of two things
is true:

1. **The rubric had no criterion that would have caught it.** Add the criterion
   to `references/audit-rubric.md`, at the right level, with a binary verdict
   and a stated fix. If it is a specific visual default, add it by name to the
   ban list in `references/anti-generic.md`.
2. **The direction file was too vague to audit against.** The audit can only be
   as sharp as the constraint it checks. Fix what
   `references/design-direction.md` *requires* a direction to declare.

Another agent adds a context, a handoff, and a place for instructions to
contradict each other. It does not add judgment. Four agents cover the four
genuinely different jobs — find out what is true, decide what the brand is,
execute a decision, judge a result. A fifth would overlap one of them.

The same applies to the skill body. If you are about to add fifteen lines of
detail to `SKILL.md`, they belong in a reference file with a pointer from the
phase that needs them. The body stays under 500 lines and stays skimmable.

## Run the evals before and after anything significant

```
evals/README.md
```

The characteristic failure of this plugin is tuning to the last case: a
dashboard comes out too airy, `SKILL.md` gets a nudge toward density, and the
next landing page comes out cramped. The change looked like a fix because only
one case was in view.

Run **all** the reference ideas — the dense data app, the landing page, the
mobile onboarding flow, and the incremental round — after any change to
`SKILL.md`, a reference file, or an agent prompt. Not after a typo; after
anything that changes behavior. Read the outputs against the general checks in
`evals/README.md`.

## Structural rules that cannot be violated

These come from the Claude Code plugin reference. Breaking one produces a plugin
that works today via `--plugin-dir` and breaks on marketplace install.

1. **Only `plugin.json` lives inside `.claude-plugin/`.** `skills/`, `agents/`,
   `hooks/`, and `.mcp.json` live at the plugin root.
2. **Every SKILL.md has `name` in its frontmatter.** Without it, Claude Code
   falls back to the installation directory name — which for a marketplace
   plugin is a version string that changes on every update, silently breaking
   every reference to the skill.
3. **No absolute paths.** Component paths are relative to the plugin root and
   start with `./`. Packaged scripts and files are referenced through
   `${CLAUDE_PLUGIN_ROOT}`.
4. **Nothing outside the plugin root.** No `../`, no symlink pointing out.
5. **No `version` in `plugin.json`.** Without it the version comes from the
   commit SHA, which is the right mode for a plugin under active development.
6. **Plugin agents accept only** `name`, `description`, `model`, `effort`,
   `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`,
   `isolation`. Not `hooks`, not `mcpServers`, not `permissionMode`.

## Editing conventions

- **Kebab-case** for every directory and file name.
- **The plugin's own content is English** — SKILL.md, references, agent prompts,
  templates, docs. What the plugin *produces* follows the user's language.
- **The language instruction must appear in every agent file.** Subagents run in
  isolated contexts and never see the user's original message. Drop it from one
  agent and that agent alone starts answering in English. This is easy to break
  and invisible until someone runs the plugin in another language.
- **Never invent a Pencil tool or signature.** `references/pencil-mcp.md` is
  verified against the live server; anything unconfirmed is marked **TO VERIFY**
  and must stay marked until it is actually checked. Verify with
  `mcp__pencil__read_skill`, which needs a `.pen` file open in the editor.

## Reloading during development

`SKILL.md` and the reference files are read fresh on each use — edit and the
change applies immediately.

Changes to `agents/*.md`, `plugin.json`, or `.mcp.json` are cached. Run
`/reload-plugins` after touching those.

## What not to add

- **`commands/`** — legacy format. New capability goes in `skills/`.
- **Approval gates in the pipeline** — the target is a long unattended run. The
  audit phases are the quality control, not the user's attention.
- **`CLAUDE.md` at the plugin root** — it is not loaded as project context.
  Instructions that need to reach the model go in a skill.
- **An invented `.mcp.json`** — see `decisions.md`. A wrong MCP config breaks
  plugin loading in a way that is genuinely hard to diagnose.
