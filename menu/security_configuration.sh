#!/bin/bash

security_configuration() {

  menu_items=()
  ufw=""
  fail2ban=""
  ufw_installed
  if [[ $? == 1 ]]; then
    ufw=1
    ufw_is_active
    if [[ $? == 1 ]]; then
      menu_items+=("$(trans "Вимкнути фаервол")")
    else
      menu_items+=("$(trans "Увімкнути фаервол")")
    fi
  fi

  fail2ban_installed
  if [[ $? == 1 ]]; then
    fail2ban=1
    fail2ban_is_active
    if [[ $? == 1 ]]; then
      menu_items+=("$(trans "Вимкнути захист від брутфорсу")")
    else
      menu_items+=("$(trans "Увімкнути захист від брутфорсу")")
    fi
  fi

  menu_items+=("$(trans "Налаштування фаєрвола")" "$(trans "Налаштування захисту від брутфорса")" "$(trans "Повернутись назад")")
  res=$(display_menu "$(trans "Налаштування захисту")" "${menu_items[@]}")

  case "$res" in
    "$(trans "Вимкнути фаервол")")
      disable_ufw
      security_configuration
      ;;
    "$(trans "Увімкнути фаервол")")
      enable_ufw
      security_configuration
      ;;
    "$(trans "Вимкнути захист від брутфорсу")")
      disable_fail2ban
      security_configuration
      ;;
    "$(trans "Увімкнути захист від брутфорсу")")
      enable_fail2ban
      security_configuration
      ;;
    "$(trans "Налаштування фаєрвола")")
        configure_ufw
        security_configuration
      ;;
    "$(trans "Налаштування захисту від брутфорса")")
        configure_fail2ban
        security_configuration
      ;;
    "$(trans "Повернутись назад")")
        security_settings
      ;;
  esac
}
