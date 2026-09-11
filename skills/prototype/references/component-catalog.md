# Component catalog

Read this at phase 6 (system), when deciding the base component set, and at
phase 7 before building any screen. The `designer` reads it on every task.

This is a repertoire, organized by **the job the user is doing** rather than by
component name — because the failure it prevents is not "used the wrong
component" but "did not think of the component at all". Left to its defaults, a
generative designer builds a full screen for everything, forgets the actions
that are not the primary one, and never reaches for a modal, a sheet, a popover
or a toast even when they are exactly right.

Every entry says when to use it and, just as important, when not to.

---

## The first decision: screen, or something lighter?

**Do not build a screen for something that is not a destination.** The single
most common structural mistake is a new full screen for a task that belongs in an
overlay on the screen the user is already on.

| Use a **full screen** when | Use an **overlay** when |
|---|---|
| The user would want to come back here (it is a place) | The user must not lose sight of what they were doing |
| The task is long — more than ~5 fields, or multi-step | The task is short — a confirmation, a quick edit, a choice |
| It needs its own URL, back entry, or deep link | It is subordinate to the current screen and ends by returning to it |
| The content is the point (a detail view, a report) | The content is a question or a small form |

If the task is short **and** subordinate, pick the overlay from the ladder below.
Lighter is better; go heavier only when the lighter one cannot hold it.

```
tooltip → popover → dropdown menu → toast → bottom sheet / drawer → modal dialog → screen
```

---

## Confirm, interrupt, inform

| Component | Use it for | Not for |
|---|---|---|
| **Modal dialog** | Confirming a destructive or irreversible action; a decision the user *must* make before continuing; a short focused form (≤5 fields) that must not lose context | Anything the user could ignore; long forms; content that deserves a URL; "are you sure?" on reversible actions (use Undo instead) |
| **Alert dialog** | A blocking system message with one acknowledgment: session expired, update required, permission needed | Success messages (toast); anything with more than two actions |
| **Bottom sheet** *(mobile)* | The mobile equivalent of a modal for choices and short forms — in the thumb zone, dismissible by swipe | Anything with more than ~6 options (use a screen); desktop |
| **Toast / snackbar** | Feedback after an action: "Saved", "3 items archived — **Undo**". Non-blocking, auto-dismissing | Errors the user must act on; anything longer than one line; confirmations *before* an action |
| **Banner** | A persistent system-level message: offline, trial ending, verification pending. Sits at the top, stays until resolved | Per-action feedback; anything that should auto-dismiss |
| **Inline alert** | A message tied to a specific region — validation summary above a form, a warning inside a card | Global messages (banner); action feedback (toast) |
| **Empty state** | A collection with nothing in it. **Always with a way forward** — the primary create action, or an explanation of what will appear here | A "no results" search (that is its own state, with "clear filters") |

### Destructive actions: the non-negotiable rule

**Every destructive or irreversible action gets a modal confirmation.** Delete,
remove a member, cancel a subscription, send to everyone, overwrite, revoke,
archive-without-undo. No exceptions, on any viewport (bottom sheet on mobile is
the same thing).

The dialog itself has a shape:

- **Title names the thing**: "Delete 3 shipments?" — not "Are you sure?" and
  not "Confirm".
- **Body states the consequence** in one or two sentences: what disappears, who
  is affected, whether it can be undone.
- **The destructive button is a verb with the object**: "Delete 3 shipments".
  Never "OK", "Yes", or "Confirm" — those force the user to re-read the title to
  know what they are agreeing to.
- **Cancel is the safe default**: it is the button that gets initial focus and
  the Escape key, and it sits where the eye lands first.
- **The destructive button uses the destructive color** from the direction's
  palette, and is the only thing on the dialog that does.
- **High stakes get type-to-confirm** — delete a workspace, delete an account,
  bulk-delete above some threshold: the user types the name.

**The reversible counterpart:** for actions that *can* be undone — archive,
move, mark as read, single-item delete with trash — **do not confirm. Act
immediately and offer Undo in a toast.** Confirmation dialogs on reversible
actions train users to click through them, which is exactly what makes them
useless on the irreversible ones.

---

## Choose

