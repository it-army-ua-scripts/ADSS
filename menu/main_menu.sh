#!/bin/bash

main_menu() {
  menu_items=("Встановити докер" "Розширення портів" "Налаштування безпеки" "ДДОС")
  display_menu "Головне меню" "${menu_items[@]}"
  case $? in
    1)
      install_docker
      main_menu
    ;;
    2)
      extend_ports
      main_menu
    ;;
    3)
      security_settings
    ;;
    4)
      ddos
    ;;
  esac
}
