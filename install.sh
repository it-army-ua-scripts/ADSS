#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
WORKING_DIR="/opt/itarmy"
if [ -r /etc/os-release ]; then
			  PACKAGE_MANAGER=""
        lsb_dist=""
        lsb_dist="$(. /etc/os-release && echo "$ID")"
        lsb_dist=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')

        case "$lsb_dist" in
                debian | ubuntu)
                    PACKAGE_MANAGER="apt-get"
                ;;
                fedora)
                    PACKAGE_MANAGER="dnf"
                ;;
                centos)
                    PACKAGE_MANAGER="yum"
                ;;
        esac

        if [[ ! -z "$PACKAGE_MANAGER" ]]; then
	        TOOLS=('zip' 'unzip' 'gnupg' 'ca-certificates' 'curl' 'git' 'dialog')
          sudo "$PACKAGE_MANAGER" update -y
          for i in "${!TOOLS[@]}"; do
            sudo "$PACKAGE_MANAGER" install -y ${TOOLS[i]}
          done
          if [[ -d "$WORKING_DIR" ]];then
             source "${WORKING_DIR}/utils/updater.sh"
             export SCRIPT_DIR="${WORKING_DIR}/"
             update_adss
          else
             sudo mkdir -p "$WORKING_DIR"
             sudo chown $(whoami) "$WORKING_DIR"
             git clone https://github.com/it-army-ua-scripts/ADSS.git "$WORKING_DIR"
          fi

          sudo ln -sf  "$WORKING_DIR/bin/adss" /usr/local/bin/adss
        else
          echo -e "${RED}Менеджер пакетів не знайдено${NC}"
        fi
else
  echo -e "${RED}Неможливо визначити операційну систему${NC}"
fi
