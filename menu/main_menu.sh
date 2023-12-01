#!/bin/bash

main_menu() {
  menu_items=("$(trans "Розширення портів")" "DDOS")
  res=$(display_menu "$(trans "Головне меню")" "${menu_items[@]}")

  case "$res" in
    "$(trans "Розширення портів")")
      extend_ports
      main_menu
      ;;
    "DDOS")
      ddos
      ;;
  esac
}
