#!/bin/bash

step3(){

menu=(
      "Встановлення ддос інструментів"
      "Управління ддос інструментами"
      "Повернутись назад"
      )
init "$menu"
menu_result="$?"

case "$menu_result" in
  0)
      echo -ne "
Юзер ІД ${RED}(Для збору та використання для лідерборда особистої статистики)${NC}:
"
      read user_id

      if [[ "$user_id" ]]; then
        sed -i "s/user-id=.*/user-id=$user_id/g" ${SCRIPT_DIR}/services/EnvironmentFile
      fi

      install_mhddos
      install_db1000n
      install_distress
  ;;
  1)
      step4
  ;;
  2)
      main_menu_init
  ;;
esac
}