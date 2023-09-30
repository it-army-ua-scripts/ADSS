#!/bin/bash

main_menu() {
  menu_items=("$(trans "Розширення портів")" "$(trans "Налаштування безпеки")" "DDOS")
  display_menu "$(trans "Головне меню")" "${menu_items[@]}"
  case $? in
  1)
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
