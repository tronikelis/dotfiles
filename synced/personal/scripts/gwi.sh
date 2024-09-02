#!/bin/sh

set -eou pipefail

rm_worktree="s/worktree //"

base="$(git worktree list --porcelain | head -n 1 | sed "$rm_worktree")"

worktree="$(
	git worktree list --porcelain |
		tail -n +2 |
		grep 'worktree ' |
		sed "$rm_worktree" |
		cut -c $((${#base} + 1))- |
		fzf --reverse --header-first --header "Select Git Worktree"
)"

tab_title="git: $worktree"

worktree="$base$worktree"

# "" -> \"\" lmao
tab_title="$(printf "$tab_title" | sed "s/\"/\\\\\"/g")"

current_id="$(
	kitten @ ls |
		jq ".[].tabs.[] | select(.title == \"$tab_title\") .id"
)"

if [[ -z "$current_id" ]]; then
	printf "got empty id, launching\n"
	kitten @ launch --type=tab --tab-title "$tab_title" --cwd "$worktree" --hold nvim .
else
	printf "focusing id $current_id\n"
	kitten @ focus-tab --match "id:$current_id"
fi
