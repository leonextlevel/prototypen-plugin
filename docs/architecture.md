# Architecture

## The problem this shape solves

Ask a model to design something and it produces the statistical center of its
training data: Inter, `#3b82f6`, a white card with a soft shadow, a centered
hero. Not because it is bad at design, but because that is what the average of
everything looks like. Asking for creativity does not move it — "be bold"
produces the same output with different adjectives.

The only thing that reliably moves it is **constraint declared before
generation**, plus **judgment applied afterward by something that did not
generate it**. Every architectural decision here follows from those two
sentences.

## The pieces

```
skills/discover/SKILL.md         optional interactive intake — asks, writes the spec
skills/brand/SKILL.md            optional interactive brand exploration — asks, writes the brand
skills/prototype/SKILL.md        the process — what happens, in what order, and when to stop
  └── references/*.md            the detail — loaded per phase, not up front
skills/finalize/SKILL.md         after the last round — consolidates design/, writes its README
skills/roadmap/SKILL.md          after finalize — the business roadmap under docs/
agents/*.md                      five executors, each in its own context
hooks/                           two guards that make the two most dangerous rules mechanical
templates/*.md                   the shape of every artifact the skills write
```

### Five skills, split on two seams

The first seam is **whether a question is worth its cost.** In `discover` and
`brand`, nothing has been generated yet, or only candidates have; a question
costs one exchange and can redirect an entire run, so asking is the
highest-leverage thing available. In `prototype`, generation is underway and
the target is a long unattended run; a question costs the run its autonomy,
so the rule inverts to decide-and-record. Putting both behaviors in one skill
would mean one body carrying two contradictory instructions about questions.

The second seam is **what the skill consumes and produces.** `prototype`
consumes a spec and produces a canvas plus its documents. `finalize` consumes
that output after the last round and produces a consolidated folder; it makes
one decision the pipeline cannot, which is that the run is over and the
recoverability scaffolding (dated audits, a run log, amendments appended
rather than applied) can go. `roadmap` consumes the finalized folder and
produces a document for a different audience, the people deciding what to
build, in a different place, `docs/`. Neither is a phase: a phase runs inside
one round, and both of these run once across all rounds.

Every interactive skill is **optional**. `prototype` writes its own spec when
`discover` has not run and its own brand when `brand` has not, so the
unattended property holds either way. They are skills rather than
`commands/` because plugin skills are already invocable as
`/prototypen:<name>`. See `decisions.md`.

### The prototype skill

`skills/prototype/SKILL.md` is the orchestrator. It holds mode detection, the
phase sequence, the delegation map, the commit rule, the attempt limit, and the
language and voice rules — and nothing else. It is deliberately kept under
300 lines, because a skill body is loaded whenever the skill triggers, and a
body that grows past skimming length stops being read carefully and starts
being read partially. What an agent needs to know lives in that agent's file
and the references it reads; the skill body says what to put in the prompt,
not how to draw.

**It decides:** whether this is a bootstrap or an incremental run, whether the
brand phase applies, which agent runs when, when to commit, and when to stop
trying.

### The references

Fourteen files under `skills/prototype/references/`, each loaded only by the
phase that needs it, and shared by the other four skills. This is what keeps the skill body short without losing
detail: `design-direction.md` is 200 lines of specification that matters
intensely for one phase and not at all for the other nine.

| File | Decides |
|---|---|
| `writing.md` | the voice of everything the plugin writes, documents and canvas copy alike |
| `brand.md` | when the brand phase runs, what a brand must define, the logo variants |
| `design-direction.md` | the divergence axes, the twelve things a direction declares, the token inventory it must fill, how to choose |
| `anti-generic.md` | what is banned, and the boundary between visual and interaction |
| `screen-craft.md` | the craft baseline — navigation, targets, hierarchy, secondary screens, content, and the per-screen self-review |
| `layout.md` | arrangement — composition intent per archetype, space, spacing, alignment, distribution, and the numeric method |
| `change-protocol.md` | who may raise a change, who decides, the three kinds, propagation, the log |
| `component-catalog.md` | the repertoire by job — which component for which behavior, the screen-vs-overlay decision, the destructive-action rule, the forgotten actions |
| `landing-page.md` | the study a landing page is built from: visitor, one action, objections, proof, section order |
| `canvas-structure.md` | how the Pencil document is organized: regions, groups, rows, versions side by side; and the sweep |
| `audit-rubric.md` | every pass/fail criterion, at five levels |
| `handoff.md` | what phase 10 exports so the prototype exists outside pen.dev — PNGs, HTML, `tokens.json`, `tokens.css` |
| `run-protocol.md` | the branch, the commits, `design/run.md`, resuming, rollback |
| `pencil-mcp.md` | the verified Pencil API and its failure modes |

### The hooks

Two `PreToolUse` guards in `hooks/`. They exist because the two rules that
matter most were, until now, only text: *every Pencil write targets
`design/prototype.pen`* and *nothing reads a `.pen` outside the MCP*. The first
guards against a verified property of the tool — `execute` on a path that does
not exist silently writes into whatever canvas is active — and the second
against flooding a context with a document that is only meaningful through
`Get`. Both were stated in five files each and depended on the model reading
them; a hook does not. The path guard cannot see the *active* editor, so the
`get_app_state` check remains in the skill — the hook covers the half it can
see, and the instruction covers the other half.

