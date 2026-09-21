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

---

## 2026-09-09 — Viewport and theme are mandatory questions, and are handled differently

**Decided:** `/prototypen:discover` always asks, in its first round, which
viewports (desktop / mobile / both) and which themes (light / dark / both) are in
scope, with a primary named for each. Both go into a **Targets** table in
`design/product-spec.md`, and no later phase may narrow it.

**Why they must be asked rather than inferred:** neither is volunteered, and both
are expensive to change late. A desktop table and a mobile card list are
different designs, not one design at two widths, so discovering "it's also mobile"
after the direction phase means redoing the density and grid. Dark mode is worse:
a palette that passes WCAG AA in light routinely fails in dark, so retrofitting
it means rebuilding the palette that everything already references.

**The non-obvious part — the two axes are handled differently**, which is what
keeps the work linear instead of combinatorial. Two viewports and two themes
could mean four screen sets; it means two.

- **Viewport duplicates screens.** The designs genuinely differ. Flow regions are
  split by viewport (`Flow — Checkout / Mobile`), and the primary viewport is
  built and audited *first*, so a failed audit throws away half as much.
- **Theme does not duplicate screens.** pen.dev variables are themed natively —
  `SetVariables` takes `{value, theme: {mode: "dark"}}` arrays — so one screen
  renders in every theme *provided every color is a variable*. A duplicated dark
  canvas is four times the surface and it drifts, because someone fixes a label
  in light and forgets dark.

This promotes an existing rule to load-bearing: **no color literal, ever**. A
hardcoded hex renders fine in the theme being looked at and silently breaks every
other one, and it will not appear in the screenshot the auditor is reviewing. It
is now rubric criterion 1.8, checked with `Get` without `resolveVariables`, next
to 1.7 (every color token declares a value for every declared theme). Contrast
(3.6) is checked **per theme**, and a small `Theme Check` set of two or three
representative screens gets screenshotted in the non-default theme rather than
assuming it inverts cleanly.

**Would change if:** pen.dev's themed variables stop covering a case that matters
— per-theme imagery, or a theme that changes layout rather than only color. Then
that specific case gets a duplicated screen, not the whole set.

---

## 2026-09-09 — README in Portuguese and presentational; technical detail moved out

**Decided:** `README.md` is the GitHub presentation of the project, written in
Portuguese. The operational detail it used to carry — prerequisites, loading,
reloading, validation, repository layout, structural rules, language convention —
moved to `docs/development.md`.

**Why:** the README was doing two jobs badly. It opened as a pitch and then
turned into a runbook, so a visitor landing from GitHub had to read setup
instructions to find out what the thing does, and someone actually installing it
had the setup interleaved with positioning. Splitting them lets the README argue
for the approach — the generic-design problem, constraint before generation,
isolated audit, and the handful of design decisions that explain the shape — and
lets `development.md` be the runbook.

Portuguese is the user's language and the intended audience of the GitHub page.
This is a deliberate, single exception to the plugin's English convention, noted
in the README itself and in `development.md`: everything *internal* — skills,
references, agent prompts, templates, and `docs/` — stays English, because that
is what the model reads and what keeps artifacts stable across users.

**Not a `CLAUDE.md`.** The user suggested one as a possible home. It would be the
wrong file twice over: a `CLAUDE.md` at the plugin root is not loaded as project
context (it is a rule in this plugin's own build spec, and the reason instructions
live in skills), and the content being moved is documentation for humans, not
context for a model. `docs/development.md` sits with the rest of the
documentation and is reachable from the README's table.

**Structural rules and validation now live in one place.** They were duplicated
between `contributing.md` and the new `development.md`; `contributing.md` now
points at it rather than restating it, so the two cannot drift apart.

---

## 2026-09-09 — The repository is its own single-plugin marketplace

**Decided:** added `.claude-plugin/marketplace.json` declaring one plugin whose
`source` is `"./"` — the repo root.

**Why:** installing through the VS Code extension, or through
`claude plugin install`, requires a marketplace manifest; without one both report
that none exists. A separate marketplace repository would be the right shape for
publishing several plugins, and is overhead for one. The single-plugin
marketplace is the standard pattern for this case, and the official marketplace
uses the same plain-string relative `source` form (`"./plugins/<name>"`) for the
plugins it hosts in-repo.

**This does not violate the "only `plugin.json` in `.claude-plugin/`" rule.**
That rule exists to keep *components* — `skills/`, `agents/`, `hooks/`,
`.mcp.json` — at the plugin root, where the loader expects them. `marketplace.json`
is the other manifest, and `.claude-plugin/` is exactly where it belongs; the
official marketplace ships it at that path.

**No `version` was added, and none is needed.** This was the trigger condition
recorded earlier for reconsidering the no-version decision, so it was tested
rather than assumed: installed from the marketplace, the plugin reports
`Version: 7ce29d3ac88b` — the commit SHA — and `claude plugin update` pulls newer
commits. Publishing does not force a semver. A real version becomes worthwhile
when someone needs to *pin* one, or when `claude plugin tag` is used to cut
releases; until then the SHA is more informative than a stale `0.1.0`.

**Verified end to end** rather than by inspection: marketplace added, plugin
installed at user scope, and a session with no `--plugin-dir` resolved all six
components (`prototypen:discover`, `prototypen:prototype`, and the four agents).
That last check also confirms structural rule 2 holds under marketplace install —
both skills carry `name` in their frontmatter, so neither falls back to the cache
directory name.

---

## 2026-09-09 — Author name corrected to the repository's git identity

**Decided:** `plugin.json` and `marketplace.json` name **Leandro Bueno**.

**Why:** the initial `plugin.json` took the author name from the session's
account identity, which did not match the repository's configured git user
(`Leandro Bueno <leandrobueno.dev@gmail.com>`). The four commits made while
building the plugin were also authored under the mismatched name, because the
commit commands passed an explicit `-c user.name`, overriding the repo's own
configuration. Later commits use the configured identity.

**Left alone:** the author on those four existing commits. Rewriting history is
the repository owner's call, and the repo has not been pushed, so `git rebase`
or `git filter-branch` remains available if the mismatch matters.

---

## 2026-09-10 — A craft baseline, paired one-to-one with the rubric

**Decided:** added `skills/prototype/references/screen-craft.md` — navigation
patterns by destination count and viewport, spacing application (edge insets,
component padding, proximity grouping, gaps between interactive elements),
alignment posture, target sizes and legibility floors, hierarchy in practice,
the secondary-screen catalog by application type, and a pre-report checklist.
Read by the `designer` on every task and by the `auditor` when judging.

