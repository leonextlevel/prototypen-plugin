#!/usr/bin/env python3
"""Flags the mechanical tells of generated prose in Markdown or plain text.

    scripts/prose-check.py <file.md> [more files...]
    scripts/prose-check.py --text "<string>"        # one string, e.g. canvas copy

Exit 1 when anything is flagged, 0 otherwise. Output is one line per finding
with the file, the line and the reason, so it reads like a linter.

What it flags, and why (skills/prototype/references/writing.md):

  STACCATO   three or more consecutive short sentences (<= 9 words) in one
             paragraph: ideas separated by periods where one sentence with a
             connective, or a list, would read as a person wrote it
  DENSE      a paragraph whose sentences average under 10 words
  DASH       an em dash or travessão used as a connector
  FRAGMENT   "Not X. Y." and "X. Not Y." emphasis fragments
  CONTRAST   "not X, it is Y" / "não é X, é Y" reflex
  TRIAD      three bolded lead-in bullets in a row
  WORD       inflated vocabulary (seamless, robust, leverage, ...)

Code blocks, tables and headings are skipped. Lists are checked per item.
"""
import re
import sys

SHORT = 9
INFLATED = {
    "en": ["seamless", "robust", "leverage", "elevate", "delve", "crucial",
           "empower", "streamline", "unlock", "journey", "ecosystem",
           "cutting-edge", "game-changer", "holistic", "synergy"],
    "pt": ["robusto", "alavancar", "elevar", "crucial", "empoderar",
           "otimizar a jornada", "jornada do usuário", "ecossistema",
           "sinergia", "impactante", "disruptivo", "desbravar"],
}
ABBREV = re.compile(r"\b(e\.g|i\.e|etc|vs|Dr|Sr|Sra|St|No|Nº|approx|ca)\.$", re.I)


def sentences(par):
    par = re.sub(r"`[^`]*`", "x", par)
    par = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", par)
    parts, buf = [], ""
    for tok in re.split(r"(?<=[.!?])\s+", par.strip()):
        buf = (buf + " " + tok).strip()
        if ABBREV.search(buf) or re.search(r"\b\d+\.$", buf):
            continue
        parts.append(buf)
        buf = ""
    if buf:
        parts.append(buf)
    return [p for p in parts if re.search(r"\w", p)]


def words(s):
    return len(re.findall(r"[\w'’-]+", s))


def check_paragraph(par, where, out):
    sents = sentences(par)
    if not sents:
        return
    run = 0
    for s in sents:
        if words(s) <= SHORT:
            run += 1
            if run == 3:
                out.append((where, "STACCATO", "three short sentences in a row: " + " ".join(sents)[:120]))
        else:
            run = 0
    if len(sents) >= 4 and sum(words(s) for s in sents) / len(sents) < 10:
        out.append((where, "DENSE", "%d sentences averaging %.0f words" % (len(sents), sum(words(s) for s in sents) / len(sents))))
    if re.search(r"\s[—–]\s|\w—\w", par):
        out.append((where, "DASH", "em dash used as a connector"))
    for s in sents:
        if re.match(r"^(Not|Nem|Não)\s+\w[^.!?]{0,40}[.!?]$", s) and words(s) <= 5:
            out.append((where, "FRAGMENT", s))
    if re.search(r"\b(is|are|it's|isn't)\s+not\s+(about\s+)?[^,;.]{1,40}[,;]\s*(it|this|that)\s+(is|'s)\b", par, re.I) or \
       re.search(r"\bnão\s+(é|se trata de)\s+[^,;.]{1,40},\s*(é|mas)\b", par, re.I):
        out.append((where, "CONTRAST", "\"not X, it is Y\" reflex"))
    low = par.lower()
    for lang, ws in INFLATED.items():
        for w in ws:
            if re.search(r"\b" + re.escape(w) + r"\b", low):
                out.append((where, "WORD", w))


def check_text(text, name, out):
    lines = text.split("\n")
    in_code = False
    par, start = [], 0
    bold_bullets = 0

    def flush(end):
        if par:
            check_paragraph(" ".join(par), "%s:%d" % (name, start + 1), out)
        par.clear()

    for i, line in enumerate(lines):
        if line.strip().startswith("```"):
            in_code = not in_code
            flush(i)
            continue
        if in_code:
            continue
        s = line.strip()
        if not s or s.startswith("#") or s.startswith("|") or s.startswith("---") or s.startswith(">") and len(s) < 4:
            flush(i)
            bold_bullets = 0 if not s.startswith("|") else bold_bullets
            continue
        if re.match(r"^([-*+]|\d+\.)\s", s):
            flush(i)
            body = re.sub(r"^([-*+]|\d+\.)\s+", "", s)
            if re.match(r"^\*\*[^*]+\*\*[:.]?\s", body):
                bold_bullets += 1
                if bold_bullets == 3:
                    out.append(("%s:%d" % (name, i + 1), "TRIAD", "three bolded lead-in bullets in a row"))
            else:
                bold_bullets = 0
            check_paragraph(body, "%s:%d" % (name, i + 1), out)
            continue
        if not par:
            start = i
        par.append(s)
    flush(len(lines))


def main(argv):
    out = []
    if len(argv) >= 2 and argv[0] == "--text":
        check_text(" ".join(argv[1:]), "text", out)
    else:
        if not argv:
            print(__doc__)
            return 2
        for path in argv:
            try:
                check_text(open(path, encoding="utf-8").read(), path, out)
            except OSError as e:
                print("%s: %s" % (path, e), file=sys.stderr)
                return 2
    for where, kind, msg in out:
        print("%s: %s: %s" % (where, kind, msg))
    print("%d finding(s)" % len(out))
    return 1 if out else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