The rule for adding a hook is the same as for adding an agent, inverted: a hook
is justified when a rule is **mechanically checkable from the tool call alone**
and its violation is expensive. Judgment does not go in a hook.

### Why there are two opposite reference files

`anti-generic.md` and `screen-craft.md` pull in opposite directions on purpose,
and together they define the shape of an acceptable design.

`anti-generic.md` is a **ban list**: it says what not to reach for, and it exists
because the model's defaults are the category average. `screen-craft.md` is a
**baseline**: it says what every competent product designer does without being
asked, and it exists because a model told only "be original" will happily break
things that should not be broken.

The line between them is the same one `anti-generic.md` draws internally:
originality belongs to the palette, the type, the surface treatment and the
composition; convention belongs to where things are and how they behave. Ignoring
the first file produces a generic design; ignoring the second produces a design
that is different and worse.

`screen-craft.md` is also the plugin's main lever on **audit throughput**. Every
rule in it has a matching criterion in `audit-rubric.md` (3.12–3.16, 4.10), and
the designer reads it before drawing rather than meeting it for the first time in
a finding. A standard handed over up front is far cheaper than the same standard
discovered through two fix cycles.

### Why a fifth agent, when the rule says "rubric line, not subagent"

The rule in `contributing.md` is that a generic design which got past the audit
becomes a criterion, not an agent. The `layout-reviewer` is not an exception to
that rule; it is what the rule was always meant to protect — and stating the
rule more precisely shows why.

A new agent is justified when it has a **different input and a different
question**, not merely a different failure mode. The four original agents split
on exactly that: the researcher's input is the world and its question is what
is true; the brand designer's input is the occupied territory and its question
is where to stand; the designer's input is the direction and its question is
how to realize it; the auditor's input is the direction plus the screen and its
question is whether they match.

The layout reviewer's input is **geometry plus the screen's composition
intent**, and its question is **whether the arrangement does what it claims** —
centered means centered, one edge means one edge, equal means equal. It needs
no direction file beyond two items, no brand, no ban list. It is cheap
(sonnet), narrow, and numeric first. Folding that into the auditor would put a
3px partial-alignment check inside a 45-criterion opus judgment pass, where it
was in fact getting lost — the observed failure that prompted the agent.

By contrast, *splitting the designer* into a system-builder and a screen-builder
would not pass the test: same input (direction and tokens), same question (how
to realize it on the canvas). It would add a handoff and no judgment.

### Three review tiers, and why the cheap ones do not undermine the isolated one

The plugin's central claim is that an agent cannot judge its own work in the
same context — so it may look inconsistent that the `designer` now reviews
every screen before reporting it. It is not, because the two reviews answer
different questions.

The **self-review** (section 7 of `screen-craft.md`) is mechanical: a `Get`
visitor for clipping, missing fills, color literals, near-miss alignment and
overlap, then one screenshot read for crowding, edge contact, wrong color,
contrast and text problems. None of that requires taste, and none of it is
subject to the self-justification problem — an agent that placed a card can
still see that it overlaps the next one. Two passes, then report, naming what
is still open.

The **audit** (phase 8, isolated context) is judgment: does this match the
direction's personality sentence, is the committed choice visible, is the
hierarchy right. That is exactly what the generating context cannot assess.

Between them sits the **layout review** (phase 7b, `layout-reviewer`, fresh
context, sonnet): composition intent stated per screen, checked by bounds, fixed
where the fix is geometric, escalated where it is not. It catches what the
self-review misses because it is not in the generating context, and what the
audit would waste attention on because it is beneath the audit's question.

The reason to have all three is the attempt limit. Each screen gets three visual fix
cycles in the audit; spending one of them on a 3px misalignment is a waste of
the scarce resource. The self-review exists so that the auditor's findings are
about things only an auditor could find. The auditor is told to flag anything
mechanical the self-review missed as "not caught by self-review" — a process
signal that tightens the procedure rather than a reason to soften the verdict.

### The agents

Five subagents, each in an isolated context with a scoped toolset.

| Agent | Model | Decides | Cannot |
|---|---|---|---|
| `researcher` | sonnet | what is true about the domain and what territory is taken | have aesthetic opinions |
| `brand-designer` | opus, high effort | name, positioning, tone, archetype, palette, logo | design screens |
| `designer` | sonnet, medium effort | how to realize a decided direction on the canvas; which component a screen needs that the system lacks | write files, invent tokens |
| `layout-reviewer` | sonnet | whether the arrangement does what it claims — alignment, distribution, space — by geometry | judge design; touch color, type, copy, structure |
| `auditor` | opus for the visual pass; sonnet (override) for the structural pass | PASS or FAIL, against the rubric, with every FAIL classified | fix anything |

Two of these constraints are load-bearing rather than tidy:

