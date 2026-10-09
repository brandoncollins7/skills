#!/usr/bin/env python3
"""Readability report for a chapter in Markdown. No dependencies.

Usage: python3 -I readability.py chapter.md [--max-sentence 22]

Measures body prose only: strips Markdown tables, code blocks, headings, footnote
definitions and the sections named Footnotes / verify_before_print / numbers_for_appendix_b /
source_register / fact_sheet_updates / readability. Reports Flesch Reading Ease,
Flesch-Kincaid grade, sentence statistics, the longest sentences, and words of 3+ syllables
that appear often (candidates for a plain alternative or a definition).

Targets used by the kdp-book skill: FK grade 6-7, Reading Ease >= 65, average sentence 12-15
words, no sentence over 22 words.
"""
import re
import sys
from collections import Counter

STOP_SECTIONS = {"footnotes", "verify_before_print", "numbers_for_appendix_b",
                 "source_register", "fact_sheet_updates", "readability", "sources"}


def body_text(md: str) -> str:
    out, skip, in_code = [], False, False
    for line in md.splitlines():
        s = line.strip()
        if s.startswith("```"):
            in_code = not in_code
            continue
        if in_code:
            continue
        if s.startswith("#"):
            title = s.lstrip("#").strip().lower()
            skip = title in STOP_SECTIONS
            continue
        if skip:
            continue
        if s.startswith("|") or re.match(r"^\[\^\d+\]:", s):
            continue
        s = re.sub(r"\[\^\d+\]", "", s)              # footnote markers
        s = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", s)    # images
        s = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", s)  # links -> text
        s = re.sub(r"[*_`>#]+", "", s)
        s = re.sub(r"^\s*(?:[-+]|\d+\.)\s+", "", s)   # list markers
        if s:
            out.append(s)
    return " ".join(out)


def syllables(word: str) -> int:
    w = re.sub(r"[^a-z]", "", word.lower())
    if not w:
        return 0
    if len(w) <= 3:
        return 1
    w = re.sub(r"(?:[^laeiouy]es|ed|[^laeiouy]e)$", "", w)
    w = re.sub(r"^y", "", w)
    groups = re.findall(r"[aeiouy]{1,2}", w)
    return max(1, len(groups))


def sentences(text: str):
    # Protect common abbreviations and decimals before splitting.
    t = re.sub(r"\b(e\.g|i\.e|vs|Mr|Mrs|Ms|Dr|No|St)\.", lambda m: m.group(0).replace(".", "§"), text)
    t = re.sub(r"(\d)\.(\d)", r"\1§\2", t)
    parts = re.split(r"(?<=[.!?])\s+(?=[A-Z0-9\"“(])", t)
    return [p.replace("§", ".").strip() for p in parts if re.search(r"[A-Za-z]", p)]


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    max_len = 22
    if "--max-sentence" in sys.argv:
        max_len = int(sys.argv[sys.argv.index("--max-sentence") + 1])
    md = open(sys.argv[1], encoding="utf-8").read()
    text = body_text(md)
    sents = sentences(text)
    words = [w for w in re.findall(r"[A-Za-z][A-Za-z'’-]*", text)]
    if not sents or not words:
        print("No body text found.")
        return 1
    n_s, n_w = len(sents), len(words)
    n_syl = sum(syllables(w) for w in words)
    asl, asw = n_w / n_s, n_syl / n_w
    ease = 206.835 - 1.015 * asl - 84.6 * asw
    grade = 0.39 * asl + 11.8 * asw - 15.59
    lengths = sorted(((len(re.findall(r"[A-Za-z][A-Za-z'’-]*", s)), s) for s in sents), reverse=True)
    over = [(n, s) for n, s in lengths if n > max_len]
    hard = Counter(w.lower() for w in words if syllables(w) >= 3 and len(w) > 6)

    print(f"words {n_w} | sentences {n_s} | avg sentence {asl:.1f} words | longest {lengths[0][0]} words")
    print(f"Flesch Reading Ease {ease:.1f} (target >= 65) | Flesch-Kincaid grade {grade:.1f} (target 6-7)")
    print(f"sentences over {max_len} words: {len(over)}")
    for n, s in over[:10]:
        print(f"  [{n}] {s[:160]}")
    print("frequent long words (3+ syllables):")
    for w, c in hard.most_common(20):
        print(f"  {w} x{c}")
    ok = ease >= 65 and grade <= 7.5 and not over
    print("PASS" if ok else "REVISE")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
