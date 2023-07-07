#!/bin/bash

check_enabled() {
  services=("mhddos" "distress" "db1000n")
  stop_service=0
  for service in "${services[@]}"
  do
    if sudo systemctl is-active "$service" >/dev/null; then
      stop_service=1
      break
    fi
  done
  return "$stop_service"
}

stop_services() {
  adss_dialog "Зупиняємо атаку"
  sudo systemctl stop distress.service
  sudo systemctl stop db1000n.service
  sudo systemctl stop mhddos.service
  confirm_dialog "Атака зупинена"
}

ddos_tool_managment(){
    menu_items=("Статус атаки")
    check_enabled
    enabled_tool=$?
    if [[ "$enabled_tool" == 1 ]]; then
      menu_items+=("Зупинити атаку")
    fi
    menu_items+=("MHDDOS" "DB1000N" "Distress" "Повернутись назад")
    display_menu "Управління ддос інструментами" "${menu_items[@]}"
    status=$?
    if [[ "$enabled_tool" == 1 && "$status" == 2 ]]; then
       stop_services
       ddos_tool_managment
    fi
    case $status in
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
            ddos_tool_managment
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
}