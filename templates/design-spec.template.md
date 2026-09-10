# Design Spec — <Product Name>

> Instantiated by phase 10 (Handoff) to `design/design-spec.md`.
> Written in English here; **translate the section headings into the user's
> language** when instantiating, and write all content in the user's language.
> Token names, component names, and canvas node names stay in English.
> This is the handoff document: what an implementer needs that the canvas
> cannot show.

## Targets
<The viewports and themes this design covers, carried from
design/product-spec.md. An implementer reads this first — it says which screen
sets and which theme values exist.>

| | Targets | Primary |
|---|---|---|
| **Viewport** | | |
| **Theme** | | |

## How to read this
<Where the canvas file is, how the regions are organized, and how a name here
maps to a node there.>

## Tokens
<Every design token, with its .pen variable name and its intended name in code.
Themed values shown per theme.>

### Color
| Canvas variable | Code name | Light | Dark | Use |
|---|---|---|---|---|

### Typography
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

<Plus the scale: ratio, base size, and every step with its intended role.>

### Spacing
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

### Radius, border, shadow
| Canvas variable | Code name | Value | Use |
|---|---|---|---|

## Components
<Every base component: what it is, its variants, its states, and the props an
implementation needs. Include the canvas node name so it can be found.>

### <Component Name>
- **Canvas node:** `<Name>`
- **Purpose:** <One sentence.>
- **Variants:** <List.>
- **States:** <default, hover, focus, active, disabled, loading, error — whichever apply.>
- **Props:** <Name, type, default, what it does.>
- **Behavior the canvas cannot show:** <Focus handling, keyboard interaction, truncation, responsive collapse.>

## Screens
| Flow | Screen | Viewport | Canvas node | States built | Notes |
|---|---|---|---|---|---|

## Rules the canvas cannot show
- **Focus order:** <Per screen where it is not obvious.>
- **Responsive behavior:** <What reflows, what collapses, what hides, at which breakpoints.>
- **Motion:** <What animates, duration, easing, and what must not animate.>
- **Copy tone:** <The rules for writing new strings, from design/brand.md.>
- **Accessibility:** <Contrast decisions, touch target minimums, anything that constrains implementation.>

## Open findings
<Carried over from the latest audit report: what failed three fix cycles and was
left unresolved, and what a human needs to decide.>
