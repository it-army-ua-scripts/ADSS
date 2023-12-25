#!/bin/bash

install_db1000n() {
    adss_dialog "$(trans "Встановлюємо DB1000N")"
    install() {
      cd $TOOL_DIR

      case "$OSARCH" in
        aarch64*)
          sudo curl -Lo db1000n_linux_arm64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_arm64.tar.gz
          sudo tar -xf db1000n_linux_arm64.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_arm64.tar.gz
        ;;

        armv6* | armv7* | armv8*)
          sudo curl -Lo db1000n_linux_armv6.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_armv6.tar.gz
          sudo tar -xf db1000n_linux_armv6.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_armv6.tar.gz
        ;;

        x86_64*)
          sudo curl -Lo db1000n_linux_amd64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_amd64.tar.gz
          sudo tar -xf db1000n_linux_amd64.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_amd64.tar.gz
        ;;

        i386* | i686*)
          sudo curl -Lo db1000n_linux_386.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_386.tar.gz
          sudo tar -xf db1000n_linux_386.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_386.tar.gz
        ;;

        *)
            confirm_dialog "$(trans "Неможливо визначити розрядность операційної системи")"
            ddos_tool_managment
        ;;
      esac
      regenerate_db1000n_service_file
    }
    install > /dev/null 2>&1
    confirm_dialog "$(trans "DB1000N успішно встановлено")"
}

