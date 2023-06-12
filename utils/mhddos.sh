#!/bin/bash

install_mhddos() {

    cd $SCRIPT_DIR
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
    sudo ln -sf  "$SCRIPT_DIR"/services/mhddos.service /etc/systemd/system/mhddos.service
    echo -e "${GREEN}MHDDOS успішно встановлено${NC}"
}

configure_mhddos() {

    declare -A params
    echo -e "${GRAY}Залиште пустим якщо хочите видалити пераметри${NC}"
    read -e -p "Юзер ІД: " -i "$(get_mhddos_variable 'user-id')" user_id

    params[user-id]=$user_id
    read -e -p "Мова (ua | en | es | de | pl | it): " -i "$(get_mhddos_variable 'lang')" lang

    languages=("ua" "en" "es" "de" "pl" "it")
    if [[ -n "$lang" ]];then
      while [[ ! "${languages[*]}" =~ "$lang" ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Мова (ua | en | es | de | pl | it): " -i "$(get_mhddos_variable 'lang')" lang
      done
    fi

    params[lang]=$lang

    read -e -p "Кількість копій (auto | X): " -i "$(get_mhddos_variable 'copies')" copies
    if [[ -n "$copies" ]];then
      while  [[ ! $copies =~ ^[0-9]+$ && "$copies" != "auto" ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Кількість копій (auto | X): " -i "$(get_mhddos_variable 'copies')" copies
      done
    fi

    params[copies]=$copies
    read -e -p "VPN (false | true): " -i "$(get_mhddos_variable 'vpn')" vpn
    if [[ -n "$vpn" ]];then
      while [[ $vpn != false && $vpn != true ]]
        do
          echo "Будь ласка введіть правильні значення"
          read -e -p "VPN (false | true): " -i "$(get_mhddos_variable 'vpn')" vpn
        done
    fi

    params[vpn]=$vpn

    if [[ $vpn == true ]]; then
      read -e -p "VPN percents (1-100): " -i "$(get_mhddos_variable 'vpn-percents')" vpn_percents
      if [[ -n "$vpn_percents" ]];then
        while [[ $vpn_percents -lt 1 || $vpn_percents -gt 100 ]]
        do
          echo "Будь ласка введіть правильні значення"
          read -e -p "VPN percents (1-100): " -i "$(get_mhddos_variable 'vpn-percents')" vpn_percents
        done
      fi

      params[vpn-percents]=$vpn_percents
    else
      params[vpn-percents]=" "
    fi


    read -e -p "Threads: " -i "$(get_mhddos_variable 'threads')" threads
    if [[ -n "$threads" ]];then
      while [[ ! $threads =~ ^[0-9]+$ ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -e -p "Threads: " -i "$(get_mhddos_variable 'threads')" threads
      done
    fi

    params[threads]=$threads

    read -e -p "Проксі (шлях до файлу або веб-ресурсу): " -i "$(get_mhddos_variable 'proxies')" proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    params[proxies]=$proxies

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
    	  write_mhddos_variable "$i" "$value"
    done
    regenerate_service_file
    echo -e "${GREEN}Успішно виконано${NC}"
}

get_mhddos_variable() {
  local lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)
  local variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_mhddos_variable() {
  sed -i  "/\[mhddos\]/,/\[\/mhddos\]/s/$1=.*/$1=$2/g" "${SCRIPT_DIR}"/services/EnvironmentFile
}

regenerate_service_file() {
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)

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

  sed -i  "s/ExecStart=.*/$start/g" "${SCRIPT_DIR}"/services/mhddos.service

  sudo systemctl daemon-reload
}

mhddos_run() {
  sudo systemctl stop distress.service
  sudo systemctl stop db1000n.service
  sudo systemctl start mhddos.service
}

mhddos_auto_enable() {
  sudo systemctl enable mhddos.service
}

mhddos_stop() {
  sudo systemctl stop mhddos.service
}

mhddos_get_status() {
  sudo systemctl status mhddos.service
}
initiate_mhddos() {
  if [[ ! -e "/etc/systemd/system/mhddos.service" ]]; then
    echo -e "${RED}MHDDOS не встановлений, будь ласка встановіть і спробуйте знову${NC}"
  else
    menu=(
            "Запуск MHDDOS"
            "Зупинка MHDDOS"
            "Налаштування MHDDOS"
            "Статус MHDDOS"
            "Повернутись назад"
            )
      init "$menu"
      menu_result="$?"
      case "$menu_result" in
        0)
            mhddos_run
            mhddos_get_status
        ;;
        1)
            mhddos_stop
            mhddos_get_status
        ;;
        2)
            configure_mhddos
        ;;
        3)
            mhddos_get_status
        ;;
        4)
            step4
        ;;
      esac
  fi

}