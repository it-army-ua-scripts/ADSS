#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

extend_ports() {

    port_range_string="net.ipv4.ip_local_port_range=16384 65535"
    specified_file="/etc/sysctl.conf"

    if [[ $(grep -L "$port_range_string" "$specified_file")  ]]; then
        echo -e "${GREEN}Розширюємо порти${NC}"
        sudo bash -c "echo '$port_range_string' >> $specified_file"
        sudo sysctl -p
    fi
}
