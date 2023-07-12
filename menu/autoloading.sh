#!/bin/bash

autoload_configuration() {
  db1000n_installed
  if [[ $? == 1 ]]; then
    ddos_tool_managment
  fi
  distress_installed
  if [[ $? == 1 ]]; then
    ddos_tool_managment
  fi
  mhddos_installed
  if [[ $? == 1 ]]; then
    ddos_tool_managment
  fi

  if mhddos_enabled; then
    mhddos_item_menu="Вимкнути автозапуск MHDDOS"
  else
    mhddos_item_menu="Увімкнути автозапуск MHDDOS"
  fi

  if db1000n_enabled; then
    db1000n_item_menu="Вимкнути автозапуск DB1000N"
  else
    db1000n_item_menu="Увімкнути автозапуск DB1000N"
  fi

  if distress_enabled; then
      distress_item_menu="Вимкнути автозапуск MHDDOS"
  else
      distress_item_menu="Увімкнути автозапуск MHDDOS"
  fi
  menu_items=("$mhddos_item_menu" "$db1000n_item_menu" "$distress_item_menu" "Повернутись назад")
  display_menu "Налаштування автозапуску" "${menu_items[@]}"
  status=$?

  case $status in
    1)
      if mhddos_enabled; then
        mhddos_auto_disable
      else
        mhddos_auto_enable
      fi
      autoload_configuration
    ;;
    2)
      if db1000n_enabled; then
        db1000n_auto_disable
      else
        db1000n_auto_enable
      fi
      autoload_configuration
    ;;
    3)
      if distress_enabled; then
          distress_auto_disable
      else
          distress_auto_enable
      fi
      autoload_configuration
    ;;
    4)
      ddos_tool_managment
    ;;
  esac
}