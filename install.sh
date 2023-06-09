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
              tmp_folder="/tmp/itarmy"

              sudo mkdir -p "$tmp_folder"
              sudo mv "$WORKING_DIR/services/EnvironmentFile" "$tmp_folder"
              MOVES=("db1000n" "distress" "mhddos_proxy_linux")
              for MOVE in "${!MOVES[@]}"; do
               sudo mv "$WORKING_DIR/${MOVES[MOVE]}" "$tmp_folder" 2>/dev/null
              done

              sudo rm -rf "$WORKING_DIR"
              sudo mkdir -p "$WORKING_DIR"
              sudo chown $(whoami) "$WORKING_DIR"
              git clone https://github.com/it-army-ua-scripts/ADSS.git "$WORKING_DIR"
              sudo cp "$tmp_folder/EnvironmentFile" "$WORKING_DIR/services" 2>/dev/null
              sudo cp "$tmp_folder"/* "$WORKING_DIR" 2>/dev/null
              sudo rm -rf "$tmp_folder"

              SERVICES=('mhddos' 'distress' 'db1000n')
              for SERVICE in "${!SERVICES[@]}"; do
                source "${WORKING_DIR}/utils/${SERVICES[SERVICE]}.sh"
                export SCRIPT_DIR="${WORKING_DIR}/"
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
