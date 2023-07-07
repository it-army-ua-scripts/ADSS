#!/bin/bash

install_distress() {
    adss_dialog "Встановлюємо Distress"

    install() {
        cd $TOOL_DIR
        OSARCH=$(uname -m)
        package=''
        case "$OSARCH" in
          aarch64*)
            package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_aarch64-unknown-linux-musl
          ;;

          x86_64*)
            package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_x86_64-unknown-linux-musl
          ;;

          i386* | i686*)
            package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_i686-unknown-linux-musl
          ;;

          *)
            confirm_dialog "Неможливо визначити розрядность операційної системи"
            ddos_tool_managment
          ;;
        esac

        sudo curl -Lo distress "$package"
        sudo chmod +x distress
        regenerate_distress_service_file
        sudo ln -sf  "$SCRIPT_DIR"/services/distress.service /etc/systemd/system/distress.service
    }
    install > /dev/null 2>&1
    confirm_dialog "Distress успішно встановлено"
}

configure_distress() {
    clear
    declare -A params;

    echo -e "${GRAY}Залиште пустим якщо хочите видалити пераметри${NC}"
    read -e -p "Юзер ІД: " -i "$(get_distress_variable 'user-id')" user_id

    params[user-id]=$user_id

    read -e -p "Відсоткове співвідношення використання власної IP адреси (0-100): " -i "$(get_distress_variable 'use-my-ip')" use_my_ip
    if [[ -n "$use_my_ip" ]];then
      while [[ $use_my_ip -lt 0 || $use_my_ip -gt 100 ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Відсоткове співвідношення використання власної IP адреси (0-100): " -i "$(get_distress_variable 'use-my-ip')" use_my_ip
      done
    fi

    params[use-my-ip]=$use_my_ip

    read -e -p "Кількість підключень Tor (0-100): "  -i "$(get_distress_variable 'use-tor')" use_tor
    if [[ -n "$use_tor" ]];then
      while [[ $use_tor -lt 0 || $use_tor -gt 100 ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Кількість підключень Tor (0-100): " -i "$(get_distress_variable 'use-tor')" use_tor
      done
    fi
    params[use-tor]=$use_tor

    read -e -p "Кількість створювачів завдань (4096): "  -i "$(get_distress_variable 'concurrency')" concurrency
    if [[ -n "$concurrency" ]];then
      while [[ ! $concurrency =~ ^[0-9]+$ ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Кількість створювачів завдань (4096): " -i "$(get_distress_variable 'concurrency')" concurrency
      done
    fi

    params[concurrency]=$concurrency

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
    	  write_distress_variable "$i" "$value"
    done
    regenerate_distress_service_file
    confirm_dialog "Успішно виконано"
}

get_distress_variable() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_distress_variable() {
  sed -i "/\[distress\]/,/\[\/distress\]/s/$1=.*/$1=$2/g" "${SCRIPT_DIR}"/services/EnvironmentFile
}

regenerate_distress_service_file() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/bin/distress"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[distress]" || "$key" = "[/distress]" ]]; then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" "${SCRIPT_DIR}"/services/distress.service

  sudo systemctl daemon-reload
}

distress_run() {
  sudo systemctl stop mhddos.service
  sudo systemctl stop db1000n.service
  sudo systemctl start distress.service
}

distress_auto_enable() {
  sudo systemctl disable mhddos.service >/dev/null
  sudo systemctl disable db1000n.service >/dev/null
  sudo systemctl enable distress >/dev/null
}

distress_stop() {
  sudo systemctl stop distress.service
}

distress_get_status() {
  clear
  sudo systemctl status distress.service
  echo -e "${GRAY}Нажміть будь яку клавішу щоб продовжити${NC}"
  read -s -n 1 key
  initiate_distress
}

initiate_distress() {
  if [[ ! -e "/etc/systemd/system/distress.service" ]]; then
    confirm_dialog "Distress не встановлений, будь ласка встановіть і спробуйте знову"
    ddos_tool_managment
  else
      menu_items=("Запуск Distress" "Зупинка Distress")

      if sudo systemctl is-enabled distress >/dev/null 2>&1; then
        enabled_disabled="Вимкнути автозавантаження"
      else
        enabled_disabled="Увімкнути автозавантаження"
      fi
      menu_items+=("$enabled_disabled" "Налаштування Distress" "Статус Distress" "Повернутись назад")
      display_menu "Distress" "${menu_items[@]}"

      case $? in
        1)
          distress_run
          distress_get_status
        ;;
        2)
          distress_stop
          distress_get_status
        ;;
        3)
          if sudo systemctl is-enabled distress >/dev/null 2>&1; then
            sudo systemctl disable distress >/dev/null
            confirm_dialog "Distress видалено з автозавантаження"
          else
            distress_auto_enable
            confirm_dialog "Distress додано в автозавантаження"
          fi
          initiate_distress
        ;;
        4)
          configure_distress
          initiate_distress
        ;;
        5)
          distress_get_status
        ;;
        6)
          ddos_tool_managment
        ;;
      esac
  fi
}