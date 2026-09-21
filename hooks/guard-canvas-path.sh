#!/usr/bin/env bash
# PreToolUse guard for mcp__pencil__execute.
#
# `execute` against a filePath that does not exist does not fail — it silently
# writes into whatever canvas is active in the editor (verified on the live
# server, see skills/prototype/references/pencil-mcp.md). This hook makes the
# rule "every write targets <project>/design/prototype.pen" mechanical: any
# execute whose filePath resolves elsewhere is denied before it runs.
#
# Exit 2 blocks the call and feeds stderr back to the model.

set -u
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
  fp="$(printf '%s' "$input" | jq -r '.tool_input.filePath // empty')"
elif command -v python3 >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("cwd",""))')"
  fp="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("filePath",""))')"
else
  echo "prototypen: neither jq nor python3 available; canvas-path guard skipped." >&2
  exit 0
fi

[ -n "$cwd" ] || cwd="$PWD"

if [ -z "$fp" ]; then
  echo "prototypen: execute called without filePath. Pass the absolute path of <project>/design/prototype.pen — a missing or wrong path silently writes into whatever canvas is active." >&2
  exit 2
fi

case "$fp" in
  /*) abs="$fp" ;;
  *)  abs="$cwd/$fp" ;;
esac

norm() {
  if command -v realpath >/dev/null 2>&1; then realpath -m "$1" 2>/dev/null || printf '%s' "$1"
  elif command -v python3 >/dev/null 2>&1; then python3 -c 'import os,sys; print(os.path.normpath(sys.argv[1]))' "$1"
  else printf '%s' "$1"; fi
}

abs="$(norm "$abs")"
target="$(norm "$cwd/design/prototype.pen")"

if [ "$abs" != "$target" ]; then
  echo "prototypen: execute filePath is '$fp' (resolves to '$abs'); the only allowed canvas is '$target'. A path that does not exist silently writes into the active canvas. Run get_app_state, confirm design/prototype.pen is the active editor, and pass its absolute path." >&2
  exit 2
fi

if [ ! -f "$target" ]; then
  echo "prototypen: '$target' does not exist on disk. execute would silently write into whatever canvas is active. Create the file (Step 0 of the prototype skill) and have the user open it before writing." >&2
  exit 2
fi

exit 0
