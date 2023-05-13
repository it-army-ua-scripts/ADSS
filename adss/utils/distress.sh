#!/bin/bash

install_distress() {

    if [ ! -d $WORKING_DIR ]; then
        sudo mkdir $WORKING_DIR
    fi

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо Distress${NC}"

    sudo curl -Lo distress_x86_64-unknown-linux-musl https://github.com/Yneth/distress-releases/releases/latest/download/distress_x86_64-unknown-linux-musl
    sudo chmod +x distress_x86_64-unknown-linux-musl

    echo -e "${GREEN}Distress успішно встановлено${NC}"
}
