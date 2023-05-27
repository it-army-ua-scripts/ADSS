#!/bin/bash

install_db1000n() {

    sudo mkdir -p $WORKING_DIR

    cd $WORKING_DIR
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

configure() {
    declare -A params;
    declare langs;

    read -p "Юзер ІД: " user_id

    if [[ -z "$user_id" ]]; then
      user_id=" "
    fi

    params[user-id]=$user_id

    read -p "Автооновлення (1 | 0): " enable_self_update

    while [[ "$enable_self_update" != "1" && "$enable_self_update" != "0" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Автооновлення (1 | 0): " enable_self_update
    done

    params[enable-self-update]=$enable_self_update

    read -p "Проксі (шлях до файлу або веб-ресурсу): " proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    if [[ -z "$proxies" ]]; then
      proxies=" "
    fi

    params[proxies]=$proxies

    read -p "Масштабування (1 | 0): " scale

   while [[ "$scale" != "1" && "$scale" != "0" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Масштабування (1 | 0): " scale
    done

    params[scale]=$scale

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"

    	  if [[ -n "$value" ]]; then
    	    write_variable "$i" "$value"
    	  fi
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

get_variable() {
  lines=$(sed -n "/\[db1000n\]/,/\[\/db1000n\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_variable() {
  sed -i "/\[db1000n\]/,/\[\/db1000n\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}

run() {
  sudo systemctl stop mhddos.service
  sudo systemctl stop distress.service
  sudo systemctl start db1000n.service
}

stop() {
  sudo systemctl stop db1000n.service
}

get_status() {
  sudo systemctl status db1000n.service
}

initiate() {
   menu=(
        "Запустити"
        "Зупинити"
        "Статус"
        )
  init "$menu"
  menu_result="$?"
  case "$menu_result" in
    0)
        run
        get_status
    ;;
    1)
        stop
        get_status
    ;;
    2)
        get_status
    ;;
  esac
}