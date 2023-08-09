#!/bin/bash

security_configuration() {

  menu_items=()
  ufw=""
  fail2ban=""
  ufw_installed
  if [[ $? == 1 ]]; then
    ufw_is_active
    if [[ $? == 1 ]]; then
        menu_items+=("$(trans "Увімкнути фаервол")")
        ufw=1
    else
        menu_items+=("$(trans "Вимкнути фаервол")")
        ufw=0
    fi
  fi

  fail2ban_installed
  if [[ $? == 1 ]]; then
    fail2ban_is_active
    if [[ $? == 1 ]]; then
        menu_items+=("$(trans "Увімкнути захист від брутфорсу")")
        fail2ban=1
    else
        menu_items+=("$(trans "Вимкнути захист від брутфорсу")")
        fail2ban=0
    fi
  fi

  menu_items+=("$(trans "Налаштування фаєрвола")" "$(trans "Налаштування захисту від брутфорса")" "$(trans "Повернутись назад")")
  display_menu "$(trans "Налаштування захисту")" "${menu_items[@]}"
  res=$?
  if [[ $res == 1 && $ufw == 1 ]]; then
    enable_ufw
    security_configuration
  elif [[ $res == 1 && $ufw == 0 ]]; then
    disable_ufw
    security_configuration
  elif [[ $res == 2 && $fail2ban == 1 ]]; then
    enable_fail2ban
    security_configuration
  elif [[ $res == 2 && $fail2ban == 0 ]]; then
    disable_fail2ban
    security_configuration
  else
    case $res in
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
  fi
}