#!/bin/bash

security_configuration() {
  menu_items=("$(trans "Налаштування фаєрвола")" "$(trans "Налаштування захисту від брутфорса")" "$(trans "Повернутись назад")")
  display_menu "$(trans "Налаштування захисту")" "${menu_items[@]}"

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