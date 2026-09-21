# Evals

## Why this exists

The failure mode of a skill like this one is tuning to the last case. Someone
runs the pipeline on a dashboard, the density comes out wrong, a line gets added
to `SKILL.md` pushing toward tighter spacing — and the next landing page comes
out cramped. The change looked like a fix because only one case was in view.

These reference ideas exist to keep more than one case in view. **Run all of
them after any significant change to `SKILL.md`, to a reference file, or to an
agent prompt.** Not after a typo fix; after anything that changes behavior.

There is no automated harness here. These are prompts you run by hand and read
the output of, which is appropriate — what is being evaluated is a design, and
the failure modes are visual and structural. The value is in running the *same*
set every time, not in automating it.

## How to run one

1. Start from a **clean project directory** with no `design/`. Answer the
   access-mode question with **headless** unless the case is about app mode;
   it removes the editor from the variables. Bootstrap mode is what most
   changes affect.
2. Give the prompt verbatim. Do not help, do not clarify, do not answer
   questions the pipeline should have decided for itself — the target is an
   unattended run.
3. Let it run to handoff.
4. Check the observations below, plus the general checks — from the exported
   `design/screens/*.png`, which is what a reader without pen.dev sees.
5. Copy `design/screens/` (unversioned in the project, present on disk),
   `design/tokens.json`, `design/design-direction.md` and the audit into
   `evals/baselines/<case>/<date>/` (see `baselines/README.md`). The next
   change gets diffed against it.
6. To exercise incremental mode, run a follow-up in the same directory: *"add a
   settings screen"*. Then check that it did not redefine tokens, did not
   duplicate components, and did not redesign anything it was not asked about.

## General checks, every case

- **Would a designer recognize this as generic?** Open the screenshot cold and
  look for the ban list: Inter, `#3b82f6`, the purple gradient, the white card
  with a soft shadow, the centered hero with two CTAs, the pastel circle icon.
- **Is the committed choice visible?** The direction file names one non-neutral
  decision. Can you see it in the screenshot and describe it?
- **Are the three directions genuinely distinct**, or one direction at three
  saturations?
- **Is the canvas organized?** Open the `.pen` file cold. Do the region names
  tell you what is where, without a screenshot?
- **Is every artifact in the user's language**, including canvas microcopy, with
  file names and node names still in English?
- **Did the audit find real things?** An audit report with no FAILs on a first
  run means the rubric is not biting, not that the work was perfect.
- **Did it run unattended**, without stopping to ask — and without a permission
  prompt?
- **Is the type what the direction declared?** Open a PNG next to the
  direction's type pairing. A serif direction rendering in a sans means the
  family is not on Google Fonts and criterion 3.24 did not bite.
- **Is the icon set one system?** One library, one weight, the declared sizes.
- **Does every interactive component have its states** in the design-system
  export — hover, focus, pressed, disabled, and error for inputs?
- **Did the token inventory come out complete?** `tokens.json` has every
  required role from `design-direction.md` Step 3b, with a value per theme.
- **Do the exports exist and read cleanly?** `design/screens/<flow>/` has one
  PNG per screen version and state, named by the screen; `tokens.css` drops
  into a project as-is; `design/screens/` is not in `git status`.
- **Are the versions side by side?** Open the document screenshot: for a
  two-viewport or two-theme case, each screen's versions sit in one row,
  top-aligned, and its states in the rows below. A version floating at its
  own `y` means the row structure was not used.
- **Does the prose read as written by a person?** Open `product-spec.md` and
  the audit. Count em dashes per page, look for "not X, it is Y", for three
  short sentences in a row. Then the canvas copy: a button that reads like a
  paragraph, an exclamation mark, an "Oops".

## The reference ideas

### 1. Dense data application
> A tool for a small logistics company to track shipments: a list of every
> active shipment with its status, carrier, cost, and ETA; a detail view per
> shipment with its event history; and a weekly cost report. Used all day by
> three dispatchers on desktop.

**Watch for:** density that actually serves the job — a dispatcher scanning
sixty rows needs information per pixel, not whitespace. Table structure that
survives long carrier names and eight-digit numbers. Whether the empty and
long-list states were built. Whether the direction phase resisted the airy
default that looks better in a screenshot and worse at work. Whether the "hero"
reflex leaked into a tool that has no hero.

### 2. Landing page
> A single marketing page for a hardware product: a machine that roasts coffee
> at home. It needs to explain what it is, show it, justify the price, and get
> the visitor onto a waitlist.

**Watch for:** the centered-hero-with-two-CTAs reflex, and the three-identical-
feature-cards row right below it. Whether the type has any real contrast or is
one family at three weights. Whether the imagery is `Generate`d appropriately as
fills rather than hand-drawn or omitted. Whether it commits to a register at
all — a landing page with no point of view is the clearest signal the direction
phase went through the motions.

### 3. Mobile onboarding flow
> A mobile app for tracking a course of medication. Design the onboarding: first
> launch, adding the first medication, setting reminder times, granting
> notification permission, and the first home screen with nothing in it yet.

**Watch for:** touch target sizes (44pt), one-handed reach, and permission
denied — that state is explicitly in the flow and is the one most often skipped.
Whether the empty home screen offers a way forward or just says "no data".
Whether the interaction conventions of mobile survived the anti-generic pass:
back navigation where it belongs, the primary action where a thumb is. This case
is the sharpest test of the "ban list restricts visual, never interaction"
boundary.

### 2b. Landing page from discovery
Run `/prototypen:discover` for case 2 and answer that the landing page is in
scope, then run the pipeline.

**Watch for:** the landing study in the spec (visitor, one action, objections
in order, proof available, section order) and whether the built page follows
it section by section with one action label repeated. Whether the
confirmation and submit-error screens exist. Whether research added the
landing-page section.

### 3b. Brand exploration
Run `/prototypen:discover` for case 3, answer that the brand is to be
explored, then `/prototypen:brand`.

**Watch for:** three candidates that are actually different positions, not
one mark in three colors; the candidates side by side and top-aligned in the
Brand region; the specimen (mark on light and dark, a button, a line of
text) present per candidate; one axis per refinement round; the canvas clean
of `Brand Candidate` boxes at the end; the Exploration section in
`brand.md`; and the pipeline skipping phase 3 afterward.

### 4. Incremental round
Run case 1 to completion, then, in the same project:

> Add bulk actions to the shipment list: select multiple shipments and change
> their status at once.

**Watch for:** mode detection firing (it must skip research, brand, and
direction). Existing tokens read before anything is created. The checkbox and
bulk-action bar built from existing components, or a clear report if they cannot
be. **No hardcoded values, no duplicate components** — both are hard failures in
incremental mode. And the organization sweep running even though only one region
was touched.

### 5. Finalize and roadmap
After case 4, run `/prototypen:finalize`, then `/prototypen:roadmap`.

**Watch for:** what finalize deleted (earlier audits, `run.md`, exploration
leftovers) and that it deleted nothing else; the two rejected directions
reduced to their rationale; amendments applied and listed under History;
`design/README.md` short enough to read in two minutes and pointing at every
file. Then the roadmap: every screen version from the design-spec table
appears exactly once in the coverage matrix; the first milestone closes the
core loop with its states; secondary screens attach where they are first
needed; no design commentary; the prose reads like a product lead wrote it.

## The cost case

Not a design case: the same case 1 prompt run twice, once headless and once
in app mode, with `/cost` recorded at the end of each. The estimate in
`docs/decisions.md` (2026-09-20) is 15–25% less in headless; this is the
measurement. Run it after any change to `canvas-access.md`, the runner
scripts, or the designer's reading set.
