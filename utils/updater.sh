#!/bin/bash

check_updates() {
  timestamp=$(date +%s)
  if [[ -z "$ADSS_DEPLOYMENT_VERSION" ]]; then
    export ADSS_DEPLOYMENT_VERSION=$timestamp
  fi
  diff=$((timestamp - ADSS_DEPLOYMENT_VERSION))
  one_hour=3600
  need_to_update=$(echo "$diff > $one_hour" | bc -l)
  if [[ $need_to_update -eq 1  ]];then
    echo -e "${GREEN}Перевіряємо наявленість оновлень${NC}"
    current_version=$(<"$SCRIPT_DIR"/version.txt)
    current_version=${current_version//[$'\t\r\n']}
    remote_version=$(curl -s URL_файлу)
    if [[ $current_version -gt $remote_version  ]];then
        update_adss
        export ADSS_DEPLOYMENT_VERSION=$(date +%s)
    fi
  fi
}

update_adss() {
  echo -e "${GREEN}Оновляємо ADSS${NC}"
  service_dir="${SCRIPT_DIR}/services"
  service_dir_tmp="${SCRIPT_DIR}/services_tmp"
  cd $SCRIPT_DIR && \
  sudo mv "$service_dir" "$service_dir_tmp" && \
  git pull --all && \
  sudo rm -rf "$service_dir" && \
  sudo mv "$service_dir_tmp" "$service_dir"
  echo -e "${GREEN}ADSS успішно оновлено${NC}"
}