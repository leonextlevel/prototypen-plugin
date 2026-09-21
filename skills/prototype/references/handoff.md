# Handoff

Read this at phase 10, and again from `/prototypen:finalize`. The output is
`design/design-spec.md` plus the exported deliverables a reader without
pen.dev can consume: an implementing agent, a stakeholder, the user on a
phone, the eval baselines.

## What phase 10 produces

```
design/
├── design-spec.md               the handoff document (template: design-spec.template.md)
├── tokens.json                  every variable, W3C Design Tokens format, all themes
├── tokens.css                   the same as CSS custom properties, one block per theme
└── screens/                     unversioned: a .gitignore inside it ignores everything
    ├── <flow-slug>/
    │   ├── <NN>-<screen-slug>-<viewport>.png          one PNG per screen version
    │   ├── <NN>-<screen-slug>-<viewport>-<state>.png  and per state or overlay variant
    │   ├── <NN>-<screen-slug>-<viewport>-dark.png     and per theme copy
    │   └── index.html                                 the flow exported as HTML
    ├── design-system/components.png
    └── brand/brand.png
```

Slugs are the English canvas names lowercased, with every run of spaces,
`/`, `—`, `@` and other punctuation replaced by one `-`: `03 Payment Method
/ Mobile — Error` → `03-payment-method-mobile-error`; `03 Payment Method /
Mobile @ Dark` → `03-payment-method-mobile-dark`; `Flow — Checkout` →
`flow-checkout`.

## Screens are not versioned

The exports exist so a reader can validate the prototype without the
editor; they are regenerated from the canvas on every handoff and by
`/prototypen:finalize`, so they carry no history worth keeping, and they are
binary. Before exporting, write `design/screens/.gitignore` containing:

```
*
!.gitignore
```

`git add design/` then skips them. The eval baselines copy from the folder
on disk (`evals/README.md`), which still works. The logo previews under
`design/brand/logo/preview/` stay versioned; they are few and the logo has
no other visible form outside SVG.

## Export only what changed

Before exporting, compare the canvas commit with the last export:
`design/screens/.exported` holds the `git log -1 --format=%H --
design/prototype.pen` of the canvas the exports came from. If it matches the
current one and the folder is populated, skip the exports and say so; the
brasario finalize re-exported 524 PNGs twice for a canvas that had not
changed. Write the new hash after a successful export. (The file sits inside
`screens/`, so it is unversioned like the rest.)

## Screens → PNG

`Export(nodeIds, "png", outputDir)` writes one file per node named
`<nodeId>.png`. Node ids are not names, so:

1. Per flow region, collect `[{id, name}]` of every **screen version and
   variant** (the leaves of the group/row structure: a `Get` visitor that
   skips frames named `… / Group` and `… / Row — …`) and `Export` them all
   into an absolute path under `design/screens/<flow-slug>/`. One `Export`
   call per region. The state exemplars are exported once with the Design
   System region, under `design/screens/design-system/states/`.
2. Rename `<nodeId>.png` → `<slug>.png` from the id→name list with a shell
   loop. Do not re-export to fix a name.

Default 2× scale. Export the Design System region and the Brand region as
one image each the same way.

## Screens → HTML

`Export(nodeIds, "html-css", "<absolute path>/design/screens/<flow-slug>/index.html")`
puts all of a flow's screens into one HTML file with CSS, assets referenced
relatively. This is what an implementing agent reads as markup.

**TO VERIFY:** whether `TextStyle.href` survives the HTML export as `<a
href>`. If it does, the navigation map can be made real by setting `href`
on every control the map names; until confirmed, the map in
`design-spec.md` is the routing table and the HTML is static.

## Tokens → `tokens.json`

From `Print(GetVariables())`, in the [W3C Design Tokens](https://tr.designtokens.org/format/)
shape. `$value` carries the default theme's value; the other themes go in
`$extensions`:

```json
{
  "$schema": "https://tr.designtokens.org/format/",
  "color": {
    "surface": {
      "$type": "color",
      "$value": "#F8F5F0",
      "$extensions": { "prototypen": { "themes": { "light": "#F8F5F0", "dark": "#1A1A1A" } } }
    }
  },
  "space": { "2": { "$type": "dimension", "$value": "8px" } },
  "font": { "body": { "$type": "fontFamily", "$value": "Fraunces" } }
}
```

Grouping follows the variable name's first segment. `$type` by Pencil type:
`color` → `color`; `number` → `dimension` with `px` for spacing, radius,
border and size, `number` for ratios, weights and durations (by name
prefix); `string` → `fontFamily` for `font-*`, otherwise `string`;
`boolean` → `boolean`.

## Tokens → `tokens.css`

```css
:root {
  --color-surface: #F8F5F0;
  --space-2: 8px;
  --font-body: "Fraunces";
}
[data-theme="dark"] {
  --color-surface: #1A1A1A;
}
```

`:root` is the default theme; every other theme gets a `[data-theme]` block
with only the tokens that differ. Names are the canvas variable names,
prefixed `--`.

## The screen table is generated, never typed

One row per screen version is data the canvas already holds. Do not write it
by hand (the brasario spec carried 521 hand-typed rows, twice). One snippet
prints the Markdown rows; paste its output under `## Screens`:

```js
slug=s=>s.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,"")
Get((n,c)=>{
  if(c.depth===0){if(!n.name.startsWith("Flow — "))c.skipChildren();return}
  if(!/ \/ Row — /.test(c.parentCtx.node.name))return
  c.skipChildren()
  flow=c.parentCtx.parentCtx.parentCtx.node.name.replace("Flow — ","")
  screen=n.name.split(" / ")[0]
  version=n.name.slice(screen.length+3)||"base"
  Print("| "+flow+" | "+screen+" | "+version+" | `"+n.name+"` (`"+n.id+"`) | `screens/"+slug("flow-"+flow)+"/"+slug(n.name)+".png` |")
})
```

A version is any direct child of a `… / Row — …` frame (region → group →
row → version, `canvas-structure.md` §4). Check the first three rows against
the canvas before pasting the rest. In headless, run it through `pen-run.sh`
and copy the `Print` output.

## Then `design-spec.md`

From `templates/design-spec.template.md`, in the voice of `writing.md`. It
references the files above instead of restating them: token tables carry
canvas name → code name → use and point at `tokens.json` for values; the
screen table is the generated one above, plus one row per state exemplar;
the navigation map is the one verified by the audit. It also carries the
open findings from the latest audit and the run summary from `design/run.md`.

## Commit

Phase 10 commits `design/` (the `.gitignore` keeps `screens/` out). Then the
skill mentions, in one line, `/prototypen:finalize` and `/prototypen:roadmap`.