| Component | Use it for | Not for |
|---|---|---|
| **Radio group** | One choice among 2–5 options that should all be visible | More than ~6 options (select); multiple choice (checkboxes) |
| **Checkbox group** | Several choices among visible options | A single on/off (switch); mutually exclusive options (radio) |
| **Switch / toggle** | One on/off setting that takes effect immediately | Anything that needs a Save button (checkbox); a choice between two named things (segmented control) |
| **Segmented control** | 2–4 mutually exclusive views or modes, always visible, instant switch — "List / Map", "Day / Week / Month" | More than 4; options with long labels; navigation between pages (tabs) |
| **Select / dropdown** | One choice among 6–20 options that do not all need to be visible | Under 5 options (radio, segmented); over ~20 (combobox with search); choices the user needs to compare |
| **Combobox / autocomplete** | Choosing from a long or open list by typing — a city, a user, a product | Short fixed lists (select) |
| **Chips / filter chips** | Selecting one or more filters that stay visible once applied; removable tags | Primary navigation; more than a row or two |
| **Date / time picker** | Picking a date; a range | Dates the user knows by heart (a plain field with a mask is faster for a birthdate) |
| **Slider** | A value on a continuous range where the *feel* matters more than precision — volume, price range | Anything where the user needs an exact number (number field with stepper) |
| **Stepper** | A small integer the user nudges — quantity, guests | Large ranges |

---

## Input

| Component | Use it for | Not for |
|---|---|---|
| **Text field** | A short single-line value. **Always with a label**, and with helper text or a placeholder only when it adds something the label does not | Long text (textarea); a choice from a known set (select) |
| **Textarea** | Multi-line free text, with a visible size hint | Short values |
| **Search field** | Searching a collection. Leading search icon, clear button once there is text, results that update as they type or on submit — decide which | Filtering a short visible list (chips) |
| **Number field** | An exact numeric value, with unit shown | Ranges (slider); small nudges (stepper) |
| **Password field** | With a show/hide toggle and inline strength/rules | — |
| **OTP / code field** | A 4–8 digit code, one cell per digit, auto-advancing | — |
| **File upload** | Drag-and-drop zone on desktop, a button on mobile; shows the file once chosen, with a remove action | — |

**Validation lives inline, next to the field, after the user leaves it** — not
in a toast, not in a modal, not only at the top of the form. The submit button
stays enabled; disabling it hides *why* the form will not go.

---

## Act

| Component | Use it for | Not for |
|---|---|---|
| **Primary button** | The one main action on the screen. **One per screen.** | Two competing primaries — pick one, demote the other |
| **Secondary button** | The alternative action next to a primary — Cancel, Back, Save draft | — |
| **Tertiary / text button** | Low-emphasis actions: "Skip", "Learn more", "Clear" | The main action |
| **Destructive button** | Delete and its relatives — the destructive color, and **always behind a modal** (see above) | Anything reversible |
| **Icon button** | A recognizable action in tight space — close, edit, more, favorite. **Needs a tooltip on desktop and a 44pt target on mobile** | Actions whose icon is not universally understood (use a label) |
| **FAB** *(mobile)* | The single most important *create* action in an app, always reachable | Anything other than create; more than one; desktop |
| **Split button / menu button** | A primary action with related variants — "Save ▾ / Save as / Save and close" | Hiding the only action |
| **Overflow menu ("⋯")** | Secondary actions on an item that do not deserve their own button — edit, duplicate, share, delete | Hiding the *primary* action on an item |
| **Sticky action bar** | On mobile, or on a long form: the primary action pinned to the bottom so it is always reachable | — |
| **Swipe actions** *(mobile)* | Row-level quick actions — archive, delete — **with a visible alternative** (an overflow menu), because swipe is undiscoverable | The only way to do something |
| **Bulk action bar** | Appears when items are selected: count, and the actions that apply to a set | — |

### The actions that get forgotten

For every collection or object screen, check the list. Each one that applies
and is missing is a defect the audit will find.

- **Create** — and it is reachable from the empty state too
- **Edit** — inline where the change is one field, a form where it is several
- **Delete / remove** — behind a modal
- **Duplicate**
- **Search**, when the collection can exceed a screen
- **Filter** and **sort**, when the collection has more than one obvious order
- **Select multiple** → bulk actions, when the user would ever act on several
- **Share / export / download**, when the object leaves the product
- **Undo**, on every reversible action
- **Retry**, on every error state
- **Refresh / pull to refresh**, on anything that changes behind the user's back
- **Sign out** and **switch account**, somewhere findable
- **Help / contact**, somewhere findable

---

## Navigate

