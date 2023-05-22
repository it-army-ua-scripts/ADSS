#!/bin/bash

install_distress() {

    sudo mkdir -p $WORKING_DIR

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо Distress${NC}"

    OSARCH=$(uname -m)

    case "$OSARCH" in
      aarch64*)
        sudo curl -Lo distress_aarch64-unknown-linux-musl https://github.com/Yneth/distress-releases/releases/latest/download/distress_aarch64-unknown-linux-musl
        sudo chmod +x distress_aarch64-unknown-linux-musl
      ;;
	  
      x86_64*)
        sudo curl -Lo distress_x86_64-unknown-linux-musl https://github.com/Yneth/distress-releases/releases/latest/download/distress_x86_64-unknown-linux-musl
        sudo chmod +x distress_x86_64-unknown-linux-musl
      ;;
	  
      i386* | i686*)
        sudo curl -Lo distress_i686-unknown-linux-musl https://github.com/Yneth/distress-releases/releases/latest/download/distress_i686-unknown-linux-musl
        sudo chmod +x distress_i686-unknown-linux-musl
      ;;
	  
      *)
        echo "Неможливо визначити розрядность операційної системи";
        exit 1
      ;;
    esac

    echo -e "${GREEN}Distress успішно встановлено${NC}"
}
