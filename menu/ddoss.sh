#!/bin/bash

ddos(){
    menu_items=("Встановлення ддос інструментів" "Управління ддос інструментами" "Повернутись назад")
    display_menu "ДДОС" "${menu_items[@]}"

    case $? in
      1)
        clear
        echo -ne "${GREEN}Для збору особистої статистики та відображення у лідерборді на офіційному сайті.${NC}"
        echo -ne "
${GREEN}Надається Telegram ботом ${ORANGE}@itarmy_stat_bot${NC}${NC}"
        echo -ne "
${GREEN}Щоб пропустити, натисніть Enter${NC}
"
        echo -ne "
Юзер ІД : "
        read user_id

        if [[ "$user_id" ]]; then
          sed -i "s/user-id=.*/user-id=$user_id/g" ${SCRIPT_DIR}/services/EnvironmentFile
        fi

        install_mhddos
        install_db1000n
        install_distress
        ddos
      ;;
      2)
        ddos_tool_managment
      ;;
      3)
        main_menu
      ;;
    esac
}