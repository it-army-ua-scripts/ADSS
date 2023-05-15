#!/bin/bash

install_db1000n() {

    if [ ! -d $WORKING_DIR ]; then
        sudo mkdir $WORKING_DIR
    fi

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо DB1000N${NC}"

    OSARCH=$(uname -m)

    case "$OSARCH" in
      x86_64* | aarch64*)
        sudo curl -Lo db1000n_linux_amd64.tar.gz  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_amd64.tar.gz
        sudo tar -xf db1000n_linux_amd64.tar.gz
        sudo rm db1000n_linux_amd64.tar.gz
      ;;

      i386*)
        sudo curl -Lo db1000n_linux_386.zip  https://github.com/Arriven/db1000n/releases/latest/download/db1000n_linux_386.zip
        sudo unzip db1000n_linux_386.zip
        sudo rm db1000n_linux_386.zip
      ;;

      *)
          echo "Неможливо перевірити бітність операційної системи";
          exit 1
      ;;
    esac

    echo -e "${GREEN}DB1000N успішно встановлено${NC}"
}
