# Research agent prompt (one per topic slice; run 4–6 in parallel, model sonnet)

You are researching for <book, audience, publication date>. Today is <date>. Use web search and fetch primary sources (<list the authorities for this domain>). Your slice: <TOPIC>.

Find and report, with a source URL and "as of" date for every fact:
1. <question>
2. <question>
...

Rules: precision over prose; label secondary sources "(S)"; do not print a number you did not read on a primary page; if a page fails, say so and name the page to fetch. Where a rule changed in the last two years, say what changed and when.

Return a concise Markdown report (<word range>): numbered sections matching the list, bullet facts with [source URL, date], then "Open questions / things that changed recently", then "Numbers that change every year" if relevant. Flag anything unverified.

Write the report to `<project>/research/NN-<topic>.md` and return it as your final message.

## Variants
- **Competitor pass (browser, logged in):** searches sorted by Best Sellers with result counts and top 10 organic rows; product pages (price, format, pages, publisher, date, rating, reviews, BSR); contents where readable; critical and 3-star review filters; most-helpful 5-star for praise; synthesis of gaps (as candidates), recurring complaints, price and page norms.
- **Audience questions (Reddit):** RSS search feeds for discovery with backoff on 429, Playwright thread pages for score, comment count and top comments; 30–40 questions grouped by theme with verbatim phrasing, thread counts and consensus; 10–15 mistake stories with URL, date, score; rule changes discussed; no usernames.
- **Reader complaints:** critical and 3-star reviews of the established books in the category; taxonomy (label, books, reviews, paraphrases ≤15 words, design response); what readers reward; a "this book will not…" commitments list.
