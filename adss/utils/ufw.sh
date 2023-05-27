#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_ufw(){
    echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"

    case $(get_distribution) in
            ubuntu | debian)
                sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
            ;;
            fedora)
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
            ;;

            centos)
                echo "Деактивовуємо стандартний фаєрвол Firewalld"
                sudo systemctl stop firewalld
                sudo systemctl disable firewalld
                sudo yum install epel-release -y && sudo yum install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
            ;;
    esac

    sudo /bin/systemctl restart ufw.service
}

is_installed() {
  systemctl is-active --quiet ufw
  echo $?
}

configure_ufw(){
  if [[ ! $(is_installed) ]]; then
    install_ufw
  fi

   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow 22
   sudo ufw --force enable
   echo "Фаєрвол UFW налаштовано і активовано"
}