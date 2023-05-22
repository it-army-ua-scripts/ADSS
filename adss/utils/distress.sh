#!/bin/bash

install_distress() {

    sudo mkdir -p $WORKING_DIR

    cd $WORKING_DIR
    echo -e "${GREEN}Встановлюємо Distress${NC}"

    OSARCH=$(uname -m)
    package=''
    case "$OSARCH" in
      aarch64*)
        package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_aarch64-unknown-linux-musl
      ;;
	  
      x86_64*)
        package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_x86_64-unknown-linux-musl
      ;;
	  
      i386* | i686*)
        package=https://github.com/Yneth/distress-releases/releases/latest/download/distress_i686-unknown-linux-musl
      ;;
	  
      *)
        echo "Неможливо визначити розрядность операційної системи";
        exit 1
      ;;
    esac

	sudo curl -Lo distress "$package"
    sudo chmod +x distress
    regenerate_service_file
    sudo ln -sf  "$SCRIPT_DIR"/services/distress.service /etc/systemd/system/distress.service

    echo -e "${GREEN}Distress успішно встановлено${NC}"
}

regenerate_service_file() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)

  start="ExecStart=/opt/itarmy/distress"

  while read -r line
  do
    key=$(echo "$line"  | cut -d '=' -f1)
    value=$(echo "$line" | cut -d '=' -f2)

    if [[ "$key" = "[distress]" || "$key" = "[/distress]" ]]; then
      continue
    fi
    if [[ "$value" ]]; then
      start="$start --$key $value"
    fi
  done <<< "$lines"
  start=$(echo $start  | sed 's/\//\\\//g')

  sed -i  "s/ExecStart=.*/$start/g" ${SCRIPT_DIR}/services/distress.service

  sudo systemctl daemon-reload
}

get_variable() {
  lines=$(sed -n "/\[distress\]/,/\[\/distress\]/p" ${SCRIPT_DIR}/services/EnvironmentFile)
  variable=$(echo "$lines" | grep "$1=" | cut -d '=' -f2)
  echo "$variable"
}

write_variable() {
  sed -i "/\[distress\]/,/\[\/distress\]/s/$1=.*/$1=$2/g" ${SCRIPT_DIR}/services/EnvironmentFile
}
