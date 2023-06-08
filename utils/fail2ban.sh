#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_fail2ban() {
    echo -e "${GREEN}Встановлюємо Fail2ban${NC}"

    case $(get_distribution) in
            debian | ubuntu)
                sudo apt-get update -y
                sudo apt-get install -y fail2ban
                echo -e "${GREEN}Fail2ban успішно встановлено${NC}"
            ;;
            fedora)
                sudo dnf update -y
                sudo dnf upgrade -y
                sudo dnf install -y fail2ban
                echo -e "${GREEN}Fail2ban успішно встановлено${NC}"
            ;;
            centos)
                sudo yum update -y
                sudo yum install -y epel-release
                sudo yum install -y fail2ban
                echo -e "${GREEN}Fail2ban успішно встановлено${NC}"
            ;;
            *)
               echo -e "${RED}Fail2ban - операційну систему не знайдено${NC}"
            ;;
    esac
}

configure_fail2ban(){
  if [[ ! -e "/etc/fail2ban" ]]; then
    echo -e "${RED}Fail2ban не встановлений, будь ласка встановіть і спробуйте знову${NC}"
  else
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
    echo -e "${GREEN}Fail2ban успішно налаштовано${NC}"
  fi
}