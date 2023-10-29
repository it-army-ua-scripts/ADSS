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
  # end 1.1.1

  # for 1.1.3
  if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'source='; then
    sed -i 's/\[\/mhddos\]/source=adss\n\[\/mhddos\]/g' "$envFile"
    regenerate_mhddos_service_file
  fi
  # end 1.1.3

  # for 1.1.4
  if awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-failover='; then
    sed -i 's/direct-udp-failover/direct-udp-mixed-flood/g' "$envFile"
    regenerate_distress_service_file
  fi

  if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'udp-packet-size='; then
    sed -i 's/\[\/distress\]/udp-packet-size=4096\n\[\/distress\]/g' "$envFile"
    regenerate_distress_service_file
  fi
  if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-mixed-flood-packets-per-conn='; then
    sed -i 's/\[\/distress\]/direct-udp-mixed-flood-packets-per-conn=30\n\[\/distress\]/g' "$envFile"
    regenerate_distress_service_file
  fi
  # for 1.1.4
}
