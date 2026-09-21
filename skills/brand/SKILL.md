---
name: brand
description: Interactive brand exploration on the Pencil canvas — puts two or three brand candidates (name, mark, base palette, type) side by side, refines the one the user picks over at most three rounds, and writes design/brand.md plus the logo SVGs. Invoke it as /prototypen:brand after /prototypen:discover and before /prototypen:prototype when nothing about the identity is decided yet and the user wants to see and shape options rather than receive one unattended. Also for "explore the brand", "show me logo options", "help me pick a palette", "refine the identity before designing".
---

# Brand exploration

Take a product with no decided identity and, with the user in the loop, arrive
at a brand the prototype can be built on: name, mark, base palette, type, tone.
Write `design/brand.md` and `design/brand/logo/*.svg`, then stop.

This exists because a brand invented unattended is a coin toss the user only
sees after every screen is drawn. When the product is new and its identity
matters, three short rounds of looking at candidates side by side cost far
less than a prototype rebuilt on a mark nobody liked.

## Where this sits

```
/prototypen:discover  →  /prototypen:brand  →  /prototypen:prototype
                                                (skips phase 3: brand.md exists)
```

You produce the brand and nothing else. No direction, no screens. When
`design/brand.md` is written, say so and hand off: run
`/prototypen:prototype`.

## Language and voice

Detect the user's language and use it for questions, for `design/brand.md`,
and for the tone-of-voice examples. Read
`skills/prototype/references/writing.md` first. Canvas node names, file names
and the product name itself are not translated. State the language in every
subagent prompt.

## Preconditions

1. **The access mode, then the canvas.** Read
   `skills/prototype/references/canvas-access.md` and ask the user which
   mode to use, **app mode suggested first**: this skill is interactive and
   the candidates are meant to be looked at on the canvas as they appear.
   Headless is the alternative when they would rather judge from the
   exported PNGs. `design/prototype.pen` must exist (create it from the
   empty document in `pencil-mcp.md` if not); in app mode it must be the
   active editor per `get_app_state` (ask the user to open it, then check
   again); in headless it must not be open in an app. State the mode in
   every brand-designer prompt. In app mode, `scripts/pen-save.sh` runs
   after every round, before the question to the user, so what they see in
   the editor and what is on disk agree.
2. **Research.** `design/research.md` must exist; its occupied-territory
   section is what makes candidates different from the category instead of
   more of it. If it is missing, delegate to `prototypen:researcher` first
   (with `design/product-spec.md` as input, or the user's description if
   there is no spec) and wait for it.
3. **Read `skills/prototype/references/brand.md`.** Everything about what a
   brand defines, the logo variants, the ban list, applies here unchanged.

## The rounds

Three at most. Each round is one `prototypen:brand-designer` task followed by
one question to the user. Between rounds you decide nothing about the brand
yourself; you carry the user's answer to the designer.

### Round 1 — Candidates

Prompt the brand designer in **candidate mode**: from the research's occupied
territory, produce **three candidates** at genuinely different unoccupied
positions. Each candidate is a box `Brand Candidate A|B|C` in the `Brand`
region, all three side by side and top-aligned (a horizontal layout frame
with `alignItems: "start"`, per `canvas-structure.md` §4), each holding:

- the name, set in the candidate's brand type;
- the mark, generated once per candidate (`Generate(frameId, "svg", …)`, the
  one place in the plugin where three generations are correct, because they
  are three brands, not five copies of one);
- the base palette as swatches with the value written on each;
- a specimen: the mark on the light and on the dark surface, one button, one
  line of body text, so the user judges the brand on something that looks
  like a product and not on a logo alone;
- one sentence of positioning under the name.

The designer exports the three boxes as PNG into
`design/brand/exploration/round-1/` (absolute path) and reports the name,
position and rationale of each in two lines apiece. If it reports that SVG
generation was unavailable (credits, quota) and the marks were built
manually from primitives, say so to the user in the same message as the
candidates: they are judging a geometric concept, and the mark can be
regenerated when the account allows.

Then ask, with `AskUserQuestion`: which candidate to continue with (A, B, C),
plus an open note for "B's mark with A's palette" style answers. Include the
PNG paths in the message so the user can look outside the editor.

### Round 2 — Refinement

Prompt the designer with the user's pick and notes. It removes the other
candidates from the canvas, keeps the chosen box as `Brand Candidate <X>`,
and lays out beside it, in the same row, **two or three variations** of what
the user was unsure about: palette (two tints of the primary, or a different
secondary), the mark (weight, proportion, one alternative reading of the same
idea), or the name (two alternatives on the same positioning), whichever the
notes point at. Never all of them at once; a round explores one axis. Export
to `round-2/`, report, ask again.

If the user's round-1 answer was a clear yes with no notes, skip this round.

### Round 3 — Confirmation

Apply the round-2 answer. The designer collapses everything into the final
brand: the five logo variants as frames in the `Brand` region, the palette,
the type specimens, and deletes the `Brand Candidate` and variation boxes.
Show the result (one PNG of the region), ask one closing question only if
something is still open; otherwise proceed to the write-up.

## The write-up

The designer writes `design/brand.md` from `templates/brand.template.md`, all
sections, in the user's language, with one addition: a short **Exploration**
section listing the candidates that were shown and why each was set aside,
in the user's words where they gave them. That is the record a later reader
needs to not re-propose a rejected direction. The logo SVGs go to
`design/brand/logo/` per `brand.md`. The exploration PNGs under
`design/brand/exploration/` are deleted; the write-up carries what mattered.

Update `design/product-spec.md`'s Targets row for the brand from "to be
explored" to "exists (design/brand.md)". Save (app mode:
`scripts/pen-save.sh`) and commit `design/` with `design: brand — <name>,
chosen from <n> candidates`. End with the canvas notice from
`canvas-access.md`, then hand off.

## Rules

- **Never ask what they want it to look like** in the abstract. Show
  candidates; ask which. A choice between real options gets a real answer.
- **The ban list applies** (`anti-generic.md`): no `-ly` names, no gradient
  swoosh, no wordmark that is just a font choice. Candidates that differ only
  in color are one candidate; regenerate.
- **One axis per round.** Refining palette and mark and name in the same
  round produces nine boxes and no decision.
- **The canvas ends clean.** No `Brand Candidate` box survives the write-up;
  the pipeline's organization sweep flags any that does (check 14).
- **Commit only `design/`**, on the branch rule from
  `skills/prototype/references/run-protocol.md`.
