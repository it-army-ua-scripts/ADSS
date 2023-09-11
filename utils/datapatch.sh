#!/bin/bash

apply_patch() {
  envFile="$SCRIPT_DIR/services/EnvironmentFile"

  # for 1.1.0
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'interface='; then
    sed -i 's/\[\/distress\]/interface=\n\[\/distress\]/g' "$envFile"
  fi

  if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'bind='; then
    sed -i 's/\[\/mhddos\]/bind=\n\[\/mhddos\]/g' "$envFile"
  fi
  # end 1.1.0

  # for 1.1.1
  if ! awk '/\[db1000n\]/,/\[\/db1000n\]/' "$envFile" | grep -q 'interface='; then
    sed -i 's/\[\/db1000n\]/interface=\n\[\/db1000n\]/g' "$envFile"
  fi
  # end 1.1.0
}
