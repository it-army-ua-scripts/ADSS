#!/bin/bash

main_menu() {
    while true; do
      menu_items=("Встановити докер" "Розширення портів" "Налаштування безпеки" "ДДОС")
      selected_choice=$(display_menu "Головне меню" "${menu_items[@]}")

      case "$selected_choice" in
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
        *)
           clear
           echo "Exiting..."
           exit 1
        ;;
      esac
    done
}
