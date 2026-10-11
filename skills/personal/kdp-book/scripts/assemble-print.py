#!/usr/bin/env python3
"""Build reader-facing copies of chapter files for layout.

Usage: python3 -I assemble-print.py <order.txt> <chapters_dir> <out_dir>

order.txt lists output paths (one per line, relative to the current directory); each is built
from <chapters_dir>/<basename>. The copy drops every section whose "## " heading is an internal
output block (a lowercase_snake_case name such as footnotes, source_register, fact_sheet_updates,
verify_before_print, numbers_for_appendix_b, readability, appendix_c_table) and keeps [^n]
footnote definitions. The [^n] markers are kept (the layout script prints them as superscripts) so
the numbered list in the print Appendix E matches the chapter text; pass --strip-markers to drop them.
"""
import os
import re
import sys


def main() -> int:
    args = [a for a in sys.argv[1:] if a != "--strip-markers"]
    strip = "--strip-markers" in sys.argv
    if len(args) != 3:
        print(__doc__)
        return 2
    order, chapters, out_dir = args
    os.makedirs(out_dir, exist_ok=True)
    n = 0
    for rel in (l.strip() for l in open(order, encoding="utf-8")):
        if not rel:
            continue
        name = os.path.basename(rel)
        md = open(os.path.join(chapters, name), encoding="utf-8").read()
        out, skip = [], False
        for line in md.splitlines(keepends=True):
            if line.startswith("## "):
                title = line[3:].strip()
                skip = bool(re.fullmatch(r"[a-z][a-z0-9_]*", title)) or title.lower() == "footnotes"
                if skip:
                    continue
            if not skip:
                out.append(line)
        txt = "".join(out)
        if strip:
            txt = re.sub(r"\[\^\d+\]", "", txt)
        open(os.path.join(out_dir, name), "w", encoding="utf-8").write(txt)
        n += 1
    print(f"assembled {n} files into {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
