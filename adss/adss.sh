#!/bin/bash

if [ $? -ne 0 ] ; then
        echo "Неправильний вхідний параметр!"; 1>&2
        exit 1;
fi

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$1" = "--auto-install" ] ; then

    source "${SCRIPT_DIR}/utils/docker.sh"
    source "${SCRIPT_DIR}/utils/fail2ban.sh"
    source "${SCRIPT_DIR}/utils/ufw.sh"

    install_docker
    sleep 1

    install_fail2ban
    sleep 1

    install_ufw
    sleep 1

    exit 0

else
    echo -ne "
Оберіть пункт меню
${GREEN}1)${NC} Оптимізація для DDOS
${GREEN}2)${NC} Меню 2
${GREEN}3)${NC} Меню 3
"
read menu_item

case "$menu_item" in
            1)
                source "${SCRIPT_DIR}/menu/port-extending.sh"
                extend_ports
            ;;
            *)
                echo -e ${GREEN}"Невірна опція."${NC}
            ;;
esac
fi