**Why a new file rather than more rules in the agent prompt:** the goal was fewer
audit failures, and the mechanism that actually produces that is **giving the
designer the standard before it draws instead of after**. That only works if the
standard and the rubric are the same thing said twice — so every rule in
`screen-craft.md` has a matching criterion (3.12–3.16 navigation, edge insets,
proximity spacing, alignment, type sizing; 4.10 secondary screens), and the
auditor is instructed to cite the section a finding comes from. A rule that lives
only in an agent prompt cannot be audited against; a criterion that exists only
in the rubric is a trap.

**Why it does not contradict `anti-generic.md`:** the two files pull opposite
ways on purpose. The ban list restricts the palette, type, surface and
composition; the baseline fixes where things are and how they behave. That is the
same line the ban list already drew internally between visual and interaction
convention. Ignoring the first produces a generic design; ignoring the second
produces one that is different and worse.

**Navigation and spacing were promoted into the direction file**, which now
declares eleven items instead of nine. Both were previously implicit and both are
expensive when left to the screen phase: navigation invented per screen means
every screen disagrees with the last about where things live, and the audit only
catches it after all of them are drawn. A spacing *scale* without stated
application rules produces evenly-spaced mush — proximity is the cheapest
hierarchy available and it only works when the within-group and between-group
gaps actually differ.

**Secondary screens got a home.** Splash, first run, permission request *and*
denied, offline, 404, no-access, session-expired, form confirmation — nobody
lists these as features, so nobody notices they are missing until they are. The
catalog is keyed by application type, which `discover` now asks for explicitly,
and the spec template carries an applies/why-not table so the decision is
recorded rather than silently skipped.

**Numbers used are platform conventions**, stated as such: 44pt touch target
(Apple HIG), 48dp (Material), 24×24 CSS px (WCAG 2.2 AA minimum target size),
16px mobile body text, 45–75 character line length, 4/8-based spacing scales.
The direction file may override them; they are the fallback shape, not a
substitute for a decision.

---

## 2026-09-10 — Simple and contextual is the brand default

**Decided:** `brand-designer` defaults to a simple, contextual brand unless the
user explicitly asks for something more elaborate, and records in
`design/brand.md` which of the two it applied.

**Why:** left unspecified, a generative brand phase drifts toward visual
complexity, because complexity reads as effort. It is the wrong instinct: a mark
that survives a favicon, one-color engraving and a 16px header is the one that
had a single clear idea, and complexity is usually where an undecided idea hides.

Stated as concrete constraints rather than as "keep it simple": one idea legible
at 16px, describable in a sentence without a comma; contextual forms preferred
over abstract ones, because abstraction has to be taught while a domain form
carries meaning; one primary color plus neutrals, with a second accent needing a
job; and no gradient, shadow, glow, bevel or transparency in the primary lockup —
which is exactly what the required `logo-mono.svg` variant already tests for.

**It is a default, not a restriction.** When the user asks for illustrative,
ornamental or maximalist, the agent does that instead.

---

## 2026-09-10 — The canvas is always `design/prototype.pen`, checked before anything, asked for once

**Decided:** Step 0 of `/prototypen:prototype` — before mode detection, before
reading the request in detail — reads the active canvas from `get_app_state`
and compares it to `<project>/design/prototype.pen`. If they differ, the skill
stops **once**, asks the user to create and open that file, explains that the
run will not stop again after this, re-checks on confirmation, and only then
proceeds. Every canvas-writing agent repeats the check at the start of its
task, and the skill repeats it before phase 5.

**Why a fixed path:** every round and every agent has to find the same document
without being told. A path chosen per run drifts, and a second `.pen` for a
second round defeats the entire canvas-organization strategy.

**Why the check is mandatory, not a courtesy — verified on the live server:**
`execute` against a `filePath` that does not exist **does not fail**. It returns
`OK`, and the mutation inside it lands in whatever canvas is active in the
editor. Tested by inserting a frame through a scratchpad path that did not
exist: the frame appeared in the unrelated `temp.pen` that was open, with no
warning. A pipeline without this check could build the entire prototype into
the wrong document and report success. This is the most dangerous property of
the tool found so far, and it is recorded in `references/pencil-mcp.md`.

**Why ask rather than automate — also tested:** copying a blank `.pen` and
opening it with `code -r <path>` returned exit 0, but the user reported it
opened in a *different* VS Code window (another project they had open) and
triggered a "suspicious file" trust prompt that needed a click. The MCP server
is attached to one window; from the agent's side there is no way to observe
which window took the file or whether it became the active canvas. An automation
that sometimes silently does the wrong thing is worse than an ask that always
does the right one. The skill is explicitly told not to try.

**Why it is the only allowed stop and why it is first:** the pipeline's rule is
no approval gates, because the target is a long unattended run. A precondition
that cannot be satisfied autonomously has to be checked *before* autonomy starts
— that is the difference between a gate and a prerequisite. Putting it first,
with the explanation of why it is being asked now, is what lets the rest of the
run promise not to stop.

**Left open:** whether an empty (0-byte) file opens correctly as a Pencil canvas,
and whether `code -r` on a path *inside* the attached workspace behaves better
than the out-of-workspace test did. Both would let the skill create the file
itself and only ask the user to open it. Marked TO VERIFY; until then, the user
creates it.

---

## 2026-09-11 — Self-review after every screen and flow, kept strictly mechanical

**Decided:** the `designer` reviews every screen before reporting it done —
a `Get` visitor pass (clipping, missing fills, color literals, near-miss
alignment, overlap, off-scale and uniform gaps), then one screenshot read as a
stranger would (misalignment, crowding, edge contact, wrong color, contrast,
text problems, confusion, missing pieces) — with at most two self-fix passes,
and then reviews each flow as a whole after its last screen. Anything left open
is named in its report. Procedure in section 8 of `screen-craft.md`.

**Why this does not contradict "self-review approves its own work":** that rule
is about judgment, and it stands — the designer is explicitly told not to grade
against the direction's personality sentence or decide whether the committed
choice shows. The self-review is confined to things that need no taste: an
agent that drew a card can still see it overlaps the next one, and a visitor
that finds `ctx.problems` is not being flattered. The two reviews answer
different questions, and the architecture doc now says so.

**Why it is worth doing at all:** the attempt limit. Each screen gets three
visual fix cycles in the audit, and screenshot critique stops converging after
that. Spending one of those three on a 3px misalignment is spending the scarce
resource on the cheap defect. The self-review costs one `Get` and one
screenshot and is meant to guarantee that audit findings are about things only
an isolated auditor could find.

