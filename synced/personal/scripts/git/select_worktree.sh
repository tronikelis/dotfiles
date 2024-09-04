#!/bin/sh

# Selects a git worktree sorted by last modified

set -eou pipefail

nl=$'\n'

rm_worktree="s/worktree //"

git_worktree_list="$(git worktree list --porcelain)"

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
	worktrees_with_time+="$(stat -c %Y "$item") $item$nl"
done

worktrees_with_time="$(printf "$worktrees_with_time" | sort -r)"
worktrees=""

IFS=$nl
for item in $worktrees_with_time; do
	worktrees+="$(printf "$item" | awk '{print $2}')$nl"
done

branch="$(
	printf "$worktrees" |
		cut -c $((${#base} + 1))- |
		fzf --reverse --header-first "$@"
)"

echo "$base $branch"
