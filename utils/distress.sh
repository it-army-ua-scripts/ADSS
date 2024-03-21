#!/bin/bash

install_distress() {
    adss_dialog "$(trans "Встановлюємо DISTRESS")"

    install() {
        cd $TOOL_DIR
        package=''
        case "$OSARCH" in
          aarch64*)
            package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_aarch64-unknown-linux-musl
          ;;

          armv6* | armv7* | armv8*)
            package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_arm-unknown-linux-musleabi
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

    echo -e "${ORANGE}$(trans "Залишіть пустим якщо бажаєте видалити пераметри")${NC}"
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stat_bot${NC}""\n"
    echo -ne "\n"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_distress_variable 'user-id')" user_id
    if [[ -n "$user_id" ]];then
      while [[ ! $user_id =~ ^[0-9]+$ ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Юзер ІД: ")" -i "$(get_distress_variable 'user-id')" user_id
      done
    fi

    params[user-id]=$user_id

    read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_distress_variable 'use-my-ip')" use_my_ip

    if [[ -n "$use_my_ip" ]]; then
      while [[ $use_my_ip -lt 0 || $use_my_ip -gt 100 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_distress_variable 'use-my-ip')" use_my_ip
      done
    fi

    params[use-my-ip]=$use_my_ip

    if [[ $use_my_ip -gt 0 ]]; then

      read -e -p "$(trans "Увімкнути ICMP флуд (1 | 0): ")" -i "$(get_distress_variable 'enable-icmp-flood')" enable_icmp_flood
      if [[ -n "$enable_icmp_flood" ]];then
        while [[ "$enable_icmp_flood" != "1" && "$enable_icmp_flood" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Увімкнути ICMP флуд (1 | 0): ")" -i "$(get_distress_variable 'enable-icmp-flood')" enable_icmp_flood
        done
      fi

      params[enable-icmp-flood]=$enable_icmp_flood

      read -e -p "$(trans "Увімкнути packet флуд (1 | 0): ")" -i "$(get_distress_variable 'enable-packet-flood')" enable_packet_flood
      if [[ -n "$enable_packet_flood" ]];then
        while [[ "$enable_packet_flood" != "1" && "$enable_packet_flood" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Увімкнути packet флуд (1 | 0): ")" -i "$(get_distress_variable 'enable-packet-flood')" enable_packet_flood
        done
      fi
      params[enable-packet-flood]=$enable_packet_flood

      read -e -p "$(trans "Вимкнути UDP флуд (1 | 0): ")" -i "$(get_distress_variable 'disable-udp-flood')" disable_udp_flood
      if [[ -n "$disable_udp_flood" ]];then
        while [[ "$disable_udp_flood" != "1" && "$disable_udp_flood" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Вимкнути UDP flood (1 | 0): ")" -i "$(get_distress_variable 'disable-udp-flood')" disable_udp_flood
        done
      fi
      params[disable-udp-flood]=$disable_udp_flood

      if [[ "$disable_udp_flood" -eq 0 ]];then
        packageSize="$(get_distress_variable 'udp-packet-size')"
        if [[ -z $packageSize || $packageSize == " "  ]];then
          packageSize=1420
        fi

        read -e -p "$(trans "Розмір UDP пакунку (576-1420): ")" -i "$packageSize" udp_packet_size
        if [[ -n "$udp_packet_size" ]];then
          while [[ "$udp_packet_size" -lt 576 || "$udp_packet_size" -gt 1420 ]]
          do
            echo "$(trans "Будь ласка введіть правильні значення")"
            read -e -p "$(trans "Розмір UDP пакунку (576-1420): ")" -i "$packageSize" udp_packet_size
          done
        fi

        params[udp-packet-size]=$udp_packet_size

        connCount="$(get_distress_variable 'direct-udp-mixed-flood-packets-per-conn')"
        if [[ -z $connCount || $connCount == " " ]];then
          connCount=30
        fi

        read -e -p "$(trans "Кількість пакетів (1-100): ")" -i $connCount direct_udp_mixed_flood_packets_per_conn
        if [[ -n "$direct_udp_mixed_flood_packets_per_conn" ]];then
          while [[ $direct_udp_mixed_flood_packets_per_conn -lt 0 || $direct_udp_mixed_flood_packets_per_conn -gt 100 ]]
          do
            echo "$(trans "Будь ласка введіть правильні значення")"
            read -e -p "$(trans "Кількість пакетів (1-100): ")" -i $connCount direct_udp_mixed_flood_packets_per_conn
          done
        fi

        params[direct-udp-mixed-flood-packets-per-conn]=$direct_udp_mixed_flood_packets_per_conn

      fi
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

    read -e -p "$(trans "Кількість створювачів завдань (50-100000): ")"  -i "$(get_distress_variable 'concurrency')" concurrency
    if [[ -n "$concurrency" ]];then
      while [[ $concurrency -lt 50 || $concurrency -gt 100000 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Кількість створювачів завдань (50-100000): ")" -i "$(get_distress_variable 'concurrency')" concurrency
      done
    fi

    params[concurrency]=$concurrency

    read -e -p "$(trans "Проксі (шлях до файлу): ")" -i "$(get_distress_variable 'proxies-path')" proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    params[proxies-path]=$proxies

    echo -ne "\n"
    echo -e "${ORANGE}$(trans "Мережеві інтерфейси (через кому: eth0,eth1,тощо.)")${NC}"
    read -e -p "$(trans "Інтерфейси: ")"  -i "$(get_distress_variable 'interface')" interface
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

  start="distress"

  declare -A data
  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[distress]" || "$key" = "[/distress]" ]]; then
      continue
    fi
    if [[ "$key" == 'disable-udp-flood' ]]; then
      if [[ "$(get_distress_variable 'use-my-ip')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'disable-udp-flood')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'disable-udp-flood')" == 1 ]]; then
        value=" "
        #end result will be just "--disable-udp-flood "
      fi
    fi

    if [[ "$key" == 'udp-packet-size' ]]; then
      if [[ "$(get_distress_variable 'use-my-ip')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'disable-udp-flood')" == 1 ]]; then
        continue
      fi
    fi

    if [[ "$key" == 'direct-udp-mixed-flood-packets-per-conn' ]]; then
      if [[ "$(get_distress_variable 'use-my-ip')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'disable-udp-flood')" == 1 ]]; then
        continue
      fi
    fi

    if [[ "$key" == 'enable-packet-flood' ]]; then
      if [[ "$(get_distress_variable 'use-my-ip')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'enable-packet-flood')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'enable-packet-flood')" == 1 ]]; then
        value=" "
        #end result will be just "--enable-packet-flood "
      fi
    fi

    if [[ "$key" == 'enable-icmp-flood' ]]; then
      if [[ "$(get_distress_variable 'use-my-ip')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'enable-icmp-flood')" == 0 ]]; then
        continue
      fi
      if [[ "$(get_distress_variable 'enable-icmp-flood')" == 1 ]]; then
        value=" "
        #end result will be just "--enable-icmp-flood "
      fi
    fi

    if [[ "$key" == 'use-my-ip' && "$(get_distress_variable 'use-my-ip')" == 0 ]];then
      continue
    fi
    if [[ "$key" == 'use-tor' && "$(get_distress_variable 'use-tor')" == 0 ]];then
      continue
    fi

    if [[ "$value" ]]; then
      data["$key"]="$value"
    fi
  done <<< "$lines"
  for key in "${!data[@]}"; do
    start="$start --$key ${data[$key]}"
  done
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/distress.*/$start/g" "${SCRIPT_DIR}"/services/distress/run

  sudo sv restart distress >/dev/null 2>&1
}

distress_run() {
  sudo rm -rf /tmp/distress >/dev/null 2>&1
  mhddos_stop
  db1000n_stop

  sudo ln -s "$SCRIPT_DIR"/services/distress /etc/runit/runsvdir/default/distress >/dev/null 2>&1
  sudo sv up distress/log >/dev/null 2>&1
}

distress_stop() {
  sudo sv stop "$SCRIPT_DIR"/services/distress/log >/dev/null 2>&1
  sudo rm -rf /etc/runit/runsvdir/default/distress >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/distress/log/supervise >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/distress/supervise >/dev/null 2>&1
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
    res=$(display_menu "DISTRESS" "${menu_items[@]}")

      case "$res" in
        "$(trans "Зупинка DISTRESS")")
           distress_stop
           distress_get_status
        ;;
        "$(trans "Запуск DISTRESS")")
          distress_run
          while ! sudo sv status distress >/dev/null 2>&1; do
             confirm_dialog "$(trans "Чекаємо на сервіс...")"
             sleep 1
          done
          distress_get_status
        ;;
        "$(trans "Налаштування DISTRESS")")
          configure_distress
          initiate_distress
        ;;
        "$(trans "Статус DISTRESS")")
          distress_get_status
        ;;
        "$(trans "Повернутись назад")")
          ddos_tool_managment
        ;;
      esac
  fi
}
