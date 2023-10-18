#!/bin/bash

main_menu() {
  menu_items=("$(trans "Розширення портів")" "DDOS")
  display_menu "$(trans "Головне меню")" "${menu_items[@]}"
  case $? in
  1)
    extend_ports
    main_menu
    ;;
  2)
    ddos
    ;;
  esac
}
