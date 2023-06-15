#!/bin/bash

install_db1000n() {
    cd $SCRIPT_DIR
    echo -e "${GREEN}Встановлюємо DB1000N${NC}"

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
          echo "Неможливо визначити розрядность операційної системи";
          exit 1
      ;;
    esac
    sudo ln -sf  "$SCRIPT_DIR"/services/db1000n.service /etc/systemd/system/db1000n.service
    echo -e "${GREEN}DB1000N успішно встановлено${NC}"
}

configure_db1000n() {
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

    read -e -p "Масштабування (1 | 0): "  -i "$(get_db1000n_variable 'scale')" scale
    if [[ -n "$scale" ]];then
      while [[ "$scale" != "1" && "$scale" != "0" ]]
      do
        echo "Будь ласка введіть правильні значення"
       read -e -p "Масштабування (1 | 0): "  -i "$(get_db1000n_variable 'scale')" scale
      done
    fi

    params[scale]=$scale

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
        write_db1000n_variable "$i" "$value"
    done
    regenerate_service_file
    echo -e "${GREEN}Успішно виконано${NC}"
}

regenerate_service_file() {
  lines=$(sed -n "/\[db1000n\]/,/\[\/db1000n\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/db1000n"

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

  sed -i  "s/ExecStart=.*/$start/g" ${SCRIPT_DIR}/services/db1000n.service

  sudo systemctl daemon-reload
}

get_db1000n_variable() {
  lines=$(sed -n "/\[db1000n\]/,/\[\/db1000n\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_db1000n_variable() {
  sed -i "/\[db1000n\]/,/\[\/db1000n\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
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
  sudo systemctl status db1000n.service
}

initiate_db1000n() {
  if [[ ! -e "/etc/systemd/system/db1000n.service" ]]; then
    echo -e "${RED}db1000n не встановлений, будь ласка встановіть і спробуйте знову${NC}"
  else
    menu=(
            "Запуск DB1000N"
            "Зупинка DB1000N"
            "Налаштування DB1000N"
            "Статус DB1000N"
            "Повернутись назад"
            )
      init "$menu"
      menu_result="$?"
      case "$menu_result" in
        0)
            db1000n_run
            db1000n_get_status
        ;;
        1)
            db1000n_stop
            db1000n_get_status
        ;;
        2)
            configure_db1000n
        ;;
        3)
            db1000n_get_status
        ;;
        4)
            step4
        ;;
      esac
  fi
}