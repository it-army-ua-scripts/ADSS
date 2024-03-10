#!/bin/bash

install_mhddos() {
    adss_dialog "$(trans "Встановлюємо MHDDOS")"
	  install() {
        cd $TOOL_DIR
        package=''
        case "$OSARCH" in
          aarch64*)
            package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_arm64
          ;;

          armv6* | armv7* | armv8*)
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
	  }
    install > /dev/null 2>&1
    if [[ $package == '' ]];then
      confirm_dialog "MHDDOS_PROXY does not support ARM32"
    else
      confirm_dialog "$(trans "MHDDOS успішно встановлено")"
    fi
}

configure_mhddos() {
    clear
    declare -A params

    echo -e "${ORANGE}$(trans "Залишіть пустим якщо бажаєте видалити пераметри")${NC}"
    echo -ne "\n"
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stat_bot${NC}""\n"
    echo -ne "\n"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_mhddos_variable 'user-id')" user_id
    if [[ -n "$user_id" ]];then
      while [[ ! $user_id =~ ^[0-9]+$ ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Юзер ІД: ")" -i "$(get_mhddos_variable 'user-id')" user_id
      done
    fi

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
	
    read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_mhddos_variable 'use-my-ip')" use_my_ip
    if [[ -n "$use_my_ip" ]];then
      while [[ $use_my_ip -lt 0 || $use_my_ip -gt 100 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Відсоткове співвідношення використання власної IP адреси (0-100): ")" -i "$(get_mhddos_variable 'use-my-ip')" use_my_ip
      done
    fi

    params[use-my-ip]=$use_my_ip

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
    read -e -p "$(trans "Інтерфейси: ")"  -i "$(get_mhddos_variable 'ifaces')" interface
    if [[ -n "$interface" ]];then
      params[ifaces]=$interface
    else
      params[ifaces]=" "
    fi

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"
    	  write_mhddos_variable "$i" "$value"
    done
    regenerate_mhddos_service_file
    if sudo sv status mhddos; then
        sudo rm -rf /tmp/_MEI* >/dev/null 2>&1
        sudo sudo sv restart mhddos >/dev/null 2>&1
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

  start="mhddos_proxy_linux"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[mhddos]" || "$key" = "[/mhddos]" ]]; then
      continue
    fi

    if [[ "$key" == 'use-my-ip' && "$(get_mhddos_variable 'use-my-ip')" == 0 ]];then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/mhddos_proxy_linux.*/$start/g" "${SCRIPT_DIR}"/services/mhddos/run

  sudo sv restart mhddos >/dev/null 2>&1
}

mhddos_run() {
  sudo rm -rf /tmp/_MEI* >/dev/null 2>&1
  distress_stop
  db1000n_stop

  sudo ln -s "$SCRIPT_DIR"/services/mhddos /etc/runit/runsvdir/default/mhddos >/dev/null 2>&1
  sudo sv up mhddos/log >/dev/null 2>&1
}

mhddos_stop() {
  sudo sv stop "$SCRIPT_DIR"/services/mhddos/log >/dev/null 2>&1
  sudo rm -rf /etc/runit/runsvdir/default/mhddos >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/mhddos/log/supervise >/dev/null 2>&1
  sudo rm -rf "$SCRIPT_DIR"/services/mhddos/supervise >/dev/null 2>&1
}

mhddos_get_status() {
  clear
  sudo sv status mhddos >/dev/null 2>&1

  if [[ $? > 0 ]]; then
    echo -e "${GRAY}$(trans "MHDDOS вимкнений")${NC}"
  else
    sudo sv status mhddos
  fi
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

is_not_arm_arch() {
  if [[ "$OSARCH" != armv6* && "$OSARCH" != armv7* && $OSARCH != armv8* ]]; then
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
    sudo sv status mhddos >/dev/null 2>&1
    if [[ $? == 0 ]]; then
      active_disactive="$(trans "Зупинка MHDDOS")"
    else
      active_disactive="$(trans "Запуск MHDDOS")"
    fi
    menu_items=("$active_disactive" "$(trans "Налаштування MHDDOS")" "$(trans "Статус MHDDOS")" "$(trans "Повернутись назад")")
    res=$(display_menu "MHDDOS" "${menu_items[@]}")

    case "$res" in
      "$(trans "Зупинка MHDDOS")")
        mhddos_stop
        mhddos_get_status
      ;;
      "$(trans "Запуск MHDDOS")")
        mhddos_run
        while ! sudo sv status mhddos >/dev/null 2>&1; do
           confirm_dialog "$(trans "Чекаємо на сервіс...")"
           sleep 1
        done
        mhddos_get_status
      ;;
      "$(trans "Налаштування MHDDOS")")
        configure_mhddos
        initiate_mhddos
      ;;
      "$(trans "Статус MHDDOS")")
        mhddos_get_status
      ;;
      "$(trans "Повернутись назад")")
        ddos_tool_managment
      ;;
    esac
  fi
}