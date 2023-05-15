#!/bin/bash

install_db1000n() {

    if [ ! -d $WORKING_DIR ]; then
        sudo mkdir $WORKING_DIR
    fi

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо DB1000N${NC}"

    OSARCH=$(uname -m)

    case "$OSARCH" in
      aarch64*)
        sudo curl -Lo db1000n_linux_arm64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_arm64.tar.gz
        sudo tar -xf db1000n_linux_arm64.tar.gz
        sudo chmod +x db1000n
        sudo rm db1000n_linux_arm64.tar.gz
      ;;

      x86_64*)
        sudo curl -Lo db1000n_linux_amd64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_amd64.tar.gz
        sudo tar -xf db1000n_linux_amd64.tar.gz
        sudo chmod +x db1000n
        sudo rm db1000n_linux_amd64.tar.gz
      ;;

      i386* | i686*)
        sudo curl -Lo db1000n_linux_386.zip  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_386.zip
        sudo unzip db1000n_linux_386.zip
        sudo chmod +x db1000n
        sudo rm db1000n_linux_386.zip
      ;;

      *)
          echo "Неможливо визначити розрядность операційної системи";
          exit 1
      ;;
    esac

    echo -e "${GREEN}DB1000N успішно встановлено${NC}"
}
