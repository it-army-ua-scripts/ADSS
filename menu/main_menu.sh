#!/bin/bash

main_menu() {
    while true; do
      selection=$(dialog --ascii-lines --clear --stdout --cancel-label "Вихід" --title "Головне меню" \
        --menu "Виберіть опцію:" 0 0 0 \
        1 "Встановити докер" \
        2 "Розширення портів" \
        3 "Налаштування безпеки" \
        3 "TEST" \
        4 "ДДОС")
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
          install_docker
        ;;
        2)
          extend_ports
        ;;
        3)
          security_settings
        ;;
        4)
          ddos
        ;;
      esac
    done
}
