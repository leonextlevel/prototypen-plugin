# Adjustment verification

Read this before applying any change to a prototype that already exists: an
incremental request from the user ("make the header shorter", "move the
filter into a drawer", "the amounts should be right-aligned"), an audit fix,
a layout fix, a component change. It is written as a procedure with the
snippets in it, because the failure it prevents is specific: **a change is
applied, the agent says "done", and nothing checked that the change is
there, that it is right, and that nothing else moved.** Judgment is not
required to follow it; every step ends in a printed number or a PASS/FAIL.

The procedure is the same in app mode and headless; in headless each
snippet is a file run through `scripts/pen-run.sh`, and the snapshots are
kept as files under the scratchpad.

## 0a. Check the request against the rules that already exist

A prototype that exists is a set of decisions: the direction, the brand,
the spec, the canvas structure and the craft rules. A request for an
adjustment can contradict one of them without the person asking knowing
it, and applying it silently either erodes the rule (the next screen will
not match) or produces a screen the audit fails on the next round. So,
**before the request becomes checks, it is compared with the rules, and a
conflict is a question to the user, not a decision.**

Who asks depends on when. **During the autonomous run** (phases 1 to 10,
including its fix cycles) nobody asks: a conflict goes through
`change-protocol.md` and the orchestrator decides. **In adjustment mode**,
which is any request after a run has reached handoff (`design/design-spec.md`
exists and `run.md` has no phase in progress), the person is present and
the change is theirs, so **whoever is applying it asks**: the orchestrator
when it finds the conflict at this step, the designer when it finds one
while working. A designer cannot address the user directly; it ends its
turn with a `QUESTION` block in the shape below, the orchestrator relays it
**verbatim** (no summary, no answer of its own) with `AskUserQuestion`, and
resumes the **same** designer with the answer (`SendMessage`), so the
context that found the conflict is the one that applies the decision.

```
QUESTION (adjustment mode)
Rule: <file, one quoted sentence>
Request: <what was asked>
Conflict: <what applying it would break, and where else the rule shows>
Options: 1 amend the rule and propagate to <screens> · 2 exception on <screen> only · 3 keep the rule and do <the nearest thing inside it>
Recommendation: <one of the three, one line why>
```

Walk the request against these five sources, and write one line per
source: "no conflict" or the rule it hits, quoted:

| Source | What to compare the request with |
|---|---|
| `design/design-direction.md` | the committed choice and the personality sentence; the token inventory (a value the request names that is not a token, or a token used for a different role); the alignment posture; the navigation system per viewport; the density and grid per viewport; the anti-generic justifications (a request that asks for something on the ban list) |
| `design/brand.md` | the palette (a color outside it), the type pairing, the tone of voice (copy the request dictates), the logo rules, "what the brand is not" |
| `design/product-spec.md` | the Targets table (a viewport or theme the request assumes and the spec did not declare), Out of scope, the navigation map (a request that removes a way in or out, or adds a screen with no route), the specific-state table (a state the request wants that becomes a generic one in disguise) |
| `canvas-structure.md` | a second `.pen`, a loose node at the root, a screen outside its flow's group, a generic state as a row, an overlay in context twice |
| the craft rules (`designer-brief.md` §2, §4, §6) | a device height or a clip, content dropped to fit, a destructive action without confirmation, a confirmation on a reversible one, an error in a toast, a hardcoded value, a second icon library, a centered paragraph, a paragraph of fragments |

Also the reverse: the change the request implies on **other screens**
(a header shorter on one screen is a header shorter on every screen that
instances it; a renamed action changes the navigation map). List them; they
are collateral by design and go in the checks, not a conflict.

**When there is a conflict**, stop and ask, once, in the user's language.
The message names the rule (file and line, quoted in one sentence), says
what the request would break and where else it shows, and offers exactly
these choices, in this order:

1. **Amend the rule** and apply the change everywhere it applies. The
   direction, brand or spec gets a dated `## Amendments` entry
   (`change-protocol.md`), and the propagation list becomes part of the
   checks: every screen the rule covers is touched, and step 3's diff is
   run on each.
2. **Apply it as a named exception** on this screen only. The rule stays;
   the exception is recorded in `design/changes.md` and in the direction's
   amendments as "exception: <screen>, <what>, <why>", so the audit does
   not fail it on the next round and the next designer does not copy it.
3. **Keep the rule** and reshape the request: say what would satisfy the
   intent inside the rule (a different token, the overlay the catalog
   names, the state as an exemplar), and do that instead.

Do not proceed on any of the three until the answer arrives, and do not
pick one to keep moving: an adjustment is the user's request, and a
question is cheaper than a wrong change on their prototype. A request with
no conflict, or one whose only effect on other screens is expected
collateral, continues without asking. The same applies to a request that
is ambiguous in a way the checks table cannot resolve (two readings that
would change different nodes): ask, in the same block, with the readings
as the options.

## 0b. Turn the request into checks before touching anything

Write, in your working notes, one row per observable fact the request
implies. If you cannot write the check, you do not understand the request;
ask the orchestrator (or, at the top level, the user) before changing
anything.

| The request says | What must be true afterward | How it is checked |
|---|---|---|
| "right-align the amounts" | every amount cell in `Table / Row` has `textAlign: "right"`, and every amount's `bounds.x + width` equals the column's right edge within 1px; the header cell too | `Get` visitor on the cells, printing `textAlign` and right edges |
| "move the filter into a drawer" | a `Drawer` instance exists on the screen with the filter's controls inside it; the old inline filter is gone; the drawer has a dismiss and an apply action; the navigation map has a row for it | `Get` by name for the drawer and for the old filter (must be absent); the spec's map |
| "make the header shorter" | the header frame's `bounds.height` equals the new value from the direction; every screen in the flow that instances the header shows the same height; nothing below the header overlaps it | bounds visitor over the header on every screen of the flow |

Two rules for the table: a value is a number or a token name, never "looks
right"; and every row names the nodes it covers (by name, then id once
found), so that "every amount cell" means a list you actually walked. When
step 0a ended in an amendment or an exception, the table carries that too:
the amendment's propagation rows, or the exception's entry in
`design/changes.md`.