**The designer cannot write files.** Its `disallowedTools` blocks `Write` and
`Edit`. This is not about safety — it is about a specific failure. An agent that
needs a token the direction file does not define, and that *can* edit the
direction file, will add the token and continue. The run succeeds and the
constraint quietly stops being a constraint. Blocked from writing, it has one
option: stop and report. That report is the most valuable thing it produces,
because it is the only signal that the direction file is incomplete.

**The auditor never fixes anything.** An agent that can fix what it finds
gravitates toward finding what it can easily fix. Separating the verdict from
the repair keeps the verdict honest.

### The voice

`references/writing.md` is read by every skill and every writing agent. It
exists because generated prose has tells (the em dash as a connector, the
staccato of short sentences, the "not X but Y" reflex, inflated vocabulary)
and readers notice them before they notice the content. The rule applies to
every document and to the copy on the canvas; the plugin's own files are
explicitly not a style sample, since they are written for a model to follow
and lean on the same devices.

### The templates

`templates/` holds the empty skeleton of every artifact, with a line under each
heading saying what belongs there. They are written in English and their
headings are translated at instantiation time (see below).

Their real function is completeness. A template with a "What the brand is NOT"
heading and an "Assumptions" heading gets those sections written; a free-form
instruction to "write a brand document" does not.

## Why the audit runs in an isolated context

This is the single most important structural decision in the plugin.

An agent that reviews its own output in the same context has already justified
every choice to itself, once, while making it. Asked to evaluate that work, it
does not re-derive the judgment — it retrieves the justification. The reasoning
that produced the design is sitting right there in the context window, and it is
persuasive, because it was persuasive enough to act on. Self-review in-context
reliably returns "looks good", and it returns it faster and more confidently
than an honest review would.

A fresh context has none of that. It has the artifact, the rubric, and the
constraint files. It never heard the argument for why the spacing is 14px, so
14px is either on the scale or it is not.

The same logic sets the model split: generation is execution, so `designer`
runs on sonnet and the expensive model is spent on judgment. The designer was
moved to opus on 2026-09-11 on the hypothesis that taste lives in execution
too, and moved back on 2026-09-20 when the first real project showed the
cost of that hypothesis (the designer makes the most tool calls, runs once
per flow in parallel and again on every fix) and no evidence for it in the
audit's findings (`decisions.md`, both dates). The auditor's structural
levels, which are mechanical, run on sonnet too; only its visual pass, and
`brand-designer`, stay on opus, for the original reason: judgment, and
irreversible naming, are where a run succeeds or fails.

## Why constraint is declared before generation

The pipeline front-loads three phases that produce no visible output:
research, brand, and direction. This is deliberate, and it is where most of the
value is.

Each one narrows what the next can do. Research says what the category already
occupies. Brand takes a position against that. Direction commits to a visual
specification within the brand. By the time any pixel exists, the space of
acceptable designs is small enough that the generic default is outside it.

This also makes auditing possible at all. "Is this design good?" is not a
question with a checkable answer. "Does this match the personality sentence in
`design-direction.md`, and is the committed choice visible?" is. **The audit is
only as good as the constraint it audits against** — which is why a vague
direction file is a worse failure than a bad one.

## The language split

The plugin is written in English. What it produces follows the user.

The split runs along a specific line: **prose and content follow the user;
identifiers stay English.** Artifact filenames, canvas node names, region names,
component names, and token names are English always, so they stay stable across
rounds and across whoever is running the plugin — a `Get` visitor looking for
`Design System` must find it regardless of who ran the previous round. Everything
a human reads as language — the documents, the audit reports, and every label,
heading, and piece of microcopy inside the prototype — is in the user's
language.

Because subagents run in isolated contexts and never see the user's original
message, the language instruction lives in **every** agent file, and the
orchestrating skill states the detected language explicitly in each delegation
prompt. Without both halves, the auditor hands a Portuguese-speaking user an
English report.

## Changes during the run

Constraints declared up front have to be **correctable without being eroded**.
`references/change-protocol.md` draws that line: agents raise, only the
orchestrating skill decides; three kinds (add a missing definition, amend a
direction decision, extend the scope); the original decision is never edited in
place — amendments go in a dated section at the end of the file; the same area
amended twice in one round means the phase-4 decision was wrong and the fix is
`git reset`, not a third patch; and every decision is logged in
`design/changes.md` so the user can review, disagree with, and revert one
decision at a time after a run that never stopped to ask.

The auditor's failure classification is what feeds it: `execution` goes back to
the designer, `direction` and `spec` go to the orchestrator. The classification
exists because a direction failure sent to the designer as an execution failure
burns two fix cycles on a constraint that cannot be satisfied.

## What is deliberately absent

- **No `commands/`.** Legacy format; skills are the current one.
- **No approval gates.** The pipeline targets a long unattended run. The audit
  phases are the quality control, not the user's attention.
- **No `CLAUDE.md` at the plugin root.** It would not be loaded as project
  context anyway. Instructions that need to reach the model go in the skill.
- **No `.mcp.json`.** See `decisions.md`.
- **No hook that judges.** The two hooks check paths. A hook that tried to
  check design quality would be the auditor with no context.
