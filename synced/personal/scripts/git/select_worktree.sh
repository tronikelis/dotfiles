#!/bin/bash

# Selects a git worktree sorted by last modified

set -eou pipefail

nl=$'\n'

rm_worktree="s/worktree //"

git_worktree_list="$(git worktree list --porcelain)"

fzf_preview='git log --date=short --pretty=format:"%Cred%h%Creset %Cblue%ad%Creset %s" --color master..{}'
fzf_preview_window='right,50%,border-left,<80(down,40%,border-top)'

base="$(
	printf "$git_worktree_list" |
		head -n 1 |
		sed "$rm_worktree" |
		# if git repo is at /cwd/.bare
		sed "s/\/.bare//"
)"

worktrees="$(
	printf "$git_worktree_list" |
		tail -n +2 |
		grep 'worktree ' |
		sed "$rm_worktree"
)"

worktrees_with_time=""

IFS=$nl
for item in $worktrees; do
	if [[ "$OSTYPE" == "darwin"* ]]; then
		worktrees_with_time+="$(stat -f %m "$item") $item$nl"
	else
		worktrees_with_time+="$(stat -c %Y "$item") $item$nl"
	fi
done

worktrees_with_time="$(printf "$worktrees_with_time" | sort -r)"
worktrees=""

IFS=$nl
for item in $worktrees_with_time; do
	worktrees+="$(printf "$item" | awk '{print $2}')$nl"
done

branch="$(
	printf "$worktrees" |
		cut -c $((${#base} + 2))- |
		fzf --reverse --header-first --preview "$fzf_preview" --preview-window "$fzf_preview_window" "$@"
)"

echo "$base/ $branch"
