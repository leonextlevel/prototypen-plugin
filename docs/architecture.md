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
skills/discover/SKILL.md         optional interactive intake — the only step that asks
skills/prototype/SKILL.md        the process — what happens, in what order, and when to stop
  └── references/*.md            the detail — loaded per phase, not up front
agents/*.md                      four executors, each in its own context
templates/*.md                   the shape of every artifact the pipeline writes
```

### Two skills, split on whether asking is allowed

`discover` and `prototype` are separated along a real seam: **whether a question
is worth its cost.**

In `discover`, nothing has been generated yet. A question costs one exchange and
can redirect an entire run, so asking is the highest-leverage thing available.
In `prototype`, generation is underway and the target is a long unattended run;
a question costs the run its autonomy, so the rule inverts to decide-and-record.

Putting both behaviors in one skill would mean a single body carrying two
contradictory instructions about questions, with the model choosing which to
follow. Splitting them makes each one unambiguous, and makes the interactive part
**optional** — `prototype` writes its own spec when `discover` has not run, so
the pipeline keeps its unattended property either way. `discover` is not a gate;
it is an alternative source for one artifact.

They are skills rather than `commands/` because plugin skills are already
invocable as `/prototypen:discover` and `/prototypen:prototype`, so the command
ergonomics come free without the legacy format. See `decisions.md`.

### The prototype skill

`skills/prototype/SKILL.md` is the orchestrator. It holds mode detection, the
phase sequence, the delegation map, the commit rule, the attempt limit, and the
language rule — and nothing else. It is deliberately kept under 500 lines,
because a skill body is loaded whenever the skill triggers, and a body that
grows past skimming length stops being read carefully and starts being read
partially.

**It decides:** whether this is a bootstrap or an incremental run, whether the
brand phase applies, which agent runs when, when to commit, and when to stop
trying.

### The references

Six files under `skills/prototype/references/`, each loaded only by the phase
that needs it. This is what keeps the skill body short without losing detail:
`design-direction.md` is 100+ lines of specification that matters intensely for
one phase and not at all for the other nine.

| File | Decides |
|---|---|
| `brand.md` | when the brand phase runs, what a brand must define, the logo variants |
| `design-direction.md` | the divergence axes, what a direction must declare, how to choose |
| `anti-generic.md` | what is banned, and the boundary between visual and interaction |
| `canvas-structure.md` | how the Pencil document is organized and audited |
| `audit-rubric.md` | every pass/fail criterion, at four levels |
| `pencil-mcp.md` | the verified Pencil API and its failure modes |

### The agents

Four subagents, each in an isolated context with a scoped toolset.

| Agent | Model | Decides | Cannot |
|---|---|---|---|
| `researcher` | sonnet | what is true about the domain and what territory is taken | have aesthetic opinions |
| `brand-designer` | opus, high effort | name, positioning, tone, archetype, palette, logo | design screens |
| `designer` | sonnet | how to realize a decided direction on the canvas | write files, invent tokens |
| `auditor` | opus, high effort | PASS or FAIL, against the rubric | fix anything |

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

The same logic sets the model split. Generation is largely execution once the
direction is decided — `designer` runs on sonnet. Judgment is where the run
actually succeeds or fails, so `auditor` runs on opus at high effort. The
expensive model is spent on deciding whether the work is good, not on producing
more of it. `brand-designer` gets the same treatment for the same reason: naming
and positioning are irreversible decisions that everything downstream inherits.

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

## What is deliberately absent

- **No `commands/`.** Legacy format; skills are the current one.
- **No approval gates.** The pipeline targets a long unattended run. The audit
  phases are the quality control, not the user's attention.
- **No `CLAUDE.md` at the plugin root.** It would not be loaded as project
  context anyway. Instructions that need to reach the model go in the skill.
- **No `.mcp.json`.** See `decisions.md`.
