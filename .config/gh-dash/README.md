# gh-dash

- `config.yml`: work dashboard (`gh dash`)
- `personal.yml`: everything outside Brand-Boekhouders (`gh dash-personal`)
- `common.yml`: shared defaults, keybindings, `repoPaths`

Keys in the PR view: `O` open in worktree + Ghostty/nvim, `T` unresolved threads, `M` auto-merge. In any view: `B` opens the BERP board (my items, current sprint).

`bin/gh-todo` (`gh todo`) lists your open PRs, worst problem first, with an fzf picker. `bin/gh-pr-worktree-prune [--dry-run]` removes `.worktrees/pr-N` for merged or closed PRs.

## New machine

```sh
ln -s ../Documents/joris/dotfiles/.config/gh-dash ~/.config/gh-dash
gh extension install dlvhdr/gh-dash
gh alias set --shell todo '~/.config/gh-dash/bin/gh-todo "$@"'
gh alias set --shell dash-personal 'gh dash --config "$HOME/.config/gh-dash/personal.yml" "$@"'
```
