#!/bin/bash

check_enabled() {
  services=("mhddos" "distress" "db1000n")
  stop_service=0
  for service in "${services[@]}"; do
#TODO sudo rc-service "$service" status
    if sudo rc-service is-active "$service" >/dev/null; then
      stop_service=1
      break
    fi
  done
  return "$stop_service"
}

create_symlink() {
#TODO
#  if [ ! -L "/etc/systemd/system/mhddos.service" ]; then
#    sudo ln -sf "$SCRIPT_DIR"/services/systemd/mhddos.service /etc/systemd/system/mhddos.service >/dev/null 2>&1
#  fi

#  if [ ! -L "/etc/systemd/system/distress.service" ]; then
#    sudo ln -sf "$SCRIPT_DIR"/services/systemd/distress.service /etc/systemd/system/distress.service >/dev/null 2>&1
#  fi

#  if [ ! -L "/etc/systemd/system/db1000n.service" ]; then
#    sudo ln -sf "$SCRIPT_DIR"/services/systemd/db1000n.service /etc/systemd/system/db1000n.service >/dev/null 2>&1
#  fi

  if [ ! -L "/etc/init.d/mhddos" ]; then
    sudo ln -sf "$SCRIPT_DIR"/services/openrc/mhddos /etc/init.d/mhddos >/dev/null 2>&1
  fi

  if [ ! -L "/etc/init.d/distress" ]; then
    sudo ln -sf "$SCRIPT_DIR"/services/openrc/distress /etc/init.d/distress >/dev/null 2>&1
  fi

  if [ ! -L "/etc/init.d/db1000n" ]; then
    sudo ln -sf "$SCRIPT_DIR"/services/openrc/db1000n /etc/init.d/db1000n >/dev/null 2>&1
  fi
}

stop_services() {
  adss_dialog "$(trans "Зупиняємо атаку")"
#TODO
  #sudo rc-service  distress.service stop  >/dev/null
  #sudo rc-service  db1000n.service stop  >/dev/null
  #sudo rc-service  mhddos.service stop  >/dev/null
  
  sudo rc-service distress stop >/dev/null
  sudo rc-service db1000n stop >/dev/null
  sudo rc-service mhddos stop >/dev/null
  
  confirm_dialog "$(trans "Атака зупинена")"
  ddos_tool_managment
}

get_ddoss_status() {
  services=("mhddos" "distress" "db1000n")
  service=""

  for element in "${services[@]}"; do
    if rc-service is-active --quiet "$element.service"; then
      service="$element"
      break
    fi
  done
  if [[ -n "$service" ]]; then
    while true; do
      clear
      echo -e "${GREEN}$(trans "Запущено $service")${NC}"

      #Fix Kali
      #https://t.me/c/1764189517/301014
      #https://t.me/c/1764189517/300970
      #tail --lines=20 /var/log/syslog | grep -w "$service"
	  #Fix Parrot
      #journalctl -n 20 -u "$service.service" --no-pager

      #Fix Ubuntu < 19
      lsb_version="$(. /etc/os-release && echo "$VERSION_ID")"
      lsb_id="$(. /etc/os-release && echo "$ID")"
	  
      if [[ "$lsb_id" == "ubuntu" ]] &&
         [[ "$lsb_version" < 19* ]]; then
        journalctl -n 20 -u "$service.service" --no-pager
      else
        tail --lines=20 /var/log/adss.log
      fi

      echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"

      sleep 3
      if read -rsn1 -t 0.1; then
        break
      fi
    done
  else
    confirm_dialog "$(trans "Немає запущених процесів")"
  fi
}

ddos_tool_managment() {
  menu_items=("$(trans "Статус атаки")")
  check_enabled
  enabled_tool=$?
  if [[ "$enabled_tool" == 1 ]]; then
    menu_items+=("$(trans "Зупинити атаку")")
  fi
  menu_items+=("$(trans "Налаштування автозапуску")")
  is_not_arm_arch
  if [[ $? == 1 ]]; then
    menu_items+=("MHDDOS")
  fi
  menu_items+=("DB1000N" "DISTRESS" "$(trans "Повернутись назад")")
  res=$(display_menu "$(trans "Управління ддос інструментами")" "${menu_items[@]}")

  case "$res" in
  "$(trans "Статус атаки")")
    get_ddoss_status
    ddos_tool_managment
    ;;
  "$(trans "Зупинити атаку")")
    stop_services
    ;;
  "$(trans "Налаштування автозапуску")")
    autoload_configuration
    ;;
  "MHDDOS")
    initiate_mhddos
    ;;
  "DB1000N")
    initiate_db1000n
    ;;
  "DISTRESS")
    initiate_distress
    ;;
  "$(trans "Повернутись назад")")
    ddos
    ;;
  esac
}
