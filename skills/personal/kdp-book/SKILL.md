---
name: kdp-book
description: Run the end-to-end pipeline for a nonfiction book on Amazon KDP, from evidence-based niche selection through parallel research, a timeline outline with per-chapter agent prompts, an editorial review loop with the user, a primary-source fact-check gate, chapter drafting, and pre-publication checks. Use when the user wants to find a book niche, validate a KDP idea with Amazon data, outline or write a nonfiction book, or says "book pipeline", "KDP", "niche research", "fact-check the book" or "write the chapters".
---

# KDP book pipeline

Nine phases, four user gates. Never skip a gate: the user decides niche, title, review changes and publication. Every phase writes to the project folder and the vault note; every number carries its source and date.

## Delegation: who does what

The main session is the advisor and orchestrator: it runs the gates, gives the recommendation at each decision, merges results and holds the whole picture. That role wants the strongest model available (Fable, or Opus). If the session is running on Sonnet, send the orchestration-heavy steps (niche ranking and rationale, merging research into the outline, merging fact-check verdicts, the advice at each gate) to an Opus subagent and relay its answer. Everything heavy goes to subagents via the Agent tool (`subagent_type: general-purpose`, set `model` explicitly), launched in parallel in one message whenever the pieces are independent.

| Step | Model | Why |
|---|---|---|
| Topic research slices, competitor and review mining, Reddit pass | sonnet, 4–6 in parallel | Fetch-and-cite work; speed and cost |
| Fact-check verifiers | sonnet, one per topic group | Quote-the-rule work; parallel |
| Chapter drafts | sonnet, one per chapter | Brief plus fact sheet carry the quality |
| Outline author, editor applying a review, cast and structure changes | opus | Judgment across the whole book |
| Product-recommendation, legal, cross-border and tax-heavy chapters | opus | Highest error cost |
| Merge of fact-check verdicts, final consistency pass, book-level synthesis | opus (or main session) | Needs the whole picture |

Rules: give every agent its output file path and a return format; never let two agents share the Playwright browser; resume an agent that already holds the context with SendMessage (the editor, a researcher being corrected) instead of starting cold; the main session never writes chapters itself.

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

Ask the user to review the outline or to run an external reviewer. Save the review in `reviews/`, apply it with an Opus editor that writes a change log, then **Gate 3:** put scope, format, cast and any corrections to the user as explicit decisions.

## Phase 6: fact sheet and fact-check gate

Extract every rule the chapters depend on into a fact sheet (`templates/fact-sheet.md`, status per row). Run parallel verifiers by topic against primary sources only (`templates/fact-check-agent-prompt.md`), merge verdicts, and report "corrections that change the book".

## Phase 7: sample layout

Lay out one chapter with a worksheet, a reference page and a sources page; set page count and price from that.

## Phase 8: chapters

One agent per chapter with the brief and fact sheet (`templates/chapter-agent-prompt.md`); each returns text, footnotes, `verify_before_print` and `numbers_for_appendix`. Assemble, run humanizer, check cross-references and the fact sheet.

## Phase 9: pre-publication (Gate 4)

Expert review (CPA, lawyer, cross-border as the topic needs), errata page, KDP checklist in REFERENCE.md, legitimate ARC reviews, 30-day BSR re-check. **Gate 4:** user approves upload.

See [REFERENCE.md](REFERENCE.md) for methods, tooling and KDP rules.
