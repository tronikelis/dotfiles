#!/bin/zsh

all_tabs="$(
    kitty @ ls | jq -r '
        .[]
        | select(.is_active)
        | .tabs[]
        | select(.is_focused == false)
        | [.title, "id:\(.id)"]
        | @tsv
    ' | column -ts $'\t'
)"

new_tab_id="$(fzf --header "Select tab:" --header-first --reverse <<<"${all_tabs}" | awk '{ print $2 }')"
kitty @ focus-tab -m "${new_tab_id}"
