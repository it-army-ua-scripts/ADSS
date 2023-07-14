#!/bin/bash

load_translation_file() {
  local PATH_TO_LOCALIZATION="$SCRIPT_DIR/i18n"
  lang_param_found=false
  for arg in "$@"; do
      if [[ "$arg" == "--lang" ]]; then
          lang_param_found=true
      elif [[ "$arg" == "en" && "$lang_param_found" == true ]]; then
          source "$PATH_TO_LOCALIZATION/en.sh"
          break
      elif [[ "$arg" == "ua" && "$lang_param_found" == true ]]; then
          source "$PATH_TO_LOCALIZATION/ua.sh"
          break
      fi
  done

  if [[ "$lang_param_found" == false ]]; then
    source "$PATH_TO_LOCALIZATION/ua.sh"
  fi
}

trans() {
  if [[ -z "${localization[$1]}" ]]; then
    echo "$1"
  else
    echo "${localization[$1]}"
  fi
}