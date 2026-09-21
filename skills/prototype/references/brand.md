# Brand

Read this at phase 3, and any time the user brings an existing brand.

## When this phase runs

The brand phase is **conditional**, and its condition is independent of
bootstrap/incremental mode. It runs when **both** are true:

- there is no `design/brand.md` in the project, **and**
- the user supplied no existing brand (name, logo, palette, guidelines).

If either exists: load it as a **constraint** and skip the phase. An existing
brand is not a starting point to improve on — it is a boundary. Where it is
silent (say it defines a logo and colors but no type), extend it in its own
spirit and record what you added and why in `design/brand.md`, clearly marked as
an addition rather than as something the brand already said.

The condition is independent of mode: a project that already has research,
direction, and screens but no brand file still runs this phase.

There is a third path. When the spec's Targets table says the brand is **to
be explored**, the user wants to see candidates and choose before the
prototype commits to one. That is `/prototypen:brand`, an interactive skill
that runs the brand designer in candidate mode (two or three candidates side
by side on the canvas, at most three rounds) and writes the same
`design/brand.md`. Once it has run, this phase is skipped like any supplied
brand. The pipeline's Step 0 mentions the pending exploration in its one
question if the user starts `/prototypen:prototype` before running it.

## Order is mandatory: research first, brand second

`design/research.md` must exist before this phase starts.

Research feeds the brand the **territory the competitors already occupy** —
their names and naming patterns, their tone, their palettes, their archetypes,
the visual register of the category. Without it, a brand invented from the idea
alone lands exactly where everyone else already is, because the same idea
suggests the same associations to everyone.

The purpose is positioning by contrast: **place the new brand where there is
room, not where the category is crowded.** If every competitor is a blue,
lowercase, friendly-sans, `-ly`-suffixed helper, that is not a template to
match. It is a map of occupied ground.

State this explicitly in `design/brand.md`: which territory the competitors hold,
and which unoccupied position this brand takes.

## What the brand defines

Write all of it to `design/brand.md`, in the user's language.

1. **Name** — the product name.
2. **Name rationale** — where it comes from, what it means, what it evokes, how
   it sounds said aloud, and how it differs from the competitor naming pattern
   found in research.
3. **Availability check** — a viable, honest check, not a legal opinion:
   - is the `.com` (and one relevant local TLD) apparently taken?
   - does a product with this name already exist **in the same sector**?
   - is it an existing trademark obvious enough to find?
   Report findings and **flag conflicts plainly**. Say what was checked and what
   was not. **Never state or imply that the name is legally clear** — that
   requires a trademark search this pipeline does not perform. Write that
   sentence into the document.
4. **Positioning, in one sentence** — who it is for, what it does, and what
   makes it different. One sentence, not a paragraph.
5. **Tone of voice** — three to five adjectives, each with a do/don't example
   written in the user's language, because tone is what the canvas microcopy is
   audited against.
6. **Archetype** — the archetype, and specifically how this brand plays it
   differently from the competitors who share it.
7. **Primary palette** — the brand colors with their meaning and their
   hierarchy. This is the brand palette; the product palette in
   `design-direction.md` derives from it and may extend it, never contradict it.
8. **Brand typography** — the family or pairing that carries the brand, with the
   reason. Subject to `anti-generic.md`.
9. **What the brand is not** — the explicit negative space. The adjacent
   positions it deliberately rejects, the tones it will not use, the visual
   moves that are off-limits. This section is what makes the rest enforceable.

## Logo

Produced as **SVG files** in `design/brand/logo/`. Required variants:

| File | What it is |
|---|---|
| `logo-primary.svg` | The main lockup. The default. |
| `logo-horizontal.svg` | Wide lockup for headers and narrow horizontal space. |
| `logo-symbol.svg` | The mark alone — reduced/app-icon use, no wordmark. |
| `logo-mono.svg` | Single-color, one flat value. Must survive a fax and an engraving. |
| `logo-inverse.svg` | The dark-background version. Not the primary with a swapped fill unless that genuinely works. |

Also document, in `design/brand.md`:

- **Clear space** — the minimum breathing room, expressed as a ratio of some
  part of the mark (e.g. "the height of the counter in the O"), so it scales.
- **Minimum size** — the smallest width at which the primary lockup stays
  legible, and the size below which you must switch to the symbol.
- **Misuse** — the specific things not to do to this mark: don't stretch, don't
  recolor outside the palette, don't add effects, don't place on a busy
  background, don't rebuild the lockup by retyping the name.

**Production.** Generate the mark with `Generate(frameId, "svg", prompt)` on the
canvas — never hand-draw a logo out of paths and shapes while generation
works; hand-built marks always look hand-built. Generate **once**, then
build the variants from that mark rather than generating five times: five
generations produce five different logos. Generation is async; see the
polling rules in `pencil-mcp.md`.

**When generation is unavailable** (the account is out of credits, the
response names a quota or a plan limit, or a second attempt lands empty),
follow the manual path in `pencil-mcp.md`: a geometric mark from
primitives, the SVG files written by hand from the same primitives, one
note in the run log and in `design/brand.md` saying the mark was built
manually and can be regenerated. The concept adapts to the tool: a
monogram, a ring, a cut shape, not an illustration. What does not change
is the rest of this file: the name, the positioning, the palette, the type
and the misuse rules are decided the same way, and the variants are still
five.

## The brand is a constraint on phase 4

The brand enters design direction as a **constraint, not a suggestion**. Palette,
typography, tone, and archetype are inputs the three directions must work
within.

**If none of the three proposed directions can live with the brand, the problem
is in the directions.** Regenerate them. Never loosen the brand to accommodate a
direction you liked — that inverts the dependency and produces a brand that
means nothing, since anything can satisfy it.

## Brand is subject to the ban list

`anti-generic.md` applies to the brand as much as to the interface. Specifically,
these count as defaults to avoid, not as choices:

- **Invented names with `-ly` / `-ify` / `-io` / `-r` suffixes**, dropped vowels,
  and the two-cheerful-syllables pattern. Every AI names this way.
- **The generic abstract gradient symbol** — the swooping shape, the rounded
  hexagon, the abstract knot, in purple-to-blue, meaning nothing in particular.
- **The wordmark that is just the name set in a neutral grotesque**, possibly
  lowercase, possibly with one letter in the accent color. That is not a logo;
  it is a font choice.
- The generic overlapping-translucent-circles mark.
- A name built from a Latin root plus a tech suffix, chosen because it sounded
  serious.

The name should be sayable, spellable after hearing it once, and connected to
the positioning. The mark should mean something you can state in a sentence.
