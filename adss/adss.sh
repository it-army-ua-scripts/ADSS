#!/bin/bash

if [ $? -ne 0 ] ; then
        echo "Неправильний вхідний параметр!"; 1>&2
        exit 1;
fi

export SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export WORKING_DIR="/opt/itarmy/"
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m'

if [ "$1" = "--auto-install" ] ; then

    declare -a UTILS;

    UTILS=('docker' 'tools' 'fail2ban' 'ufw' 'mhddos' 'db1000n' 'distress')

    for i in "${!UTILS[@]}"; do
        source "${SCRIPT_DIR}/utils/${UTILS[i]}.sh"
        install_"${UTILS[i]}"
    done

else
    echo -ne "
Оберіть пункт меню
${GREEN}1)${NC} Оптимізація для DDOS
${GREEN}2)${NC} Ввести Юзер ІД (Для збору та використання для лідерборда особистої статистики) наданний ботом https://t.me/itarmy_stat_bot
${GREEN}3)${NC} Меню 3
"
read menu_item

case "$menu_item" in
            1)
                source "${SCRIPT_DIR}/menu/port-extending.sh"
                extend_ports
            ;;
            2)
                source "${SCRIPT_DIR}/menu/user-id.sh"
                set_user_id
            ;;
            *)
                echo -e ${GREEN}"Невірна опція."${NC}
            ;;
esac
fi