**The feedback loop:** the auditor reads the designer's report first and marks
any mechanical miss the report does not mention as "not caught by self-review",
without softening the FAIL. That phrase is the signal for tightening the
procedure — it is how section 8 grows a new check instead of the rubric growing
a new subagent.

---

## 2026-09-11 — A component catalog organized by job, and the destructive-action rule

**Decided:** added `references/component-catalog.md` — a repertoire organized by
what the user is doing (confirm, choose, input, act, navigate, disclose, show a
collection, show status, structure) rather than by component name, each entry
with when to use it and when not. Read at phase 6 to decide the base component
set and at phase 7 before every screen. Rubric criteria 3.17–3.19 and 4.11 are
its auditable form.

**Why by job, not by name:** the failure being prevented is not "used the wrong
component" but "did not think of the component at all". A generative designer
left to its defaults builds a full screen for everything, never reaches for a
modal, sheet, popover or toast, and forgets the actions that are not the primary
one. A list keyed by component name does not help with that — the agent has to
already know it wants a modal to look up "modal". A list keyed by "confirm",
"choose", "disclose" is looked up by the situation, which is what the agent
actually has in front of it.

**The screen-versus-overlay decision comes first**, with a ladder from lightest
to heaviest (tooltip → popover → menu → toast → sheet/drawer → modal → screen)
and the rule to take the lightest rung that holds the task. This is the single
most common structural mistake and it is now a FAIL (3.18).

**Destructive actions always confirm in a modal — and reversible ones never do.**
The second half is as important as the first: a confirmation on a reversible
action trains users to click through dialogs, which is exactly what makes the
dialog on the irreversible action useless. So reversible actions act immediately
and offer Undo in a toast. The dialog itself has a required shape (title names
the thing, body states the consequence, destructive button is a verb with the
object in the destructive color, Cancel is the safe default, type-to-confirm for
high stakes), and "OK"/"Yes"/"Confirm" as the destructive button label is a
FAIL (3.17).

**The forgotten-actions list** — create, edit, delete, duplicate, search, filter,
sort, bulk select, share/export, undo, retry, refresh, sign out, help — is walked
per collection and object screen, at design time and at audit (4.11). The
product-spec template gained "Other actions" and "Overlays it opens" columns so
the walk happens at intake, before anything is drawn.

**The catalog says which; the direction says how.** Explicitly: it is not a
mandate to use everything, and it does not override the direction's visual
decisions. A modal is still a modal in every direction.

---

## 2026-09-11 — Content first, navigation after; screens are content-height; no safe-area bands

**Decided:** three linked changes to how a screen is built, all from the same
observed defect.

1. **Navigation is placed after content, not before.** The system is still
   decided once in the direction file and its components are still built in
   phase 6 — nothing about *what* the navigation is changes. What changes is the
   order on a screen: build every section, row and state first, then instance
   the navigation component, with bottom navigation at the bottom of the frame
   wherever the content ends.
2. **Screen frames are viewport-width and `fit_content` in height — never a
   device height, never clipped.** A tall screen is correct.
3. **No safe-area bands.** Status bar, notch, dynamic island and home indicator
   are not drawn; the handoff spec tells the implementer to apply platform
   insets.

**The defect that prompted it:** with "navigation first" as the rule, the agent
sized the screen frame to a phone, pinned the tab bar to the bottom, and cut off
the content that no longer fit. The result looked like a device and showed a
third of the screen. `clip: true` — which pen.dev's own guide suggests for screen
frames, and which `canvas-structure.md` had adopted — made the cut silent.

**Why all-content-visible is the governing principle:** the prototype is not a
device mockup. It is the specification the implementing agents read, and the
complete picture the user gets of what each screen holds. Content hidden below a
fold or behind a clip is content that will not be built and cannot be reviewed.
Scrolling is an implementation behavior — the implementer decides what scrolls,
the prototype shows what exists. A screen that is genuinely enormous is itself
information: it usually means the spec is asking one screen to do two jobs.

**Why safe areas go:** in a prototype they produce an empty band at the top and
another at the bottom of every mobile screen, communicating nothing and hiding
the real edge-spacing decision behind a fake one. They are a platform concern
with a platform mechanism, and the handoff names any element that must stay
clear of the home indicator so the implementer applies it. The *designed* insets
— sides, padding under the app bar — stay; the device chrome does not.

**Deviation from pen.dev's guide, recorded:** `clip: true` on screen frames is
not used. Horizontal overflow remains a defect and `ctx.problems` still catches
it; the visitor works on unclipped frames too.

**Rubric:** 3.13 no longer mentions safe areas; new 3.20 (all content visible,
content-height, nothing displaced by navigation) and 3.21 (no safe-area bands).
The handoff template gained the two implementer notes.

---

## 2026-09-11 — A fifth agent, `layout-reviewer`, and the rule that admits it

**Decided:** added `agents/layout-reviewer.md` (sonnet, fresh context, per
flow, between the designer's self-review and the audit, and again after audit
fixes that touch layout) and `references/layout.md`, extracted from
`screen-craft.md` and extended with composition intent per screen archetype,
space usage, distribution, the numeric method, and the partial-alignment
failure catalog. The reviewer may fix mechanical geometry in place; it may not
restructure, judge, or touch color, type, copy or components.

**The observed failure:** screens that should be centered came out left-ranged,
or centered in the heading only; forms with three field widths; content hugging
one side of a wide screen. These are the defects a viewer feels instantly and
cannot name — and they were surviving because the designer's self-review is in
the generating context, and the auditor's attention, at opus with ~45 criteria,
is on judgment. A 3px partial alignment does not compete with "does this match
the direction's personality sentence".

**The rule, made precise rather than broken:** `contributing.md` said a generic
design that got past the audit becomes a rubric line, not a subagent, and that a
fifth agent would overlap one of the four. Both were slightly wrong as stated.
The real test is **a different input and a different question**. The layout
reviewer's input is geometry plus the screen's composition intent; its question
is whether the arrangement does what it claims. It needs two items from the
direction file and nothing else from the constraint set. That is not a subset of
the auditor's job; it is a job the auditor is badly shaped for. The rule now
says this, and it also says what still fails the test: a "typography reviewer"
(same input as the auditor, a subset of its question) and splitting the designer
by phase (same input, same question, one more handoff) — which was explicitly
considered and rejected.

**Why it fixes rather than only reports:** its fixes are geometric and
verifiable by the same bounds check that found them — a parent's `alignItems`,
a `gap`, a sizing mode. Routing "set `alignItems: center`" through the designer
costs a full context for no added judgment. The auditor does not fix because
its findings are judgments; the layout reviewer fixes because its findings are
measurements. It is told to fix the cause, never nudge `x`, and to escalate
anything that needs structure, content, or a decision about intent.

