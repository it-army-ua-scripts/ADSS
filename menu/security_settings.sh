#!/bin/bash

security_settings() {
  menu_items=("Встановлення захисту" "Налаштування захисту" "Повернутись назад")
  selected_choice=$(display_menu "Налаштування безпеки" "${menu_items[@]}")

  case $selected_choice in
    1)
      install_ufw
      install_fail2ban
      security_settings
    ;;
    2)
      security_configuration
    ;;
    3)
      main_menu
    ;;
  esac
}