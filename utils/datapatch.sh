#!/bin/bash

apply_patch() {
  envFile="$SCRIPT_DIR/services/EnvironmentFile"

  # for 1.1.0
  if ! grep -q "interface=" "$envFile"; then
    sed -i 's/\[\/distress\]/interface=\n\[\/distress\]/g' "$envFile"
  fi

  if ! grep -q "bind=" "$envFile"; then
    sed -i 's/\[\/mhddos\]/bind=\n\[\/mhddos\]/g' "$envFile"
  fi
  # end 1.1.0
}
