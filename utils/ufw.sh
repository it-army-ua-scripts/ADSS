#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"
install_ufw() {
  case $(get_distribution) in
  fedora | rocky)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo rc-service firewalld stop
      sudo rc-update del firewalld
      sudo dnf install ufw -y && sudo ufw disable
      sudo /bin/rc-service ufw.service restart
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  ol)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo dnf install epel-release -y
      sudo rc-service firewalld stop
      sudo rc-update del firewalld
      sudo dnf install ufw -y && sudo ufw disable
      sudo /bin/rc-service ufw.service restart
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  *)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
      sudo /bin/rc-service ufw.service restart
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  esac
}
ufw_is_active() {
  if rc-service is-active --quiet ufw; then
    return 1
  else
    return 0
  fi
}
enable_ufw() {
  sudo rc-update add ufw  >/dev/null 2>&1
  sudo rc-service ufw start  >/dev/null 2>&1
  confirm_dialog "$(trans "UFW успішно увімкнено")"
}
disable_ufw() {
  sudo rc-update del ufw  >/dev/null 2>&1
  sudo rc-service ufw stop  >/dev/null 2>&1
  confirm_dialog "$(trans "UFW успішно вимкнено")"
}
ufw_installed() {
  if [[ ! $(sudo ufw status 2>/dev/null) ]]; then
    return 0
  else
    return 1
  fi
}
configure_ufw() {
  ufw_installed
  if [[ $? == 0 ]]; then
    confirm_dialog "$(trans "UFW не встановлений, будь ласка встановіть і спробуйте знову")"
  else
    adss_dialog "$(trans "Налаштовуємо UFW фаєрвол")"
    configure() {
      sudo ufw default deny incoming
      sudo ufw default allow outgoing
      sudo ufw allow 22
      sudo ufw --force enable
    }
    configure >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW налаштовано і активовано")"
  fi
}
