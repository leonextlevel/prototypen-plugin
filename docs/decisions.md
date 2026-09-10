# Decisions

Decisions made while building this plugin where the specification was silent or
where two reasonable options existed. Each records what was decided, why, and
what would change it.

---

## 2026-09-09 — No `.mcp.json` is shipped

**Decided:** the plugin does not include an `.mcp.json`. The README documents
that the `pencil` server must be configured separately.

**Why:** the real configuration was found in the user's `~/.claude.json`:

```json
"pencil": {
  "type": "stdio",
  "command": "/home/leandro/.vscode/extensions/highagency.pencildev-0.6.71/out/mcp-server-linux-x64",
  "args": ["--app", "visual_studio_code", "--agent", "claudeCodeCLI"]
}
```

So the config *could* have been written. It was not, for three reasons: the
command is an absolute path, which violates the plugin's own no-absolute-paths
rule; it is pinned to extension version `0.6.71` and to `linux-x64`, so it would
break on the next VS Code extension update and on any other machine or platform;
and it is installed as a user-scoped server already, so shipping a project-scoped
duplicate would add a per-server approval prompt for no benefit.

The pen.dev VS Code extension registers this server itself. Anyone with pen.dev
installed already has it.

**Would change if:** pen.dev ships a stable, platform-independent launch command
(an `npx` package, or a binary on `PATH`).

---

## 2026-09-09 — Pencil MCP was fully verified, not left as "to verify"

**Decided:** `references/pencil-mcp.md` documents the complete verified API
rather than the partial list the specification allowed for.

**Why:** the first attempt to introspect the server failed — every Pencil tool
returns `Failed to access file ""` when no `.pen` file is open in the editor.
The user then opened one, which made `get_app_state`, `read_skill()`, and
`read_skill({path: "execute.md"})` all work. That turned a guess into a
transcript.

The verified surface is larger than the specification assumed: four tools
(`execute`, `get_app_state`, `get_style`, `read_skill`), and inside `execute`,
`Insert`, `Copy`, `Update`, `Replace`, `Move`, `Delete`, `Generate`,
`SetVariables`, `Get`, `GetVariables`, `FindEmptySpace`, `Print`,
`TakeScreenshot`, and `Export`. The failure-precondition itself turned out to be
worth documenting — it is the most likely cause of a dead run.

**One item remains open**, marked **TO VERIFY** in `references/pencil-mcp.md`:
`Export` documents no `"svg"` format, only `png`, `jpeg`, `webp`, `pdf`,
`html-tailwind`, and `html-css`. Since the brand phase must deliver
`design/brand/logo/*.svg`, the reference specifies writing the SVG source by
hand from path geometry (`Get` with `includePathGeometry: true`) and using
`Export` only for PNG previews — until someone confirms which path actually
works.

---

## 2026-09-09 — Screens nest inside flow regions, slightly against pen.dev's own convention

**Decided:** screens live inside named `Flow — <Name>` region frames, not
directly at the document root.

**Why:** pen.dev's own skill says to represent each screen as a top-level frame
under `document`. That is right for a single design session and wrong for this
pipeline, which must find its own work again in a later round, months later,
without a screenshot. Flat roots do not carry flow membership, and once a
document holds forty screens from six flows, nothing in the hierarchy says which
belongs to which.

The deviation is small and stays inside the spirit of the rule that matters:
pen.dev's actual constraint is that the root stays clean — only page/screen
frames, reusable component frames, and **other major container frames**. A named
flow region is a major container frame. What the rule forbids is loose text,
icons, and shapes at the root, which this structure forbids more strictly than
pen.dev does.

**Would change if:** nesting turns out to break `clip`, layout, or screenshot
behavior on screen frames in practice.

---

## 2026-09-09 — The `designer` agent cannot write files

**Decided:** `agents/designer.md` sets `disallowedTools: Write, Edit,
NotebookEdit, WebSearch, WebFetch, mcp__pencil__get_style`.

**Why:** the specification asked for `disallowedTools` to block what the
designer should not touch, without saying what. The load-bearing block is
`Write`/`Edit`. The designer is forbidden from inventing a design token; an
agent that hits a missing token and *can* edit `design-direction.md` will add it
and continue, the run will succeed, and the constraint will have quietly stopped
being a constraint. Unable to write, it has exactly one option: stop and report.
That report is the only mechanism by which the direction file gets fixed instead
of silently violated.

`get_style` is blocked because Pencil's style archetypes exist for when the user
has no direction — the opposite of this pipeline's situation, and a direct route
back to a generic look. `WebSearch`/`WebFetch` are blocked because research
belongs to phase 2; a designer that browses mid-screen is drifting.

---

## 2026-09-09 — Model and effort assignment

**Decided:** `researcher` and `designer` on sonnet; `brand-designer` and
`auditor` on opus with `effort: high`.

**Why:** the specification fixed these, and the reasoning is worth recording
because it drives the whole architecture. Once the direction is decided,
drawing screens is execution — sonnet does it well and there is a lot of it.
Judgment is where a run actually succeeds or fails, so the expensive model is
spent deciding whether work is good rather than producing more of it. Naming and
positioning get the same treatment: they are irreversible and everything
downstream inherits them.

---

## 2026-09-09 — Author metadata taken from the git/session identity

**Decided:** `plugin.json` names Leandro Lopes <leandrolopessjc15@gmail.com> as
author, MIT license.

**Why:** the specification required `author` and `license` fields without
specifying values. The email is the one this session is running under. MIT is
the conventional permissive default for a plugin of this kind.

**Would change if:** the plugin is published under an organization.

---

