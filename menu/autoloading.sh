#!/bin/bash

autoload_configuration() {
  menu_items=()
  if mhddos_installed ; then
    is_not_arm_arch
    if [[ $? == 1 ]]; then
      if mhddos_enabled; then
        mhddos_item_menu="$(trans "Вимкнути автозапуск MHDDOS")"
      else
        mhddos_item_menu="$(trans "Увімкнути автозапуск MHDDOS")"
      fi
      mhddos_scheduler="$(trans "Керування розкладом MHDDOS")"
      menu_items+=("$mhddos_item_menu" "$mhddos_scheduler")
      check_if_mhddos_running_on_schedule
      if [[ $? == 0 ]]; then
        mhddos_scheduler_stop="$(trans "Зупинити запуск MHDDOS за розкладом")"
        menu_items+=("$mhddos_scheduler_stop")
      fi
    fi
  fi

#  if db1000n_installed ; then
#    if db1000n_enabled; then
#      db1000n_item_menu="$(trans "Вимкнути автозапуск DB1000N")"
#    else
#      db1000n_item_menu="$(trans "Увімкнути автозапуск DB1000N")"
#    fi
#    menu_items+=("$db1000n_item_menu")
#  fi

  if distress_installed ; then
    if distress_enabled; then
      distress_item_menu="$(trans "Вимкнути автозапуск DISTRESS")"
    else
      distress_item_menu="$(trans "Увімкнути автозапуск DISTRESS")"
    fi
    distress_scheduler="$(trans "Керування розкладом DISTRESS")"
    menu_items+=("$distress_item_menu" "$distress_scheduler")
    check_if_distress_running_on_schedule
    if [[ $? == 0 ]]; then
      distress_scheduler_stop="$(trans "Зупинити запуск DISTRESS за розкладом")"
      menu_items+=("$distress_scheduler_stop")
    fi
  fi

  if x100_installed; then
    if x100_enabled; then
      x100_item_menu="$(trans "Вимкнути автозапуск X100")"
    else
      x100_item_menu="$(trans "Увімкнути автозапуск X100")"
    fi
    x100_scheduler="$(trans "Керування розкладом X100")"
    menu_items+=("$x100_item_menu" "$x100_scheduler")
    check_if_x100_running_on_schedule
    if [[ $? == 0 ]]; then
      x100_scheduler_stop="$(trans "Зупинити запуск X100 за розкладом")"
      menu_items+=("$x100_scheduler_stop")
    fi
  fi

  if [[ ${#menu_items[@]} -eq 0 ]]; then
        confirm_dialog "$(trans "ДДОС інструменти не встановлено")"
        ddos_tool_managment
  fi

  menu_items+=("$(trans "Повернутись назад")")

  res=$(display_menu "$(trans "Налаштування автозапуску")" "${menu_items[@]}")

  case "$res" in
  "$(trans "Керування розкладом MHDDOS")")
      mhddos_configure_scheduler
    ;;
  "$(trans "Зупинити запуск MHDDOS за розкладом")")
      stop_mhddos_on_schedule
      confirm_dialog "$(trans "Запуск MHDDOS за розкладом успішно ПРИПИНЕНО")"
      autoload_configuration
    ;;
  "$(trans "Керування розкладом DISTRESS")")
      distress_configure_scheduler
    ;;
  "$(trans "Зупинити запуск DISTRESS за розкладом")")
    stop_distress_on_schedule
    confirm_dialog "$(trans "Запуск DISTRESS за розкладом успішно ПРИПИНЕНО")"
    autoload_configuration
  ;;
  "$(trans "Керування розкладом X100")")
    x100_configure_scheduler
    ;;
  "$(trans "Зупинити запуск X100 за розкладом")")
    stop_x100_on_schedule
    confirm_dialog "$(trans "Запуск X100 за розкладом успішно ПРИПИНЕНО")"
    autoload_configuration
    ;;
  "$(trans "Вимкнути автозапуск MHDDOS")")
    mhddos_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск MHDDOS")")
    mhddos_auto_enable
    autoload_configuration
    ;;
#  "$(trans "Вимкнути автозапуск DB1000N")")
#    db1000n_auto_disable
#    autoload_configuration
#    ;;
#  "$(trans "Увімкнути автозапуск DB1000N")")
#    db1000n_auto_enable
#    autoload_configuration
#    ;;
  "$(trans "Вимкнути автозапуск DISTRESS")")
    distress_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск DISTRESS")")
    distress_auto_enable
    autoload_configuration
    ;;
  "$(trans "Вимкнути автозапуск X100")")
    x100_auto_disable
    autoload_configuration
    ;;
  "$(trans "Увімкнути автозапуск X100")")
    x100_auto_enable
    autoload_configuration
    ;;
  "$(trans "Повернутись назад")")
    ddos_tool_managment
    ;;
  esac
}
