#!/bin/bash

x100_run() {
  db1000n_stop
  distress_stop
  mhddos_stop
  sudo systemctl start x100.service >/dev/null 2>&1
}

x100_auto_enable() {
  sudo systemctl disable mhddos.service >/dev/null 2>&1
  sudo systemctl disable db1000n.service >/dev/null 2>&1
  sudo systemctl disable distress.service >/dev/null 2>&1
  sudo systemctl enable x100 >/dev/null 2>&1
  create_symlink
  confirm_dialog "$(trans "X100 додано до автозавантаження")"
}

x100_auto_disable() {
  sudo systemctl disable x100 >/dev/null 2>&1
  create_symlink
  confirm_dialog "$(trans "X100 видалено з автозавантаження")"
}

x100_enabled() {
  sudo systemctl is-enabled x100 >/dev/null 2>&1 && return 0 || return 1
}

x100_stop() {
  sudo systemctl stop x100.service >/dev/null 2>&1
}

x100_get_status() {
  while true; do
    clear
    st=$(sudo systemctl status x100.service)
    echo "$st"
    echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
    sleep 3
    if read -rsn1 -t 0.1; then
      break
    fi
  done

  initiate_x100
}

docker_installed() {
  docker container ls   1>/dev/null   2>/dev/null  && return 0 || return 1
}

install_docker() {
  if [ -r /etc/os-release ]; then
    clear
    sudo apt install -y docker.io
    if ! grep -q docker /etc/group; then
      sudo groupadd docker
      sudo usermod -aG docker $USER
    fi
    sudo service docker start
    sudo systemctl enable docker
  else
    echo -e "${RED}Неможливо визначити операційну систему/Unable to determine operating system${NC}"
  fi
}

initiate_x100() {
   x100_installed
   if [[ $? == 1 ]]; then
      menu_items=("$(trans "Так")" "$(trans "Ні")")
      res=$(display_menu "$(trans "X100 не встановлений, встановити?")" "${menu_items[@]}")
      case "$res" in
        "$(trans "Так")")
          confirm_dialog "$(trans "Встановлюємо Х100")"
          install_x100
          confirm_dialog "$(trans "Х100 успішно встановлено")"
        ;;
        "$(trans "Ні")")
          ddos_tool_managment
        ;;
      esac
   fi
   docker_installed
   if [[ $? == 1 ]]; then
     confirm_dialog "$(trans "Встановлюємо докер")"
     install_docker
     confirm_dialog "$(trans "Докер успішно встановлено")"
   fi
  if sudo systemctl is-active x100 >/dev/null 2>&1; then
    active_disactive="$(trans "Зупинка X100")"
  else
    active_disactive="$(trans "Запуск X100")"
  fi
   menu_items=("$active_disactive" "$(trans "Налаштування X100")"  "$(trans "Статус X100")" "$(trans "Повернутись назад")")
   res=$(display_menu "X100" "${menu_items[@]}")

  case "$res" in
   "$(trans "Запуск X100")")
     x100_run
     x100_get_status
   ;;
   "$(trans "Зупинка X100")")
     x100_stop
     x100_get_status
   ;;
   "$(trans "Налаштування X100")")
     configure_x100
     initiate_x100
   ;;
   "$(trans "Статус X100")")
     x100_get_status
   ;;
   "$(trans "Повернутись назад")")
     ddos_tool_managment
   ;;
  esac
}

