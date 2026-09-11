# Product Spec — <Product Name>

> Instantiated by phase 1 (Intake) to `design/product-spec.md`.
> Written in English here; **translate the section headings into the user's
> language** when instantiating, and write all content in the user's language.

## Summary
<One paragraph: what this product is, for whom, and what it replaces today.>

## Targets
<Decided, not assumed. Every later phase is bound by this table and none may
narrow it. If the user did not state one, decide, and record the decision under
Assumptions.>

| | Targets | Primary | Notes |
|---|---|---|---|
| **Application type** | <native mobile / web app / marketing site / internal tool / desktop> | — | <drives the secondary screens below> |
| **Viewport** | <desktop / mobile / both> | <which one is designed first> | <target widths for each> |
| **Theme** | <light / dark / both> | <which one is the default> | <any theme-specific constraint> |

<A desktop table and a mobile card list are two designs, not one design at two
widths. A palette that passes contrast in light frequently fails in dark. Both
decisions have to reach the direction phase before any color or density is
chosen.>

## Personas
<Two to four. For each: who they are, their context of use, their level of
domain expertise, and what device and situation they are in. No demographics
that do not change a design decision.>

## Jobs to be done
<What each persona hires this product for, phrased as a job, not a feature.
Rank them — the primary job earns the primary screen.>

## Core loop
<The thing the user does over and over. Name it, and say how often.>

## Screen inventory
<Every screen, grouped by flow. One line each: name, purpose, the primary object
it shows, and the primary action available on it.>

| Flow | Screen | Purpose | Primary action |
|---|---|---|---|

## Secondary screens
<The screens the application type requires that nobody lists as features. Decide
from context which apply — do not build all of them. Catalog and reasoning in
skills/prototype/references/screen-craft.md.>

| Screen | Applies? | Why / why not |
|---|---|---|
| Splash / launch | | |
| Onboarding / first run | | |
| Permission request | | |
| Permission denied | | |
| Sign in / sign up / forgot password | | |
| Offline / no connection | | |
| 404 / not found | | |
| 403 / no access | | |
| Session expired | | |
| Settings / profile | | |
| Form confirmation | | |

## State inventory
<For every screen, which of these states apply and what each one shows. This
table is what the completeness audit checks against — a state missing here is a
state nobody will notice is missing from the canvas.>

| Screen | Empty | Loading | Error | First run | Long list | Long text | Permission denied |
|---|---|---|---|---|---|---|---|

## Content realities
<The things that break layouts: longest realistic name, longest label in the
user's language, largest number, deepest nesting, most items, the field that is
optional and usually blank.>

## Out of scope
<What this prototype deliberately does not cover, so nobody audits it for a
missing thing that was never intended.>

## Assumptions
<Every decision made because the request was silent. One line each, with the
reasoning. This is where a reader checks whether the pipeline guessed wrong.>
