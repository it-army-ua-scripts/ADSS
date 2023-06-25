#!/bin/bash

security_configuration() {
  menu_items=("Налаштування фаєвола" "Налаштування захисту від брутфорса" "Повернутись назад")
  display_menu "Налаштування захисту" "${menu_items[@]}"

  case $? in
    1)
      configure_ufw
      security_configuration
    ;;
    2)
      configure_fail2ban
      security_configuration
    ;;
    3)
      security_settings
    ;;
  esac
}