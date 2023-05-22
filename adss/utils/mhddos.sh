#!/bin/bash

install_mhddos() {

    sudo mkdir -p $WORKING_DIR

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо MHDDOS${NC}"
	
    OSARCH=$(uname -m)
    package=''
    case "$OSARCH" in
      aarch64*)
        package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux_arm64
      ;;

      x86_64*)
        package=https://github.com/porthole-ascend-cinnamon/mhddos_proxy_releases/releases/latest/download/mhddos_proxy_linux
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

	  sudo curl -Lo mhddos_proxy_linux "$package"
    sudo chmod +x mhddos_proxy_linux
    regenerate_service_file
    sudo ln -sf  "$SCRIPT_DIR"/services/mhddos.service /etc/systemd/system/mhddos.service

    echo -e "${GREEN}MHDDOS успішно встановлено${NC}"
}

regenerate_service_file() {
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/mhddos_proxy_linux"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[mhddos]" || "$key" = "[/mhddos]" ]]; then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" ${SCRIPT_DIR}/services/mhddos.service

  sudo systemctl daemon-reload
}

get_variable() {
  lines=$(sed -n "/\[mhddos\]/,/\[\/mhddos\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_variable() {
  sed -i "/\[mhddos\]/,/\[\/mhddos\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}
