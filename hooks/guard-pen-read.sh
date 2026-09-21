#!/usr/bin/env bash
# PreToolUse guard for Read / Grep / Glob / Bash.
#
# .pen files are read only through the Pencil MCP (Get visitors, GetVariables,
# TakeScreenshot). Reading one with a file tool dumps a document that can be
# hundreds of kilobytes into the context, and the MCP server describes the
# format as opaque. This hook denies the obvious ways of doing it by accident.
# Git operations on .pen files (add, diff, checkout) are not affected.
#
# Exit 2 blocks the call and feeds stderr back to the model.

set -u
input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
  file_path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
  path="$(printf '%s' "$input" | jq -r '.tool_input.path // empty')"
  pattern="$(printf '%s' "$input" | jq -r '.tool_input.pattern // empty')"
  glob="$(printf '%s' "$input" | jq -r '.tool_input.glob // empty')"
  command_str="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
elif command -v python3 >/dev/null 2>&1; then
  read -r tool file_path path pattern glob < <(printf '%s' "$input" | python3 -c '
import json,sys
d=json.load(sys.stdin); t=d.get("tool_input") or {}
print(d.get("tool_name",""), t.get("file_path",""), t.get("path",""), t.get("pattern",""), t.get("glob",""))')
  command_str="$(printf '%s' "$input" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("command",""))')"
else
  exit 0
fi

deny() {
  echo "prototypen: $1 .pen files are read only through the Pencil MCP — Get visitors with ctx.bounds/ctx.problems, Print(GetVariables()), TakeScreenshot. See skills/prototype/references/pencil-mcp.md." >&2
  exit 2
}

case "$tool" in
  Read)
    case "$file_path" in *.pen) deny "Read on '$file_path' is blocked." ;; esac ;;
  Grep)
    case "$path" in *.pen) deny "Grep on '$path' is blocked." ;; esac
    case "$glob" in *.pen*) deny "Grep with glob '$glob' would read .pen files." ;; esac ;;
  Glob)
    case "$pattern" in *.pen) deny "Glob for '$pattern' is pointless — the canvas is always design/prototype.pen." ;; esac ;;
  Bash)
    stripped="$(printf '%s' "$command_str" | sed -E 's/>>?[[:space:]]*[^[:space:];&|]*\.pen//g')"
    if printf '%s' "$stripped" | grep -Eq '(^|[;&|[:space:]])(cat|head|tail|less|more|grep|rg|sed|awk|strings|jq|xxd|hexdump|python3?|node)([[:space:]]+[^;&|]*)?[[:space:]][^[:space:];&|]*\.pen([[:space:]]|$|[;&|])'; then
      deny "Shell command reads a .pen file."
    fi ;;
esac

exit 0
