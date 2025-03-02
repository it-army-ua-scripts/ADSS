#!/bin/bash

apply_patch() {
  envFile="$SCRIPT_DIR/services/EnvironmentFile"

  # for 1.1.0
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'interface='; then
    sed -i 's/\[\/distress\]/interface=\n\[\/distress\]/g' "$envFile"
  fi

#  if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'bind='; then
#    sed -i 's/\[\/mhddos\]/bind=\n\[\/mhddos\]/g' "$envFile"
#  fi
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
#  if awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-failover='; then
#    sed -i 's/direct-udp-failover/direct-udp-mixed-flood/g' "$envFile"
#    regenerate_distress_service_file
#  fi

  if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'udp-packet-size='; then
    sed -i 's/\[\/distress\]/udp-packet-size=4096\n\[\/distress\]/g' "$envFile"
    regenerate_distress_service_file
  fi
  if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-mixed-flood-packets-per-conn='; then
    sed -i 's/\[\/distress\]/direct-udp-mixed-flood-packets-per-conn=30\n\[\/distress\]/g' "$envFile"
    regenerate_distress_service_file
  fi
  # for 1.1.4

  # for 1.1.8
  if awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'vpn='; then
    sed -i '/\[mhddos\]/,/\[\/mhddos\]/ s/^vpn=.*//' "$envFile"
    regenerate_mhddos_service_file
  fi
  if awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'vpn-percents='; then
    sed -i '/\[mhddos\]/,/\[\/mhddos\]/ s/^vpn-percents=.*//' "$envFile"
    regenerate_mhddos_service_file
  fi

  sed -i '/\[mhddos\]/,/\[\/mhddos\]/ {
            /^\[mhddos\]/b
            /^\[\/mhddos\]/b
            /^[[:space:]]*$/d
          }' "$envFile"

  if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'use-my-ip='; then
    sed -i 's/\[\/mhddos\]/use-my-ip=0\n\[\/mhddos\]/g' "$envFile"
    regenerate_mhddos_service_file
  fi
  if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'source='; then
    sed -i 's/\[\/distress\]/source=adss\n\[\/distress\]/g' "$envFile"
    regenerate_distress_service_file
  fi
  if ! awk '/\[db1000n\]/,/\[\/db1000n\]/' "$envFile" | grep -q 'source='; then
    sed -i 's/\[\/db1000n\]/source=adss\n\[\/db1000n\]/g' "$envFile"
    regenerate_db1000n_service_file
  fi
  # for 1.1.8

  # for 1.2.1
  udpPackageSize=$(sed -n '/\[distress\]/,/\[\/distress\]/ s/udp-packet-size=\([0-9]\+\)/\1/p' "$envFile")
  if [[ $udpPackageSize -gt 1420 ]]; then
    sed -i '/\[distress\]/,/\[\/distress\]/ s/udp-packet-size=[0-9]\+/udp-packet-size=1252/g' "$envFile"
    regenerate_distress_service_file
  fi
  # for 1.2.1

  # for 1.2.2
    if awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'bind='; then
      sed -i '/\[mhddos\]/,/\[\/mhddos\]/ s/bind=/ifaces=/g' "$envFile"
      regenerate_mhddos_service_file
    elif ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'ifaces='; then
      sed -i 's/\[\/mhddos\]/ifaces=\n\[\/mhddos\]/g' "$envFile"
      regenerate_mhddos_service_file
    fi
    if awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-failover='; then
      sed -i '/\[distress\]/,/\[\/distress\]/ s/direct-udp-failover=/disable-udp-flood=/g' "$envFile"
      regenerate_distress_service_file
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'enable-icmp-flood='; then
      sed -i 's/\[\/distress\]/enable-icmp-flood=0\n\[\/distress\]/g' "$envFile"
      regenerate_distress_service_file
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'enable-packet-flood='; then
      sed -i 's/\[\/distress\]/enable-packet-flood=0\n\[\/distress\]/g' "$envFile"
      regenerate_distress_service_file
    fi
    if awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'direct-udp-mixed-flood='; then
      sed -i '/^\[distress\]/,/^\[\/distress\]/{/direct-udp-mixed-flood=/d}'  "$envFile"
      regenerate_distress_service_file
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'disable-udp-flood='; then
      use_my_ip=$(sed -n '/\[distress\]/,/\[\/distress\]/ s/use-my-ip=\([0-9]\+\)/\1/p' "$envFile")
      if [[ $use_my_ip -eq 0 ]]; then
        sed -i 's/\[\/distress\]/disable-udp-flood=0\n\[\/distress\]/g' "$envFile"
      else
        sed -i 's/\[\/distress\]/disable-udp-flood=1\n\[\/distress\]/g' "$envFile"
      fi
      regenerate_distress_service_file
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'proxies-path='; then
      sed -i 's/\[\/distress\]/proxies-path=\n\[\/distress\]/g' "$envFile"
      regenerate_distress_service_file
    fi
  # for 1.2.2

  # 2.0.5
    if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'cron-to-run='; then
      sed -i 's/\[\/mhddos\]/cron-to-run=\n\[\/mhddos\]/g' "$envFile"
    fi
    if ! awk '/\[mhddos\]/,/\[\/mhddos\]/' "$envFile" | grep -q 'cron-to-stop='; then
      sed -i 's/\[\/mhddos\]/cron-to-stop=\n\[\/mhddos\]/g' "$envFile"
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'cron-to-run='; then
      sed -i 's/\[\/distress\]/cron-to-run=\n\[\/distress\]/g' "$envFile"
    fi
    if ! awk '/\[distress\]/,/\[\/distress\]/' "$envFile" | grep -q 'cron-to-stop='; then
      sed -i 's/\[\/distress\]/cron-to-stop=\n\[\/distress\]/g' "$envFile"
    fi

    if ! grep -q '^\[x100\]$' "$envFile" || ! grep -q '^\[/x100\]$' "$envFile"; then
        echo -e "\n[x100]\n[/x100]" >> "$envFile"
    fi
    if ! awk '/\[x100\]/,/\[\/x100\]/' "$envFile" | grep -q 'cron-to-run='; then
      sed -i 's/\[\/x100\]/cron-to-run=\n\[\/x100\]/g' "$envFile"
    fi
    if ! awk '/\[x100\]/,/\[\/x100\]/' "$envFile" | grep -q 'cron-to-stop='; then
      sed -i 's/\[\/x100\]/cron-to-stop=\n\[\/x100\]/g' "$envFile"
    fi

  # end 2.0.5
}
