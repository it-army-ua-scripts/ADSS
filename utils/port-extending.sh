#!/bin/bash

extend_ports() {
  port_range_string="net.ipv4.ip_local_port_range=16384 65535"
  specified_file="/usr/lib/sysctl.d/port-extending.conf"

  sudo touch $specified_file

  if [[ -f "$specified_file" ]]; then
    if [[ $(grep -L "$port_range_string" "$specified_file") ]]; then
      extend() {
        sudo bash -c "echo '$port_range_string' >> $specified_file"
        sudo sysctl --system
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
