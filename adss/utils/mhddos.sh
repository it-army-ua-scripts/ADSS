#!/bin/bash

install_mhddos() {

    if [ ! -d $WORKING_DIR ]; then
        sudo mkdir $WORKING_DIR
    fi

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо MHDDOS${NC}"
    sudo curl -Lo mhddos_proxy_linux https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_arm64
    echo -e "${GREEN}MHDDOS успішно встановлено${NC}"
}