**Why `layout.md` is its own file:** the discipline is checkable by numbers, the
reviewer needs exactly this and nothing else from the craft set, and
`screen-craft.md` at 381 lines was carrying two subjects. Screen-craft keeps
what a screen must contain; layout keeps how it is arranged.

---

## 2026-09-11 — A change protocol: agents raise, the skill decides, nothing is edited in place

**Decided:** `references/change-protocol.md`, plus failure classification in
the audit report (`[FAIL:execution]` / `[FAIL:direction]` / `[FAIL:spec]`), a
`design/changes.md` log, and a `## Amendments` convention for the direction and
brand files.

**The gap it fills:** the pipeline declared constraints up front and executed
within them, and had one escape hatch — the designer stops and reports a
missing token, the orchestrator "amends the direction". Nothing said how, who
else could raise what, what happened when the direction itself was wrong rather
than the execution, how far a change had to propagate, or where the user could
see what had been decided in a run that never asked them. Meanwhile the audit
had no way to say "the designer did this right and it is still wrong", so
direction failures were being sent back as execution failures and burning fix
cycles on constraints that could not be satisfied.

**Three kinds, because they have three different owners:** *add* (a missing
definition — derived from what exists, put in the owning artifact), *amend* (a
direction decision that did not survive the real content — the smallest change
that resolves it), *extend* (scope the spec did not ask for — added if the
existing jobs imply it, otherwise written under Out of scope for the user; the
pipeline does not invent jobs).

**Never edit the original in place.** Amendments are dated entries appended to
the file. A direction whose history is visible can be audited against; one that
has been silently rewritten cannot, and the next round would inherit a
constraint nobody decided.

**The second-amendment rule** is the guard against erosion: the same area of the
direction amended twice in one round is the signal that the phase-4 decision was
wrong, not the detail — and the answer is `git reset` to phase 4, not a third
patch. Two patches on a bad foundation is how a direction file becomes a list of
exceptions.

**The orchestrator decides, not the user.** This keeps the run unattended. The
change log is the user's window: one entry per decision — kind, raised by,
problem, decision, why, propagated to, commit — written so that they can
disagree with exactly one decision and know exactly what to revert.

**The classification is what makes it work.** `direction` and `spec` failures do
not count against a screen's three cycles, because they are not the screen's
fault. The auditor is told the misclassification cost explicitly: a direction
failure sent to the designer as execution produces three cycles of a designer
trying to satisfy a constraint that cannot be satisfied.

---

## 2026-09-11 — A navigation map in the spec, and a reachability level in the audit

