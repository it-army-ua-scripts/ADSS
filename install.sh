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
          if [[ -d "$WORKING_DIR" ]]; then
            echo -e "${GREEN}Програма вже встановлена${NC}"
          else
            sudo mkdir -p "$WORKING_DIR"
            sudo chown $(whoami) "$WORKING_DIR"
            git clone https://github.com/it-army-ua-scripts/ADSS.git "$WORKING_DIR"

            sudo ln -sf  "$WORKING_DIR/adss/bin/adss" /usr/local/bin/adss
          fi
        else
          echo -e "${RED}Неможливо визначити пакунок${NC}"
        fi
else
  echo -e "${RED}Неможливо визначити операційну систему${NC}"
fi