#!/bin/bash

ddos(){
  while true; do
    selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "ДДОС" \
      --menu "Виберіть опцію:" 0 0 0 \
      1 "Встановлення ддос інструментів" \
      2 "Управління ддос інструментами" \
      3 "Повернутись назад")

    exit_status=$?
    case $exit_status in
        255 | 1)
             clear
             echo "Exiting..."
             exit 0
        ;;
    esac
    case $selection in
      1)
        clear
        echo -ne "
Юзер ІД ${GREEN}(Для збору та використання для лідерборда особистої статистики)${NC}:
"
        read user_id

        if [[ "$user_id" ]]; then
          sed -i "s/user-id=.*/user-id=$user_id/g" ${SCRIPT_DIR}/services/EnvironmentFile
        fi

        install_mhddos
        install_db1000n
        install_distress
      ;;
      2)
        ddos_tool_managment
      ;;
      3)
        main_menu
      ;;
    esac
  done
}