# KDP book pipeline: reference

## Niche research method

**Shelf checks.** For each candidate keyword run both stores, sorted by Best Sellers, and record the result count and the top 10 organic rows. Then open the top 5 product pages. Amazon search results do not show BSR; product pages do, in the details block, and only after the page has rendered (scroll to the bottom, wait ~1.5 s).

**The decisive signal.** Amazon omits the "Best Sellers Rank" line entirely for a title that has never sold. A shelf where every 2026 title has no rank is a shelf with no buyers, whatever the search volume looks like.

**BSR to sales per day (amazon.com Books pool; Kindle similar; amazon.ca roughly one tier lower).** Anchored to BookBeam's published examples; estimates, not promises.

| BSR | Sales/day |
|---|---|
| #5k–10k | 15–30 |
| #10k–15k | 10–18 |
| #25k–30k | 6–10 |
| #45k–55k | 3–5 |
| #80k | ~2 |
| #200k | ~0.5 |
| #300k–400k | 2–3/week |
| #600k–1M | ~1/week |
| >1M | 1–2/month |
| no rank | 0 |

A rank taken within three weeks of launch may be a promo spike; re-check at 30 days before treating it as proof. Review velocity reflects marketing spend as much as demand.

**Scoring.** Profit ×3, moat ×2, window ×2, interest ×1, minus policy risk (AI-disclosure enforcement hits health and education hardest; YMYL topics draw complaints). Present a table with one line of evidence per row.

**Council.** If the llm-council backend is available, send the ranked table and the evidence and ask for a critique, a single first pick, blind spots and title angles. Expect it to split; use the consensus points, not the vote.

## Research phase

- Four to six Sonnet agents in parallel, each a topic slice, each told: primary sources only for numbers, cite URL and page date, label secondary sources, return an "unverified / changed recently" list, and a "numbers that change every January" list where relevant.
- Competitor pass in a logged-in browser: search result snapshots (Best Sellers sort), product data, tables of contents where readable, critical-review filters (`/product-reviews/<ASIN>/?filterByStar=critical&sortBy=recent`; amazon.ca shows only the first 10 per filter and ignores page numbers), most-helpful 5-star for what readers reward.
- Reader complaints: the newcomer or niche titles rarely have reviews; mine the established books in the category instead. Build a taxonomy (label, books, reviews, paraphrases, design response) and a "this book will not" commitments list for the writer brief.
- Audience questions: see Reddit tooling below. Low-scored niche threads supply wording, not authority.

## Outline rules

- Organise by the reader's decisions in time order, with two clocks where deadlines matter (time since arrival, calendar). Open with who the book is for and a routing page.
- Small cast: two or three main characters plus at most one who appears only in a recurring box for a minority reader type.
- Each chapter: title, summary, blockquoted prompt that a Sonnet agent can execute (research first, primary sources, specific pages to fetch, worked example, worksheet, what to flag). Prompts state the current best understanding as a hypothesis to establish, never as a conclusion to preserve.
- One primary home per explanation; cross-reference elsewhere.
- Product recommendations come after the comparison, as dated, conditional worked examples, with the conditions that would change them and a disclosure line.
- Lighter template beats a mandatory scene-plus-table-plus-checklist in every chapter.

## Editorial review loop

Ask the user for a review (or they run one externally); save it under `reviews/`; have an Opus editor apply it in place and write a change log listing each point and what changed or was declined and why. Then ask the user the decisions the review raised, one at a time, in plain language, with a recommendation.

## Fact sheet and fact-check gate

Fact sheet columns: ID, claim, authority URL, effective or page date, status (Verified (P) with report and section; Verified (review); Needs verification; Conflict), chapters. Verifiers work by topic in parallel, primary sources only, quote the rule (≤30 words), record the page date, and return a verdict table (Confirmed / Corrected / Unverified) plus "corrections that change the book". Only one agent at a time may use the Playwright browser.

## Chapter drafting

Prepend the shared writer brief and the fact sheet to each chapter prompt. Output: chapter Markdown, numbered sources with date fetched, `verify_before_print`, `numbers_for_appendix`, `source_register`, `fact_sheet_updates`. After assembly: humanizer pass, cross-reference check, appendix build from the chapter returns.

## KDP rules to carry (verify each at publication time)

- AI-generated text and images must be disclosed at upload; edited AI text still counts; enforcement is active.
- New-title cap: 2 per format per week (since 2026-09-21), resets Sunday 00:00 UTC. Series plans must budget slots.
- Kindle 70% royalty band $2.99–$12.99 (since 2026-07-07); print royalty 60% of list less printing cost.
- Review swaps and Facebook review groups violate Amazon policy; use BookSirens, Voracious Readers or a mailing list.
- Pen names are allowed; fabricated credentials are not. Referral codes must be disclosed.
- Listing: 7 backend keywords, 3 categories, title under 200 characters, who-this-is-for on the cover and page one.

## Tooling notes

- **Chrome extension** (`mcp__claude-in-chrome__*`): best for Amazon with the user's login. Batches of five product pages; ten time out. Disconnects are usually transient. Some sites (reddit.com) are blocked at the extension level and cannot be allowed by the user.
- **Playwright plugin** (`mcp__playwright__*`): a separate browser profile; the user must sign in there separately, and a session may not survive between runs, so re-run the login pre-flight every time. Signed-out symptoms: Amazon review pages redirect to `/ap/signin`; Reddit search pages bounce to the front page or a login wall (thread pages still render). Reddit thread pages render logged-out; search pages do not. Only one agent may use it at a time; tabs for parallel page loads.
- **Reddit RSS**: `https://www.reddit.com/r/<sub>/search.rss?q=<q>&restrict_sr=on&sort=top&t=all` works with a browser user agent; 429 on rapid requests; no vote counts. `scripts/reddit-rss-fetch.sh`.
- **Firecrawl** refuses reddit.com. **curl** to Amazon hits a bot check.
- **fxtwitter** (`api.fxtwitter.com/<user>/status/<id>`) returns single tweets; use Chrome for threads.
- **Amazon autocomplete**: `completion.amazon.com/api/2017/suggestions?limit=11&prefix=<kw>&suggestion-type=KEYWORD&alias=stripbooks&mid=ATVPDKIKX0DER` (amazon.ca: `completion.amazon.ca`, `mid=A2EUQ1WTGCTBG2`).
- **LLM Council**: backend in `~/Projects/scatterbrain/llm-council`, port 8001; run the curl in the background with a 600 s timeout; check OpenRouter credit first (`/api/v1/credits`), a full run costs several dollars.
- **Government pages for verifiers**: canada.ca and CRA pages usually fetch with WebFetch or curl plus a browser user agent; `ontario.ca/laws` statute pages are a JavaScript shell, so read the e-Laws API consolidation behind them; Revenu Québec, RAMQ and some territorial pages block curl (use Firecrawl or Playwright, read-only); PEI's tenancy page sits behind a captcha (use the appeals-board page, never bypass). Record each page's own "date modified"; CRA sub-pages can lag the main page by months (the HBP repayment sub-page did), so prefer the newer page and note the stale one.
- **Fact-check output discipline**: verifiers quote the rule in 30 words or fewer, give Confirmed / Corrected / Unverified, and list "corrections that change the book" separately. Expect roughly a third of "needs verification" rows to come back Corrected; several of today's corrections (repealed regulation, a Reddit consensus that was wrong, a tax rebate that had ended) would have reached print without the gate.