| Component | Use it for | Not for |
|---|---|---|
| **Bottom tab bar** *(mobile)* | 3–5 primary destinations, always visible | More than 5; secondary destinations |
| **Sidebar** *(desktop)* | Persistent navigation for 5–15 destinations, grouped | Two destinations (top bar) |
| **Top nav bar** | Marketing sites; apps with 2–5 destinations | Deep hierarchies |
| **In-page tabs** | Switching between views *of the same object* — "Details / History / Files". Content changes, location does not | Navigating between different places (that is a nav bar) |
| **Breadcrumb** | Showing depth in a hierarchy deeper than two levels, with each level clickable | Flat apps; mobile |
| **Stepper / wizard** | A long task broken into ordered steps, with progress shown and back allowed | Anything under ~5 fields (one form); non-linear tasks |
| **Pagination** | Long collections on desktop, where the user may want page N | Feeds (infinite scroll with a "load more" fallback) |
| **Command palette** *(desktop)* | Power-user jump to any object or action by typing | The only navigation |
| **Back** | Always present on any pushed screen; goes where the user came from | — |

---

## Disclose and layer

| Component | Use it for | Not for |
|---|---|---|
| **Tooltip** | The name of an icon button; a one-line clarification. Hover on desktop, long-press on mobile — so **never essential information** | Anything the user must read; touch-only interfaces as the sole means |
| **Popover** | A small amount of content anchored to a trigger — a color picker, a mini form, a preview. Dismisses on outside click | Confirmations (modal); long content |
| **Dropdown menu** | A list of actions or options anchored to a trigger | Navigation (nav bar); choosing a value in a form (select) |
| **Context menu** *(desktop)* | Right-click actions on an item — **always mirrored in a visible overflow menu** | The only way to reach an action |
| **Drawer / side panel** | Detail or edit for a selected item *without leaving the list* — the list stays visible. Also settings and filters on desktop | Primary content; mobile (use a screen or a sheet) |
| **Accordion** | Long content the user scans by heading — FAQ, settings groups | Content the user needs to see all of at once; forms |
| **Expandable row** | A table row that reveals detail in place | Detail rich enough to need its own screen |

---

## Show collections

| Component | Use it for | Not for |
|---|---|---|
| **Table** | Many records with several comparable attributes — desktop. Sortable headers, right-aligned numbers, a fixed first column when wide | Mobile (list or cards); records with one or two attributes (list) |
| **List** | Records with one primary attribute and a little metadata — mobile-friendly, tappable rows | Comparing attributes across records (table) |
| **Card grid** | Records where the visual (image, preview) is the primary attribute | Dense data; records without a visual |
| **Data grid** | Spreadsheet-like editing of many cells | Read-only data (table) |
| **Kanban** | Items moving through a small number of states | More than ~6 states |
| **Timeline / activity feed** | Events in time order | Records without a time dimension |
| **Tree** | Genuinely hierarchical data — folders, org charts | Flat data with categories (grouped list) |

Every collection has an **empty state, a loading state (skeleton in the shape of
the content), and a long state** — they are in the completeness audit.

---

## Show status

| Component | Use it for | Not for |
|---|---|---|
| **Badge / pill** | A status word — Active, Pending, Failed — with a color from the direction's semantic set **and the word**, never color alone | Counts (count badge); long text |
| **Count badge** | A number on an icon — unread, cart | Zero (hide it) |
| **Status dot** | Online/offline, live/paused — next to a name | Anything needing explanation |
| **Progress bar** | Determinate progress — upload, steps completed | Unknown duration (spinner or skeleton) |
| **Skeleton** | Loading a screen or list whose *shape* is known — it holds the layout still | Very short waits under ~300ms (nothing); progress with a known end (progress bar) |
| **Spinner** | A short indeterminate wait inside a component — a button after click, a small panel | Whole-screen loading (skeleton) |
| **Avatar** | A person or organization, with initials as the fallback | Decorative images |
| **Tag** | A user-applied label, often removable | System status (badge) |

---

## Structure

| Component | Use it for | Not for |
|---|---|---|
| **Page header** | Title, optional description, and the page-level actions on the right — this is where Create usually lives on desktop | — |
| **App bar** *(mobile)* | Title, back, and at most two icon actions | Five icons |
| **Card** | A self-contained unit the user acts on as a whole — a product, a person, a summary. **Needs a reason to be a card**: it is selectable, draggable, or visually distinct content | Wrapping every section of a page; a list of text rows |
| **Section header** | Labeling a group within a page, often with a small action | — |
| **Divider** | Separating groups where space alone is ambiguous | Between every item; where a gap would do |
| **Sticky footer** | Actions that must stay reachable on a long screen | Decoration |

---

## What this catalog is not

It is not a mandate to use everything. A simple product needs a dozen of these,
not sixty. The base component set built in phase 6 is the subset this product's
screens actually need — decided by walking the screen inventory and asking, for
each screen, which jobs from this file it does.

And it does not override the direction. The catalog says *which* component;
`design/design-direction.md` says what it looks like. A modal is still a modal
in a dense editorial direction and in an airy utilitarian one.
