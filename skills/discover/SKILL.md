---
name: discover
description: Interactive product discovery — interrogates an idea with the user and writes design/product-spec.md, the input the prototype pipeline consumes. Invoke it explicitly as /prototypen:discover before /prototypen:prototype when the idea is still loose, when requirements live in the user's head rather than in a document, or when the user asks to explore, scope, or think through an idea before designing it. Optional: the prototype skill writes its own spec by deciding when this has not run.
---

# Discover

Interrogate an idea until it is specific enough to design against, and write
`design/product-spec.md`.

This is the **one place in `prototypen` where asking questions is correct.**
Everywhere else the pipeline decides and records the assumption, because a long
unattended run cannot stop for input. Here the cost is inverted: nothing has
been generated yet, so a question costs one exchange and saves an entire run
built on a wrong guess.

## Relationship to the pipeline

```
/prototypen:discover  →  design/product-spec.md  →  /prototypen:prototype
                                                    (skips its own intake)
```

You are **optional and additive, not a gate.** `/prototypen:prototype` runs
perfectly well without you — it writes the spec itself by deciding and recording
assumptions. You exist for when the user would rather answer six questions than
audit six assumptions afterward.

When you finish, say so and hand off explicitly:

> `design/product-spec.md` está pronto. Rode `/prototypen:prototype` para começar
> o design. *(in the user's language)*

Do not start designing. Do not run research. Do not open the canvas. You produce
one document and stop.

## Language

Detect the user's language from their messages and use it — for your questions
and for `design/product-spec.md`. Section headings from
`templates/product-spec.template.md` are translated, not copied in English. File
names stay English.

## How to interrogate

**Batch the questions. Cap the rounds at three.** Discovery that turns into an
interview loses the user, and past three rounds the answers stop improving —
people do not know more about their idea because you asked a seventh time.

Use `AskUserQuestion` when the option set is genuinely closed — **viewport
targets, theme targets**, primary device, whether a brand exists. Use open prose
when it is not (what job this replaces today). Never present a multiple choice
whose real answer is "something else entirely."

**Viewport and theme are asked in the first round, always**, even when the user
gave a detailed brief. They are cheap to ask, nobody volunteers them, and both
are expensive to change after the direction phase has committed to a palette and
a density.

**Ask what you cannot decide. Decide everything else.** If the answer is
derivable from the domain, from the request, or from a sensible default, derive
it and record it under Assumptions — do not spend a question on it. The user's
attention is the scarce resource here, not your tokens.

**Start from what they gave you.** Read the request first and ask only about
what it left genuinely open. A question whose answer is already in their first
message reads as not having listened.

## What to ask about

Ordered by how much the answer constrains the design. If you only get one round,
ask from the top.

1. **The job, and what it replaces today.** Not "what should the app do" — what
   does the user do now, in what tool, and where does it hurt? The spreadsheet
   or WhatsApp thread the job currently lives in tells you more than a feature
   list.
2. **Who uses it, how often, and in what situation.** A tool used fifty times a
   day by a trained dispatcher and a tool used once by a stranger are opposite
   designs. Frequency and expertise decide density; context of use (one-handed
   on a train, a 30-inch monitor, bright sunlight, a shared screen) decides
   nearly everything else. **This is the single highest-value answer you can
   collect** — the direction phase chooses between dense and airy on exactly
   this, and without it that choice defaults.
3. **Viewport targets — mandatory, never assumed.** Desktop, mobile, or both,
   and if both, **which is primary**. "Responsive" is not an answer: it says the
   layout adapts, not what it was designed for. A dense desktop table and a
   mobile card list are two designs, not one design at two widths, and deciding
   that later means redoing the direction. Also collect the target width for
   each: a desktop app for a 30-inch monitor is not a desktop app for a 13-inch
   laptop.

4. **Theme targets — mandatory, never assumed.** Light, dark, or both, and if
   both, **which is the default**. Ask it plainly; almost nobody volunteers it,
   and retrofitting dark mode after the palette is set means rebuilding the
   palette. A palette that works in light frequently fails contrast in dark, so
   this decision has to reach the direction phase before any color is chosen.

   Both of these go into `design/product-spec.md` under **Targets**, and every
   later phase is bound by them: the direction declares a palette per theme, the
   tokens are themed variables, the canvas carries a screen set per viewport, and
   the audit checks contrast in every declared theme. Nothing downstream may
   quietly narrow this list.

5. **What kind of application this is** — native mobile app, web app, marketing
   site, internal tool, desktop app. It determines a whole class of screens
   nobody lists as features and everybody expects: a mobile app needs a splash
   and a permission flow, a web app needs 404 and session-expired, a marketing
   site needs a form confirmation. Derive these yourself from the answer — do not
   ask the user to list them. The catalog is in
   `skills/prototype/references/screen-craft.md`.

6. **Whether a brand already exists.** Name, logo, palette, guidelines, or a
   parent product it must sit inside. This determines whether the pipeline's
   brand phase runs at all, and an existing brand discovered halfway through
   invalidates the design direction. **Always ask this.** If one exists, ask
   where the files are.
7. **Scale and content realities.** How many items in the biggest list, the
   longest realistic name, the largest number, the deepest nesting. This is what
   breaks layouts, and users know it and never volunteer it.
8. **Constraints that are not negotiable.** An existing design system, a
   framework, an accessibility requirement, a regulatory rule, a device the
   client insists on.
9. **What is explicitly out of scope**, so nothing is audited later for a
   missing thing that was never intended.

## What NOT to ask

**Never ask the user what they want it to look like.**

Asked directly, people say "clean, modern, professional, minimalist" — which is
a description of the generic default this entire plugin exists to escape. It is
not that users have bad taste; it is that the question has no good answer in the
abstract, so everyone reaches for the same four adjectives.

Visual decisions are made in the pipeline, against evidence: research maps what
the category already looks like, the brand takes a position against it, and the
direction phase commits to a specification. **Your job is to collect the job,
not the taste.** A precise answer to "who uses this and how often" constrains
the visual outcome far more than any aesthetic preference the user could state.

The exception is a **hard constraint**, not a preference: an existing brand, a
mandated design system, a client who has already rejected something specific.
Those are facts, and they belong in the spec.

Also do not ask: anything you can decide, anything already in their message,
which of two implementations to use, or how many screens they want.

## What you produce

`design/product-spec.md`, from `templates/product-spec.template.md`, with all of
its sections: summary, **targets**, personas, jobs to be done, core loop, screen
inventory, **state inventory**, content realities, out of scope, and assumptions.

Three of those carry more weight than the rest:

- **Targets** — the viewports and themes, stated as a decided list with a primary
  named for each. This section is a contract: every later phase reads it and none
  may narrow it. If the user genuinely does not know, decide, write the decision
  under Assumptions, and say which one you chose — an unstated target becomes an
  unbuilt screen set.

- **The state inventory** — for every screen, which of empty / loading / error /
  first run / long list / long text / permission denied apply, and what each
  shows. Phase 8's completeness audit checks against this table. A state missing
  here is a state nobody will ever notice is missing from the canvas.
- **Assumptions** — every decision you made because the request was silent and
  you judged it not worth a question. One line each, with the reasoning. This is
  where the user checks whether you guessed wrong, and it is cheaper to read
  than to answer.

Derive the screen inventory yourself from the jobs **and from the application
type** — the flows the jobs imply, plus the secondary screens the platform
requires (splash, first run, permission request and denied, offline, 404,
session expired, form confirmation, as applicable). Do not ask the user to list
screens: deciding what screens exist is design work, and it is yours.

## When there is already a spec

If `design/product-spec.md` exists, do not overwrite it. Read it, ask what
changed, and amend it — noting what moved and why. A spec that gets silently
replaced takes the audit trail with it.
