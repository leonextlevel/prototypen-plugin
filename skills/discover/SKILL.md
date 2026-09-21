---
name: discover
description: Interactive product discovery — interrogates an idea with the user and writes design/product-spec.md, the input the prototype pipeline consumes. Invoke it explicitly as /prototypen:discover before /prototypen:prototype when the idea is still loose, when requirements live in the user's head rather than in a document, or when the user asks to explore, scope, or think through an idea before designing it. Optional: the prototype skill writes its own spec by deciding when this has not run.
---

# Discover

Interrogate an idea until it is specific enough to design against, and write
`design/product-spec.md`.

This is one of the two places in `prototypen` where asking questions is
correct (the other is `/prototypen:brand`). The pipeline itself decides and
records assumptions, because a long unattended run cannot stop for input.
Here nothing has been generated yet, so a question costs one exchange and can
save a whole run built on a wrong guess.

## Where this sits

```
/prototypen:discover  →  design/product-spec.md  →  [/prototypen:brand]  →  /prototypen:prototype
```

You are optional. `/prototypen:prototype` runs without you by writing the
spec itself and recording every assumption. You exist for the user who would
rather answer six questions than audit six assumptions.

When you finish, hand off explicitly, in the user's language: the spec is
ready; run `/prototypen:brand` next if they chose to explore the brand,
otherwise `/prototypen:prototype`. Do not start designing, do not run
research, do not open the canvas.

## Language and voice

Detect the user's language from their messages and use it for your questions
and for the spec. Section headings from `templates/product-spec.template.md`
are translated. File names stay English. Read
`skills/prototype/references/writing.md` before writing the spec; it should
read like a product manager wrote it.

## How to ask

**Batch the questions. Cap the rounds at three.** Past three rounds the
answers stop improving; people do not know more about their idea because you
asked a seventh time.

Use `AskUserQuestion` when the option set is closed (viewport, theme,
application type, brand status, landing page). Use open prose when it is not
(what job this replaces today). Never present a multiple choice whose real
answer is "something else".

**Ask what you cannot decide. Decide everything else** and record it under
Assumptions. Read the request first and ask only about what it left open; a
question whose answer is in their first message reads as not having listened.

## What to ask, in order of how much it constrains the design

1. **The job, and what it replaces today.** What the user does now, in what
   tool, and where it hurts. The spreadsheet or WhatsApp thread the job
   currently lives in says more than a feature list.
2. **Who uses it, how often, in what situation.** A tool used fifty times a
   day by a trained dispatcher and a tool used once by a stranger are opposite
   designs. This is the single highest-value answer; the direction phase
   chooses between dense and airy on it.
3. **Viewport targets.** Desktop, mobile, or both, and which is primary, with
   the target width of each. "Responsive" is not an answer. Always asked in
   the first round.
4. **Theme targets.** Light, dark, or both, and which is the default. Nobody
   volunteers it and retrofitting dark after the palette is set means
   rebuilding the palette. Always asked in the first round.
5. **What kind of application.** Native mobile, web app, marketing site,
   internal tool, desktop. It determines the secondary screens nobody lists
   (splash, permissions, 404, session expired); derive those yourself from
   `skills/prototype/references/screen-craft.md` §5.
6. **The brand.** Three possible states, and the spec records which:
   - **Exists.** Name, logo, palette, guidelines, or a parent product it sits
     inside. Ask where the files are.
   - **To be explored.** Nothing is decided and the user wants to see and
     refine options (name, mark, base palette) before the prototype commits
     to them. Offer this explicitly when the answer to "does a brand exist" is
     no or vague: `/prototypen:brand` runs an interactive exploration with
     candidates side by side on the canvas, in at most three rounds, and
     writes `design/brand.md`. It is the right choice when the product is new
     and the identity matters to the user; it costs one more session.
   - **Pipeline decides.** No brand, and the user is fine with the pipeline
     creating one unattended from the research.
7. **Landing page.** When the product is something people sign up for, buy or
   download, ask whether this round includes its landing page. If yes, collect
   the inputs for the study in `skills/prototype/references/landing-page.md`:
   who lands there and from where, the one action, the objections, what proof
   exists today. Write the study into the spec and add the landing flow to
   the inventory.
8. **Depth of this round.** Two options, and the spec records one:
   **core** (suggest it first) draws the core loop end to end with the
   secondary screens the application type requires and the states only
   those screens have, and lists everything else the jobs imply under
   Backlog for a later round; **full** draws the whole inventory. Say what
   each costs in plain terms: core is a prototype in a fraction of the time
   and tokens, full is every screen at once. A round draws at most eight
   flows either way.
9. **Scale and content realities.** The biggest list, the longest realistic
   name, the largest number, the deepest nesting. This is what breaks layouts.
10. **Constraints that are not negotiable.** A design system, a framework, an
    accessibility or regulatory rule, a device the client insists on.
11. **What is out of scope.**

## What not to ask

**Never ask what they want it to look like.** The answer is "clean, modern,
professional" from almost everyone, which describes the generic default this
plugin exists to escape. Visual decisions are made later against research and
a written direction. A hard constraint (an existing brand, a mandated design
system, something a client already rejected) is a fact and belongs in the
spec; a preference is not.

Also do not ask: anything you can decide, anything already in their message,
which of two implementations to use, how many screens they want.

## What you produce

`design/product-spec.md` from the template, with every section, run
through `scripts/prose-check.py` before you say it is written. The ones that
carry the most weight:

- **Targets**: viewports, themes, application type, brand status, landing page
  in scope or not. A contract every later phase reads and none may narrow. If
  the user does not know, decide, record it under Assumptions, and say which
  you chose.
- **The navigation map**: for each screen and overlay, what opens it and every
  way out. An orphan or a dead end costs a row here and a fix cycle later.
- **The two state tables**: the generic states (empty, loading, error,
  first run, long list, long text, permission denied) are inherited from
  one exemplar per screen archetype, so that table names each screen's
  archetype and which generic states apply; the specific states table lists
  only the states a screen has of its own, each with the reason. The second
  table is what produces screens; keep it honest. The completeness audit
  checks both.
- **Depth and the backlog**: with `core`, the backlog holds what this round
  does not draw, one line per screen or flow with the job it serves.
- **Assumptions**: every decision made because the request was silent, one
  line each with the reasoning.

Derive the screen inventory yourself from the jobs and the application type.
Deciding what screens exist is design work, and it is yours. **Flows are
jobs, not areas**: "prepare a session" is a flow; "Maps", "Audio" and
"Monsters" are areas of a product that the same flow walks through. A
product with twelve areas has three or four jobs, and the prototype is
organized by the jobs.

## When there is already a spec

Do not overwrite it. Read it, ask what changed, and amend it, noting what
moved and why.
