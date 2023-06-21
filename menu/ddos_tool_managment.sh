#!/bin/bash

ddos_tool_managment(){
  while true; do
    selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "Управління ддос інструментами" \
      --menu "Виберіть опцію:" 0 0 0 \
      1 "Статус атаки" \
      2 "Зупинити атаку" \
      3 "MHDDOS" \
      4 "DB1000N" \
      5 "Distress" \
      6 "Повернутись назад")
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