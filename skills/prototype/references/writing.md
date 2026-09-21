# Writing

Read this before writing any document, report, or piece of canvas copy. It
applies to everything the plugin produces: the spec, the research, the brand
document, the direction, the audits, the handoff, the roadmap, and every label,
heading, button and empty-state line inside the prototype.

The goal is text that reads as if a person on the team wrote it. Model-written
prose has tells, and readers notice them before they notice the content. The
plugin's own files are not a style sample; they are written for a model to
follow, and they lean on the very devices listed below.

## Tells to avoid

- **Em dashes as the default connector.** One per page is fine. One per
  paragraph reads as generated. Use a comma, a period, parentheses, or split
  the sentence. In Portuguese, the travessão has the same effect; use vírgula
  or dois-pontos.
- **The staccato rhythm.** Many short sentences in a row, each landing a point.
  Fragments used for emphasis ("Not a feature. A habit."). Vary the length; let
  some sentences carry a subordinate clause. The period test below makes
  this checkable.
- **The contrast reflex.** "It is not X, it is Y." "This is not about X; it is
  about Y." Say what it is.
- **Triads.** Three adjectives, three parallel clauses, three bullet points
  when two or four were the real number.
- **Bolded lead-ins on every bullet**, colons used as a drumroll, and a
  one-line aphorism closing each paragraph.
- **Inflated vocabulary**: seamless, robust, leverage, elevate, delve, crucial,
  empower, streamline, unlock, journey, ecosystem. Plain words instead.
- **Headings that summarize the paragraph beneath them** in title case. Use
  short noun phrases.
- **Hedging stacks** ("it may be worth considering whether") and confidence
  stacks ("clearly", "undoubtedly") alike.

## The period test

The tell readers notice first is the period used to separate ideas that
belong together: "The app runs on three surfaces. The GM writes. The TV
shows the world. Players see what is theirs." Each sentence is fine; four in
a row is a voice. A period is not forbidden; three or more short sentences
in a row in one paragraph is the signal that something went wrong, and the
fix is one of these, in order of preference:

1. **One sentence with a connective.** "The app runs on three surfaces at
   once: the GM's laptop, which is the only one that writes, a TV in the
   room that shows the world, and each player's phone with what is theirs."
   Commas, colons, "which", "while", "so that", "because" are what carry a
   thought across its parts.
2. **A list**, when the items really are items (surfaces, criteria, screens).
   A list is honest about being a list; a paragraph of fragments pretends
   to be prose.
3. **Cut.** Often the third short sentence restates the second.

Run `scripts/prose-check.py <file>` on every document before committing it
and on the canvas copy longer than a label (see below). It flags runs of
three short sentences (`STACCATO`), paragraphs averaging under ten words
(`DENSE`), em dashes (`DASH`), emphasis fragments (`FRAGMENT`), the
"not X, it is Y" reflex (`CONTRAST`), bolded-lead-in triads (`TRIAD`) and
inflated words (`WORD`). Fix what it flags, then rerun; commit when it exits
0. It cannot read taste, so a clean run is necessary, not sufficient.

## What to do instead

Write the way the people who will read it talk about their work. A product
spec sounds like a product manager describing the product to an engineer. A
research report sounds like someone who read forty reviews and is telling you
what they found. An audit sounds like a reviewer listing what is wrong and
where. Sentences of different lengths, ordinary words, one idea per paragraph,
and a claim followed by the fact that supports it.

Lists are for things that are actually lists (criteria, screens, tokens).
Reasoning goes in paragraphs.

## Canvas copy

Interface text follows the product's tone of voice from `design/brand.md` and
the conventions of real products in that locale, which means:

- Short. A button is a verb; a heading names the thing on the screen; an empty
  state says what is missing and offers the one action that fixes it.
- No em dashes or travessões inside UI text. No exclamation marks unless the
  brand's tone calls for them, and then rarely.
- No filler ("Welcome to your dashboard!"), no jokes in error messages, no
  "Oops".
- Sample content looks like real data for the locale: real-looking names,
  dates in the local format, the local currency, addresses shaped like local
  addresses.
- Body copy on the canvas (an empty state's line, an onboarding paragraph,
  a landing section, sample article text) obeys the period test. Before
  reporting a flow, list every text node with more than one sentence and
  run each through `scripts/prose-check.py --text "<content>"`:

  ```js
  Get(flowId, n => n.type === "text" && typeof n.content === "string" && (n.content.match(/[.!?](\s|$)/g) || []).length >= 2 && Print(n.id, "|", n.name, "|", n.content))
  ```

## When the user asks for something else

If the user names a style (formal, playful, terse, a house style guide), that
wins. Otherwise this file is the default.
