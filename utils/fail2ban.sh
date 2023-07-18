#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_fail2ban() {
  case $(get_distribution) in
          fedora | rocky)
             adss_dialog "$(trans "Встановлюємо Fail2ban")"
             install() {
                sudo dnf update -y
                sudo dnf upgrade -y
                sudo dnf install -y fail2ban
             }
             install > /dev/null 2>&1
             confirm_dialog "$(trans "Fail2ban успішно встановлено")"
          ;;
          centos)
               adss_dialog "$(trans "Встановлюємо Fail2ban")"
               install() {
                   sudo yum update -y
                   sudo yum install -y epel-release
                   sudo yum install -y fail2ban
               }
               install > /dev/null 2>&1
               confirm_dialog "$(trans "Fail2ban успішно встановлено")"
          ;;
          *)
              adss_dialog "$(trans "Встановлюємо Fail2ban")"
              install() {
                 sudo apt-get update -y
                 sudo apt-get install -y fail2ban
              }
              install > /dev/null 2>&1
              confirm_dialog "$(trans "Fail2ban успішно встановлено")"
          ;;
  esac
}

configure_fail2ban(){
  if [[ ! -e "/etc/fail2ban" ]]; then
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
    configure > /dev/null 2>&1
    confirm_dialog "$(trans "Fail2ban успішно налаштовано")"
  fi
}