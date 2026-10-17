---
name: kdp-book
description: Run the end-to-end pipeline for a nonfiction book on Amazon KDP, from evidence-based niche selection through parallel research, a timeline outline with per-chapter agent prompts, an editorial review loop with the user, a primary-source fact-check gate, chapter drafting, and pre-publication checks. Use when the user wants to find a book niche, validate a KDP idea with Amazon data, outline or write a nonfiction book, or says "book pipeline", "KDP", "niche research", "fact-check the book" or "write the chapters".
---

# KDP book pipeline

Nine phases, four user gates plus a review after the outline and after every chapter. Never skip a gate or a review: the user decides niche, title, the outline, each chapter, review changes and publication. Every phase writes to the project folder and the vault note; every number carries its source and date.

## Delegation: Sonnet agents, Opus advisor

Every subagent runs on Sonnet (Agent tool, `subagent_type: general-purpose`, `model: sonnet` set explicitly). Opus is the advisor: it plans, briefs, reviews and decides, and does not draft. The main session is the advisor when it runs on Opus (or Fable). If the main session runs on anything else, launch one advisor subagent with `model: opus` for each advisor task below and relay its answer; keep it alive with SendMessage so it holds the whole book.

| Step | Sonnet agent does | Opus advisor does |
|---|---|---|
| Niche shelf checks, topic research, competitor and review mining, Reddit pass | Fetches, extracts and cites; 4–6 in parallel | Picks the slices, ranks the niches, writes the gate recommendation |
| Outline | Drafts it from the advisor's brief (cast, timeline, chapter list, evidence map) | Writes the brief, then reviews the draft for structure, one home per explanation and evidence gaps |
| Editor applying a review | Applies each point and writes the change log | Decides contested points before the edit; checks the change log after |
| Fact-check | One verifier per topic group | Merges verdicts, runs the transfer check, lists corrections that change the book |
| Chapter draft | One agent per chapter, on the user's instruction | Writes the chapter brief; reviews the draft before the user sees it |
| Product-recommendation, legal, cross-border and tax-heavy chapters | Drafts as usual | Line-by-line review of every rule, number and qualification against the fact sheet |
| Consistency pass, assembly, book-level synthesis | Mechanical checks and edits | Final read across chapters and the call on what goes to the user |

**Advisor review loop.** For any step with an advisor review, the Sonnet agent returns its output; the advisor reviews it against the brief and the fact sheet and sends corrections back to the same agent with SendMessage (not a fresh launch); the agent fixes and returns. At most two rounds, then the advisor flags what is left for the user. The advisor states its verdict in the hand-off: what it checked, what it changed, what it could not settle.

Rules: give every agent its output file path and a return format; never let two agents share the Playwright browser; resume an agent that already holds the context with SendMessage (the editor, a researcher being corrected) instead of starting cold; neither the main session nor the advisor writes chapters itself.

## Setup (once per book)

1. Project folder `~/Projects/books/<slug>/` with `research/`, `reviews/`, `fact-check/`, `chapters/`; `git init` if new. Shelf data and rankings go in `~/Projects/books/history/`.
2. Vault note `Projects/<Book>/<Book>.md` (obsidian-vault skill) with a Tasks section; update it at every phase.
3. `tasks/todo.md` plan; memory file for the project.

## Phase 1: niche (Gate 1)

- Candidates come from the user, threads they share, or a brainstorm. For each: Amazon search (Kindle `i=digital-text` and Books `i=stripbooks`, sort `s=exact-aware-popularity-rank`), then product pages for the top 5. Use `scripts/amazon-extractors.js` via Chrome `javascript_tool` inside `browser_batch`, five pages per batch.
- Record ASIN, title, pub date, price, format, pages, publisher, reviews, BSR. **No rank line means never sold.** Convert BSR with the bands in REFERENCE.md.
- Score profit ×3, moat ×2, window ×2, interest ×1, minus policy risk. News-window niches usually show zero sales; evergreen shelves show indie titles at #5k–#50k within weeks.
- Optional: LLM Council (llm-council skill) for a second opinion.
- **Gate 1:** present the ranked table with evidence; the user picks.

