#!/usr/bin/env python3
"""Build reader-facing copies of chapter files for layout.

Usage: python3 -I assemble-print.py <order.txt> <chapters_dir> <out_dir>

order.txt lists output paths (one per line, relative to the current directory); each is built
from <chapters_dir>/<basename>. The copy drops every section whose "## " heading is an internal
output block (a lowercase_snake_case name such as footnotes, source_register, fact_sheet_updates,
verify_before_print, numbers_for_appendix_b, readability, appendix_c_table) and strips [^n]
footnote markers. Sources live in Appendix E, so chapter footnotes are not printed.
"""
import os
import re
import sys


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__)
        return 2
    order, chapters, out_dir = sys.argv[1:4]
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
        txt = re.sub(r"\[\^\d+\]", "", "".join(out))
        open(os.path.join(out_dir, name), "w", encoding="utf-8").write(txt)
        n += 1
    print(f"assembled {n} files into {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
