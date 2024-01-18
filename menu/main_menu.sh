#!/bin/bash

main_menu() {
  menu_items=("$(trans "Розширення портів")" "$(trans "Налаштування безпеки")" "DDOS" "$(trans "Статус атаки")")
  res=$(display_menu "$(trans "Головне меню")" "${menu_items[@]}")

  case "$res" in
    "$(trans "Розширення портів")")
      extend_ports
      main_menu
      ;;
    "$(trans "Налаштування безпеки")")
      security_settings
      ;;
    "DDOS")
      ddos
      ;;
    "$(trans "Статус атаки")")
      get_ddoss_status
      main_menu
      ;;
  esac
}
