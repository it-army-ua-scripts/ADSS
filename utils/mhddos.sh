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
        create_symlink
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
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stats_bot${NC}""\n"
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
    echo -e "${ORANGE}$(trans "Мережеві інтерфейси (через пробіл: eth0 eth1 тощо.)")${NC}"
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
  local lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" "${SCRIPT_DIR}"/services/EnvironmentFile)

  local start="ExecStart=${SCRIPT_DIR}/bin/mhddos_proxy_linux"

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
    if [[ "$key" == 'cron-to-run' || "$key" == 'cron-to-stop' ]];then
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
  sudo systemctl stop x100.service >/dev/null 2>&1
  sudo systemctl start mhddos.service >/dev/null 2>&1
}

mhddos_auto_enable() {
  sudo systemctl disable distress.service >/dev/null 2>&1
  sudo systemctl disable db1000n.service >/dev/null 2>&1
  sudo systemctl disable x100 >/dev/null 2>&1
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
  sudo systemctl is-enabled mhddos >/dev/null 2>&1  && return 0 || return 1
}

mhddos_stop() {
#  create_symlink
  sudo systemctl stop mhddos.service >/dev/null 2>&1
}

mhddos_get_status() {
  while true; do
    clear
    st=$(sudo systemctl status mhddos.service)
    echo "$st"
    echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
    sleep 3
    if read -rsn1 -t 0.1; then
      break
    fi
  done
  initiate_mhddos
}
mhddos_installed() {
  if [[ ! -f "$TOOL_DIR/mhddos_proxy_linux" ]]; then
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

mhddos_configure_scheduler() {
  clear
  echo -ne "${GREEN}  .---------------- $(trans "хвилина") (0 - 59)
  |  .------------- $(trans "година") (0 - 23)
  |  |  .---------- $(trans "день місяця") (1 - 31)
  |  |  |  .------- $(trans "місяць") (1 - 12)
  |  |  |  |  .---- $(trans "день тижня") (0 - 6)
  |  |  |  |  |
  *  *  *  *  *${NC}"

  echo -ne "\n\n"
  echo -ne "${GREEN}$(trans "Або згенеруйте його за посиланням") ${NC}${RED}https://crontab.guru/${NC}"
  echo -ne "\n\n"
  echo -ne "$(trans "Зверніть увагу на ваш час командою") ${GREEN}date${NC}"
  echo -ne "\n\n"
  echo -ne "$(trans "Наприклад:")"
  echo -ne "\n"
  echo -ne "  ${GREEN}$(trans "Запуск MHDDOS о 20:00 щодня") -${NC} ${RED}0 20 * * *${NC}"
  echo -ne "\n"
  echo -ne "  ${GREEN}$(trans "Зупинка MHDDOS о 08:00 щодня") -${NC} ${RED}0 8 * * *${NC}"
  echo -ne "\n\n"
  read -e -p "$(trans "Введіть cron-час для ЗАПУСКУ (формат: * * * * *): ")" -i "$(get_mhddos_variable 'cron-to-run')" cron_time_to_run
  echo -ne "\n"
  read -e -p "$(trans "Введіть cron-час для ЗУПИНКИ (формат: * * * * *): ")"  -i "$(get_mhddos_variable 'cron-to-stop')" cron_time_to_stop


  if [[ -n "$cron_time_to_run" ]]; then
    write_mhddos_variable "cron-to-run" "$cron_time_to_run"
  elif [[ "$cron_time_to_run" == "" ]]; then
    sudo crontab -l | grep -v 'mhddos_run' | sudo crontab -
    write_mhddos_variable "cron-to-run" ""
  fi

  if [[ -n "$cron_time_to_stop" ]]; then
    write_mhddos_variable "cron-to-stop" "$cron_time_to_stop"
  elif [[ "$cron_time_to_stop" == "" ]]; then
    sudo crontab -l | grep -v 'mhddos_stop' | sudo crontab -
    write_mhddos_variable "cron-to-stop" ""
  fi

  if [[ "$cron_time_to_run" == "" ]] && [[ "$cron_time_to_stop" == "" ]]; then
      confirm_dialog "$(trans "Запуск MHDDOS за розкладом припинено")"
      autoload_configuration
  elif [[ -n "$cron_time_to_run" ]] || [[ -n "$cron_time_to_stop" ]]; then
    to_start_mhddos_schedule_running
  else
    autoload_configuration
  fi
}

check_if_mhddos_running_on_schedule() {
  ($(sudo crontab -l | grep -q 'mhddos_run') || $(sudo crontab -l | grep -q 'mhddos_stop')) >/dev/null 2>&1  && return 0 || return 1
}

to_start_mhddos_schedule_running() {
    local menu_items=("$(trans "Так")" "$(trans "Ні")")
    local res=$(display_menu "$(trans "Запустити MHDDOS за розкладом?")" "${menu_items[@]}")
    case "$res" in
    "$(trans "Так")")
      run_mhddos_on_schedule
      confirm_dialog "$(trans "MHDDOS буде ЗАПУЩЕНО за розкладом")"
      autoload_configuration
    ;;
    "$(trans "Ні")")
      autoload_configuration
    ;;
    esac
}

