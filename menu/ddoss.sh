#!/bin/bash

ddos() {
  menu_items=("$(trans "Встановлення ддос інструментів")" "$(trans "Управління ддос інструментами")" "$(trans "Повернутись назад")")
  display_menu "DDOS" "${menu_items[@]}"

  case $? in
  1)
    clear
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stat_bot${NC}""\n"
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Щоб пропустити, натисніть Enter")${NC}""\n""\n"
    echo -ne "$(trans "Юзер ІД: ")"
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
