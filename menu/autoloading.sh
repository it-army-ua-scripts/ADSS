#!/bin/bash

autoload_configuration() {
  ddos_tool_installed
  if [[ $? == 1 ]]; then
    confirm_dialog "$(trans "ДДОС інструменти не встановлено")"
    ddos_tool_managment
  fi

  is_not_arm_arch
  if [[ $? == 1 ]]; then
    if mhddos_enabled; then
      mhddos_item_menu="$(trans "Вимкнути автозапуск MHDDOS")"
    else
      mhddos_item_menu="$(trans "Увімкнути автозапуск MHDDOS")"
    fi
  fi

  if db1000n_enabled; then
    db1000n_item_menu="$(trans "Вимкнути автозапуск DB1000N")"
  else
    db1000n_item_menu="$(trans "Увімкнути автозапуск DB1000N")"
  fi

  if distress_enabled; then
    distress_item_menu="$(trans "Вимкнути автозапуск DISTRESS")"
  else
    distress_item_menu="$(trans "Увімкнути автозапуск DISTRESS")"
  fi
  menu_items=("$mhddos_item_menu" "$db1000n_item_menu" "$distress_item_menu" "$(trans "Повернутись назад")")
  res=$(display_menu "$(trans "Налаштування автозапуску")" "${menu_items[@]}")

  case "$res" in
  "$(trans "Вимкнути автозапуск MHDDOS")")
    mhddos_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск MHDDOS")")
    mhddos_auto_enable
    autoload_configuration
    ;;
  "$(trans "Вимкнути автозапуск DB1000N")")
    db1000n_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск DB1000N")")
    db1000n_auto_enable
    autoload_configuration
    ;;
  "$(trans "Вимкнути автозапуск DISTRESS")")
    distress_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск DISTRESS")")
    distress_auto_enable
    autoload_configuration
    ;;
  "$(trans "Повернутись назад")")
    ddos_tool_managment
    ;;
  esac
}
