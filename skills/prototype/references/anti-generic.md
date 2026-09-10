# Anti-generic constraint

Read this at phase 4 (direction), phase 6 (system), and every audit.

AI-generated design has a recognizable face. Not a bad face — a *default* one,
arrived at by every model independently because it is the statistical center of
the training data. The result is a product that looks like every other product
generated the same week, which is the one thing a prototype meant to sell an
idea cannot afford.

**This is not fixed by asking for creativity.** "Be bold", "be original", and
"avoid generic design" produce the same output with different adjectives. It is
fixed by naming the defaults, banning them by name, and requiring a written
justification to use one.

## The rule

Every item on the list below is **forbidden unless `design/design-direction.md`
explicitly justifies it for this project, by name.**

"The direction file says Inter because the product is a developer tool whose
users read code all day in a grotesque, and the type pairing sets Inter against
a high-contrast serif for headings" is a justification. "Inter is clean and
readable" is not — that is the default arguing for itself.

The justification must exist **before** generation, in the direction file. A
justification written during the audit, to excuse something already drawn, does
not count.

## The ban list

**Typography**
- Inter as an automatic choice — and the whole neutral-grotesque reflex:
  Roboto, Open Sans, Helvetica/Arial, system-ui, Poppins, Montserrat, Lato,
  Nunito, Source Sans, DM Sans, Manrope, Plus Jakarta Sans.
- A single family used for everything, with weight as the only contrast.
- A type scale with no stated ratio — sizes picked one at a time.

**Color**
- `#3b82f6` and its neighbors — the Tailwind `blue-500`/`blue-600` band, and
  the whole "trustworthy SaaS blue" family, as a primary chosen by default.
- The purple-to-blue gradient (`#6366f1` → `#8b5cf6` → `#a855f7` and relatives),
  in a hero, a button, a logo, or a background blob.
- Untouched Tailwind default palette ramps used as the product palette.
- Pastel tints as the only secondary color story.

**Surface and shape**
- The white card with a soft diffuse shadow on a light-gray page. Especially
  three of them in a row.
- Uniform border radius on absolutely everything — the same `8px` on buttons,
  cards, inputs, avatars, images, and modals.
- Shadow used as the only means of establishing depth or hierarchy.
- Glassmorphism, and the frosted translucent panel over a blurred gradient.

**Layout**
- The centered hero: big centered headline, centered subhead, two CTAs side by
  side (one filled, one outlined), centered.
- The three-column feature grid of identical cards, each with an icon, a
  three-word title, and two lines of body copy.
- Everything centered because nothing was decided.
- Wrapping every element in its own box or card. A container needs a structural
  or functional reason to exist.
- A single max-width column with uniform vertical rhythm and no other structure.

**Iconography and imagery**
- The pastel circle with a small icon centered in it.
- Emoji used as interface iconography.
- The generic abstract gradient mark as a logo (see `brand.md`).
- Stock photography of diverse people smiling at a laptop.

**Motion**
- Fade-and-rise on scroll applied uniformly to every section.

## What this list is *not*

**It restricts the visual layer. It never restricts interaction convention.**

Users learned where the filter lives, what a save button looks like, that the
primary action sits at the end of a form, that a back arrow goes back, that a
red destructive action asks before it destroys. Those are not defaults to
escape. They are the accumulated cost of everyone else's user research, and
breaking them produces a prototype that is original and unusable.

So:

| Break this | Never break this |
|---|---|
| The palette | Where the primary action is |
| The type pairing | What a disabled control looks like |
| The card-and-shadow surface treatment | That destructive actions confirm |
| The centered hero composition | Where navigation lives |
| The uniform radius | Focus order and keyboard reachability |
| The icon treatment | Contrast minimums (see `audit-rubric.md`) |
| The grid and density | The meaning of an established icon |

Originality goes in **how it looks**. Convention stays in **where things are and
how they behave**.

## Positive obligation

Avoiding the list is not enough — a design can dodge every item and still be
characterless. The direction file must also make at least one **committed,
non-neutral choice** that a viewer would notice and could describe: a real type
pairing with contrast, a palette that came from a concept rather than a color
picker, a density that is deliberately tight or deliberately generous, a
structural idea that repeats.

If the audit cannot name that choice by looking at a screenshot, the direction
did not commit to one.
