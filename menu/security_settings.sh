#!/bin/bash

security_settings() {
  menu_items=("$(trans "Встановлення захисту")" "$(trans "Налаштування захисту")" "$(trans "Повернутись назад")")
  res=$(display_menu "$(trans "Налаштування безпеки")" "${menu_items[@]}")

  case "$res" in
  "$(trans "Встановлення захисту")")
    install_ufw
    install_fail2ban
    security_settings
    ;;
  "$(trans "Налаштування захисту")")
    security_configuration
    ;;
  "$(trans "Повернутись назад")")
    main_menu
    ;;
  esac
}
