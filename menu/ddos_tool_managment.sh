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

create_symlink() {
  if [ ! -L "/etc/systemd/system/mhddos.service" ]; then
    sudo ln -sf  "$SCRIPT_DIR"/services/mhddos.service /etc/systemd/system/mhddos.service >/dev/null 2>&1
  fi

  if [ ! -L "/etc/systemd/system/distress.service" ]; then
      sudo ln -sf  "$SCRIPT_DIR"/services/distress.service /etc/systemd/system/distress.service >/dev/null 2>&1
  fi

  if [ ! -L "/etc/systemd/system/db1000n.service" ]; then
    sudo ln -sf  "$SCRIPT_DIR"/services/db1000n.service /etc/systemd/system/db1000n.service >/dev/null 2>&1
  fi
}

stop_services() {
  adss_dialog "Зупиняємо атаку"
  sudo systemctl stop distress.service >/dev/null
  sudo systemctl stop db1000n.service >/dev/null
  sudo systemctl stop mhddos.service >/dev/null
  confirm_dialog "Атака зупинена"
  ddos_tool_managment
}

get_ddoss_status() {
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
    if [[ "$enabled_tool" == 1 ]]; then
        case $status in
          1)
            get_ddoss_status
          ;;
          2)
            stop_services
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
    else
      case $status in
        1)
          get_ddoss_status
        ;;
        2)
          initiate_mhddos
        ;;
        3)
          initiate_db1000n
        ;;
        4)
          initiate_distress
        ;;
        5)
          ddos
        ;;
      esac
    fi
}