#!/bin/bash

install_db1000n() {
    adss_dialog "Встановлюємо DB1000N"
    install() {
      cd $TOOL_DIR
      OSARCH=$(uname -m)

      case "$OSARCH" in
        aarch64*)
          sudo curl -Lo db1000n_linux_arm64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_arm64.tar.gz
          sudo tar -xf db1000n_linux_arm64.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_arm64.tar.gz
        ;;

        x86_64*)
          sudo curl -Lo db1000n_linux_amd64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_amd64.tar.gz
          sudo tar -xf db1000n_linux_amd64.tar.gz
          sudo chmod +x db1000n
          sudo rm db1000n_linux_amd64.tar.gz
        ;;

        i386* | i686*)
          sudo curl -Lo db1000n_linux_386.zip  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_386.zip
          sudo unzip db1000n_linux_386.zip
          sudo chmod +x db1000n
          sudo rm db1000n_linux_386.zip
        ;;

        *)
            confirm_dialog "Неможливо визначити розрядность операційної системи"
            ddos_tool_managment
        ;;
      esac
      regenerate_db1000n_service_file
      sudo ln -sf  "$SCRIPT_DIR"/services/db1000n.service /etc/systemd/system/db1000n.service
    }
    install > /dev/null 2>&1
    confirm_dialog "DB1000N успішно встановлено"
}

configure_db1000n() {
    clear
    declare -A params;
    echo -e "${GRAY}Залиште пустим якщо хочите видалити пераметри${NC}"

    read -e -p "Юзер ІД: " -i "$(get_db1000n_variable 'user-id')" user_id

    params[user-id]=$user_id

    read -e -p "Автооновлення (1 | 0): " -i "$(get_db1000n_variable 'enable-self-update')" enable_self_update

    if [[ -n "$enable_self_update" ]];then
        while [[ "$enable_self_update" != "1" && "$enable_self_update" != "0" ]]
        do
          echo "Будь ласка введіть правильні значення"
          read -e -p "Автооновлення (1 | 0): " -i "$(get_db1000n_variable 'enable-self-update')" enable_self_update
        done
    fi

    params[enable-self-update]=$enable_self_update

    read -e -p "Проксі (шлях до файлу або веб-ресурсу): " -i "$(get_db1000n_variable 'proxy')" proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    params[proxy]=$proxies

    read -e -p "Масштабування (1 | X): "  -i "$(get_db1000n_variable 'scale')" scale
    if [[ -n "$scale" ]];then
      while [[ ! $scale =~ ^[0-9]+$ && "$scale" != "1" ]]
      do
        echo "Будь ласка введіть правильні значення"
       read -e -p "Масштабування (1 | X): "  -i "$(get_db1000n_variable 'scale')" scale
      done
    fi

    params[scale]=$scale

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
        write_db1000n_variable "$i" "$value"
    done
    regenerate_db1000n_service_file
    confirm_dialog "Успішно виконано"
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

  start="ExecStart=/opt/itarmy/bin/db1000n"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[db1000n]" || "$key" = "[/db1000n]" ]]; then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" "${SCRIPT_DIR}"/services/db1000n.service

  sudo systemctl daemon-reload
}

db1000n_run() {
  sudo systemctl stop mhddos.service
  sudo systemctl stop distress.service
  sudo systemctl start db1000n.service
}

db1000n_stop() {
  sudo systemctl stop db1000n.service
}

db1000n_get_status() {
  clear
  sudo systemctl status db1000n.service
  echo -e "${GRAY}Нажміть будь яку клавішу щоб продовжити${NC}"
  read -s -n 1 key
  initiate_db1000n
}

initiate_db1000n() {
  if [[ ! -e "/etc/systemd/system/db1000n.service" ]]; then
    confirm_dialog "DB1000N не встановлений, будь ласка встановіть і спробуйте знову"
    ddos_tool_managment
  else
        menu_items=("Запуск DB1000N" "Зупинка DB1000N")

        if sudo systemctl is-enabled db1000n >/dev/null 2>&1; then
          enabled_disabled="Вимкнути автозавантаження"
        else
          enabled_disabled="Увімкнути автозавантаження"
        fi
        menu_items+=("$enabled_disabled" "Налаштування DB1000N" "Статус DB1000N" "Повернутись назад")
        display_menu "DB1000N" "${menu_items[@]}"

        case $? in
          1)
            db1000n_run
            db1000n_get_status
          ;;
          2)
            db1000n_stop
            db1000n_get_status
          ;;
          3)
            if sudo systemctl is-enabled db1000n >/dev/null 2>&1; then
              sudo systemctl disable db1000n >/dev/null
              confirm_dialog "DB1000N видалено з автозавантаження"
            else
              sudo systemctl enable db1000n >/dev/null
              confirm_dialog "DB1000N додано в автозавантаження"
            fi
            initiate_db1000n
          ;;
          4)
            configure_db1000n
            initiate_db1000n
          ;;
          5)
            db1000n_get_status
          ;;
          6)
            ddos_tool_managment
          ;;
        esac
  fi
}