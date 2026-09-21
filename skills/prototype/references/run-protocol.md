# Run protocol

Read this at Step 0 and whenever a phase ends. It covers the branch, the
commits, the run state file, and how a run resumes. None of it is design; all
of it is what makes a long unattended run recoverable and reviewable.

## The branch

Design commits are frequent — one per phase, plus one per change decision — and
they land in a repository the user is also working in. Rules:

- If the current branch is the repository's default branch (`main`, `master`,
  or whatever `origin/HEAD` points at), **create `design/<YYYY-MM-DD>` from it
  and work there**. Ten commits appearing on `main` without a review is
  intrusive; a branch the user can merge or discard is not.
- If the current branch is anything else, stay on it — the user chose it.
- If the tree is dirty at Step 0 with changes outside `design/`, leave them
  alone: commit only `design/`, never `git add -A`.
- Say which branch will receive the commits in the Step 0 message, in the same
  breath as the canvas ask, so the user hears it before the run goes quiet.

## The commits

At the end of every phase, and after every change decision:

```
scripts/pen-save.sh <abs path>/design/prototype.pen   # app mode only; headless saves itself
git add design/
git commit -m "design: phase 6 — system tokens and base components"
```

A save that fails is an error to resolve before committing, never a
"canvas save pending" note in the message: a commit without the canvas
cannot be reset to.

Always `git add design/` — the path, not `-A`, not `.`. The canvas and the
documents go together in one commit so a `git reset` to a phase restores both.

Message shapes:

| Event | Message |
|---|---|
| Phase end | `design: phase <N> — <phase name>` |
| Change decision | `design: <add\|amend\|extend> — <one-line title> (<raised by>, <finding ref>)` |
| Audit fix cycle | `design: phase 8 — fix cycle <n> for <screen>` |
| Incremental round | `design: <what was asked> — phases <list>` |

`design/screens/` is never committed; phase 10 writes a `.gitignore` inside
it (`handoff.md`). The logo previews under `design/brand/logo/preview/` are.

## The run state: `design/run.md`

Written at Step 0, updated at every commit. It is the index a resumed session
reads first, and the summary the user reads to see what happened.

```markdown
# Run — 2026-09-11

- **Mode:** bootstrap | incremental
- **Request:** <the user's request, one line>
- **Language:** <detected>
- **Branch:** design/2026-09-11
- **Canvas:** /abs/path/design/prototype.pen
- **Access:** headless | app (desktop | vscode)
- **Targets:** desktop (primary) + mobile · light (default) + dark · depth core

| Phase | Status | Commit | Note |
|---|---|---|---|
| 1 Intake | done | a1b2c3d | spec written by the skill (discover did not run) |
| 2 Research | done | b2c3d4e | |
| 3 Brand | skipped | — | brand supplied by the user |
| 4 Direction | done | c3d4e5f | chosen: "Ledger" |
| 5 Canvas structure | done | d4e5f6a | |
| 6 System | done | e5f6a7b | 41 tokens, 14 components |
| 7 Screens | in progress | — | Flow — Shipments done; Flow — Reports building |
| 7b Layout review | pending | | |
| 8 Audit | pending | | |
| 9 Organization sweep | pending | | the audit's final pass |
| 10 Handoff | pending | | |

## Changes
<one line per entry in design/changes.md: date — kind — title — commit>

## Open findings
<carried from the latest audit; empty until phase 8>
```

Status values: `pending`, `in progress`, `done`, `skipped` (with the reason),
`redone` (with the commit that was reset to). A phase that was reset and redone
keeps both rows, so the history stays visible.

## Resuming

A resumed session, or a request that says "continue":

1. Read `design/run.md`. The first row that is not `done` or `skipped` is where
   the run stopped.
2. `git status`. A dirty `design/` means that phase was interrupted mid-way:
   `git stash` or `git checkout -- design/` to return to the last commit — the
   phase is redone from its start, not patched from the middle.
3. Step 0 again, in the mode `run.md` names: app mode → `get_app_state`,
   the canvas must be `design/prototype.pen`; headless → the file must not
   be open in an app. Check out the branch named in `run.md`.
4. Continue from that phase. Mode detection still applies: with
   `design/design-direction.md` present, phases 2 and 4 are not redone.
5. Half-built frames left on the canvas carry `placeholder: true`; the organization
   sweep catches them (check 12 in `canvas-structure.md`), and a redone phase 7
   flow finds them by name and updates in place rather than duplicating.

## Rollback

When the audit condemns a phase — a `direction` failure amended twice in one
round, a token set that leaks into every screen — go back to that phase's
commit and redo it:

```bash
git log --oneline -- design/
git reset --hard <sha of the last good phase>
```

Then mark the redone phases in `run.md` and continue. Never patch a bad
foundation on top of itself.
