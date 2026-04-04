#!/bin/bash

get_infobox_dimensions() {
  local text="$1"
  local lines
  local columns
  local width
  local height
  local text_width
  local text_lines

  if declare -F get_terminal_lines >/dev/null 2>&1; then
    lines=$(get_terminal_lines)
    columns=$(get_terminal_columns)
    text_width=$(get_dialog_text_width)
    text=$(wrap_dialog_text "$text" "$text_width")
    text_lines=$(count_text_lines "$text")
  else
    lines=24
    columns=80
    text_lines=$(printf '%s\n' "$text" | awk 'END { print NR }')
  fi

  width=$((columns - 8))
  if [[ "$width" -lt 34 ]]; then
    width=34
  elif [[ "$width" -gt 90 ]]; then
    width=90
  fi

  height=$((text_lines + 6))
  if [[ "$height" -lt 8 ]]; then
    height=8
  elif [[ "$height" -gt $((lines - 2)) ]]; then
    height=$((lines - 2))
  fi

  ADSS_INFOBOX_HEIGHT="$height"
  ADSS_INFOBOX_WIDTH="$width"
  ADSS_INFOBOX_TEXT="$text"
}

adss_dialog() {
  get_infobox_dimensions "$1"
  if declare -F use_plain_terminal_ui >/dev/null 2>&1 && use_plain_terminal_ui; then
    print_console_block "Execution Message" "$ADSS_INFOBOX_TEXT"
    return
  fi

  dialog --ascii-lines --title "Execution Message" --no-collapse --infobox "$ADSS_INFOBOX_TEXT" "$ADSS_INFOBOX_HEIGHT" "$ADSS_INFOBOX_WIDTH" || {
    if declare -F mark_plain_terminal_ui >/dev/null 2>&1; then
      mark_plain_terminal_ui
    fi
    print_console_block "Execution Message" "$ADSS_INFOBOX_TEXT"
  }
}

confirm_dialog() {
  get_infobox_dimensions "$1"
  if declare -F use_plain_terminal_ui >/dev/null 2>&1 && use_plain_terminal_ui; then
    print_console_block "Execution Message" "$ADSS_INFOBOX_TEXT"
    sleep 2
    return
  fi

  dialog --ascii-lines --title "Execution Message" --no-collapse --infobox "$ADSS_INFOBOX_TEXT" "$ADSS_INFOBOX_HEIGHT" "$ADSS_INFOBOX_WIDTH" || {
    if declare -F mark_plain_terminal_ui >/dev/null 2>&1; then
      mark_plain_terminal_ui
    fi
    print_console_block "Execution Message" "$ADSS_INFOBOX_TEXT"
  }
  sleep 2
}
