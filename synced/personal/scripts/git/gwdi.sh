#!/bin/bash

# [G]it
# [W]orktree
# [D]elete
# [I]nteractive

set -eou pipefail

selected="$(
	~/personal/scripts/git/select_worktree.sh --header 'Delete Git Worktrees' -m
)"

base="$(printf "$selected" | head -n1 | awk '{print $1}')"
branches="$(printf "$selected" | cut -d' ' -f2)"

IFS=$'\n'
for branch in $branches; do
	echo "deleting $base$branch"
	git worktree remove "$base$branch"
done
