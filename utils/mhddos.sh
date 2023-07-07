#!/bin/bash

install_mhddos() {
    adss_dialog "Встановлюємо MHDDOS"
	  install() {
        cd $TOOL_DIR
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
            confirm_dialog "Відсутня реалізація MHDDOS для x86 архітектури, що відповідає 32-бітній розрядності"
            ddos_tool_managment
          ;;

          *)
            confirm_dialog "Неможливо визначити розрядность операційної системи"
            ddos_tool_managment
          ;;
        esac

        sudo curl -Lo mhddos_proxy_linux "$package"
        sudo chmod +x mhddos_proxy_linux
        regenerate_mhddos_service_file
        sudo ln -sf  "$SCRIPT_DIR"/services/mhddos.service /etc/systemd/system/mhddos.service
	  }
    install > /dev/null 2>&1
    confirm_dialog "MHDDOS успішно встановлено"
}

configure_mhddos() {
    clear
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
      if [[ $vpn == true ]]; then
        params[vpn]=" "
      fi
    fi

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
    regenerate_mhddos_service_file
    confirm_dialog "Успішно виконано"
}

get_mhddos_variable() {
  local lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)
  local variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_mhddos_variable() {
  sed -i  "/\[mhddos\]/,/\[\/mhddos\]/s/$1=.*/$1=$2/g" "${SCRIPT_DIR}"/services/EnvironmentFile
}

regenerate_mhddos_service_file() {
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/bin/mhddos_proxy_linux"

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
  sudo systemctl stop distress.service >/dev/null 2>&1
  sudo systemctl stop db1000n.service >/dev/null 2>&1
  sudo systemctl start mhddos.service >/dev/null 2>&1
}

mhddos_auto_enable() {
  sudo systemctl disable distress.service >/dev/null 2>&1
  sudo systemctl disable db1000n.service >/dev/null 2>&1
  sudo systemctl enable mhddos.service >/dev/null 2>&1
}

mhddos_stop() {
  sudo systemctl stop mhddos.service >/dev/null 2>&1
}

mhddos_get_status() {
  clear
  sudo systemctl status mhddos.service
  echo -e "${GRAY}Нажміть будь яку клавішу щоб продовжити${NC}"
  read -s -n 1 key
  initiate_mhddos
}
initiate_mhddos() {
  if [[ ! $(systemctl status mhddos.service >/dev/null 2>&1) ]]; then
    confirm_dialog "MHDDOS не встановлений, будь ласка встановіть і спробуйте знову"
    ddos_tool_managment
  else
      menu_items=("Запуск MHDDOS" "Зупинка MHDDOS")
      if sudo systemctl is-enabled mhddos >/dev/null 2>&1; then
        enabled_disabled="Вимкнути автозавантаження"
      else
        enabled_disabled="Увімкнути автозавантаження"
      fi
      menu_items+=("$enabled_disabled" "Налаштування MHDDOS" "Статус MHDDOS" "Повернутись назад")
      display_menu "MHDDOS" "${menu_items[@]}"

      case $? in
        1)
          mhddos_run
          mhddos_get_status
        ;;
        2)
          mhddos_stop
          mhddos_get_status
        ;;
        3)
          if sudo systemctl is-enabled mhddos >/dev/null 2>&1; then
            sudo systemctl disable mhddos >/dev/null
            confirm_dialog "MHDDOS видалено з  автозавантаження"
          else
            mhddos_auto_enable
            confirm_dialog "MHDDOS додано в автозавантаження"
          fi
          initiate_mhddos
        ;;
        4)
          configure_mhddos
          initiate_mhddos
        ;;
        5)
          mhddos_get_status
        ;;
        6)
          ddos_tool_managment
        ;;
      esac
  fi
}