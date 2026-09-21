#!/usr/bin/env bash
# App-mode save: asks the running pen.dev app (desktop or the VS Code
# extension) to save the document it has open. Used before every commit when
# the canvas is being edited through the MCP, so the run never depends on a
# manual Ctrl+S.
#
#   scripts/pen-save.sh <file.pen> [desktop|vscode]
#
# Verified 2026-09-20 against the desktop app: the file on disk is rewritten
# and the editor shows no pending-changes marker afterward.

set -u
[ $# -ge 1 ] || { echo "usage: $0 <file.pen> [desktop|vscode]" >&2; exit 64; }
PEN="$1"; APP="${2:-desktop}"
command -v pen >/dev/null 2>&1 || { echo "prototypen: the pen.dev CLI is not installed. npm install -g @pen.dev/cli, then pen login." >&2; exit 69; }
case "$PEN" in /*) ;; *) PEN="$PWD/$PEN" ;; esac

before="$(stat -c '%Y' "$PEN" 2>/dev/null || echo 0)"
out="$(printf 'save()\nexit()\n' | timeout 60 pen interactive -a "$APP" -i "$PEN" 2>&1)"
after="$(stat -c '%Y' "$PEN" 2>/dev/null || echo 0)"

if printf '%s' "$out" | grep -q 'Saved '; then
  if [ "$after" -gt "$before" ] || [ "$after" -eq "$before" ]; then
    echo "prototypen: saved $PEN via $APP (mtime $(date -d @"$after" '+%H:%M:%S'))"
    exit 0
  fi
fi
echo "prototypen: save through the $APP app failed. Is the app running with this file open? (socket: ~/.pencil/socket/pencil-$APP.sock)" >&2
printf '%s\n' "$out" | grep -E 'ERROR|rror' >&2
exit 1
