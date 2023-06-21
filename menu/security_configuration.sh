#!/bin/bash

security_configuration() {
  while true; do
    selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "Налаштування захисту" \
      --menu "Виберіть опцію:" 0 0 0 \
      1 "Налаштування фаєвола" \
      2 "Налаштування захисту від брутфорса" \
      3 "Повернутись назад")

    exit_status=$?
    case $exit_status in
        255 | 1)
             clear
             echo "Exiting..."
             exit 0
        ;;
    esac

    case $selection in
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