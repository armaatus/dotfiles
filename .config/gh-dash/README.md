# gh-dash

- `config.yml`: work dashboard (`gh dash`)
- `personal.yml`: everything outside Brand-Boekhouders (`gh dash-personal`)
- `common.yml`: shared defaults, keybindings, `repoPaths`

Keys in the PR view: `I` review with tuicr + Claude, `O` open in worktree + Ghostty/nvim, `T` unresolved threads, `M` auto-merge. In any view: `B` opens the BERP board (my items, current sprint).

`bin/gh-todo` (`gh todo`) lists your open PRs, worst problem first, with an fzf picker. `bin/gh-pr-worktree-prune [--dry-run]` cleans up worktrees, review tmux sessions and tuicr sessions of merged or closed PRs.

## Reviewing

- `gh queue`: teammates' PRs waiting on you, tiered DEEP > SKIM > TRUST by `bin/lib/tier.jq` (tests: `bin/tests/tier.test.sh`). Enter starts a review.
- `I` / `gh-pr-review OWNER/REPO N`: tmux session `<repo>-<N>` in the PR worktree, tuicr left, Claude right running the `pr-review-session` skill (`dotfiles/claude/skills`) with `review/claude-settings.json` (read-only plus tuicr drafts and review notes). Claude briefs you, reviews the commits the CI bot never saw and adds 🤖 drafts; delete to reject, keep to endorse. Leave `ask` comments and tell it "answer my asks"; say "ready?" before `:submit`.
- `gh digest [--days N]`: summary of merged PRs you didn't review, appended with the per-PR notes to `~/Documents/brand/review-notes/<week>.md`.

## New machine

```sh
ln -s ../Documents/joris/dotfiles/.config/gh-dash ~/.config/gh-dash
ln -s ../Documents/joris/dotfiles/.config/tuicr ~/.config/tuicr
ln -s ../../Documents/joris/dotfiles/claude/skills/pr-review-session ~/.claude/skills/pr-review-session
gh extension install dlvhdr/gh-dash
brew install tuicr tmux fzf jq
gh alias set --shell todo '~/.config/gh-dash/bin/gh-todo "$@"'
gh alias set --shell queue '~/.config/gh-dash/bin/gh-queue "$@"'
gh alias set --shell digest '~/.config/gh-dash/bin/gh-digest "$@"'
gh alias set --shell dash-personal 'gh dash --config "$HOME/.config/gh-dash/personal.yml" "$@"'
```