## 1. Snapshot before

One visitor over each screen the change will touch, and over its **row**
(the versions beside it), printing one line per node: id, name, type,
bounds, and the properties the change is about. Keep the output.

```js
snap = (rootId, tag) => Get(rootId, (n, c) => Print(tag, "|", n.id, "|", n.name, "|", n.type, "|",
  Math.round(c.bounds.x), Math.round(c.bounds.y), Math.round(c.bounds.width), Math.round(c.bounds.height), "|",
  n.type === "text" ? (n.textAlign || "left") + " " + (typeof n.content === "string" ? n.content.slice(0, 40) : "") : (n.layout || "") + " " + (n.alignItems || "") + " " + (n.justifyContent || "")))
snap(screenId, "BEFORE")
```

In headless, save the printed block to `<scratch>/before-<screen>.txt`. In
app mode it stays in your context; do not summarize it away.

## 2. Apply the change at its cause

- A **component** change goes on the `reusable: true` node in the Design
  System, never on an instance, so every instance follows. Then list the
  instances (`Get(n => n.ref === componentId && Print(n.id, n.name))`)
  because step 4 walks them.
- A **layout** change goes on the parent (`alignItems`, `justifyContent`,
  `gap`, `padding`, a child's `fill_container`), never on a child's `x`/`y`.
- A **content** change goes on the text node's `content`; if the new text
  is longer, `textGrowth` and the width are part of the change.
- A **structural** change (a new overlay, a moved section) follows
  `canvas-structure.md`: the new thing is named per the table, sits in the
  right row, and the old thing is removed, not hidden.
- Never delete and recreate a screen to change it; `Update` in place.

## 3. Snapshot after, and diff

Run the same visitor with `"AFTER"`. Then compare, line by line, in one of
two ways:

- **Headless:** `diff <(grep BEFORE before.txt | cut -d'|' -f2-) <(grep AFTER after.txt | cut -d'|' -f2-)`.
- **App mode:** print only what changed. Store the before values in the
  snippet's globals and print the differences:

```js
before = {}
Get(screenId, (n, c) => { before[n.id] = [Math.round(c.bounds.x), Math.round(c.bounds.y), Math.round(c.bounds.width), Math.round(c.bounds.height)].join(",") })
```
…apply the change (same or later call)…
```js
Get(screenId, (n, c) => { v = [Math.round(c.bounds.x), Math.round(c.bounds.y), Math.round(c.bounds.width), Math.round(c.bounds.height)].join(","); if (before[n.id] !== v) Print("MOVED", n.id, n.name, before[n.id] || "new", "->", v) })
Get(screenId, n => n.id in before && delete before[n.id]); for (id in before) Print("GONE", id)
```

Read the diff against the table from step 0:

- Every node the request meant to change appears with the expected value:
  **the request is applied.** If a row of the table has no matching
  change, it is not done; go back to step 2.
- Every node that appears and is **not** in the table is collateral. A
  sibling moving because its parent's gap changed is expected and goes in
  the report; a node on another screen moving, a node disappearing, or a
  version in the row losing its top alignment is a defect: fix, re-snapshot.

## 4. The mechanical pass on everything touched

The self-review from `screen-craft.md` §7, run on each touched screen and on
each instance listed in step 2:

```js
Get(screenId, (n, c) => {
  if (c.problems) Print("CLIP", n.id, n.name, c.problems)
  if (n.type === "text" && !n.fill) Print("NOFILL", n.id, n.name)
  if (typeof n.fill === "string" && n.fill.startsWith("#")) Print("LITERAL", n.id, n.name, n.fill)
  if (n.placeholder) Print("PLACEHOLDER", n.id, n.name)
})
```

Then, on the container the change lives in, the numeric checks from
`layout.md` §6 that apply: left edges, cross-axis centers (§1b), gaps on
the scale, widths in the group, trailing values' right edge. Print the
numbers; compare; fix the cause; rerun until the visitor prints nothing.

If the change touched text longer than a label, run it through
`scripts/prose-check.py --text "<content>"` (`writing.md`).

## 5. Look once, as a stranger

One screenshot of the touched screen (`TakeScreenshot([screenId])` in app
mode; `Export` to PNG and Read in headless), and one of the **row** when
the screen has other versions, so the top alignment is seen. Go through
the visual list in `screen-craft.md` §7 in order (misalignment, crowding,
edge contact, cut content, wrong token, contrast, text problems, confusion,
missing). Anything found goes back through steps 2 to 4; at most two
passes, then it is an open item in the report.

## 6. Propagate what the change implies

- A new state, screen or overlay → its row in the spec's inventory and
  navigation map, and the state tables (`product-spec.md`), by the
  orchestrator.
- A changed token or component → `design/design-direction.md`'s inventory
  or component list, and every instance walked in step 4.
- A changed control the navigation map names → the map row still holds:
  the "entered from" control exists with its label, the "exits to" control
  exists.
- A changed screen with a PNG export → the export is stale;
  `design/screens/.exported` is cleared so the next handoff re-exports.

## 7. Save and report

In app mode, `scripts/pen-save.sh` runs before anything is reported. The
report has a fixed shape; a report without it is not accepted by the
orchestrator:

```
Request: <one line>
Rules checked: no conflict | conflict with <rule>, resolved as <amend | exception | reshaped> by the user
Checks:
- [PASS] <row from step 0> — <node names/ids, measured value>
- [PASS] …
- [FAIL] <row> — <what is still wrong, what was tried>
Collateral: <nodes that moved as expected, one line> | none
Mechanical pass: clean | <what remains, named>
Screenshot read: nothing found | <what remains>
Propagation: <spec rows, direction entries, instances walked> | none needed
Saved: yes (app mode) | by pen-run.sh (headless)
```

"Done" without the checks is the failure this file exists for. An honest
`[FAIL]` line costs the orchestrator one decision; an unverified `[PASS]`
costs a round.
