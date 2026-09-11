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
