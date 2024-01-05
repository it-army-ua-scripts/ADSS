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
  display_menu "$(trans "Налаштування захисту")" "${menu_items[@]}"
  res=$?
  if [[ $ufw == 1 && $fail2ban == 1 ]]; then
    case $res in
    1)
      ufw_is_active
      if [[ $? == 1 ]]; then
        disable_ufw
      else
        enable_ufw
      fi
      security_configuration
      ;;
    2)
      fail2ban_is_active
      if [[ $? == 1 ]]; then
        disable_fail2ban
      else
        enable_fail2ban
      fi
      security_configuration
      ;;
    3)
      configure_ufw
      security_configuration

      ;;
    4)
      configure_fail2ban
      security_configuration
      ;;
    5)
      security_settings
      ;;
    esac
  elif [[ $ufw == 1 && $fail2ban == "" ]]; then
    case $res in
    1)
      ufw_is_active
      if [[ $? == 1 ]]; then
        disable_ufw
      else
        enable_ufw
      fi
      security_configuration
      ;;
    2)
      configure_ufw
      security_configuration

      ;;
    3)
      configure_fail2ban
      security_configuration
      ;;
    4)
      security_settings
      ;;
    esac
  elif [[ $ufw == "" && $fail2ban == 1 ]]; then
    case $res in
    1)
      fail2ban_is_active
      if [[ $? == 1 ]]; then
        disable_fail2ban
      else
        enable_fail2ban
      fi
      security_configuration
      ;;
    2)
      configure_ufw
      security_configuration
      ;;
    3)
      configure_fail2ban
      security_configuration
      ;;
    4)
      security_settings
      ;;
    esac
  else
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
  fi
}
