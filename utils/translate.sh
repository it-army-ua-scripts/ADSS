#!/bin/bash

load_translation_file() {
  local PATH_TO_LOCALIZATION="$SCRIPT_DIR/i18n"
  for arg in "$@"; do
    if [[ $arg == "--lang" ]]; then
      case "$arg" in
          en)
            source "$PATH_TO_LOCALIZATION/en.sh"
            ;;
          *)
            source "$PATH_TO_LOCALIZATION/ua.sh"
            ;;
        esac
    else
      source "$PATH_TO_LOCALIZATION/ua.sh"
    fi
  done
}

trans() {
  if [[ -z "${localization[$1]}" ]]; then
    echo "$1"
  else
    echo ${localization[$1]}
  fi
}