#!/bin/bash

x100_run() {
  db1000n_stop
  distress_stop
  mhddos_stop
  clear
  cd "$SCRIPT_DIR/x100-for-docker/for-macOS-and-Linux-hosts" && ./run-and-auto-update.bash
}

initiate_x100() {
   x100_installed
   if [[ $? == 1 ]]; then
      menu_items=("$(trans "Так")" "$(trans "Ні")")
      res=$(display_menu "$(trans "X100 не встановлений, встановити?")" "${menu_items[@]}")
      case "$res" in
        "$(trans "Так")")
          install_x100
        ;;
        "$(trans "Ні")")
          ddos_tool_managment
        ;;
      esac
   else

      menu_items=("$(trans "Запуск X100")" "$(trans "Налаштування X100")" "$(trans "Повернутись назад")")
      res=$(display_menu "X100" "${menu_items[@]}")

      case "$res" in
        "$(trans "Запуск X100")")
          x100_run
        ;;
        "$(trans "Налаштування X100")")

        ;;
        "$(trans "Повернутись назад")")
          ddos_tool_managment
        ;;
      esac
   fi
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

    curl -L  --fail  --max-time 30  "https://raw.githubusercontent.com/ihorlv/db1000nX100/main/source-code/docker/x100-for-docker.zip" -o "./x100-for-docker.zip"
    unzip ./x100-for-docker.zip
    rm ./x100-for-docker.zip

    cd "$SCRIPT_DIR/x100-for-docker"

    chmod -R ug+x "./for-macOS-and-Linux-hosts"

    echo -ne "${GREEN}$(trans "Для збору особистої статистики та відображення у лідерборді на офіційному сайті.")${NC} ${ORANGE}https://itarmy.com.ua/leaderboard ${NC}""\n"
    echo -ne "${GREEN}$(trans "Надається Telegram ботом")${NC} ${ORANGE}@itarmy_stat_bot${NC}""\n"
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
    initiate_x100
}
