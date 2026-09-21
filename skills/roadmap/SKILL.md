---
name: roadmap
description: Turns a finalized design (design/README.md and the documents it indexes) into a business roadmap under docs/ — sequenced milestones that together cover every screen, state and flow of the prototype, each with its goal, scope, acceptance criteria, dependencies and success metric. Invoke it as /prototypen:roadmap after /prototypen:finalize when the design is done and the question becomes what to build first. Also for "plan the releases from the prototype", "turn the design into a delivery plan", "what is the MVP here".
---

# Roadmap

Read the finalized design and write the plan to build it: which screens and
flows land in which milestone, in what order, and why, so that every screen
in the prototype appears in exactly one milestone and nothing is built before
what it depends on.

The output is for the people who decide what gets built and when: a founder,
a product manager, an engineering lead. It is a business document, not a
design one. It talks about jobs served and outcomes, cites screens by name
as the units of delivery, and never re-argues the design.

## Preconditions

- `design/README.md` exists (the folder was finalized). If not, run
  `/prototypen:finalize` first; a roadmap built on a folder with a stale spec
  covers screens that were dropped and misses ones that were added.
- Read, in this order: `design/README.md`, `design/product-spec.md`,
  `design/design-spec.md` (the screen table and the navigation map are the
  inventory you cover), `design/brand.md` (positioning and the name, for the
  overview), `design/changes.md` (decisions that shape sequencing, such as
  what was moved out of scope).
- Read `skills/prototype/references/writing.md`. The roadmap reads as if the
  product lead wrote it, and `scripts/prose-check.py` runs over every file
  you write before the commit.

## One question, and only when needed

The milestone cut is a business decision. Derive it from the spec: the
primary job earns the first milestone, the core loop has to be complete
inside it, and secondary jobs follow in their ranked order. That is enough
for most products.

Ask one round with `AskUserQuestion` only when the spec does not settle it:
the jobs are not ranked, two personas carry equal weight, or the user has
told you elsewhere that a launch date or a sales motion drives the order.
Offer the cuts you can see (by job, by persona, by revenue path) and let
them pick. Otherwise decide, and record the reasoning under Assumptions.

## How to sequence

1. **Inventory.** List every flow, every screen version, every state and
   every overlay from `design-spec.md`'s screen table. This is the coverage
   set; the roadmap is not done until each item is placed once.
2. **Dependencies.** From the navigation map and the content realities: what
   must exist for a screen to be reachable (the navigation it hangs from,
   the sign-in before the settings), what must exist for it to have content
   (the create flow before the list's long-list state), and what the brand
   and system need first (tokens, base components, the logo variants an
   app icon requires). Secondary screens attach to the milestone that first
   needs them: permission request with the first feature that asks, 404 with
   the first public route, session expired with sign-in.
3. **The first milestone** is the smallest set that lets the primary persona
   complete the core loop end to end, with every state that loop actually
   hits (empty and first run always; loading and error always; long list
   when the loop produces lists). A milestone that ships a screen without its
   error state ships a trap.
4. **Following milestones** each serve one job or one persona, in the spec's
   order, and each is complete on its own terms: its screens, states,
   overlays, and the forgotten actions the catalog lists for them.
5. **Launch** is its own milestone when a landing page is in scope: the
   landing flow, its confirmation and error screens, the brand assets
   (favicon, social image, app store listing if the type calls for it), the
   legal pages the footer links to.
6. **Later** holds what the spec put out of scope and what the change log
   deferred, listed so nobody assumes it was forgotten.

Sequencing, not scheduling. No dates unless the user gave them; the reader
adds their own.

## What you write

```
docs/
├── roadmap.md                  the overview
└── roadmap/
    ├── 01-<milestone-slug>.md
    ├── 02-<milestone-slug>.md
    └── …
```

From `templates/roadmap.template.md`, in the user's language, headings
translated, file names English.

**`docs/roadmap.md`** carries: the product in a paragraph (name, positioning,
who it is for, what it replaces); the milestones as a table (number, name,
the job or persona it serves, the outcome it makes possible, the screens
count); the sequencing rationale in prose (why this cut, what drove the
order, what would change it); the **coverage matrix**, one row per screen
version and state with the milestone it belongs to, sorted by milestone;
dependencies between milestones; risks carried from the audit's open findings
and the spec's pending items; and the assumptions.

**Each milestone file** carries: the goal in one sentence a stakeholder would
sign; the persona and job; the flows and screens in scope, each with its
states and overlays as acceptance criteria ("the shipments list shows its
empty state with the create action when no shipments exist"); the
navigation that must work (entries and exits, from the map); the design
system pieces it requires (components and tokens by name, from
`design-spec.md`); dependencies on earlier milestones; what is explicitly
deferred to a later one; the success metric, one or two, tied to the job;
and open questions.

## Rules

- **Every screen once.** The coverage matrix is checked against the screen
  table before you finish; a missing row or a duplicate is a defect.
- **Screens are named as the canvas names them** (`03 Payment Method /
  Mobile`), so the reader can find them in `design/screens/` and on the
  canvas.
- **No design commentary.** The direction was chosen and audited. If a
  milestone needs something the design does not have, that is an open
  question in the milestone file, not a redesign proposal.
- **Commit `docs/`** with `docs: roadmap — <n> milestones from the design`,
  on the current branch. Then say where the overview is and which milestone
  comes first.
