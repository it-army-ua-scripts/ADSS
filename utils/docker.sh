#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_docker() {
  case $(get_distribution) in
          debian)
              adss_dialog "Встановлюємо докер"
              install() {
                 sudo apt-get update -y
                 sudo apt-get install ca-certificates curl gnupg -y
                 sudo install -m 0755 -d /etc/apt/keyrings
                 curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                 sudo chmod a+r /etc/apt/keyrings/docker.gpg
                 echo \
                    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
                  sudo apt-get update -y
                  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                  sudo systemctl start docker
              }
              install > /dev/null 2>&1
              confirm_dialog "Докер успішно встановлено"
          ;;
          fedora)
              adss_dialog "Встановлюємо докер"
              install() {
                  sudo dnf install -y dnf-plugins-core
                  sudo dnf config-manager \
                      --add-repo \
                      https://download.docker.com/linux/fedora/docker-ce.repo
                  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                  sudo systemctl start docker
              }

              install > /dev/null 2>&1
              confirm_dialog "Докер успішно встановлено"
          ;;

          centos)
              adss_dialog "Встановлюємо докер"
              install() {
                 sudo yum install -y yum-utils
                  sudo yum-config-manager \
                      --add-repo \
                      https://download.docker.com/linux/centos/docker-ce.repo
                  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                  sudo systemctl start docker
              }
              install > /dev/null 2>&1
              confirm_dialog "Докер успішно встановлено"
          ;;
          *)
              adss_dialog "Встановлюємо докер"
              install() {
                  sudo mkdir -m 0755 -p /etc/apt/keyrings
                  curl  -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                  echo \
                    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                  sudo apt-get update -y
                  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                  sudo systemctl start docker
              }
              install > /dev/null 2>&1
              confirm_dialog "Докер успішно встановлено"
          ;;
  esac
}
