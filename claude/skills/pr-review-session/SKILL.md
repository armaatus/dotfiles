---
name: pr-review-session
description: Assist the human reviewing someone else's GitHub PR in tuicr (left tmux pane) - brief them, review the commits the CI bot never saw, add findings as tuicr drafts, answer questions and `ask` comments, check drafts before submit, and log what the PR changed. Use when invoked as /pr-review-session OWNER/REPO#N, normally by the gh-pr-review launcher.
---

# PR review session

The human is the reviewer; you are their assistant. They read the diff in tuicr, decide every comment and submit the review themselves. Your job is to make them **understand** the change first and **judge** it second.

Argument: `OWNER/REPO#N`. Split it into `REPO_SLUG=OWNER/REPO` and `N`. The tuicr session slug is `gh:OWNER/REPO/pr/N`.

## Hard rules

- Read-only on the repo and on GitHub. Never edit, create or delete repo files; never commit, push, switch branches, or post, reply, resolve, approve or merge on GitHub. The human submits from tuicr.
- The only things you write: tuicr drafts in this PR's session, and the review notes file (step 6).
- Every finding cites a `file:line` you actually read. If unsure it is real, drop it.
- Never repeat a point an open review thread already makes (they are listed in the context).

## 1. Load context

```bash
~/.config/gh-dash/bin/gh-pr-context OWNER/REPO N
git fetch origin
```

Read `REVIEW.md`, `CONTEXT.md` and `docs/agents/domain.md` when they exist: the rubric and the domain language.

## 2. Brief (print it, at most ~40 lines)

1. **Intent**: one line, plus the linked issue's problem in one line.
2. **What changes in the system**: new or changed concepts, data model, flows, endpoints; responsibilities that moved between modules. Use the domain's own words.
3. **Fit**: does it sit where this kind of code belongs? Name any duplicated concept, bypassed layer, or cross-app import that skips an `api.py`.
4. **Risk spots**: `file:line` with one line each on why.
5. **Reading order**: numbered files, each with what to look for.
6. **Tier**: the context's tier (DEEP, SKIM or TRUST), raised (never lowered) if the risk spots warrant it, with the reason. Use only these three names.
7. **Coverage**: what the CI bot reviewed, which commits nobody AI-reviewed yet, and the human's last review (tuicr preselects commits since then).

Print the brief before starting step 3, so the human can read while you work.

## 3. Review what the CI bot missed

Scope:

- The bot never reviewed: the whole PR, `git diff origin/<base>...origin/<head>`.
- Commits after the bot's review: `git diff <bot-review-sha> origin/<head>`.
- None: skip the line review and do only the design pass.

Line review: if `.claude/skills/review-pr/SKILL.md` exists, follow its Steps 3-5 (fan-out threshold, one agent per surface, skeptic verification, severity, exact new-file line numbers) on that scope. Skip its Step 0 mode logic and Steps 6-9: never post. Otherwise review by its categories yourself: architecture, security, performance, error handling, tests, data integrity, code quality, API design.

Design pass, over the whole PR: fit with the architecture, naming against the domain language, behaviour without a test, scope beyond the linked issue. Report only what has evidence.

## 4. Add findings as tuicr drafts

Map severity to type: Critical → `blocking`, High → `should-fix`, Medium → `consider`, Low → `nit` (at most 5 nits; mention the rest as a count in chat). Content always starts with `🤖 `. Anchor on a new-side line that is part of the PR diff.

Wait until the left pane has opened the session (`tuicr review list --repo OWNER/REPO` shows the slug), then add each finding:

```bash
tuicr review add --session "gh:OWNER/REPO/pr/N" --username Claude --input - <<'JSON'
{"type": "should-fix", "file": "path/to/file.py", "line": 42, "side": "new",
 "content": "🤖 One-line title\n\nWhat is wrong and the concrete failure scenario.\n\nFix: ... (use a ```suggestion block for a literal line replacement)"}
JSON
```

Use `start_line`/`end_line` for a range. Afterwards run `tuicr review comments --session ...` and confirm each draft was stored on the intended line. Remember the id and content of each draft you added. Finish with a one-line count per type in chat.

## 5. While the human reviews

- Answer questions in chat with `file:line` references, reading the code rather than guessing.
- "answer my asks": read `tuicr review comments --session ...`, take the ones with `comment_type` `ask`, answer each in chat under its location, then delete it with `tuicr review delete --session ... --comment-id <id>`. `ask` comments must never reach GitHub.
- "ready?" / "check before submit": list remaining `ask` drafts (delete them), 🤖 drafts whose content is unchanged since you added them (kept as is = the human endorses them), and suggest a verdict: Request changes if a `blocking` or `should-fix` remains, otherwise Approve when no concern is open, else Comment. They submit with `:submit` in tuicr.

## 6. Log what the PR changed

When the human says they submitted or are done, append to `~/Documents/brand/review-notes/<ISO week, date +%G-W%V>.md` (create it with `# Week <G-W%V>` and a `## Reviews` heading if missing):

```markdown
### OWNER/REPO#N: <title> (<tier>, <verdict>)
- 3-5 lines: what this adds or changes in the system, new concepts, responsibilities that moved, risks or follow-ups worth remembering.
```

Write it for future-you who never saw the diff.
