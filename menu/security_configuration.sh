#!/bin/bash

security_configuration() {
  while true; do
    menu_items=("Налаштування фаєвола" "Налаштування захисту від брутфорса" "Повернутись назад")
    selected_choice=$(display_menu "Налаштування захисту" "${menu_items[@]}")

    case $selected_choice in
      1)
        configure_ufw
      ;;
      2)
        configure_fail2ban
      ;;
      3)
        security_settings
      ;;
    esac
  done
}