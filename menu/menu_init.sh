#!/bin/bash

display_menu() {
    title="$1"
    shift
    options=("$@")
    local dialog_args=()
    local index
    for index in "${!options[@]}"; do
      dialog_args+=("$((index+1))" "${options[index]}")
    done
    local selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "$title" \
            --menu "Виберіть опцію:" 0 0 0 "${dialog_args[@]}")

    if [[ -z "$selection" ]]; then
         clear
         echo "Exiting..."
         exit 0
    fi
    return "$selection"
}