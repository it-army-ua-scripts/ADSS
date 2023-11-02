#!/bin/bash

install_distress() {
    adss_dialog "$(trans "Встановлюємо DISTRESS")"

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
            confirm_dialog "$(trans "Неможливо визначити розрядность операційної системи")"
            ddos_tool_managment
          ;;
        esac

        sudo curl -Lo distress "$package"
        sudo chmod +x distress
        regenerate_distress_service_file
    }
    install > /dev/null 2>&1
    confirm_dialog "$(trans "DISTRESS успішно встановлено")"
}

configure_distress() {
    clear
    declare -A params;

    echo -e "${GRAY}$(trans "Залишіть пустим якщо бажаєте видалити пераметри")${NC}"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_distress_variable 'user-id')" user_id

    params[user-id]=$user_id

    read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_distress_variable 'use-my-ip')" use_my_ip
    if [[ -n "$use_my_ip" ]];then
      while [[ $use_my_ip -lt 0 || $use_my_ip -gt 100 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_distress_variable 'use-my-ip')" use_my_ip
      done
    fi

    params[use-my-ip]=$use_my_ip

    if [[ $use_my_ip > 0 ]]; then
      read -e -p "$(trans "Увімкнути UDP flood (1 | 0): ")" -i "$(get_distress_variable 'direct-udp-failover')" direct_udp_failover
      if [[ -n "$direct_udp_failover" ]];then
        while [[ "$direct_udp_failover" != "1" && "$direct_udp_failover" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Увімкнути UDP flood (1 | 0): ")" -i "$(get_distress_variable 'direct-udp-failover')" direct_udp_failover
        done
      fi

      params[direct-udp-failover]=$direct_udp_failover
    else
      params[direct-udp-failover]=" "
    fi

    params[direct-udp-failover]=$direct_udp_failover

    read -e -p "$(trans "Кількість підключень Tor (0-100): ")"  -i "$(get_distress_variable 'use-tor')" use_tor
    if [[ -n "$use_tor" ]];then
      while [[ $use_tor -lt 0 || $use_tor -gt 100 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Кількість підключень Tor (0-100): ")" -i "$(get_distress_variable 'use-tor')" use_tor
      done
    fi

    params[use-tor]=$use_tor

    read -e -p "$(trans "Кількість створювачів завдань (4096): ")"  -i "$(get_distress_variable 'concurrency')" concurrency
    if [[ -n "$concurrency" ]];then
      while [[ ! $concurrency =~ ^[0-9]+$ ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Кількість створювачів завдань (4096): ")" -i "$(get_distress_variable 'concurrency')" concurrency
      done
    fi

    params[concurrency]=$concurrency

    echo -ne "\n"
    echo -e "${ORANGE}$(trans "Назва інтерфейсу (ensXXX, ethX, тощо.)")${NC}"
    read -e -p "$(trans "Інтерфейс: ")"  -i "$(get_distress_variable 'interface')" interface
    if [[ -n "$interface" ]];then
      params[interface]=$interface
    else
      params[interface]=" "
    fi

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
    	  write_distress_variable "$i" "$value"
    done
    regenerate_distress_service_file
    if sudo sv status distress; then
        sudo rm -rf /tmp/distress >/dev/null 2>&1
        sudo sv restart distress >/dev/null 2>&1
    fi
    confirm_dialog "$(trans "Успішно виконано")"
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

  start="ExecStart=$SCRIPT_DIR/bin/distress"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[distress]" || "$key" = "[/distress]" ]]; then
      continue
    fi
    if [[ "$key" == 'direct-udp-failover' ]];then
      if [[ "$value" == 0 ]]; then
        continue
      elif [[ "$value" == 1 ]]; then
        value=" "
      fi
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" "${SCRIPT_DIR}"/services/distress.service

  sudo sv restart distress
}

distress_run() {
  sudo rm -rf /tmp/distress >/dev/null 2>&1
  mhddos_stop
  db1000n_stop

  sudo ln -s "$SCRIPT_DIR"/services/distress /etc/runit/runsvdir/default/distress >/dev/null 2>&1
}

distress_stop() {
  sudo rm -rf /etc/runit/runsvdir/default/distress
}

distress_get_status() {
  clear
  sudo sv status distress >/dev/null 2>&1

  if [[ $? > 0 ]]; then
    echo -e "${GRAY}$(trans "DISTRESS вимкнений")${NC}"
  else
    sudo sv status distress
  fi

  echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
  read -s -n 1 key
  initiate_distress
}

distress_installed() {
  if [[ ! -f "$TOOL_DIR/distress" ]]; then
      confirm_dialog "$(trans "DISTRESS не встановлений, будь ласка встановіть і спробуйте знову")"
      return 1
  else
      return 0
  fi
}

initiate_distress() {
   distress_installed
   if [[ $? == 1 ]]; then
    ddos_tool_managment
  else
    sudo sv status distress >/dev/null 2>&1
    if [[ $? == 0 ]]; then
      active_disactive="$(trans "Зупинка DISTRESS")"
    else
      active_disactive="$(trans "Запуск DISTRESS")"
    fi
    menu_items=("$active_disactive" "$(trans "Налаштування DISTRESS")" "$(trans "Статус DISTRESS")" "$(trans "Повернутись назад")")
    display_menu "DISTRESS" "${menu_items[@]}"

    case $? in
      1)
        sudo sv status distress >/dev/null 2>&1
        if [[ $? == 0 ]]; then
           distress_stop
           distress_get_status
        else
          distress_run
          while ! sudo sv status distress >/dev/null 2>&1; do
             confirm_dialog "$(trans "Wait for the service...")"
             sleep 1
          done
          distress_get_status
        fi
      ;;
      2)
        configure_distress
        initiate_distress
      ;;
      3)
        distress_get_status
      ;;
      4)
        ddos_tool_managment
      ;;
    esac
  fi
}
