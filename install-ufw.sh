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

install_ufw(){
    echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"

    case "$lsb_dist" in
            ubuntu | debian)
                sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default deny incoming
                sudo ufw default allow outgoing
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;
            fedora)
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default allow outgoing
                sudo ufw default deny incoming
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;

            centos)
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo dnf install epel-release -y && sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default allow outgoing
                sudo ufw default deny incoming
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;
    esac
}

install_ufw
