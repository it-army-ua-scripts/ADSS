#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
WORKING_DIR="/opt/itarmy/"
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
	        TOOLS=('zip' 'unzip' 'gnupg' 'ca-certificates' 'curl' 'git')

          toUpdate=true
          for i in "${!TOOLS[@]}"; do
            if ! which ${TOOLS[i]} >/dev/null; then
              if [[ "$toUpdate" == true ]];then
               sudo "$PACKAGE_MANAGER" update -y
               toUpdate=false
              fi
              sudo "$PACKAGE_MANAGER" install -y ${TOOLS[i]}
            fi
          done
	          if [[ -d "$WORKING_DIR" ]];then
	              sudo find . ! -path ""$WORKING_DIR"/services/EnvironmentFile" -delete &>/dev/null
	              git clone https://github.com/it-army-ua-scripts/ADSS.git "$WORKING_DIR"
	              SERVICES=('mhddos' 'distress' 'db1000n')
                for SERVICE in "${!SERVICES[@]}"; do
                  source "${WORKING_DIR}/utils/${SERVICES[SERVICE]}.sh"
                  regenerate_service_file
                done
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