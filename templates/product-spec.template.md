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
| **Brand** | <exists (where) / to be explored / pipeline decides> | — | <"to be explored" means /prototypen:brand runs before the prototype> |
| **Landing page** | <in scope / not this round / not applicable> | — | <when in scope, the study below is filled and Flow — Landing Page is in the inventory> |
| **Depth** | <core / full> | — | <core, the default: the core loop end to end, the required secondary screens, the specific states; everything else goes to Backlog. full: the whole inventory. At most eight flows per round either way> |

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
<Every screen, grouped by flow. Flows are the user's jobs (what they came to
do), not areas of the product; a product with twelve areas has three or four
jobs. One line each: name, purpose, the primary object it shows, the primary
action available on it, and its archetype (list, object, form, dashboard;
the state exemplars are built per archetype).>

| Flow | Screen | Archetype | Purpose | Primary action | Other actions | Overlays it opens |
|---|---|---|---|---|---|---|

<"Other actions" is checked against the forgotten-actions list in
skills/prototype/references/component-catalog.md — create, edit, delete,
duplicate, search, filter, sort, bulk select, share/export, undo, retry, refresh.
"Overlays it opens" names the modals, sheets, drawers and popovers this screen
uses instead of navigating away — a destructive action here implies a
confirmation modal.>

## Navigation map
<The graph, declared before anything is drawn. One row per screen and per
overlay (modal, sheet, drawer) in every flow. "Entered from" lists every
control that opens it — a nav item, a list row, a button, a deep link. "Exits
to" lists every way out and where each goes: back, close/cancel, the completion
action, tab bar. Every screen needs at least one entry and one exit; every
overlay needs a dismiss AND a completion path. A row with an empty cell is an
orphan or a dead end, found here instead of in the audit.>

| Flow | Screen / overlay | Entered from | Exits to |
|---|---|---|---|
| | | | |

<Flow entry: which screen is the first one, and how the user gets to it from the
product's navigation. Flow end: where the last screen returns to.>

## Landing page
<Only when Targets says it is in scope. The study from
skills/prototype/references/landing-page.md: who lands here and from where,
the one action, the objections in order, the proof available today (and what
is pending), and the section order with what each section answers. The
landing flow's screens (the page per viewport, the form confirmation, the
submit error) go in the inventory and the navigation map like any other.>

| # | Section | Answers which objection | Proof or content it needs |
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
| Submit error | | |

## Generic states
<The states every screen has in common are built once per archetype as
exemplars in the Design System (`canvas-structure.md` §3b) and inherited. One
row per screen: its archetype and which generic states apply, with a note
where the inherited exemplar needs a different message on this screen (the
copy, not the layout). This table produces no screens; the completeness
audit checks the exemplars against it.>

| Screen | Archetype | Empty | Loading | Error | First run | Long list | Long text | Permission denied | Copy note |
|---|---|---|---|---|---|---|---|---|---|

## Specific states
<The states only this screen has, each with the reason it cannot be an
exemplar: it changes the screen's structure or actions (a live-session banner,
a locked object, a selection mode with its bulk bar, a search with no results
that offers "clear filters", an editing mode). Every row here becomes a
screen row on the canvas; a row without a reason is a generic state in
disguise and does not belong here.>

| Screen | State | Why it needs its own screen | What changes |
|---|---|---|---|

## Backlog
<When Depth is core: every screen, flow and state the jobs imply that this
round does not draw, one line each with the job it serves. This is the
inventory of the next round, not a list of omissions.>

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
