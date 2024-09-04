#!/bin/sh

# [G]it
# [W]orktree
# [S]elect
# [I]nteractive

set -eou pipefail

selected="$(
	~/personal/scripts/git/select_worktree.sh --header 'Select Git Worktree'
)"

base="$(printf "$selected" | awk '{print $1}')"
branch="$(printf "$selected" | awk '{print $2}')"

tab_title="git: $branch"
worktree="$base$branch"
printf "will switch to $worktree\n"

# "" -> \"\" lmao
tab_title="$(printf "$tab_title" | sed "s/\"/\\\\\"/g")"

current_id="$(
	kitten @ ls |
		jq ".[].tabs.[] | select(.title == \"$tab_title\") .id"
)"

if [[ -z "$current_id" ]]; then
	printf "got empty id, launching\n"
	kitten @ launch --type=tab --tab-title "$tab_title" --cwd "$worktree"
else
	printf "focusing id $current_id\n"
	kitten @ focus-tab --match "id:$current_id"
fi
