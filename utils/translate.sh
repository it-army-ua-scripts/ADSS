#!/bin/bash

apply_localization() {
  local PATH_TO_LOCALIZATION="$SCRIPT_DIR/i18n"
  local file_to_include=""
  lang_param_found=false
  for arg in "$@"; do
    if [[ "$arg" == "--lang" ]]; then
      lang_param_found=true
    elif [[ "$arg" == "en" && "$lang_param_found" == true ]]; then
      file_to_include="$PATH_TO_LOCALIZATION/en.sh"
      break
    fi
  done
  echo "$file_to_include"
}

trans() {
  if [[ -z "${localization[@]}" || -z "${localization[$1]}" ]]; then
    echo "$1"
  else
    echo "${localization[$1]}"
  fi
}
