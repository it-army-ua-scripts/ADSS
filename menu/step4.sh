#!/bin/bash

step4(){

menu=(
      "Статус атаки"
      "MHDDOS"
      "DB1000N"
      "Distress"
      "Повернутись назад"
      )
init "$menu"
menu_result="$?"
service=""
case "$menu_result" in
  0)
     services=("mhddos" "distress" "db1000n")
      service=""

      for element in "${services[@]}"
      do
        if systemctl is-active --quiet "$element.service"; then
          service="$element"
          break
        fi
      done
      if [[ -n "$service" ]]; then
        while true; do
          clear
          echo -e "${GREEN}Запущено $service${NC}"
          journalctl -u "$service.service" | tail -20
          sleep 5
        done
      else
        echo -e "${RED}Немає запущених процесів${NC}"
      fi
  ;;
  1)
    initiate_mhddos
  ;;
  2)
    initiate_db1000n
  ;;
  3)
    initiate_distress
  ;;
  4)
    step3
  ;;
esac
}