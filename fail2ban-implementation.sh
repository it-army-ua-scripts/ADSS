#!/bin/bash

get_distribution() {
	lsb_dist=""

	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi

	echo "$lsb_dist"
}

lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

GREEN='\033[0;32m'
NC='\033[0m'

install_fail2ban() {
    echo -e "${GREEN}Встановлюємо Fail2ban${NC}"

    case "$lsb_dist" in
            debian)
                sudo apt-get update -y
                sudo apt-get upgrade -y
                sudo apt-get install -y fail2ban
            ;;
            ubuntu)
                sudo apt-get update -y
                sudo apt-get install -y fail2ban
            ;;
            fedora)
                sudo dnf update -y
                sudo dnf upgrade -y
                sudo dnf install -y fail2ban
            ;;
            centos)
                sudo yum update -y
                sudo yum install -y epel-release
                sudo yum install -y fail2ban
            ;;
    esac
}

sudo service fail2ban status &> /dev/null
if [ $? -ne 0 ]; then
    install_fail2ban
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sudo bash -c "echo '

[ssh]
enabled = true
port 	= ssh
filter = sshd
action = iptables[name=sshd, port=ssh, protocol=tcp]
logpath = /var/log/auth.log
maxretry = 3
bantime = 600' >> /etc/fail2ban/jail.local"
    sudo service fail2ban restart
    echo -e "${GREEN}Fail2ban успішно встановлено${NC}"
fi

#bit=$(uname --m)


