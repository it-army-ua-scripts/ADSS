#!/bin/bash

install_fail2ban() {
  adss_dialog "$(trans "Встановлюємо Fail2ban")"
  install() {
    sudo pacman -Sy fail2ban --noconfirm
  }
  install >/dev/null 2>&1

  confirm_dialog "$(trans "Fail2ban успішно встановлено")"
}

fail2ban_is_active() {
  if systemctl is-active --quiet fail2ban; then
    return 1
  else
    return 0
  fi
}
enable_fail2ban() {
  sudo systemctl enable fail2ban >/dev/null 2>&1
  sudo systemctl start fail2ban >/dev/null 2>&1
  confirm_dialog "$(trans "Fail2ban успішно увімкнено")"
}
disable_fail2ban() {
  sudo systemctl disable fail2ban >/dev/null 2>&1
  sudo systemctl stop fail2ban >/dev/null 2>&1
  confirm_dialog "$(trans "Fail2ban успішно вимкнено")"
}

fail2ban_installed() {
  if [[ ! -e "/etc/fail2ban" ]]; then
    return 0
  else
    return 1
  fi
}

configure_fail2ban() {
  fail2ban_installed
  if [[ $? == 0 ]]; then
    confirm_dialog "$(trans "Fail2ban не встановлений, будь ласка встановіть і спробуйте знову")"
  else
    adss_dialog "$(trans "Налаштовуємо Fail2ban")"
    configure() {
      sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
      sudo bash -c "echo '
        [ssh]
        enabled = true
        port 	= ssh
        filter = sshd
        action = iptables[name=sshd, port=ssh, protocol=tcp]
        logpath = %(sshd_log)s
        backend = %(sshd_backend)s
        maxretry = 3
        bantime = 600' >> /etc/fail2ban/jail.local"

      sudo /bin/systemctl restart fail2ban.service
    }
    configure >/dev/null 2>&1
    confirm_dialog "$(trans "Fail2ban успішно налаштовано")"
  fi
}
