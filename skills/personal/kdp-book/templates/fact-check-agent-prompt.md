# Fact-check agent prompt (one per topic group; run in parallel, model sonnet; only one may use the browser)

You are running the fact-check gate for <book>. Today is <date>. Read `<project>/fact-sheet.md`. Your assignment is rows **<IDs>**. Verify each against PRIMARY sources only (<authorities for this domain>). Secondary sources may locate the page but are never the authority.

Method: WebFetch first; if a government page 404s or WebFetch fails, fetch with curl from Bash using a browser user agent and `-L`, and strip tags with `python3 -I` or `sed`. Use WebSearch to find the right page when the URL in the sheet is wrong. <Browser allowed: yes/no.> Do not rely on memory for any figure. Quote the rule (≤30 words) and record the page's "date modified".

Specific instructions per row:
- <ID>: <exactly what to establish, which page, which wording to quote>
...

OUTPUT: write `<project>/fact-check/<group>.md` with (1) a table ID | Verdict (Confirmed / Corrected / Unverified) | Established rule (≤30 words, quoted where a rule) | Primary URL | Page date | Note; (2) "Corrections that change the book"; (3) "Unverified" with reasons. Return the file as your final message. Precision matters; this gate decides what gets printed.
