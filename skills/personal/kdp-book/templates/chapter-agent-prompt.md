# Chapter agent prompt (one per chapter; model sonnet, or opus for the product-recommendation and legal chapters)

<Paste the Shared writer brief and the Shared fact sheet from the outline above this line.>

Write Chapter <N>, "<title>" (<word range>), per the shared writer brief and fact sheet.

Fetch ladder (use in this order, and say which rung you reached for any page you cite): (1) WebFetch; (2) curl from Bash with a browser user agent and -L, stripping tags with python3 -I or sed; (3) the Playwright MCP browser, read-only: load the tools with ToolSearch "select:mcp__playwright__browser_tabs,mcp__playwright__browser_navigate,mcp__playwright__browser_evaluate", open your OWN tab with browser_tabs {action:"new"}, select it before every navigate or evaluate because other agents share the browser, read with evaluate (not snapshots or screenshots), and close your tab when done; (4) only then mark the item Unverified with the reason. Never bypass a captcha or sign in; if a site needs a login the user has not provided, stop at rung 4.

Research first. Start from `research/<files and sections>` and the evidence map rows for this chapter. Fetch and cite these primary pages on the day you write: <list>. Establish, then write: <each hypothesis the chapter depends on, with its fact-sheet ID>. Where a fact-sheet row is Needs verification or Conflict, you must settle it from the primary page or write around it.

Use <character> as the worked example: <the specific numbers and dates from the character sheet>. Include: <worksheet / table / box>. Every account opening or purchase gets a dated step-by-step walkthrough. Do not re-explain <topics whose primary home is another chapter>; cross-reference them.

Readability: run `python3 -I ~/.claude/skills/kdp-book/scripts/readability.py <chapter file>` on your draft. If it prints REVISE, revise the prose (never the rules) and run it again until it prints PASS, or explain which remaining sentences cannot be shortened without losing a rule.

Return one Markdown file: the chapter; `## Footnotes` (URL, title, date fetched); `## verify_before_print`; `## numbers_for_appendix_b` (figure, value, source, date); `## source_register` (claim, authority, passage, effective date, date checked); `## fact_sheet_updates` (ID, old status, new status, evidence); `## readability` (average sentence length, longest sentence, FK grade, Reading Ease, terms defined). No process commentary. Write it to `<project>/chapters/<NN>-<slug>.md`.
