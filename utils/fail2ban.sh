#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_fail2ban() {
  case $(get_distribution) in
          debian | ubuntu | pop)
              adss_dialog "Встановлюємо Fail2ban"
              install() {
                 sudo apt-get update -y
                 sudo apt-get install -y fail2ban
              }
              install > /dev/null 2>&1
              confirm_dialog "Fail2ban успішно встановлено"
          ;;
          fedora)
             adss_dialog "Встановлюємо Fail2ban"
             install() {
                sudo dnf update -y
                sudo dnf upgrade -y
                sudo dnf install -y fail2ban
             }
             install > /dev/null 2>&1
             confirm_dialog "Fail2ban успішно встановлено"
          ;;
          centos)
               adss_dialog "Встановлюємо Fail2ban"
               install() {
                   sudo yum update -y
                   sudo yum install -y epel-release
                   sudo yum install -y fail2ban
               }
               install > /dev/null 2>&1
               confirm_dialog "Fail2ban успішно встановлено"
          ;;
          *)
            confirm_dialog "[Fail2ban] - операційну систему не знайдено"
          ;;
  esac
}

configure_fail2ban(){
  if [[ ! -e "/etc/fail2ban" ]]; then
    confirm_dialog "Fail2ban не встановлений, будь ласка встановіть і спробуйте знову"
  else
    adss_dialog "Налаштовуємо Fail2ban"
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
    confirm_dialog "Fail2ban успішно налаштовано"
  fi
}