run_mhddos_on_schedule() {
  sudo systemctl disable mhddos >/dev/null 2>&1
  sudo systemctl disable distress >/dev/null 2>&1
  sudo systemctl disable x100 >/dev/null 2>&1
  sudo systemctl disable db1000n >/dev/null 2>&1
  create_symlink

  chmod +x "$SCRIPT_DIR/utils/mhddos.sh"
  local cron_time_to_run=$(get_mhddos_variable 'cron-to-run')
  local cron_time_to_stop=$(get_mhddos_variable 'cron-to-stop')
  sudo crontab -l | grep -v 'mhddos_run' | sudo crontab -
  sudo crontab -l | grep -v 'mhddos_stop' | sudo crontab -
  sudo crontab -l | grep -v 'distress_run' | sudo crontab -
  sudo crontab -l | grep -v 'distress_stop' | sudo crontab -
  sudo crontab -l | grep -v 'x100_run' | sudo crontab -
  sudo crontab -l | grep -v 'x100_stop' | sudo crontab -
  if [[ -n "$cron_time_to_run" ]]; then
    (sudo crontab -l 2>/dev/null; echo "$cron_time_to_run bash -c '. $SCRIPT_DIR/utils/mhddos.sh && mhddos_run'") | sudo crontab -
  fi

  if [[ -n "$cron_time_to_stop" ]]; then
    (sudo crontab -l 2>/dev/null; echo "$cron_time_to_stop bash -c '. $SCRIPT_DIR/utils/mhddos.sh && mhddos_stop'") | sudo crontab -
  fi
}

stop_mhddos_on_schedule() {
  sudo crontab -l | grep -v 'mhddos_run' | sudo crontab -
  sudo crontab -l | grep -v 'mhddos_stop' | sudo crontab -
  write_mhddos_variable "cron-to-run" ""
  write_mhddos_variable "cron-to-stop" ""
}


initiate_mhddos() {
  mhddos_installed
  if [[ $? == 1 ]]; then
    confirm_dialog "$(trans "MHDDOS не встановлений, будь ласка встановіть і спробуйте знову")"
    ddos_tool_managment
  else
      if sudo systemctl is-active mhddos >/dev/null 2>&1; then
        local active_disactive="$(trans "Зупинка MHDDOS")"
      else
        local active_disactive="$(trans "Запуск MHDDOS")"
      fi
      local menu_items=("$active_disactive" "$(trans "Налаштування MHDDOS")" "$(trans "Статус MHDDOS")" "$(trans "Повернутись назад")")
      local res=$(display_menu "MHDDOS" "${menu_items[@]}")

      case "$res" in
        "$(trans "Зупинка MHDDOS")")
          mhddos_stop
          mhddos_get_status
        ;;
        "$(trans "Запуск MHDDOS")")
          mhddos_run
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
