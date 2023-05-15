#!/bin/bash

install_mhddos() {

    if [ ! -d $WORKING_DIR ]; then
        sudo mkdir $WORKING_DIR
    fi

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо MHDDOS${NC}"
	
    OSARCH=$(uname -m)

    case "$OSARCH" in
      aarch64*)
        sudo curl -Lo mhddos_proxy_linux_arm64 https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_arm64
        sudo chmod +x mhddos_proxy_linux_arm64
      ;;

      x86_64*)
        sudo curl -Lo mhddos_proxy_linux https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux
        sudo chmod +x mhddos_proxy_linux
      ;;

      i386* | i686*)
        echo "Відсутня реалізація MHDDOS для x86 архітектури, що відповідає 32-бітній розрядності";
        exit 1
      ;;

      *)
        echo "Неможливо визначити розрядность операційної системи";
        exit 1
      ;;
    esac
	
    echo -e "${GREEN}MHDDOS успішно встановлено${NC}"
}
