#!/bin/bash

use_plain_terminal_ui() {
  [[ "$ADSS_FORCE_PLAIN_UI" == "1" ]]
}

mark_plain_terminal_ui() {
  ADSS_FORCE_PLAIN_UI="1"
}

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

print_console_block() {
  local title="$1"
  local text="$2"

  clear 2>/dev/null || true
  printf '=== %s ===\n\n' "$title"
  printf '%s\n' "$text"
  printf '\n'
}

display_scrollable_text_plain() {
  local title="$1"
  local text="$2"

  print_console_block "$title" "$(wrap_dialog_text "$text")"
  read -r -p "Press Enter to continue..." _
}

display_scrollable_text() {
  local title="$1"
  local text="$2"
  local lines
  local columns
  local width
  local height
  local tmpfile
  local dialog_status

  if use_plain_terminal_ui; then
    display_scrollable_text_plain "$title" "$text"
    return
  fi

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
  dialog_status=$?

  rm -f "$tmpfile"

  if [[ "$dialog_status" -ne 0 ]]; then
    mark_plain_terminal_ui
    display_scrollable_text_plain "$title" "$text"
  fi
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

display_menu_plain() {
  local title="$1"
  local prompt_text="$2"
  shift 2
  local options=("$@")
  local choice
  local index

  while true; do
    print_console_block "$title" "$prompt_text"

    for index in "${!options[@]}"; do
      printf '%s. %s\n' "$((index + 1))" "${options[index]}"
    done

    printf '\n0. %s\n\n' "$(trans "Вихід")"
    read -r -p "> " choice

    if [[ "$choice" == "0" || -z "$choice" ]]; then
      clear 2>/dev/null || true
      echo "Exiting..."
      exit 0
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#options[@]}" ]]; then
      echo "${options[$((choice - 1))]}"
      return
    fi
  done
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
  local selection
  local dialog_status

  if use_plain_terminal_ui; then
    display_menu_plain "$title" "$prompt_text" "${options[@]}"
    return
  fi

  read -r dialog_height dialog_width dialog_menu_height <<< "$(get_dialog_menu_dimensions "$prompt_text" "${#options[@]}")"

  for index in "${!options[@]}"; do
    dialog_args+=("${options[index]}" "")
  done
  selection=$(dialog --ascii-lines --clear --stdout --cancel-label "$(trans "Вихід")" --title "$title" \
    --no-collapse --menu "$prompt_text" "$dialog_height" "$dialog_width" "$dialog_menu_height" "${dialog_args[@]}")
  dialog_status=$?

  if [[ "$dialog_status" -ne 0 && -z "$selection" ]]; then
    mark_plain_terminal_ui
    display_menu_plain "$title" "$prompt_text" "${options[@]}"
    return
  fi

  if [[ -z "$selection" ]]; then
    clear 2>/dev/null || true
    echo "Exiting..."
    exit 0
  fi
  echo "$selection"
}
