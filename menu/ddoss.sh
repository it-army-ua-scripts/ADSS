#!/bin/bash

ddos() {
  menu_items=("$(trans "Встановлення ддос інструментів")" "$(trans "Управління ддос інструментами")" "$(trans "Повернутись назад")")
  res=$(display_menu "DDOS" "${menu_items[@]}")

  case "$res" in
  "$(trans "Встановлення ддос інструментів")")
    clear
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stats_bot${NC}""\n"
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Щоб пропустити, натисніть Enter")${NC}""\n""\n"
    echo -ne "$(trans "Юзер ІД: ")"
    read user_id

    if [[ "$user_id" ]]; then
      sed -i "s/user-id=.*/user-id=$user_id/g" ${SCRIPT_DIR}/services/EnvironmentFile
    fi

    is_not_arm_arch
    if [[ $? == 1 ]]; then
      install_mhddos
    fi

#    install_db1000n
    install_distress
    ddos
    ;;
  "$(trans "Управління ддос інструментами")")
    ddos_tool_managment
    ;;
  "$(trans "Повернутись назад")")
    main_menu
    ;;
  esac
}
