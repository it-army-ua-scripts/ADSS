#!/bin/bash

wrap_dialog_text() {
  local text="$1"
  local width="${2:-72}"
  local wrapped=""
  local line=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then
      wrapped+=$'\n'
      continue
    fi

    wrapped+="$(printf '%s' "$line" | fold -s -w "$width")"$'\n'
  done <<< "$text"

  printf '%s' "${wrapped%$'\n'}"
}

display_menu() {
  title="$1"
  shift
  local prompt_text
  if [[ "$1" == "--text" ]]; then
    prompt_text="$2"
    shift 2
  else
    prompt_text="$(trans "Оберіть опцію:")"
  fi
  options=("$@")
  local dialog_args=()
  local index
  for index in "${!options[@]}"; do
    dialog_args+=("${options[index]}" "")
  done
  local selection=$(dialog --ascii-lines --clear --stdout --cancel-label "$(trans "Вихід")" --title "$title" \
    --menu "$prompt_text" 0 0 0 "${dialog_args[@]}")

  if [[ -z "$selection" ]]; then
    clear >$(tty)
    echo "Exiting..."
    exit 0
  fi
  echo "$selection"
}
