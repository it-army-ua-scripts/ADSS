#!/bin/bash

main_menu_notice_compact() {
  local notice
  notice="$(cat <<EOF
$(trans "УВАГА! ⚠️")
$(trans "Є важливе повідомлення від команди.")
$(trans "Повний текст доступний у README.")
EOF
)"

  wrap_dialog_text "$notice"
}

show_main_menu_notice_if_needed() {
  if ! is_compact_dialog_screen; then
    return
  fi

  if [[ "$ADSS_MAIN_NOTICE_SHOWN" == "1" ]]; then
    return
  fi

  display_scrollable_text "$(trans "Головне меню")" "$(main_menu_notice_full)"
  ADSS_MAIN_NOTICE_SHOWN="1"
}

main_menu_notice_full() {
  local notice
  notice="$(cat <<EOF
$(trans "УВАГА! ⚠️")

$(trans "Утіліти IT ARMY а також команда розвідки в повному складі залишаються вірними патріотами України, які працюють проти ворога кожен день.")
$(trans "Всі розвідники і розробники утіліт, які працювали з вами всі 4+ років, залишаються єдиними в своїй позиції, без винятку.")

$(trans "Інформація про компрометацію нашої команди є ініціативою адміністратора ТГ-каналу, який, спираючись на непідтверджені зв’язки з МінЦифри, намагався отримати доступ до чутливого коду та конфігурації під виглядом необхідного аудиту, хоча багато років він цього аудиту не потребував.")

$(trans "Оскільки ця особа не підтвердила ані організацію, яку він представляє, ані мету своїх потреб, ми були вимушені відмовити задля безпеки.")
$(trans "Ми інформуємо вас через утіліти, бо не маємо доступу до офіційного каналу.")

$(trans "Якщо ви сумніваєтеся в поточних цілях, ви завжди можете подивитися, куди спрямовано трафік.")
$(trans "Ми просимо вас не зупиняти сервери, оскільки робота продовжується і від адміністратора ТГ каналу ви не отримаєте правдивої інформації.")

$(trans "Скоріше за все, ми будемо створювати новий канал. Очікуйте нову інформацію через утіліти.")

$(trans "Дякуємо за довіру. Слава Україні!")
EOF
)"

  wrap_dialog_text "$notice"
}

main_menu() {
  menu_items=("$(trans "Статус атаки")" "$(trans "Розширення портів")" "DDOS" "$(trans "Налаштування безпеки")")
  show_main_menu_notice_if_needed

  if is_compact_dialog_screen; then
    res=$(display_menu "$(trans "Головне меню")" --text "$(main_menu_notice_compact)" "${menu_items[@]}")
  else
    res=$(display_menu "$(trans "Головне меню")" --text "$(main_menu_notice_full)" "${menu_items[@]}")
  fi

  case "$res" in
    "$(trans "Статус атаки")")
      get_ddoss_status
      main_menu
      ;;
    "$(trans "Розширення портів")")
      extend_ports
      main_menu
      ;;
    "DDOS")
      ddos
      ;;
    "$(trans "Налаштування безпеки")")
      security_settings
      ;;
  esac
}
