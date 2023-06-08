#!/bin/bash

install_distress() {

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо Distress${NC}"

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
        echo "Неможливо визначити розрядность операційної системи";
        exit 1
      ;;
    esac

	  sudo curl -Lo distress "$package"
    sudo chmod +x distress
    regenerate_service_file
    sudo ln -sf  "$SCRIPT_DIR"/services/distress.service /etc/systemd/system/distress.service

    echo -e "${GREEN}Distress успішно встановлено${NC}"
}

configure_distress() {
    declare -A params;

    echo -e "${GREEN}Залиште пустим якщо хочите видалити пераметри${NC}"
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
    regenerate_service_file
    echo -e "${GREEN}Успішно виконано${NC}"
}


regenerate_service_file() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/distress"

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

  sed -i  "s/ExecStart=.*/$start/g" ${SCRIPT_DIR}/services/distress.service

  sudo systemctl daemon-reload
}

get_distress_variable() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_distress_variable() {
  sed -i "/\[distress\]/,/\[\/distress\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}

distress_run() {
  sudo systemctl stop mhddos.service
  sudo systemctl stop db1000n.service
  sudo systemctl start distress.service
}

distress_stop() {
  sudo systemctl stop distress.service
}

distress_get_status() {
  sudo systemctl status distress.service
}

initiate_distress() {
  if [[ ! -e "/etc/systemd/system/distress.service" ]]; then
    echo -e "${RED}Distress не встановлений, будь ласка встановіть і спробуйте знову${NC}"
  else
    menu=(
            "Запустити"
            "Зупинити"
            "Статус"
            )
      init "$menu"
      menu_result="$?"
      case "$menu_result" in
        0)
            distress_run
            distress_get_status
        ;;
        1)
            distress_stop
            distress_get_status
        ;;
        2)
            distress_get_status
        ;;
      esac
  fi
}