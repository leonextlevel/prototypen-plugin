# Contributing

## Before you commit, always

```bash
claude plugin validate .
```

**Expect exactly one warning** — the missing `version`, which is the intended
state. `--strict` fails by design. If a *second* warning appears, that one is
real. Detail in [development.md](development.md).

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

The same reasoning governs adding a **skill**. There are two, and they are split
on whether asking the user a question is allowed — before generation it is the
highest-leverage move, during generation it costs the run its autonomy. A third
skill needs a seam that real. A new *phase* of the pipeline is not one; that goes
in `prototype`'s body or a reference file.

Another agent adds a context, a handoff, and a place for instructions to
contradict each other. It does not add judgment by itself. **The test for a new
agent is a different input and a different question** — not a different
failure mode. The five agents pass it: the researcher (the world → what is
true), the brand designer (occupied territory → where to stand), the designer
(the direction → how to realize it), the layout reviewer (geometry plus intent
→ does the arrangement do what it claims), the auditor (direction plus screen →
do they match). A "typography reviewer" would fail it: same input as the
auditor, a subset of its question. Splitting the designer by phase would fail
it: same input, same question, one more handoff.

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

Six of them, listed in [development.md](development.md) — only `plugin.json`
inside `.claude-plugin/`, `name` in every SKILL.md frontmatter, no absolute
paths, nothing outside the plugin root, no `version`, and the closed set of agent
frontmatter fields. Breaking one produces a plugin that works locally via
`--plugin-dir` and breaks on marketplace install, which local testing will not
catch.

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

- **`commands/`** — legacy format, and unnecessary: plugin skills are already
  invocable as `/prototypen:discover` and `/prototypen:prototype`, so a skill
  gives both the typed entry point and autotriggering. New capability goes in
  `skills/`.
- **Approval gates in the pipeline** — the target is a long unattended run. The
  audit phases are the quality control, not the user's attention.
- **`CLAUDE.md` at the plugin root** — it is not loaded as project context.
  Instructions that need to reach the model go in a skill.
- **An invented `.mcp.json`** — see `decisions.md`. A wrong MCP config breaks
  plugin loading in a way that is genuinely hard to diagnose.
