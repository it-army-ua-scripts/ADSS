#!/bin/bash

security_settings() {
  while true; do
    menu_items=("Встановлення захисту" "Налаштування захисту" "Повернутись назад")
    selected_choice=$(display_menu "Налаштування безпеки" "${menu_items[@]}")

    case $selected_choice in
      1)
        install_ufw
        install_fail2ban
      ;;
      2)
        security_configuration
      ;;
      3)
        main_menu
      ;;
    esac
  done
}