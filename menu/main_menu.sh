#!/bin/bash

main_menu() {
  menu_items=("$(trans "Статус атаки")" "$(trans "Розширення портів")" "DDOS" "$(trans "Налаштування безпеки")")
  res=$(display_menu "$(trans "Головне меню")" "${menu_items[@]}")

  case "$res" in
    "$(trans "Статус атаки")")
      get_ddoss_status
      main_menu
      ;;
    "$(trans "Розширення портів")")
      extend_ports
      main_menu
      ;;
    "DDOS")
      ddos
      ;;
    "$(trans "Налаштування безпеки")")
      security_settings
      ;;
  esac
}
