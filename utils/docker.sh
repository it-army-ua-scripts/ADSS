#!/bin/bash

source "${SCRIPT_DIR}/utils/definitions.sh"

install_docker() {
    echo -e "${GREEN}Встановлюємо докер${NC}"

    case $(get_distribution) in
            debian)
                curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                sudo chmod a+r /etc/apt/keyrings/docker.gpg
                echo \
                  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
                  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
                  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo systemctl start docker
                echo -e "${GREEN}Докер успішно встановлено${NC}"
            ;;
            ubuntu)
                sudo mkdir -m 0755 -p /etc/apt/keyrings
                curl  -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
                echo \
                  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt-get update -y
                sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo systemctl start docker
                echo -e "${GREEN}Докер успішно встановлено${NC}"
            ;;
            fedora)
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager \
                    --add-repo \
                    https://download.docker.com/linux/fedora/docker-ce.repo
                sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                sudo systemctl start docker
                echo -e "${GREEN}Докер успішно встановлено${NC}"
            ;;

            centos)
                sudo yum install -y yum-utils
                sudo yum-config-manager \
                    --add-repo \
                    https://download.docker.com/linux/centos/docker-ce.repo
                sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
                sudo systemctl start docker
                echo -e "${GREEN}Докер успішно встановлено${NC}"
            ;;
            *)
                echo -e "${RED}Docker - операційну систему не знайдено${NC}"
            ;;
    esac
}
