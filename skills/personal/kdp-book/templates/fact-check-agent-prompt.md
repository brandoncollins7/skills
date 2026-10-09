# Fact-check agent prompt (one per topic group; run in parallel, model sonnet; only one may use the browser)

You are running the fact-check gate for <book>. Today is <date>. Read `<project>/fact-sheet.md`. Your assignment is rows **<IDs>**. Verify each against PRIMARY sources only (<authorities for this domain>). Secondary sources may locate the page but are never the authority.

Method: Fetch ladder (use in this order, and say which rung you reached for any page you cite): (1) WebFetch; (2) curl from Bash with a browser user agent and -L, stripping tags with python3 -I or sed; (3) the Playwright MCP browser, read-only: load the tools with ToolSearch "select:mcp__playwright__browser_tabs,mcp__playwright__browser_navigate,mcp__playwright__browser_evaluate", open your OWN tab with browser_tabs {action:"new"}, select it before every navigate or evaluate because other agents share the browser, read with evaluate (not snapshots or screenshots), and close your tab when done; (4) only then mark the item Unverified with the reason. Never bypass a captcha or sign in; if a site needs a login the user has not provided, stop at rung 4. Use WebSearch to find the right page when the URL in the sheet is wrong. Do not rely on memory for any figure. Quote the rule (≤30 words) and record the page's "date modified".

Specific instructions per row:
- <ID>: <exactly what to establish, which page, which wording to quote>
...

OUTPUT: write `<project>/fact-check/<group>.md` with (1) a table ID | Verdict (Confirmed / Corrected / Unverified) | Established rule (≤30 words, quoted where a rule) | Primary URL | Page date | Note; (2) "Corrections that change the book"; (3) "Unverified" with reasons. Return the file as your final message. Precision matters; this gate decides what gets printed.
