#!/bin/bash

install_mhddos() {
    adss_dialog "$(trans "Встановлюємо MHDDOS")"
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
            package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_x86
          ;;

          *)
            confirm_dialog "$(trans "Неможливо визначити розрядность операційної системи")"
            ddos_tool_managment
          ;;
        esac

        sudo curl -Lo mhddos_proxy_linux "$package"
        sudo chmod +x mhddos_proxy_linux
        regenerate_mhddos_service_file
        create_symlink
	  }
    install > /dev/null 2>&1
    confirm_dialog "$(trans "MHDDOS успішно встановлено")"
}

configure_mhddos() {
    clear
    declare -A params
    echo -e "${GRAY}$(trans "Залишіть пустим якщо бажаєте видалити пераметри")${NC}"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_mhddos_variable 'user-id')" user_id

    params[user-id]=$user_id
    read -e -p "$(trans "Мова (ua | en | es | de | pl | it): ")" -i "$(get_mhddos_variable 'lang')" lang

    languages=("ua" "en" "es" "de" "pl" "it")
    if [[ -n "$lang" ]];then
      while [[ ! "${languages[*]}" =~ "$lang" ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Мова (ua | en | es | de | pl | it): ")" -i "$(get_mhddos_variable 'lang')" lang
      done
    fi

    params[lang]=$lang

    read -e -p "$(trans "Кількість копій (auto | X): ")" -i "$(get_mhddos_variable 'copies')" copies
    if [[ -n "$copies" ]];then
      while  [[ ! $copies =~ ^[0-9]+$ && "$copies" != "auto" ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Кількість копій (auto | X): ")" -i "$(get_mhddos_variable 'copies')" copies
      done
    fi

    params[copies]=$copies
    read -e -p "VPN (false | true): " -i "$(get_mhddos_variable 'vpn')" vpn
    if [[ -n "$vpn" ]];then
      while [[ $vpn != false && $vpn != true ]]
      do
          echo "$(trans "Будь ласка введіть правильні значення")"
          read -e -p "VPN (false | true): " -i "$(get_mhddos_variable 'vpn')" vpn
      done
    	params[vpn]=$vpn
    fi

    if [[ $vpn == true ]]; then
      read -e -p "VPN percents (1-100): " -i "$(get_mhddos_variable 'vpn-percents')" vpn_percents
      if [[ -n "$vpn_percents" ]];then
        while [[ $vpn_percents -lt 1 || $vpn_percents -gt 100 ]]
        do
          echo "$(trans "Будь ласка введіть правильні значення")"
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
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "Threads: " -i "$(get_mhddos_variable 'threads')" threads
      done
    fi

    params[threads]=$threads

    read -e -p "$(trans "Проксі (шлях до файлу або веб-ресурсу): ")" -i "$(get_mhddos_variable 'proxies')" proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    params[proxies]=$proxies

    echo -ne "\n"
    echo -e "${ORANGE}$(trans "IP адреса кожного інтерфейсу через пробіл.")${NC}"
    read -e -p "$(trans "Інтерфейси: ")"  -i "$(get_mhddos_variable 'bind')" interface
    if [[ -n "$interface" ]];then
      params[bind]=$interface
    else
      params[bind]=" "
    fi

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
    	  write_mhddos_variable "$i" "$value"
    done
    regenerate_mhddos_service_file
    if systemctl is-active --quiet mhddos.service; then
        sudo rm -rf /tmp/_MEI* >/dev/null 2>&1
        sudo systemctl restart mhddos.service >/dev/null 2>&1
    fi
    confirm_dialog "$(trans "Успішно виконано")"
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
  vpn=false
  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[mhddos]" || "$key" = "[/mhddos]" ]]; then
      continue
    fi

    if [[ "$key" == 'vpn' ]];then
      vpn=$value
    	if [[ "$value" == false ]]; then
    		continue
    	elif [[ "$value" == true ]]; then
    		value=" "
    	fi
    fi
    if [[ "$key" == 'vpn-percents' && "$vpn" == false ]];then
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
  sudo rm -rf /tmp/_MEI* >/dev/null 2>&1
  sudo systemctl stop distress.service >/dev/null 2>&1
  sudo systemctl stop db1000n.service >/dev/null 2>&1
  sudo systemctl start mhddos.service >/dev/null 2>&1
}

mhddos_auto_enable() {
  sudo systemctl disable distress.service >/dev/null 2>&1
  sudo systemctl disable db1000n.service >/dev/null 2>&1
  sudo systemctl enable mhddos.service >/dev/null 2>&1
  create_symlink
  confirm_dialog "$(trans "MHDDOS додано до автозавантаження")"
}
mhddos_auto_disable() {
 sudo systemctl disable mhddos >/dev/null 2>&1
 create_symlink
 confirm_dialog "$(trans "MHDDOS видалено з автозавантаження")"
}
mhddos_enabled() {
  if sudo systemctl is-enabled mhddos >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

mhddos_stop() {
  create_symlink
  sudo systemctl stop mhddos.service >/dev/null 2>&1
}

mhddos_get_status() {
  clear
  sudo systemctl status mhddos.service
  echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
  read -s -n 1 key
  initiate_mhddos
}
mhddos_installed() {
  if [[ ! -f "$TOOL_DIR/mhddos_proxy_linux" ]]; then
      confirm_dialog "$(trans "MHDDOS не встановлений, будь ласка встановіть і спробуйте знову")"
      return 1
  else
      return 0
  fi
}
initiate_mhddos() {
  mhddos_installed
  if [[ $? == 1 ]]; then
    ddos_tool_managment
  else
      if sudo systemctl is-active mhddos >/dev/null 2>&1; then
        active_disactive="$(trans "Зупинка MHDDOS")"
      else
        active_disactive="$(trans "Запуск MHDDOS")"
      fi
      menu_items=("$active_disactive" "$(trans "Налаштування MHDDOS")" "$(trans "Статус MHDDOS")" "$(trans "Повернутись назад")")
      display_menu "MHDDOS" "${menu_items[@]}"

      case $? in
        1)
          if sudo systemctl is-active mhddos >/dev/null 2>&1; then
            mhddos_stop
            mhddos_get_status
          else
            mhddos_run
            mhddos_get_status
          fi
        ;;
        2)
          configure_mhddos
          initiate_mhddos
        ;;
        3)
          mhddos_get_status
        ;;
        4)
          ddos_tool_managment
        ;;
      esac
  fi
}