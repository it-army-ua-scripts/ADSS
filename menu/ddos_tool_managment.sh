#!/bin/bash

ddos_tool_managment(){
  while true; do
    menu_items=("Статус атаки" "Зупинити атаку" "MHDDOS" "DB1000N" "Distress" "Повернутись назад")
    selected_choice=$(display_menu "Управління ддос інструментами" "${menu_items[@]}")

    case $selected_choice in
      1)
           services=("mhddos" "distress" "db1000n")
            service=""

            for element in "${services[@]}"
            do
              if systemctl is-active --quiet "$element.service"; then
                service="$element"
                break
              fi
            done
            if [[ -n "$service" ]]; then
              while true; do
                clear
                echo -e "${GREEN}Запущено $service${NC}"
                journalctl -u "$service.service" | tail -20
                echo -e "${GRAY}Нажміть будь яку клавішу щоб продовжити${NC}"

                sleep 3
                if read -rsn1 -t 0.1; then
                  break
                fi
              done
              ddos_tool_managment
            else
               confirm_dialog "Немає запущених процесів"
            fi
      ;;
      2)
          adss_dialog "Зупиняємо атаку"
          sudo systemctl stop distress.service
          sudo systemctl stop db1000n.service
          sudo systemctl stop mhddos.service
          confirm_dialog "Атака зупинена"
      ;;
      3)
        initiate_mhddos
      ;;
      4)
        initiate_db1000n
      ;;
      5)
        initiate_distress
      ;;
      6)
        ddos
      ;;
    esac
  done
}