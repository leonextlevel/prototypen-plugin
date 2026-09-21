#!/usr/bin/env bash
# PreToolUse guard for Bash: the headless canvas runner may only target
# <project>/design/prototype.pen, the same rule guard-canvas-path.sh applies
# to the MCP. Any `pen-run.sh` or `pen-save.sh` call whose .pen argument
# resolves elsewhere is denied before it runs.
#
# Exit 2 blocks the call and feeds stderr back to the model.

set -u
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
elif command -v python3 >/dev/null 2>&1; then
  cwd="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("cwd",""))')"
  cmd="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("command",""))')"
else
  exit 0
fi

printf '%s' "$cmd" | grep -Eq 'pen-(run|save)\.sh' || exit 0
[ -n "$cwd" ] || cwd="$PWD"

norm() {
  if command -v realpath >/dev/null 2>&1; then realpath -m "$1" 2>/dev/null || printf '%s' "$1"
  elif command -v python3 >/dev/null 2>&1; then python3 -c 'import os,sys; print(os.path.normpath(sys.argv[1]))' "$1"
  else printf '%s' "$1"; fi
}
target="$(norm "$cwd/design/prototype.pen")"

for tok in $(printf '%s' "$cmd" | tr -s ' ;&|' '\n' | grep -E '\.pen$'); do
  case "$tok" in /*) abs="$tok" ;; *) abs="$cwd/$tok" ;; esac
  abs="$(norm "$abs")"
  if [ "$abs" != "$target" ]; then
    echo "prototypen: headless canvas call targets '$tok' (resolves to '$abs'); the only allowed canvas is '$target'." >&2
    exit 2
  fi
done
exit 0
