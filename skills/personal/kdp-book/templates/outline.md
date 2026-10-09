# <Working title> — outline and chapter-agent prompts

Working title: **<Title: Subtitle with keywords>**
Format: <trim>, target words and pages set after the sample layout. Price: <range>. Pen name: <y/n>. AI-generated text, disclosed at upload. Referral disclosure: <none / wording>.
Built <date> from research reports in `research/`.

## Research files and their status
| File | Covers | Status |
|---|---|---|
| `research/01-....md` | ... | Current / Partially superseded by ... |

## Competitive position
<What sells, what does not, gaps as candidates (descriptions are not contents), price and page norms, speed vs accuracy.>

## Why this structure
<Timeline of the reader's decisions; two clocks if deadlines matter; cast of two or three, plus one box-only character for a minority reader type.>

## Production plan
<Sample layout step; word budget; gates; pre-publication reviewers.>

## Opening pages
<Who this is for and who should read something else; routing page; first-week checklist; early warning boxes.>

## Part I — <phase>

### Chapter 1. <Title as a decision>
**Summary.** <What the reader decides here, the trap, the worksheet, which character carries it.>
**Prompt for the chapter agent.**
> Write Chapter 1, "<title>" (<word range>), per the shared writer brief and fact sheet. Start from `research/..` §... Fetch and cite primary pages: ... Establish, then write: <hypotheses to confirm>. Use <character> as the worked example. Include <worksheet/table>. Flag unverified items.

<repeat>

## Reference guides (clearly marked; separate entry points)

## Back matter
Appendix A toolkit · Appendix B numbers and rules that change (with dates checked) · Appendix C dated product comparison · Glossary · Sources

## Evidence map
<Chapter → reader questions (verbatim phrasing) → threads/reviews → mistake stories.>

## Shared fact sheet (prepend to every chapter prompt)
<See templates/fact-sheet.md>

## Shared writer brief (prepend to every chapter prompt)
**Who you are writing for.** ...
**Scope.** ...
**Voice.** Plain English, second person, short sentences, define jargon at first use, no filler, no jokes at the reader's expense, Canadian spelling.
**Plain-language standard (required; measured).** Decide the reader's English level up front (default for newcomer or general audiences: CEFR B1). Target Flesch-Kincaid grade 6–7 and Reading Ease 65+ on body text; sentences average 12–15 words, none over 22; one idea per sentence; active voice; common word before the term, then the term consistently; every term defined once and listed for the glossary; no idioms or culture-bound metaphors; numbers as digits with unit and date; acronyms spelled out at first use per chapter, at most two per sentence; official form and program names kept exactly; arithmetic line by line; "What this means for you:" after any complex rule. Simplify the language, never the rules. Each chapter runs `scripts/readability.py` and reports the figures; a plain-language edit pass follows drafting and precedes the humanizer pass.
**Chapter template.** Decision or problem; who it applies to; explanation or worked example; key trap; short action checklist. Tables and scenes only when they help.
**Facts and sources.** Primary sources fetched during the run; every number with URL and date; secondary sources may explain but never be the sole source of a number; unverified items are written around, never printed; "as of <month year>" over "currently".
**Commitments.** <"This book will not…" list from the complaint research.>
**One home per explanation.** <table>
**Output.** Chapter Markdown; `## Footnotes`; `## verify_before_print`; `## numbers_for_appendix_b`; `## source_register`; `## fact_sheet_updates`. No process commentary.