**Decided:** `design/product-spec.md` carries a **navigation map** — one row per
screen and overlay: what opens it ("entered from") and every way out ("exits
to") — written at intake, built against by the designer, walked in the flow
self-review, carried into `design-spec.md` as the implementer's routing table,
and verified by a new audit **Level 5 — Navigation integrity** (7 criteria, no
screenshot, run with levels 1 and 2).

**The gap:** reachability was three scattered sentences — "back always exists",
"primary tasks within two steps", "nothing in the sequence is unreachable" —
with no artifact declaring the graph and no criterion walking it. So an orphan
screen (built, never linked from anywhere) or a dead end (a success screen with
no Done, a modal whose only button is the destructive one, a permission-denied
state that only explains) could pass every level, because every level looked at
screens one at a time. Reachability is a property of the graph, and it needs
the graph written down.

**Why the map lives in the spec, before drawing:** an orphan or a dead end costs
one table row to prevent and a full fix cycle to find. Declaring "entered from"
forces the question *how does the user get here* to be answered for every
screen before any exists; declaring "exits to" does the same for *how do they
leave*. An empty cell is the finding, at the cheapest possible moment.

**Why it is a separate audit level rather than more level-4 rows:** it is a
different question — not "does this state exist" but "is this screen connected"
— and it is cheap, so it runs *before* the visual pass, not after: a screen that
cannot be reached does not deserve a screenshot until it can be.

**Why it goes to handoff:** the map is exactly the routing table an implementer
needs, and a screen missing from it will not get a route. The design-spec
template now carries it, verified against the canvas.

**The canvas has no links.** pen.dev, as documented, does not encode navigation
between frames, so the check is by reading: does the control the map names
exist, visibly, on the screen the map names, labeled to go where the map says.
`Get` visitors listing each screen's named controls do most of it; a screenshot
only where a label is ambiguous.

---

## 2026-09-11 — The two most dangerous rules became hooks

**Decided:** `hooks/hooks.json` registers two `PreToolUse` guards.
`guard-canvas-path.sh` denies any `mcp__pencil__execute` whose `filePath` does
not resolve to `<cwd>/design/prototype.pen` or whose target does not exist on
disk. `guard-pen-read.sh` denies `Read`, `Grep`, `Glob` and reading shell
commands (`cat`, `head`, `grep`, `jq`, …) aimed at a `.pen` file; git commands
on `.pen` files pass.

**Why:** the wrong-canvas write is the most dangerous property of the tool
found so far — verified on the live server, recorded in five files — and it was
guarded only by text. An instruction repeated in five places is still an
instruction; a session that skims one of them writes the whole prototype into
`temp.pen` and reports success. A hook does not skim. The `.pen` read guard is
the same reasoning at lower stakes: a full document is hundreds of kilobytes
that would flood the context, and there is never a reason to read it outside
`Get`.

**What the hook cannot do:** see which file the editor has *active*. `execute`
with the correct path against a file that exists but is not the active editor
is the case the hook passes and `get_app_state` catches, so the skill keeps
that check. The two halves together cover the failure.

**The rule for adding hooks**, recorded in `contributing.md`: a hook is for a
rule that is mechanically checkable from the tool call alone and expensive to
violate. Judgment never goes in a hook.

**Implementation notes:** plain shell, `jq` with a `python3` fallback, exit 2
with a message on deny. Without either interpreter the guards warn and allow,
so a machine without them degrades to the old instruction-only behavior rather
than blocking every write. Tested by piping fake calls: wrong path, right path,
relative path normalized, missing file, `Read` on `.pen`, `Read` on `.md`,
`cat` on `.pen`, `git add` on `.pen`, `jq` on `.json`.

---

## 2026-09-11 — Phase 10 exports the prototype out of pen.dev

**Decided:** handoff produces, before `design-spec.md`: one PNG per screen and
state variant under `design/screens/<flow>/`, each flow as `html-css`, the
design-system and brand regions as images, `design/tokens.json` in the W3C
Design Tokens format with every theme, and `design/tokens.css` with one block
per theme. Procedure in `references/handoff.md`.

**Why:** the `.pen` file is readable only through the MCP, so the prototype did
not exist for anyone without the editor open — an implementing agent in
another session, a stakeholder, the user on a phone, or the eval baselines.
"Navigable prototype" in the README meant a navigation map in a markdown table.
`Export` was verified on 09/09 and unused; `tokens.css` is what an implementer
actually drops into a project on day one.

**Format choices:** W3C DTCG for `tokens.json` because it is the one format
every token tool reads; themes go in `$extensions` because the spec has no
native theme axis and a file per theme splits what the canvas keeps together.
`tokens.css` uses `:root` for the default theme and `[data-theme="<name>"]`
for the others, names verbatim from the canvas.

**Left open:** whether `html-css` export honors `TextStyle.href`. If it does,
the navigation map can be made real — every "exits to" control gets an `href`
to its target's anchor — and the HTML becomes a clickable prototype. Marked TO
VERIFY in `pencil-mcp.md` and `handoff.md`; the Pencil server was disconnected
when this was written.

---

## 2026-09-11 — The direction fills a token inventory with fixed names

**Decided:** `design-direction.md` Step 3b lists the semantic roles every
chosen direction must fill — surfaces (page, raised, overlay, sunken, scrim),
text (primary, secondary, tertiary, on-accent, link), accent (base, hover,
pressed, subtle), borders (base, strong, focus), four semantic colors each with
text and surface, type families and weights and leading, the type scale with a
role map, the spacing scale with application rules, shape, depth, motion,
icons, and per-viewport layout. Names are fixed (`color-surface-raised`,
`space-2`, `font-body`). Phase 6 writes them verbatim; criterion 1.11 fails a
run missing one; a role the product does not need is marked `—` with a reason.

**Why:** "palette derived from a concept" said what a palette *is* and nothing
about *coverage*. The designer, forbidden to invent, stopped on every gap —
pressed accent, focus ring, warning surface, overlay surface — and each stop
was a change request, a decision, a propagation and a commit in the middle of
a screen. The gaps are the same every time, so the fix is to require them up
front. Fixed names are what let an incremental round, a different user, and
`tokens.css` find the same thing.

**Why this is not a design system imposed on the direction:** the inventory
names *roles*, not values, and says nothing about what a surface or an accent
looks like. A direction may add roles. It may not rename these.

---

## 2026-09-11 — Fonts must exist; iconography is the twelfth item

**Decided:** the type pairing names exact Google Fonts families and the weights
they ship, because pen.dev renders Google Fonts and nothing else unless font
files are supplied; a family that is not there falls back silently to a sans.
Criterion 3.24 checks that the rendered face is the declared one. And the
direction declares an **iconography system** — one library of the four the
schema offers, one weight, a size scale tied to the type scale, filled or
stroked — as item 11, audited as 3.25.

**Why:** both were invisible failures. A fallback font renders without error
and the screenshot the auditor judges shows the fallback — the audit passes a
serif direction rendering in a grotesque. Mixed icon libraries and sizes were
the most recognizable AI tell left uncaught after the type and the palette,
and no item of the direction owned them.

---

## 2026-09-11 — Component states, overlay placement, placeholder sweep

**Decided:** three smaller gaps closed together.

- **Component states (4.12).** Every interactive base component gets `default`,
  `hover`, `focus`, `pressed`, `disabled` as named variants in the design-system
  region; inputs add `error` and `filled`, buttons `loading`, options
  `selected`. The handoff template already listed these states; nothing built
  or audited them, so the implementer got a guess for every state but one.
  `focus` missing is an accessibility defect.
- **Variants and overlays in the screen's column (2.12).** Screens run left to
  right in one row; each screen's states and the overlays it opens stack below
  it at the same gap. An overlay is shown in context — screen, scrim, overlay
  instanced — named `<NN> <Screen> / <Overlay>`. Before this the placement of
  variants was "beside the screen", which each designer read differently, and
  a variant to the *right* of its screen reads as the next screen in the flow.
- **Placeholder sweep (2.11).** A frame still flagged `placeholder: true` at
  the end of a round is either unfinished work or a logo generation that never
  landed; nothing checked, so it reached handoff.

---

## 2026-09-11 — A run protocol: branch, `git add design/`, `run.md`

**Decided:** `references/run-protocol.md`. On the default branch, work on a new
`design/<date>` branch; on any other branch, stay. Commit only `design/` —
`git add design/`, never `-A`. Keep `design/run.md` (mode, request, language,
branch, canvas, targets, one row per phase with status and commit, the change
log by title, open findings) updated in every commit. Resume reads it first.

**Why:** ten commits landing on `main` without a review is intrusive, and a
pipeline that `git add -A`s sweeps the user's unrelated work into design
commits. Resuming depended on interpreting `git log`, which works until a
phase is redone or a change commit lands between phases; a table with status
per phase does not need interpreting, and it is also the summary the user
reads to see what a run that never asked them actually did.

---

## 2026-09-11 — The `designer` moves to opus, on a hypothesis the evals must test

**Decided:** `agents/designer.md` runs on `opus`, `effort: high`, like the
auditor and the brand designer.

**Why:** the sonnet assignment rested on "generation is execution once the
direction is decided". That undersold how much taste lives in execution —
spacing, type, composition, the difference between a screen that follows the
direction and one that *is* the direction — and it was the biggest quality
lever left after the process layer was closed. The cost is real: the designer
makes the most tool calls of any agent and runs one per flow in parallel.

**This is a hypothesis, not a result.** The Pencil server was disconnected when
it was made, so the evals did not run. The check is `evals/README.md` with the
baselines from the previous sonnet runs side by side. **Would change back if:**
the four cases show no visible difference in the exported screens, or the
audit's execution-failure count does not drop. It is a one-line revert.

---

## 2026-09-11 — Step 0 creates the canvas file; the user only opens it

**Decided:** when `design/prototype.pen` does not exist, the skill writes the
editor's own empty document — `{"version": "2.17", "children": [], "fileToken":
"<uuid>"}` — and asks the user only to open it.

**Why:** the "TO VERIFY: does a 0-byte file open" question from 09/10 was
answered sideways. `temp.pen`, the scratch canvas the editor itself created, is
that four-line JSON; writing the same content is not a guess about the format,
it is a copy of it. Halving the ask (open, not create-and-open) shortens the
one stop the pipeline makes. Opening stays the user's for the reason recorded
on 09/10: `code -r` can land in another window and trigger a trust prompt, and
neither is observable from here.

**Left marked TO VERIFY:** that the written file opens on the first try. If a
user reports it does not, the fallback is the old ask.

---

## 2026-09-11 — Permissions are a documented prerequisite

**Decided:** `docs/usage.md` carries a `.claude/settings.json` allowlist —
the Pencil tools, `git` under `design/`, writes to `design/`, the shell bits
the run protocol needs — and names auto mode as the alternative. The skill's
preconditions say so, and `run.md` records any prompt that did interrupt.

**Why:** a plugin cannot ship permissions, and a run that stops at the first
permission prompt is not the unattended run the whole design assumes. This was
the most likely failure for anyone installing the plugin cold, and nothing
mentioned it.

---

## 2026-09-19 — A writing reference, read by everything that writes

**Decided:** `references/writing.md` names the tells of generated prose (the
em dash as default connector, the staccato of short sentences, the "not X
but Y" reflex, triads, bolded lead-ins, inflated vocabulary) and says what
to do instead, for documents and for canvas copy alike. Every skill reads it
before writing; every agent file carries the pointer next to its language
instruction, and the prototype skill passes it in every prompt.

**Why:** the user read the pipeline's output and recognized it as
model-written before reading what it said. The plugin's own files use those
same devices heavily, because they are written for a model to follow, and a
model reproduces the style it reads; so the reference says explicitly that
the plugin is not a style sample. The pointer has to be in every agent file
for the same reason the language rule does: agents run isolated.

**What would change it:** a user naming a house style. The reference is the
default, not a rule over the user's preference.

---

## 2026-09-19 — Versions of a screen sit side by side in layout rows

**Decided:** one region per flow, not one per viewport. Inside it, one
column group per screen (a vertical layout frame), holding rows (horizontal
layout frames, `alignItems: "start"`); the base row holds every version of
the screen (viewports in Targets order, each followed by its theme copy),
and each state and each overlay gets its own row with every version side by
side. The theme check moved out of the Design System region: a
representative screen's dark copy is a linked `Copy` with `theme: {mode:
"dark"}` placed right after its source. Names gained `@ <Theme>` for theme
copies and `/ Group`, `/ Row — …` for the structural frames.

**Why:** the user wanted equivalent screens next to each other, aligned at
the top, whatever their heights. The previous structure (a region per
viewport, states below in a column) put a screen's mobile version in another
region entirely and left top alignment to arithmetic on `y`. A layout row
makes the alignment a property of the document instead of a check: the
tallest frame sets the row and everything starts at the same `y`. It also
turned three organization checks into structural ones and made a
single-viewport project and a three-version project the same shape.

**Verified:** `Entity.theme` exists on every node in `pen-schema.md`
(extension 0.6.71), and `Copy` of a reusable node yields a linked `ref`.
**Left TO VERIFY:** that the copy actually renders in the other theme in the
editor and in `Export`. The fallback (a plain `Copy` with the same override)
is written down in `canvas-structure.md`.

---

## 2026-09-19 — Two fewer subagent invocations per round

**Decided:** phases 5 and 6 are one designer task, in that order, with a
commit between; phase 9 is the audit's level 2 run once more after the last
fix, not a separate auditor invocation, and when nothing needed fixing the
first audit's level 2 stands. The phase numbers stay, because the rubric,
the run log and every commit message use them.

**Why:** the user asked for a lighter flow. Phase 5 is three empty frames;
handing them to a separate context bought an extra `get_app_state`, an
extra read of every reference, and nothing else, since what matters is the
order (grid before elements), which one task preserves. Phase 9 was
literally the rubric's level 2 with a screenshot; the auditor already runs
level 2 in phase 8. What was lost: nothing the evals should detect. What
would change it: an eval showing the sweep missing things when it is not a
dedicated task.

The same request cut the designer's file from 305 lines to 166 and the
prototype skill from 493 to 264, by replacing restated craft rules with
pointers to the references the agent reads anyway. `contributing.md` now
says the agent file names what to read and what it is judged on, and does
not restate it; the restated rules had already started drifting from the
originals.

---

## 2026-09-19 — Brand exploration is a skill, and discovery asks about it

**Decided:** `/prototypen:brand` runs the brand designer in candidate mode:
three candidates side by side in the Brand region (name in its type, a mark
generated per candidate, palette swatches, a specimen with the mark on light
and dark, a button and a line of text), one `AskUserQuestion` per round, one
refinement axis per round, at most three rounds, then the same
`design/brand.md` the pipeline would have written plus an Exploration
section. Discovery asks whether the brand exists, is to be explored, or the
pipeline decides, and records it in Targets; the pipeline's Step 0 mentions
a pending exploration in its one question.

**Why:** the user found that when nothing about the identity is decided, a
short refinement of the logo and base palette before the prototype pays
for itself; a brand invented unattended is only seen after every screen is
built on it. The seam test in `contributing.md` holds: this asks, the
pipeline does not, and asking here is cheap because only candidates exist.
It is a separate skill rather than a mode of `discover` because it needs the
canvas and the research, and `discover` deliberately touches neither.

**The one exception it creates:** three `Generate` calls in round 1, against
the "generate once" rule. They are three brands, not five copies of one; the
rule's reason (five generations drift apart) does not apply across
candidates.

---

## 2026-09-19 — Screen exports are not versioned

**Decided:** phase 10 writes `design/screens/.gitignore` (`*` and
`!.gitignore`) before exporting. The logo previews under
`design/brand/logo/preview/` stay versioned.

**Why:** the user's call: the exports exist to validate the prototype
without pen.dev, not as a record. They are binary, they change on every
handoff, and the canvas is the source; committing them bloated every
design commit. The `.gitignore` inside the folder keeps the rule
self-contained (no edit to the user's root `.gitignore`) and `git add
design/` keeps working. The eval baselines copy from disk, which still
works. The earlier "if the repository forbids binaries" clause went away
with it.

---

## 2026-09-19 — A landing page is decided at intake and structured by a study

**Decided:** discovery asks, for anything people sign up for or buy, whether
the landing page is in this round; intake decides when discovery did not
run. When it is, the spec carries a landing study
(`references/landing-page.md`: the visitor and where they come from, the
one action, the objections in order, the proof available, the section order
with what each section answers) and `Flow — Landing Page` joins the
inventory with its confirmation and submit-error screens. Research adds a
landing-page section; the designer of that flow reads the reference; the
rubric gained 4.13 (every section the study lists, in order, one primary
action).

**Why:** the user wanted the landing page planned and studied rather than
improvised. The generic landing page fails before the first pixel, on an
undecided visitor and an undecided action; a study written at intake is
what the direction and the audit can hold the page to. It is a reference
and a spec section rather than a phase because it changes what phases 1, 2
and 7 produce, not the sequence.

---

## 2026-09-19 — `finalize` and `roadmap` as skills, on a second seam

**Decided:** two skills that run once, after the rounds. `finalize`
consolidates `design/`: sweeps the canvas, removes unused components and
variables, folds amendments into the direction and the brand, drops the two
rejected directions to their rationale, reconciles the spec with what was
built, keeps only the latest audit, deletes `run.md`, refreshes the exports
and `design-spec.md`, and writes `design/README.md` as the entry point.
`roadmap` reads a finalized folder and writes `docs/roadmap.md` plus one
file per milestone, placing every screen version exactly once, with states
as acceptance criteria; it asks one question only when the spec does not
settle the milestone cut.

**Why:** the user asked for both. `contributing.md` said a third skill
needs a seam as real as asking-versus-deciding. These sit on a different
one: what is consumed and produced, and when. The pipeline optimizes for
recoverability while it runs (dated audits, a run log, appended amendments)
and cannot know the run is over; `finalize` is that decision, made once
across rounds. `roadmap` writes for a different audience in a different
place. Neither is a phase, because a phase runs inside one round.

**Deliberate limits:** `finalize` asks nothing and deletes only what git
holds; `roadmap` sequences without dates and never comments on the design.
The change-protocol rule against editing a decision in place still holds
during a run; `finalize` is the moment it stops applying, and the folded
history is listed so nothing is silently rewritten.

---

## 2026-09-20 — The first real project: what it cost, and six changes

**Context:** the first complete run of the plugin on a real product
(brasario, an RPG session tool: three surfaces, twelve areas, one user)
consumed a large part of a Claude Max quota over two `prototype` rounds and
two `finalize` runs. The delivered `design/` folder was read as evidence.
The numbers: 521 screens, of which 81 base; 303 states and 137 overlays,
each a full copy of its screen; 265 screens (51%) were the five generic
states (loading, error, empty, long list, long text) repeated per screen.
457 components, 113 tokens, 114 amendments, nine "system rounds", two full
propagations across twelve flows, three audit fix cycles, 524 PNGs exported
twice, a 521-row screen table typed by the model twice. Every agent on the
critical path ran on opus at high effort.

The six decisions below come from that reading. Each is recorded on its
own so it can be reverted alone.

### States are exemplars, not screens

**Decided:** the generic states are drawn once per screen archetype (list,
object, form, dashboard) as exemplars in `Design System / Section /
States`, and inherited. A screen gets a state row only for a **specific
state** the spec lists with a reason. Overlays are shown in context once
per product. The spec's state inventory becomes two tables (generic, by
archetype; specific, with reasons) plus a backlog. Rubric level 4 checks
the exemplars; sweep checks 15 and 16 fail a generic state drawn as a row
and an overlay shown twice.

**Why:** a `Loading` of "System settings" and a `Loading` of "Campaign
list" are one skeleton on two bases, and each cost a designer, a layout
review, an audit, an export and a spec row. The multiplier over base screens
was 6.4. The implementer needs the pattern, not the product of pattern and
screen.

**Would change if:** implementers report that the exemplar plus the
generic-state table is not enough to build a given screen's state. The fix
then is a specific-state row for that screen, which the protocol already
allows.

### Depth: `core` by default, `full` on request, flows by job, eight per round

**Decided:** the Targets table declares a depth. `core` draws the core loop,
the required secondary screens and the specific states, and lists the rest
under Backlog; `full` draws everything. Flows are the user's jobs, not the
product's areas; a round draws at most eight.

**Why:** twelve area-flows for a one-person product multiplied the shell,
the repeated overlays and the states. Nothing put a ceiling on the
inventory, and "deciding what screens exist is design work" was read as
"draw all of them".

### The component inventory is the orchestrator's, and designers may add

**Decided:** a phase 5 step where the skill walks the screen inventory
against the catalog and writes the component list into the direction. A
flow designer that still needs a component builds it from existing tokens
and reports it; the additions are ratified once per phase. Propagation
happens once, in one batch, only for components that changed shape. At most
two system rounds after phase 6.

**Why:** the cascade was the second largest cost: each flow discovered
components, each discovery was a formal amendment, each batch a system
round, each round a propagation reopening twelve opus contexts, and each
propagation surfaced new gaps. Nine rounds. The change protocol was
designed to stop quiet erosion of constraints; a missing chip is not a
constraint, and treating it as one cost more than the erosion would have.

### Models: designer back to sonnet; the audit split in two passes

**Decided:** `designer` on sonnet, medium effort. The audit is a structural
pass (levels 1, 2, 4, 5) delegated with `model: sonnet`, and a visual pass
(level 3) on opus over base screens, specific states and exemplars only.
Two fix cycles per screen instead of three. The layout reviewer covers base
screens and specific states. `usage.md` carries the table of who runs on
what and where to change it.

**Why:** the 2026-09-11 move to opus was recorded as a hypothesis the evals
would test; the evals never ran, and brasario is the first data. The
designer is the agent with the most tool calls, runs once per flow in
parallel and again on every propagation and fix; opus there dominated the
bill, and the audit's execution findings do not show the taste it was
supposed to buy. The structural levels are `Get` visitors and table
comparisons, which is not judgment. Third fix cycles resolved almost
nothing the second had not.

**Would change if:** exported screens from a sonnet designer look worse on
the eval cases, criterion by criterion. Revert is one line.

### A designer brief instead of six references

**Decided:** `designer-brief.md`, one file the designer reads, condensing
`screen-craft.md`, `layout.md`, `component-catalog.md`,
`canvas-structure.md` and the Pencil rules; the long files stay as the
source, consulted by section.

**Why:** every designer task loaded roughly 1,500 lines of reference plus
the schema plus three design documents before its first canvas call, per
flow, per propagation, per fix. Most of it is context the brief carries in
a tenth of the space.

### The handoff generates what the canvas already knows

**Decided:** the screen table in `design-spec.md` is printed by a snippet
and pasted; exports are skipped when `design/screens/.exported` names the
current canvas commit.

**Why:** 521 rows typed by the model, twice, and 524 PNGs exported twice
from an unchanged canvas.

---

## 2026-09-20 — Two ways to reach the canvas, asked once, with a default

**Decided:** every skill that writes to the canvas asks the user, first and
once, whether to run in **app mode** (the MCP, pen.dev open) or **headless**
(the pen.dev CLI, `scripts/pen-run.sh`). Headless is suggested for a full
`prototype` run; app mode for incremental rounds, `brand` and `finalize`.
In app mode `scripts/pen-save.sh` (the CLI in app mode, `save()`) runs
before every commit. In headless the runner refuses to write while the file
is the active editor of a running app, and every run ends with the notice
that the file must be closed and reopened to be seen.

**Why:** the user moved from the VS Code extension to the desktop app and
lost autosave: the desktop app saves an existing `.pen` only on Ctrl+S and
does not reload a file changed on disk (both verified on 2026-09-20; the
first shows in the brasario history as "canvas save pending" on most
commits). The MCP API has no save. The CLI has both a `save()` for an open
app and a headless mode with the same engine, so the same snippet produces
the same result either way; the two paths differ in who saves and whether
the user can watch, which is a choice the user should make, not the
plugin. Headless also removes the active-file check and the class of
"wrote into the wrong canvas" errors, at the price of no live view.

**Verified:** headless build, save and export of a full screen; the
desktop app showing a headless change only after close and reopen;
`save()` in app mode rewriting the file on disk with no pending marker in
the app. Not yet measured: the token difference between the modes on the
same flow; the estimate is 15–25% in favor of headless from what leaves
the context, and the eval to confirm it is the same flow both ways with
`/cost` compared.

**Would change if:** pen.dev ships autosave or file watching in the desktop
app; then the notice goes and the guard stays.

---

## 2026-09-21 — When `Generate` has no credits, the artwork is built by hand

**Decided:** `Generate` (`"svg"` for marks, `"ai"` and `"stock"` for
fills) is retried once after an empty result, and not at all after an error
naming credits, quota or a plan limit. After that the run stops calling it
and takes a manual path: marks from primitives (ellipse, rectangle,
polygon, a few hand-written paths) with a concept primitives can carry, the
five SVG files written by hand from the same primitives, photography as
the system's placeholder frame, one note in `run.md`, in `brand.md` and in
the report, and the items under open findings. The user is told, and can
regenerate later.

**Why:** the user reported that Pencil's SVG tool misbehaves when the
account runs out of credits. The rule against hand-drawn logos assumed
generation was always available; without a fallback, a run would either
loop on `Generate` or deliver empty frames, both worse than a plain
monogram that says what it is. The concept is constrained to what
primitives do well precisely because the original rule is right about
hand-built illustration.

---

## 2026-09-21 — Three checks that do not depend on the model's judgment

**Context:** the user's reading of the plugin's output after the first
project: documents and canvas copy that separate ideas with periods in a
way that reads as generated; screens with everything ranged left and top;
and adjustments to an existing prototype reported as done without being
checked, especially when a mid-tier model applied them.

**Decided, one per problem, each mechanical:**

1. **The period test and `scripts/prose-check.py`.** `writing.md` names the
   signal (three or more short sentences in a row in one paragraph) and the
   fix in order (one sentence with a connective, a list, a cut). The script
   flags that and the other tells (em dashes, fragments, the contrast
   reflex, bolded triads, inflated words) with a line per finding. Every
   skill runs it on every document before committing; the auditor runs it on
   every multi-sentence text node of the canvas (criterion 3.9, with the
   visitor that lists them). A period is not forbidden; a run of them is a
   finding.
2. **Alignment on both axes (`layout.md` §1b, criterion 3.26).** A table of
   cross-axis rules (icon beside one line of text is centered, label and
   control centered, title and actions on one line, two columns start at
   one `y`), a table of block cases (centered archetypes centered in a
   region with an explicit height, modal actions right, amounts right), and
   the reflex test: one visitor that prints every layout frame's alignment,
   with the rule that default alignment everywhere fails on anything but a
   plain list or form. The brief said "one strong left edge per screen" and
   nothing about the vertical axis; that sentence was part of the bias.
3. **`adjustment-verification.md`.** Every change to an existing prototype
   runs as: checks written from the request before the canvas is touched,
   snapshot before, change at the cause, snapshot after, diff read against
   the checks (the request is applied; nothing else moved), the mechanical
   pass and one screenshot, propagation, a report in a fixed shape with a
   PASS or FAIL per check. The orchestrator returns a report without the
   checks section. The snippets are in the file so the procedure needs no
   invention.

**Why mechanical:** the designer and the structural audit now run on
sonnet, and the user's observation was exactly that intermediate models do
not find these problems on their own. A rule a model has to notice is
worth less than a visitor that prints a number; each of the three turns a
judgment into a printed line.

---

## 2026-09-21 — A requested adjustment that conflicts with a rule is a question, not a decision

**Decided:** in adjustment mode (any request after a run reached
handoff), the request is compared with the five sources of existing rules
(direction, brand, spec, canvas structure, craft) before it becomes
checks. A conflict, or an ambiguity the checks cannot resolve, is a
question to the user with three choices: amend the rule and propagate,
apply as a named exception on that screen, keep the rule and reshape the
request. **Whoever finds it asks**: the orchestrator at the check, or the
designer while working, through a `QUESTION` block the orchestrator relays
verbatim and answers back to the same agent. Inside the autonomous run and
its fix cycles nobody asks; a designer reports `CONFLICT` and the change
protocol applies. The answer is recorded in `design/changes.md`.

**Why:** the user asked for it, and it closes a gap in the change
protocol: that protocol makes the orchestrator decide every change so an
unattended run never erodes its constraints, but once the run is over the
person is present, the request is theirs, and the agent applying it is the
one with the facts of the conflict in front of it; a relay keeps that
context instead of re-deriving it in the orchestrator. Applying it silently either breaks the
rule on one screen (the next audit fails it, the next designer copies it)
or overrides the user by refusing. Asking costs one question in a round
the user is already attending.

**Deliberate limit:** expected collateral (a shared header changes on every
screen that instances it) is not a conflict; it goes in the checks and the
report, not in the question.

---

## 2026-09-21 — First public release: `version` 0.1.0, LICENSE, README in English

**Decided:** `plugin.json` carries `"version": "0.1.0"`, bumped in the same
commit as any change a user would notice; the 2026-09-09 decision to omit
it is superseded, and `claude plugin validate .` now passes with no
warning. A `LICENSE` file (MIT, as the manifest already declared) is at the
root. The README is written in English, for use, and points at `docs/` for
everything else.

**Why:** publishing on GitHub is the moment the "when a real semver becomes
appropriate" clause of the old decision was waiting for: people other than
the author will install it and read a changelog. The README follows the
docs' language because a public plugin's first reader is more likely to
read English than Portuguese; the Portuguese presentation lives in git
history.
