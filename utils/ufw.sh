#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_ufw(){
    case $(get_distribution) in
            ubuntu | debian)
                echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"
                sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo /bin/systemctl restart ufw.service
            ;;
            fedora)
                echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo /bin/systemctl restart ufw.service
            ;;

            centos)
                echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo yum install epel-release -y && sudo yum install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo /bin/systemctl restart ufw.service
            ;;
            *)
                echo -e "${RED}Ufw - операційну систему не знайдено${NC}"
            ;;
    esac
}

configure_ufw(){
  if [[ ! $(sudo ufw status 2>/dev/null) ]]; then
    echo -e "${RED}Ufw не встановлений, будь ласка встановіть і спробуйте знову${NC}"
  else
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow 22
    sudo ufw --force enable
    echo "Фаєрвол UFW налаштовано і активовано"
  fi
}