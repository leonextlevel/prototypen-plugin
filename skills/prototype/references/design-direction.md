# Design direction

Read this at phase 4. The output is `design/design-direction.md`, the file every
later phase is audited against.

Direction is where constraint gets declared. Skip it and the design system
becomes a pile of choices made one at a time, each defensible alone and
incoherent together. The point of producing three directions is not variety for
its own sake — it is that a choice you can only make by rejecting alternatives
is a choice you can defend in writing, and a choice you can defend in writing is
one the audit can check against.

## Step 0 — Read the targets

Open `design/product-spec.md` and read the **Targets** table before anything
else: which viewports, which themes, and which is primary in each.

Everything in step 3 is specified **for all of them**. This is not a detail to
handle later — the two decisions that most constrain a direction are density
(which differs per viewport) and palette (which must hold in every theme), and
both are decided here. A direction written for light-desktop and retrofitted to
dark-mobile is a direction rewritten.

If the Targets table is missing, the spec was written before this rule existed.
Decide the targets yourself, write them into the spec, and say so — do not
proceed with them unstated.

## Step 1 — Pick two axes

Pick **two** of these for this project. Not one (no room to diverge), not four
(the directions blur).

| Axis | One end | Other end |
|---|---|---|
| Density | **Dense** — information-first, tight rhythm, small type, many things visible at once | **Airy** — generous whitespace, few things per view, large type |
| Register | **Editorial** — typographic, expressive, reads like it was art-directed | **Utilitarian** — plain, efficient, reads like a tool |
| Contrast | **High contrast** — strong value jumps, bold accents, the interface asserts | **Quiet** — narrow value range, restrained accents, the interface recedes |
| Form | **Geometric** — hard edges, strict grid, mechanical | **Organic** — soft or irregular shapes, looser alignment, humane |

Pick the axes that the product's tension actually lives on. A trading terminal
and a meditation app are not distinguished by the same pair.

## Step 2 — Place three directions

Put the three at **genuinely different points**. If two directions differ only
in accent color, they are one direction with two swatches — regenerate.

A useful shape: two directions near opposite ends of the primary axis, and a
third that takes an unexpected position on the secondary axis. Avoid producing
one "safe", one "bold", and one "in between" — that is not three directions,
it is a slider, and the middle always wins by default.

## Step 3 — Each direction declares all of this

A direction is not a mood board. It is a specification. Each of the three must
state:

1. **Name and one-sentence personality** — testable, not decorative.
   Testable: *"Looks like a well-set financial newspaper: information dense,
   typographically confident, no ornament."* Someone can hold a screenshot next
   to that sentence and say yes or no.
   Not testable: *"Modern, clean, and friendly."*
2. **Type pairing** — two named families with a stated reason for the pairing,
   and what each is for. Both must pass `anti-generic.md`.
3. **Modular scale** — the ratio, stated (1.2 minor third, 1.25 major third,
   1.333 perfect fourth, 1.5 …), the base size, and the resulting steps. Sizes
   are derived from the ratio, not picked one at a time.
4. **Palette from a concept** — the concept first (a material, a place, a
   printing process, a time of day, an archive), then the colors derived from
   it. Neutrals included, and named as part of the palette rather than
   defaulted to gray. State the intended value distribution.

   **One palette per declared theme.** A dark theme is designed, not computed:
   inverting a light palette produces muddy neutrals, accents that glare, and
   shadows that do nothing. Derive the dark values from the same concept, and
   state for each theme the contrast pairs that must hold — because a palette
   that passes AA in light routinely fails it in dark, and the audit checks both.
5. **Target density** — stated concretely: base spacing unit, the spacing scale
   derived from it, and roughly how much a primary view should hold. **Per
   declared viewport**: density is the main thing that legitimately differs
   between desktop and mobile, and stating one number for both means one of them
   was not designed.
6. **Grid** — columns, gutters, max widths, and the breakpoints that matter,
   **per declared viewport**, with the target width each assumes.
7. **Edge treatment** — border radius (and where it varies and why), border
   weight and use, and whether depth is carried by shadow, border, value, or
   overlap. "Shadow" as the automatic answer is on the ban list.
8. **Motion** — what moves, how fast, with what easing, and what deliberately
   does not move. "None, deliberately" is a valid and often good answer.
9. **What this direction rejects** — the trade-off it accepts. A direction that
   claims no cost has not committed to anything.

A direction that can only work in one theme, or only at one viewport, when both
are in scope, is **not a candidate**. Discard it and generate another; the
targets are not negotiable and a direction that fights them will be fought all
the way to handoff.

Every direction must be compatible with `design/brand.md` if a brand exists.
**If none of the three can live with the brand, the directions are wrong — not
the brand.** Regenerate them.

## Step 4 — Choose, in writing

Write the criteria **before** naming the winner, and tie each to the audience
and the job from `design/product-spec.md`. Not to taste.

Criteria that are legitimate:
- Which one serves the primary job best? (A dense direction for a job done fifty
  times a day; an airy one for a job done once and abandoned if confusing.)
- Which one survives the real content? (Long names, long lists, empty states,
  eight-word labels in the user's actual language.)
- Which one fits the context of use? (One-handed on a phone on a train; a
  30-inch monitor; bright sunlight; a shared screen in a meeting.)
- Which one matches the brand's positioning and tone without restating it?
- Which one can the team actually build and maintain?

Criteria that are not legitimate: "the most modern", "the cleanest", "the most
professional", "I like it best". These are the default arguing for itself.

Then record, in `design/design-direction.md`:

- The full spec of the **chosen** direction (all nine items above).
- **Why the other two were rejected**, against the stated criteria — one
  paragraph each. This is what stops a later round from quietly drifting back
  toward a rejected direction.
- An **explicit justification section** for any `anti-generic.md` item this
  direction uses. Anything not justified here by name is forbidden downstream.
- The **committed choice**: the one non-neutral decision a viewer would notice
  and could describe. Named, so the audit can look for it.

## Downstream

Phase 6 turns items 3–8 into `.pen` variables verbatim. If a token is needed
later that this file does not define, the designer **stops and reports** — the
direction file is amended by decision, never extended by improvisation in the
middle of a screen.