configure_db1000n() {
    clear
    declare -A params;

    echo -e "${ORANGE}$(trans "Залишіть пустим якщо бажаєте видалити пераметри")${NC}"
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stat_bot${NC}""\n"
    echo -ne "\n"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_db1000n_variable 'user-id')" user_id
    if [[ -n "$user_id" ]];then
      while [[ ! $user_id =~ ^[0-9]+$ ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Юзер ІД: ")" -i "$(get_db1000n_variable 'user-id')" user_id
      done
    fi

    params[user-id]=$user_id

    read -e -p "$(trans "Автооновлення (1 | 0): ")" -i "$(get_db1000n_variable 'enable-self-update')" enable_self_update

    if [[ -n "$enable_self_update" ]];then
        while [[ "$enable_self_update" != "1" && "$enable_self_update" != "0" ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "$(trans "Автооновлення (1 | 0): ")" -i "$(get_db1000n_variable 'enable-self-update')" enable_self_update
        done
    fi

    params[enable-self-update]=$enable_self_update

    read -e -p "$(trans "Масштабування (1 | X): ")"  -i "$(get_db1000n_variable 'scale')" scale
    if [[ -n "$scale" ]];then
      while [[ ! $scale =~ ^[0-9]+$ && ! $scale =~ ^[+-]?[0-9]+([.][0-9]+)?$ ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
       read -e -p "$(trans "Масштабування (1 | X): ")"  -i "$(get_db1000n_variable 'scale')" scale
      done
    fi
    params[scale]=$scale

    echo -ne "\n"
    echo -e "$(trans "Список проксі у форматі") ${ORANGE}protocol://ip:port${NC} $(trans "або") ${ORANGE}ip:port${NC}"
    read -e -p "$(trans "Проксі (шлях до файлу або веб-ресурсу): ")" -i "$(get_db1000n_variable 'proxylist')" proxylist
    proxylist=$(echo $proxylist  | sed 's/\//\\\//g')
    if [[ -n "$proxylist" ]];then
      params[proxylist]=$proxylist
    else
      params[proxylist]=" "
    fi

    if [[ -n "$proxylist" ]];then
        echo -ne "\n"
        echo -e "$(trans "Укажіть протокол, якщо формат") ${ORANGE}ip:port${NC}"
        read -e -p "$(trans "Протокол проксі (socks5, socks4): ")" -i "$(get_db1000n_variable 'default-proxy-proto')" default_proxy_proto
        if [[ -n "$default_proxy_proto" ]];then
          while [[
          "$default_proxy_proto" != "socks5"
          && "$default_proxy_proto" != "socks5h"
          && "$default_proxy_proto" != "socks4"
          && "$default_proxy_proto" != "socks4a"
          ]]
          do
            echo "$(trans "Будь ласка введіть правильні значення")"
            read -e -p "$(trans "Протокол проксі (socks5, socks4, http): ")" -i "$(get_db1000n_variable 'default-proxy-proto')" default_proxy_proto
          done
          params[default-proxy-proto]=$default_proxy_proto
        fi
    else
      params[default-proxy-proto]=" "
    fi

    echo -ne "\n"
    echo -e "${ORANGE}$(trans "Назва інтерфейсу (ensXXX, ethX, тощо.)")${NC}"
    read -e -p "$(trans "Інтерфейс: ")"  -i "$(get_db1000n_variable 'interface')" interface
    if [[ -n "$interface" ]];then
      params[interface]=$interface
    else
      params[interface]=" "
    fi

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
        write_db1000n_variable "$i" "$value"
    done
    regenerate_db1000n_service_file
    if sudo sv status db1000n; then
        sudo sv restart db1000n >/dev/null 2>&1
    fi
    confirm_dialog "$(trans "Успішно виконано")"
}

get_db1000n_variable() {
  lines=$(sed -n "/\[db1000n\]/,/\[\/db1000n\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_db1000n_variable() {
  sed -i "/\[db1000n\]/,/\[\/db1000n\]/s/$1=.*/$1=$2/g" "${SCRIPT_DIR}"/services/EnvironmentFile
}

regenerate_db1000n_service_file() {
  lines=$(sed -n "/\[db1000n\]/,/\[\/db1000n\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)

  start="db1000n"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[db1000n]" || "$key" = "[/db1000n]" ]]; then
      continue
    fi
    if [[ "$key" == 'enable-self-update' ]];then
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

  sed -i  "s/db1000n.*/$start/g" "${SCRIPT_DIR}"/services/db1000n/run

  sudo sv restart db1000n
}

db1000n_run() {
  mhddos_stop
  distress_stop
  sudo ln -s "$SCRIPT_DIR"/services/db1000n /etc/runit/runsvdir/default/db1000n >/dev/null 2>&1
}

db1000n_stop() {
  sudo sv stop "$SCRIPT_DIR"/services/db1000n/log
  sudo rm -rf /etc/runit/runsvdir/default/db1000n >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/db1000n/log/supervise >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/db1000n/supervise >/dev/null 2>&1
}

db1000n_get_status() {
  clear
  sudo sv status db1000n >/dev/null 2>&1

  if [[ $? > 0 ]]; then
    echo -e "${GRAY}$(trans "DB1000N вимкнений")${NC}"
  else
    sudo sv status db1000n
  fi

  echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
  read -s -n 1 key
  initiate_db1000n
}

db1000n_installed() {
  if [[ ! -f "$TOOL_DIR/db1000n" ]]; then
      confirm_dialog "$(trans "DB1000N не встановлений, будь ласка встановіть і спробуйте знову")"
      return 1
  else
      return 0
  fi
}

initiate_db1000n() {
  db1000n_installed
  if [[ $? == 1 ]]; then
    ddos_tool_managment
  else
    sudo sv status db1000n >/dev/null 2>&1
    if [[ $? == 0 ]]; then
      active_disactive="$(trans "Зупинка DB1000N")"
    else
      active_disactive="$(trans "Запуск DB1000N")"
    fi
    menu_items=("$active_disactive" "$(trans "Налаштування DB1000N")" "$(trans "Статус DB1000N")" "$(trans "Повернутись назад")")
    res=$(display_menu "DB1000N" "${menu_items[@]}")

      case "$res" in
        "$(trans "Зупинка DB1000N")")
          db1000n_stop
          db1000n_get_status
        ;;
        "$(trans "Запуск DB1000N")")
          db1000n_run
          while ! sudo sv status db1000n >/dev/null 2>&1; do
             confirm_dialog "$(trans "Чекаємо на сервіс...")"
             sleep 1
          done
          db1000n_get_status
        ;;
        "$(trans "Налаштування DB1000N")")
          configure_db1000n
          initiate_db1000n
        ;;
        "$(trans "Статус DB1000N")")
          db1000n_get_status
        ;;
        "$(trans "Повернутись назад")")
          ddos_tool_managment
        ;;
      esac
  fi
}
