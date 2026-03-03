#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Projects ~/.config -mindepth 0 -maxdepth 2 -type d -not \( -name 'node_modules' -o -name '.git' \) | grep -vE '/(node_modules|\.git)/'| fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

# generate tmux windows
generate_tmux_windows() {
    PARENT_DIRECTORY_PATH=$1
    TYPE=$2

    subdirectories=$(find "$PARENT_DIRECTORY_PATH" -mindepth 1 -maxdepth 1 -type d)
    PARENT_DIRECTORY_NAME=$(basename "$PARENT_DIRECTORY_PATH")

    tmux_window_args="tmux new-session -"
    if [[ $TYPE == "d" ]]; then
        tmux_window_args+="d"
    fi
    tmux_window_args+="s $PARENT_DIRECTORY_NAME -c $PARENT_DIRECTORY_PATH "

    valid_subdirectories=()
    for subdirectory in $subdirectories; do
        if [[ -d "$subdirectory/.git" ]]; then
            subdirectory_name=$(basename "$subdirectory")
            tmux_window_args+="-n $subdirectory_name "
            valid_subdirectories+=("$subdirectory")
        fi
    done

    for subdirectory in "${valid_subdirectories[@]}"; do
        subdirectory_name=$(basename "$subdirectory")
        tmux_window_args+="\\; new-window -t $PARENT_DIRECTORY_NAME -c $subdirectory -n $subdirectory_name "
    done

    echo "$tmux_window_args"
}

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  command_exec=$(generate_tmux_windows "$selected" s)
  eval "$command_exec"
  tmux attach-session -t "$selected_name"
  exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
  command_to_exec=$(generate_tmux_windows "$selected" d)
  eval "$command_to_exec"
fi

tmux switch-client -t "$selected_name"
