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

install_docker() {
    echo -e "${GREEN}Встановлюємо докер${NC}"

    case "$lsb_dist" in
            debian)
                sudo apt-get update -y
                sudo apt-get install -y \
                    ca-certificates \
                    curl \
                    gnupg
                sudo install -m 0755 -d /etc/apt/keyrings
                curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
                echo \
                  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            ubuntu)
                sudo apt-get update -y
                sudo apt-get install -y \
                    ca-certificates \
                    curl \
                    gnupg
                sudo mkdir -m 0755 -p /etc/apt/keyrings
                curl  -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            fedora)
                sudo dnf  install -y dnf-plugins-core
                sudo dnf config-manager \
                    --add-repo \
                    https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;

            centos)
                sudo yum install -y yum-utils
                sudo yum-config-manager \
                    --add-repo \
                    https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo chmod 666 /var/run/docker.sock
            ;;
    esac
}

docker --help &> /dev/null
if [ $? -ne 0 ]; then
    install_docker

    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl start docker
fi

#bit=$(uname --m)


