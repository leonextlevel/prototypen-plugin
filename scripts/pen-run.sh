#!/usr/bin/env bash
# Headless canvas access: runs one or more JavaScript snippet files against a
# .pen file through the pen.dev CLI, then saves and exits. No app needs to be
# open; the file on disk is the canvas.
#
#   scripts/pen-run.sh <file.pen> <snippet.js> [<snippet.js> ...]
#
# Each snippet becomes one execute() call in the same session, so ids
# assigned without const/let carry over between snippets. Output is the
# CLI's, with base64 screenshots stripped: verify visuals with Export to PNG
# and read the file, not with TakeScreenshot.
#
# Refuses to run when the same file is the active editor of a running pen.dev
# app: the app keeps its own copy in memory and a Ctrl+S there would overwrite
# what this run writes. Close the tab first.

set -u
[ $# -ge 2 ] || { echo "usage: $0 <file.pen> <snippet.js> [...]" >&2; exit 64; }
PEN="$1"; shift
command -v pen >/dev/null 2>&1 || { echo "prototypen: the pen.dev CLI is not installed. npm install -g @pen.dev/cli, then pen login." >&2; exit 69; }
command -v node >/dev/null 2>&1 || { echo "prototypen: node is required." >&2; exit 69; }
case "$PEN" in /*) ;; *) PEN="$PWD/$PEN" ;; esac

sock="$HOME/.pencil/socket/pencil-desktop.sock"
if [ -S "$sock" ]; then
  active="$(printf 'get_app_state()\nexit()\n' | timeout 30 pen interactive -a desktop 2>/dev/null \
    | grep -o 'Currently active canvas editor: `[^`]*`' | head -1 | sed 's/.*`\(.*\)`/\1/')"
  if [ -n "$active" ] && [ "$active" = "$PEN" ]; then
    echo "prototypen: '$PEN' is open as the active editor in the pen.dev desktop app. Headless writes would be overwritten by the next Ctrl+S there. Ask the user to close that tab (or switch to app mode with scripts/pen-save.sh), then retry." >&2
    exit 75
  fi
fi

{
  for js in "$@"; do
    [ -f "$js" ] || { echo "prototypen: snippet '$js' not found" >&2; exit 66; }
    printf 'execute(%s)\n' "$(node -e 'process.stdout.write(JSON.stringify({input: require("fs").readFileSync(process.argv[1],"utf8")}))' "$js")"
  done
  echo 'save()'
  echo 'exit()'
} | { if [ -f "$PEN" ]; then pen interactive -i "$PEN" -o "$PEN"; else pen interactive -o "$PEN"; fi; } 2>&1 \
  | sed -E 's/"image": "[A-Za-z0-9+\/=]+"/"image": "<base64 stripped; Export to PNG and read the file>"/' \
  | grep -vE '^\s*$|^\[2m(File|Type|Type save)|Interactive Shell'
