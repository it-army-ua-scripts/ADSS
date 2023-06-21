#!/bin/bash

security_settings() {
  while true; do
    selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "Налаштування безпеки" \
      --menu "Виберіть опцію:" 0 0 0 \
      1 "Встановлення захисту" \
      2 "Налаштування захисту" \
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