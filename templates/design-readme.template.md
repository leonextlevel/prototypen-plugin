# Design — <Product Name>

> Instantiated by /prototypen:finalize to `design/README.md`.
> Written in English here; translate the headings and write the content in
> the user's language. This is the entry point to the folder: short, current,
> and enough for someone who has never seen the project to know where to go.

## What this is
<Two or three sentences: the product, for whom, what it replaces. From the
spec's summary.>

## Brand
<Name, positioning in one sentence, the mark's meaning in one sentence. The
palette's primary and the type pairing by name. Full document: brand.md.>

## Direction
<The chosen direction's personality sentence and its committed choice. Full
document: design-direction.md.>

## The canvas
<`design/prototype.pen`, opened in pen.dev. The regions: Design System, Brand,
one per flow. Inside a flow: one column group per screen in navigation order,
versions side by side (viewports, then the theme copy), states and overlays
in the rows below. Which viewports and themes exist, from Targets.>

## Reading order

| File | What it holds | Read it when |
|---|---|---|
| `product-spec.md` | personas, jobs, screens, states, navigation map | you need to know what exists and why |
| `design-spec.md` | tokens, components, screen table, rules for implementation | you are building it |
| `design-direction.md` | the visual specification and the token inventory | you are adding a screen or a component |
| `brand.md` | name, tone, palette, logo rules | you are writing copy or placing the logo |
| `research.md` | competitors, conventions, antipatterns | you want to know what the category does |
| `changes.md` | every decision the runs made instead of asking | you disagree with something and want to know why it is that way |
| `audits/` | the latest audit, one verdict per criterion | you want to know what was left open |
| `tokens.json`, `tokens.css` | every variable, all themes | day one of implementation |
| `screens/` | one PNG per screen version and state, each flow as HTML (unversioned; regenerate with a handoff) | you cannot open pen.dev |

## Status
<Open findings from the latest audit, one line each. What is explicitly out
of scope. Anything marked pending in the spec (proof for the landing page, a
name still to be cleared).>

## How to continue
<An incremental round: describe the change and run /prototypen:prototype in
this project; it loads what exists and builds only what was asked. A business
roadmap from this design: /prototypen:roadmap. Re-run /prototypen:finalize
after any further round.>
