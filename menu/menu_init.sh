#!/bin/bash

get_terminal_columns() {
  local columns="${COLUMNS:-}"

  if [[ -z "$columns" ]] && command -v tput >/dev/null 2>&1; then
    columns=$(tput cols 2>/dev/null)
  fi

  if [[ -z "$columns" ]] && command -v stty >/dev/null 2>&1; then
    columns=$(stty size 2>/dev/null | awk '{print $2}')
  fi

  if [[ -z "$columns" || "$columns" -lt 40 ]]; then
    columns=80
  fi

  echo "$columns"
}

get_terminal_lines() {
  local lines="${LINES:-}"

  if [[ -z "$lines" ]] && command -v tput >/dev/null 2>&1; then
    lines=$(tput lines 2>/dev/null)
  fi

  if [[ -z "$lines" ]] && command -v stty >/dev/null 2>&1; then
    lines=$(stty size 2>/dev/null | awk '{print $1}')
  fi

  if [[ -z "$lines" || "$lines" -lt 16 ]]; then
    lines=24
  fi

  echo "$lines"
}

is_compact_dialog_screen() {
  local columns
  local lines
  columns=$(get_terminal_columns)
  lines=$(get_terminal_lines)

  [[ "$columns" -lt 90 || "$lines" -lt 28 ]]
}

get_dialog_text_width() {
  local columns
  columns=$(get_terminal_columns)

  if [[ "$columns" -lt 56 ]]; then
    echo 28
  elif [[ "$columns" -lt 72 ]]; then
    echo $((columns - 14))
  elif [[ "$columns" -lt 100 ]]; then
    echo $((columns - 18))
  else
    echo 72
  fi
}

wrap_dialog_text() {
  local text="$1"
  local width="${2:-$(get_dialog_text_width)}"
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

count_text_lines() {
  local text="$1"
  if [[ -z "$text" ]]; then
    echo 0
    return
  fi

  printf '%s\n' "$text" | awk 'END { print NR }'
}

display_scrollable_text() {
  local title="$1"
  local text="$2"
  local lines
  local columns
  local width
  local height
  local tmpfile

  lines=$(get_terminal_lines)
  columns=$(get_terminal_columns)
  width=$((columns - 6))
  height=$((lines - 4))

  if [[ "$width" -lt 36 ]]; then
    width=36
  elif [[ "$width" -gt 110 ]]; then
    width=110
  fi

  if [[ "$height" -lt 12 ]]; then
    height=12
  fi

  tmpfile=$(mktemp)
  printf '%s\n' "$(wrap_dialog_text "$text")" > "$tmpfile"

  dialog --ascii-lines --clear --title "$title" --ok-label "OK" \
    --no-collapse --scrollbar --textbox "$tmpfile" "$height" "$width"

  rm -f "$tmpfile"
}

get_dialog_menu_dimensions() {
  local prompt_text="$1"
  local options_count="$2"
  local lines
  local columns
  local width
  local height
  local menu_height
  local prompt_lines

  lines=$(get_terminal_lines)
  columns=$(get_terminal_columns)
  width=$((columns - 6))
  if [[ "$width" -lt 36 ]]; then
    width=36
  elif [[ "$width" -gt 110 ]]; then
    width=110
  fi

  prompt_lines=$(count_text_lines "$prompt_text")
  menu_height=$((options_count + 1))
  if [[ "$menu_height" -lt 4 ]]; then
    menu_height=4
  elif [[ "$menu_height" -gt 12 ]]; then
    menu_height=12
  fi

  height=$((prompt_lines + menu_height + 8))
  if [[ "$height" -gt $((lines - 2)) ]]; then
    height=$((lines - 2))
  fi
  if [[ "$height" -lt 14 ]]; then
    height=14
  fi

  if [[ $((height - prompt_lines - 7)) -lt 3 ]]; then
    menu_height=3
  fi

  echo "$height $width $menu_height"
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
  prompt_text=$(wrap_dialog_text "$prompt_text")
  options=("$@")
  local dialog_args=()
  local index
  local dialog_height
  local dialog_width
  local dialog_menu_height
  read -r dialog_height dialog_width dialog_menu_height <<< "$(get_dialog_menu_dimensions "$prompt_text" "${#options[@]}")"

  for index in "${!options[@]}"; do
    dialog_args+=("${options[index]}" "")
  done
  local selection=$(dialog --ascii-lines --clear --stdout --cancel-label "$(trans "Вихід")" --title "$title" \
    --no-collapse --menu "$prompt_text" "$dialog_height" "$dialog_width" "$dialog_menu_height" "${dialog_args[@]}")

  if [[ -z "$selection" ]]; then
    clear >$(tty)
    echo "Exiting..."
    exit 0
  fi
  echo "$selection"
}
