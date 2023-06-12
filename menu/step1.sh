#!/bin/bash


step1() {
  menu=(
  "Встановлення захисту"
  "Налаштування захисту"
  "Повернутись назад"
  )
  init "$menu"
  result="$?"
  case "$result" in
    0)
        install_ufw
        install_fail2ban
    ;;
    1)
       step2
    ;;
    2)
      main_menu_init
    ;;
  esac
}