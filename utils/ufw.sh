#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"
install_ufw() {
  case $(get_distribution) in
  fedora | rocky)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo systemctl stop firewalld
      sudo systemctl disable firewalld
      sudo dnf install ufw -y && sudo ufw disable
      sudo /bin/systemctl restart ufw.service
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  ol)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo dnf install epel-release -y
      sudo systemctl stop firewalld
      sudo systemctl disable firewalld
      sudo dnf install ufw -y && sudo ufw disable
      sudo /bin/systemctl restart ufw.service
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  *)
    adss_dialog "$(trans "Встановлюємо UFW фаєрвол")"
    install() {
      sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
      sudo /bin/systemctl restart ufw.service
    }
    install >/dev/null 2>&1
    confirm_dialog "$(trans "Фаєрвол UFW встановлено і деактивовано")"
    ;;
  esac
}
ufw_is_active() {
  if systemctl is-active --quiet ufw; then
    return 1
  else
    return 0
  fi
}
enable_ufw() {
  sudo systemctl enable ufw >/dev/null 2>&1
  sudo systemctl start ufw >/dev/null 2>&1
  confirm_dialog "$(trans "UFW успішно увімкнено")"
}
disable_ufw() {
  sudo systemctl disable ufw >/dev/null 2>&1
  sudo systemctl stop ufw >/dev/null 2>&1
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
