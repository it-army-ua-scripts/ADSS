#!/bin/bash

install_distress() {

    sudo mkdir -p $WORKING_DIR

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

configure() {
    declare -A params;
    declare langs;

    read -p "Юзер ІД: " user_id

    if [[ -z "$user_id" ]]; then
      user_id=" "
    fi

    params[user-id]=$user_id


    read -p "Відсоткове співвідношення використання власної IP адреси (0-100): " use_my_ip

      while (( $use_my_ip < 0 || $use_my_ip > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "Відсоткове співвідношення використання власної IP адреси (0-100): " use_my_ip
      done

    params[use-my-ip]=$use_my_ip


    read -p "Кількість підключень Tor (0-100): " use_tor

      while (( $use_tor < 0 || $use_tor > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "Кількість підключень Tor (0-100): " use_tor
      done

    params[use-tor]=$use_tor


    read -p "Кількість створювачів завдань (4096): " concurrency

    while ! [[ $concurrency =~ ^[0-9]+$ ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Кількість створювачів завдань (4096): " concurrency
    done

    params[concurrency]=$concurrency

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

get_variable() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_variable() {
  sed -i "/\[distress\]/,/\[\/distress\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}

run() {
  sudo systemctl stop mhddos.service
  sudo systemctl stop db1000n.service
  sudo systemctl start distress.service
}

stop() {
  sudo systemctl stop distress.service
}

get_status() {
  sudo systemctl status distress.service
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