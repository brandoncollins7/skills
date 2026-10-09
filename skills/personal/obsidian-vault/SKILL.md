---
name: obsidian-vault
description: Search, create, and manage notes in Brandon's Obsidian vault with wikilinks, callouts, and the conventions defined in the vault's own CLAUDE.md.md. Use when user wants to find, create, or organize notes in Obsidian.
---

# Obsidian Vault

## Vault location

`/Users/brandon/Obsidian/_mr_e/`

The vault has its own system prompt at `/Users/brandon/Obsidian/_mr_e/CLAUDE.md.md`. **Read it on first use of this skill in a session** — it's the source of truth for vault conventions (rewritten 2026-07-04 to match the real vault) and may have been updated since this skill was last edited. This skill is the quick reference; CLAUDE.md.md wins on conflict.

The vault is **git-versioned** (checkpoint layer). Commit only when Brandon asks; plain messages, no AI attribution.

## Folder structure

- **`INDEX.md`** — the front door: every note, one line each, grouped by folder. **Read this before searching or sweeping folders.**
- **`Apple Notes/`** — **raw layer, read-only ground truth.** Imported captures. Never rewrite, rename, or reorganize; compile from it and link back to it.
- **`Brandon/`** — personal captures not tied to an active project, plus entity pages for people (Kara, Mom, Waleed, the health coach). Entity pages at the root; dated captures in person/theme subfolders (`Kara/`, `Waleed/`, `Self-Work/`).
- **`Projects/`** — one folder per active project.
- **`Archive/`** — closed projects moved whole (e.g. `Archive/Exit/`, closed 2026-08-04 — Brandon and Kara back together). Kara notes now go in `Brandon/` like any other person.
- **`Areas/`** — ongoing responsibilities.
- **`Daily/`** — daily notes, `YYYY-MM-DD.md`.

Never leave notes at the vault root.

### Placement heuristic

Ask: **does the note touch an active project (Ketamine, Glebemount, etc.)?**

- **Yes → the project folder**, even if the note is purely emotional.
- **No → `Brandon/`** for people/themes (use its person/theme subfolders for dated captures), `Areas/` for ongoing life areas.

When still unsure, match a clearly-similar existing note's folder.

## Two layers of notes

- **Raw captures** — dated (`Title YYYY-MM-DD.md`), append-only. Once written they get linked to, not rewritten. Apple Notes imports count as raw.
- **Compiled pages** — undated, updated in place:
  - **Entity pages** — one per recurring person/thing (`Kara.md`, `Mom.md`, `Waleed.md`): a rolling picture linking out to its dated captures.
  - **Concept pages / MOCs** — one per pattern or topic (`Exit MOC.md`).
- **Provenance:** every compiled page ends with a `## Sources` section linking the raw notes it was built from.

## The four compile rules

1. One idea per note, `> [!note] Summary` callout at top.
2. Update the existing page instead of creating a duplicate — check INDEX.md first.
3. Delete notes that turn out wrong — propose first, with the reason.
4. Never touch the raw layer.

## Reading rules (token economy)

- Start at INDEX.md, follow wikilinks, open only what the trail points at.
- Never sweep a whole folder "for context."
- Big cross-vault syntheses → subagent that returns conclusions only.

## Index maintenance

Every note created, moved, renamed, or deleted updates INDEX.md in the same session. Line format: `- [[Note Title]] — one-line hook`.

## Naming conventions

- **Title Case** for all note names.
- **Raw/dated captures**: append the date — `Mom Set a Boundary 2026-06-10.md`.
- **Entity/concept pages**: undated — `Kara.md`, `Exit MOC.md`.
- **Daily notes**: `YYYY-MM-DD.md`.

## Note structure

1. `# Title` (matches filename).
2. `> [!note] Summary` — 1–3 sentence framing.
3. **Tags line** — e.g. `#project/exit #personal #grief #patterns`.
4. `---` separator.
5. Body with `##` sections. Use **callouts**, not plain blockquotes: `[!note]` neutral framing, `[!tip]` side info, `[!important]` load-bearing reframe, `[!warning]` risk/pattern alarm.
6. `## Sources` — on compiled pages only: wikilinks to the raw captures behind it.
7. `## Related` — bulleted `[[wikilinks]]` with a short hook after each.

## Linking

- `[[Note Title]]` wikilinks; `[[Note Title|alias]]` when the alias reads better.
- Link generously — ≥2 links per new note is the norm.

## Sensitivity

When the user explicitly says they don't want certain context in the vault, **omit it entirely** — don't summarize it, don't allude to it. The vault is durable; conversation context is not.

## Vault check

When Brandon says "vault check" / "status": report root strays, dead wikilinks, orphan notes, likely duplicates, INDEX.md drift, and open loops in recent Daily/ and project notes. Propose fixes; don't apply structural ones without approval.

## Workflows

### Find a note

1. Read `INDEX.md` and scan hooks (preferred — one read instead of a sweep).
2. Fallbacks: `find "/Users/brandon/Obsidian/_mr_e/" -name "*.md" | grep -i "keyword"` or `grep -rl "keyword" "/Users/brandon/Obsidian/_mr_e/" --include="*.md"`.

### Find backlinks to a note

```bash
grep -rl "\\[\\[Note Title\\]\\]" "/Users/brandon/Obsidian/_mr_e/"
```

### Create a new note

1. Pick the folder via the placement heuristic (check INDEX.md for an existing page to update instead — rule 2).
2. Filename: Title Case; date suffix only for raw captures.
3. Summary callout → tags line → `---` → body with callouts.
4. Compiled pages end with `## Sources`; every note ends with `## Related` (≥2 links).
5. Write the file, then add its line to INDEX.md.
