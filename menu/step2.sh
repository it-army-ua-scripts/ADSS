#!/bin/bash

step2() {
   menu=(
          "Налаштування фаєвола"
          "Налаштування захисту від брутфорса"
          "Повернутись назад"
          )
    init "$menu"
    menu_result="$?"

    case "$menu_result" in
      0)
          configure_ufw
      ;;
      1)
          configure_fail2ban
      ;;
      2)
          step1
      ;;
    esac
}