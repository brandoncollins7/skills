# Merge upstream mattpocock/skills + install all skills

Upstream: 425 new commits. Local-only: `daa37a2` (grill-me uses AskUserQuestion) + uncommitted personalization of `skills/personal/obsidian-vault/SKILL.md`.

Dry-run (`git merge-tree`): only `skills/productivity/grill-me/SKILL.md` conflicts. Upstream also deletes the whole `personal/` bucket (incl. obsidian-vault), which would block the merge because of the uncommitted edit.

## Tasks

- [x] Stash the uncommitted obsidian-vault edit
- [x] `git merge upstream/main --no-commit`
- [x] Resolve grill-me conflict: take upstream's stub as-is (drops local AskUserQuestion edit)
- [x] Keep `skills/personal/obsidian-vault` in the merge (upstream deletes it)
- [x] Restore caveman, zoom-out, edit-article, write-a-skill into `skills/personal/` (+ personal/README.md)
- [x] Commit the merge (no AI attribution)
- [x] Pop stash so the obsidian-vault personalization is back as an uncommitted edit
- [x] Run `scripts/link-skills.sh` (now links into `~/.claude/skills` and `~/.agents/skills`; skips `misc/` + `deprecated/`)
- [x] Repoint/remove stale symlinks in `~/.claude/skills` (diagnose, review, to-issues, to-prd removed; caveman, edit-article, write-a-skill, zoom-out repointed to personal/)
- [x] Skip linking `code-review` (name clashes with built-in /code-review)
- [x] Verify: no broken links, every upstream skill linked
- [x] Not pushing to origin unless asked

## Decisions (2026-10-06)

- Removed skills: keep the no-replacement ones (caveman, zoom-out, edit-article, write-a-skill) in `personal/`.
- grill-me: take upstream as-is.
- code-review: don't link it.

## Notes

- Installer `rm -rf`s a real dir with a matching name: checked, no collisions with real dirs in `~/.claude/skills` or `~/.agents/skills`.
- Existing `misc/` links (git-guardrails, shoehorn, scaffold-exercises, setup-pre-commit) stay valid even though the new installer skips `misc/`.
- Renamed upstream: diagnose -> diagnosing-bugs, to-prd -> to-spec, review -> code-review, to-issues -> to-tickets.
- Removed upstream with no direct replacement: caveman, zoom-out, edit-article, write-a-skill (writing-for-agents covers similar ground).
- `mattpocock-skills:*` plugin (synced from claude.ai) will duplicate some skills under unprefixed names.

## Review (2026-10-06)

- Merge commit `458b3b0` (not pushed; `main` is 459 ahead of origin). Only conflict was grill-me, resolved to upstream's stub.
- Kept the fork-only `skills/personal/` bucket: obsidian-vault, edit-article, plus caveman, write-a-skill, zoom-out restored from pre-merge HEAD. Updated `personal/README.md` and added a `personal/` bullet to CLAUDE.md.
- obsidian-vault personalization is back as an uncommitted edit, same as before the merge.
- Ran `scripts/link-skills.sh`: 39 skills linked into both `~/.claude/skills` and `~/.agents/skills`; the 4 existing `misc/` links in `~/.claude/skills` still resolve. Verified all 43 non-deprecated skills, no broken repo links.
- Removed from `~/.claude/skills`: `code-review` (clashes with the built-in /code-review; re-running link-skills.sh re-adds it), and the stale links diagnose, review, to-issues, to-prd. Deleted the leftover `skills/engineering/diagnose/` (only a .DS_Store).
- Left alone: dangling `~/.claude/skills/team` and `threejs` links (point at other repos, not this one).
- Your local grill-me AskUserQuestion edit is gone (you chose upstream as-is). It's still in history at `daa37a2`.
