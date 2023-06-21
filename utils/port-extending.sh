#!/bin/bash

extend_ports() {
    port_range_string="net.ipv4.ip_local_port_range=16384 65535"
    specified_file="/etc/sysctl.conf"

    if [[ -f "$specified_file" ]]; then
       if [[ $(grep -L "$port_range_string" "$specified_file")  ]]; then
          extend() {
            sudo bash -c "echo '$port_range_string' >> $specified_file"
            sudo sysctl -p
          }
          extend  > /dev/null 2>&1
          confirm_dialog "Порти успішно розширено"
      else
         confirm_dialog "Наразі всі порти розширено"
      fi
    else
      confirm_dialog "Не можливо виконати дію"
    fi
}