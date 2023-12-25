#!/bin/bash

extend_ports() {
  port_range_string="16384 65535"
  specified_file="/proc/sys/net/ipv4/ip_local_port_range"

  if [[ -f "$specified_file" ]]; then
    if [[ $(grep -L "$port_range_string" "$specified_file") ]]; then
      extend() {
        sudo bash -c "echo '$port_range_string' >> $specified_file"
        sudo sysctl -p
      }
      extend >/dev/null 2>&1
      confirm_dialog "$(trans "Порти успішно розширено")"
    else
      confirm_dialog "$(trans "Наразі всі порти розширено")"
    fi
  else
    confirm_dialog "$(trans "Не можливо виконати дію")"
  fi
}
