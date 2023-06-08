#!/bin/bash

extend_ports() {

    port_range_string="net.ipv4.ip_local_port_range=16384 65535"
    specified_file="/etc/sysctl.conf"

    if [[ -f "$specified_file" ]]; then
       if [[ $(grep -L "$port_range_string" "$specified_file")  ]]; then
          echo -e "${GREEN}Розширюємо порти${NC}"
          sudo bash -c "echo '$port_range_string' >> $specified_file"
          sudo sysctl -p
          echo -e "${GREEN}Порти успішно розширено${NC}"
      else
          echo -e "${GREEN}Необхідна дія вже виконана${NC}"
      fi
    else
      echo -e "${RED}Не можливо виконати дію${NC}"
    fi
}
