#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Projects ~/.config -mindepth 1 -maxdepth 2 -type d -not \( -name 'node_modules' -o -name '.git' \) | grep -vE '/(node_modules|\.git)/'| fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# call python ./generate_tmux_windows.py to generate the tmux windows

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  command_exec=$(python ~/.config/tmux-sessionizer/generate_tmux_windows.py $selected s)
  eval "$command_exec"
  echo "$command_exec"
  tmux attach-session -t "$selected_name"
  exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
  command_to_exec=$(python ~/.config/tmux-sessionizer/generate_tmux_windows.py $selected d)
  eval "$command_to_exec"
  echo "$command_to_exec"
fi

tmux switch-client -t "$selected_name"