configure_x100() {
    clear
    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stats_bot${NC}""\n"
    echo -ne "\n"
    read -e -p "$(trans "Юзер ІД: ")" -i "$(get_x100_variable 'itArmyUserId')"  user_id

    configPath="$SCRIPT_DIR/x100-for-docker/put-your-ovpn-files-here/x100-config.txt"

    sed -i -e "s/itArmyUserId=$(get_x100_variable 'itArmyUserId')/itArmyUserId=$user_id/g" "$configPath"

    read -e -p "$(trans "Initial Distress Scale (0-100): ")" -i "$(get_x100_variable 'initialDistressScale')"  scale
    if [[ -n "$scale" ]];then
      while [[ $scale -lt 0 || $scale -gt 100 ]]
      do
        echo "$(trans "Будь ласка введіть правильні значення")"
        read -e -p "$(trans "Initial Distress Scale (0-100): ")" -i "$(get_x100_variable 'initialDistressScale')" scale
      done
    fi
    sed -i -e "s/initialDistressScale=$(get_x100_variable 'initialDistressScale')/initialDistressScale=$scale/g" "$configPath"
    if systemctl is-active --quiet x100.service; then
        sudo systemctl restart x100.service >/dev/null 2>&1
    fi
    confirm_dialog "$(trans "Успішно виконано")"
}

get_x100_variable() {
  configPath="$SCRIPT_DIR/x100-for-docker/put-your-ovpn-files-here/x100-config.txt"
  local lines=$(cat $configPath)
  local variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

x100_installed() {
  if [[ ! -d "$SCRIPT_DIR/x100-for-docker" ]]; then
      return 1
  else
      return 0
  fi
}

install_x100() {
    clear
    cd "$SCRIPT_DIR"

    curl -L  --fail  --max-time 30  "https://github.com/ihorlv/db1000nX100/raw/main/source-code/docker/x100-for-docker.zip" -o "./x100-for-docker.zip"
    unzip ./x100-for-docker.zip
    rm ./x100-for-docker.zip

    cd "$SCRIPT_DIR/x100-for-docker"

    chmod -R ug+x "./for-macOS-and-Linux-hosts"

    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stats_bot${NC}""\n"
    echo -ne "\n"
    read -e -p "$(trans "Юзер ІД: ")"  user_id

    configPath=./put-your-ovpn-files-here/x100-config.txt

    sed -i -e "s/itArmyUserId=0/itArmyUserId=$user_id/g" "$configPath"
    sed -i -e 's/dockerInteractiveConfiguration=1/dockerInteractiveConfiguration=0/g' "$configPath"
    ###

    scriptBeforeRunPath=./for-macOS-and-Linux-hosts/custom-script-before-run.bash
    echo " "  >> "$scriptBeforeRunPath"
    echo " "  >> "$scriptBeforeRunPath"
    echo "cd ./put-your-ovpn-files-here/FreeAndSlowVpn" >> "$scriptBeforeRunPath"
    echo "./generate-vpngate.bash" >> "$scriptBeforeRunPath"

    chmod ug+x "./put-your-ovpn-files-here/FreeAndSlowVpn/generate-vpngate.bash"
    create_symlink
     echo -ne "${GREEN}$(trans "This installation of X100 uses free and slow 'VPNGate' VPN provider.")${NC}""\n"
     echo -ne "${GREEN}$(trans "${ORANGE}http://www.vpngate.net${NC}")${NC}""\n"
     echo -ne "${GREEN}$(trans "You will need a commercial VPN account to achieve top attack speed (1 Gbit/s or more).")${NC}""\n"
     echo -ne "${GREEN}$(trans "Also, be aware, that X100 gradually increases resources usage.")${NC}""\n"
     echo -ne "${GREEN}$(trans "X100 will reach pick performance approximately in 3 hours after launch.")${NC}""\n"
     echo -ne "${GREEN}$(trans "Logs will be stored in ${ORANGE}$SCRIPT_DIR/x100-for-docker/put-your-ovpn-files-here${NC} ${GREEN}folder.${NC}")${NC}""\n"
     echo -ne "${GREEN}$(trans "For more information contact us on Telegram ${ORANGE}https://t.me/db1000nX100${NC}")${NC}""\n"
     echo -ne "${GREEN}$(trans "Also, there are some manuals and docs on our official website ${ORANGE}https://x100.vn.ua/${NC}")${NC}""\n"
     echo -ne "${GREEN}$(trans "Best regards! X100 IT ARMY TEAM! Glory to UKRAINE!")${NC}""\n"

    echo -e "${ORANGE}$(trans "Нажміть будь яку клавішу щоб продовжити")${NC}"
    read -s -n 1 key
}