## Phase 2: title and positioning (Gate 2)

Catchy title plus a keyword-carrying subtitle; pen name, AI disclosure and referral disclosure decided up front. **Gate 2:** user approves title and constraints.

## Phase 3: research (parallel Sonnet agents)

**Login pre-flight (before any browser agent launches).** Confirm the browser the agents will use is signed in: for Amazon, navigate to a `/product-reviews/<ASIN>/?filterByStar=critical` URL and check it does not redirect to `/ap/signin`; for Reddit, navigate to an `old.reddit.com/r/<sub>/search?q=...` URL and check it does not bounce to a login page or the front page. The Chrome extension and the Playwright plugin are separate profiles, so test the one the agents will use. If either is signed out, open that site's sign-in page in the Playwright window, tell the user to sign in there, and wait; never enter credentials yourself. Re-test, then launch. Tell the agents which browser is signed in to which site.

Four to six topic slices, each returning a cited report with an "unverified" list (`templates/research-agent-prompt.md`). Add: competitor interiors and critical reviews (logged-in browser), audience questions (Reddit RSS plus Playwright; see REFERENCE.md tooling), and a reader-complaint taxonomy from books with review volume. Save as `research/NN-topic.md`.

## Phase 4: outline

`templates/outline.md`: structure by the reader's decision timeline, not by topic; small recurring cast; per chapter a summary and a blockquoted agent prompt; shared writer brief; evidence map. Keep one primary home per explanation.

## Phase 5: editorial review (Gate 3)

**Stop here and wait for the user's own review of the outline.** Answers to a few decision questions are not a review; do not move to Phase 6 until the user has read the outline (or run their external reviewer on it) and sent comments or an explicit "approved". Save the review in `reviews/`, apply it with a Sonnet editor that writes a change log, with the advisor deciding contested points and checking the log, then **Gate 3:** put scope, format, cast and any corrections to the user as explicit decisions.

## Phase 6: fact sheet and fact-check gate

Extract every rule the chapters depend on into a fact sheet (`templates/fact-sheet.md`, status per row). Run parallel Sonnet verifiers by topic against primary sources only (`templates/fact-check-agent-prompt.md`); the advisor merges verdicts and report "corrections that change the book". After the merge, run a **transfer check**: compare every sentence marked Established in a chapter prompt against its fact-sheet row and restore any dropped qualification, date, threshold or cap (abbreviating "exempt on the first $500,000, up to $835,000" to "full to $835,000" is the typical error). Then ask the user for a second review of the merged commit before drafting; it will find the worked-example arithmetic the gate cannot.

## Phase 7: sample layout

Lay out one chapter with a worksheet, a reference page and a sources page; set page count and price from that.

## Phase 8: chapters

**One chapter at a time, on the user's instruction, with the user's review after each.** The user says which chapter to write next; one Sonnet agent drafts it with the brief and fact sheet (`templates/chapter-agent-prompt.md`), returning text, footnotes, `verify_before_print`, `numbers_for_appendix` and a readability block; run the plain-language edit, humanizer pass and readability re-check on that chapter; then the advisor reviews it (advisor review loop) and only then hands it to the user and waits. Apply the user's review through an editor with a change log before asking which chapter comes next. Never commission several chapters in parallel unless the user asks for that. The first chapter is the sample that sets voice and layout: the advisor writes its brief in full and reviews the draft closely; lay it out with `scripts/layout-6x9.sh` (or the book's own layout script) and measure it with `scripts/readability.py` before the user reviews it. Assemble with `scripts/assemble-print.py` (drops the internal output blocks and footnote markers; sources print from Appendix E), check cross-references and the fact sheet.

## Phase 9: pre-publication (Gate 4)

Expert review (CPA, lawyer, cross-border as the topic needs), errata page, KDP checklist in REFERENCE.md, legitimate ARC reviews, 30-day BSR re-check. **Gate 4:** user approves upload.

See [REFERENCE.md](REFERENCE.md) for methods, tooling and KDP rules.