## 2026-09-09 — Five logo variants, with named files

**Decided:** `logo-primary.svg`, `logo-horizontal.svg`, `logo-symbol.svg`,
`logo-mono.svg`, `logo-inverse.svg`.

**Why:** the specification named the five variants (primary, horizontal,
reduced/symbol, monochrome, dark-background) but not their filenames. Fixed
names make them referenceable from `brand.md`, from `design-spec.md`, and from
implementation code without a lookup step.

Also decided: the mark is generated **once** and the variants are derived from
it. `Generate` with `type: "svg"` is non-deterministic — five calls produce five
different logos, not five variants of one.

---

## 2026-09-09 — The audit rubric has four levels, not three

**Decided:** structural, canvas organization, visual, completeness.

**Why:** the specification's own numbered list had four entries under a heading
that said three. Four is correct and the ordering matters: the two cheap
screenshot-free levels run first, so a structural failure is found before an
expensive visual pass is spent on work that has to be redone anyway.

---

## 2026-09-09 — The attempt limit binds only the visual level

**Decided:** the 3-cycle limit applies to level 3 (visual) only. Levels 1, 2 and
4 are fixed until they pass.

**Why:** the specification set "at most 3 fix cycles per screen" for the reason
that screenshot critique is weak at refinement. That reasoning is specific to
subjective visual judgment. Overflow, a missing name, a duplicate component, and
a missing empty state are objective — they converge, and abandoning them after
three tries would leave real defects in the deliverable on a technicality.

---

## 2026-09-09 — `design/` is not gitignored, and `temp.pen` is

**Decided:** `.gitignore` excludes local cruft and the scratch `temp.pen`
created during this build, and says in a comment why `design/` is absent.

**Why:** the specification required that `design/` not be ignored — the design
artifacts are meant to be versioned in the projects that consume this plugin.
The comment exists because a future contributor seeing no `design/` rule may
"helpfully" add one. `temp.pen` is a scratch canvas that belongs to this build
session, not to the plugin.

---

## 2026-09-09 — `claude plugin validate . --strict` fails, deliberately

**Decided:** `plugin.json` carries no `version`, and `--strict` therefore fails.

**Why:** these two build requirements are in direct conflict.

- Structural rule 5 says: do not define `version`, so that the version is
  derived from the commit SHA — the documented mode for an internal plugin under
  active development.
- `claude plugin validate . --strict` emits `version: No version specified` as a
  **warning**, and `--strict` promotes every warning to an error.

Plain `claude plugin validate .` passes:

```
⚠ Found 1 warning:
  ❯ version: No version specified. Consider adding a version following semver
✔ Validation passed with warnings
```

The missing `version` is the **only** finding, and it is the intended state, not
a defect. Adding `"version": "0.1.0"` would clear `--strict` and simultaneously
break rule 5, freezing the version at a string nobody will remember to bump
while the plugin changes daily.

The explicit rule wins over the general linter. Everything `--strict` would
otherwise catch was verified by hand and passes: only `plugin.json` inside
`.claude-plugin/`, `name` present in the skill frontmatter, no absolute paths in
any component, no `../`, no symlinks, and no `hooks`/`mcpServers`/
`permissionMode` in any agent frontmatter.

**Would change if:** the plugin gets published to a marketplace, at which point
a real semver version becomes meaningful and rule 5 no longer applies. Until
then, run `claude plugin validate .` without `--strict` and confirm the version
warning is the sole entry.

---

## 2026-09-09 — Two invocable skills, not a `commands/` directory

**Decided:** discovery and the pipeline are two skills — `/prototypen:discover`
and `/prototypen:prototype` — and `commands/` still does not exist.

**Why:** the request was for two commands: one to explore an idea and collect
requirements, one to run the whole design. The ergonomics are right, but they do
not require the legacy format. **Plugin skills are already invocable as
`/<plugin>:<skill>`**, so a skill gives the typed-command entry point *and*
autotriggering from a plain request, while `commands/` would give only the first
and reintroduce a format that is on its way out.

So the build rule "no `commands/`" survives intact, and the user-facing behavior
they asked for exists anyway.

**Why two skills rather than one skill with two modes:** the split falls on a
real seam — **whether asking a question is worth its cost.** Before generation, a
question costs one exchange and can redirect a whole run; asking is the
highest-leverage move available. During generation, the target is a long
unattended run and a question costs the run its autonomy, so the rule inverts to
decide-and-record. One skill carrying both instructions would be one body with
two contradictory rules about questions, and the model would pick.

**How the no-gates rule survives:** `discover` is not a phase and not a gate. It
is an alternative source for phase 1's output. `prototype` skips phase 1 when
`design/product-spec.md` exists and writes it itself when it does not, so the
pipeline stays runnable end to end without ever stopping for input. The one
concession is that phase 1 may *mention* discovery in a single line when a
request is unusually thin — and then proceeds anyway, without waiting.

**Discovery must not ask about aesthetics.** This is written into the skill as a
hard prohibition rather than a preference. Asked what they want it to look like,
almost everyone answers "clean, modern, professional" — a verbatim description of
the generic default this plugin exists to escape. The question has no good answer
in the abstract, so it collects noise while feeling productive, and worse, it
gives the pipeline a fake constraint that outranks the real ones. Discovery
collects the *job*; the visual decisions are made in research and direction,
against evidence. Existing brands and mandated design systems are facts, not
preferences, and those are asked about explicitly.

**Would change if:** discovery grows past collecting requirements — if it starts
doing competitive scanning or sketching, it is duplicating phases 2 and 4 and
should be folded back rather than expanded.
