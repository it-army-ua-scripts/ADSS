#!/bin/bash

check_updates() {
  source "/etc/environment"
  if [ -z "$ADSS_DEPLOYMENT_VERSION" ]; then
      prepare_for_update
  else
      timestamp=$(date +%s)
      diff=$((timestamp - ADSS_DEPLOYMENT_VERSION))
      one_hour=300
      if [[ $diff -gt $one_hour  ]];then
        prepare_for_update
      fi
  fi
}
prepare_for_update() {
  echo -e "$(trans "${GREEN}Перевіряємо наявленість оновлень${NC}")"
  current_version=$(<"$SCRIPT_DIR"/version.txt)
  current_version=${current_version//[$'\t\r\n']}
  remote_version=$(curl -s 'https://raw.githubusercontent.com/it-army-ua-scripts/ADSS/main/version.txt')

  if [[ "$current_version" < "$remote_version" ]]; then
      update_adss
  fi
  write_version $(date +%s)
  sleep 2
}
write_version() {
  env_file="/etc/environment"
  sudo sed -i '/ADSS_DEPLOYMENT_VERSION/d' $env_file
  echo "ADSS_DEPLOYMENT_VERSION=\"$1\"" | sudo tee -a $env_file >/dev/null 2>&1
  source $env_file
}

update_adss() {
  echo -e "$(trans "${GREEN}Оновляємо ADSS${NC}")"
  cd $SCRIPT_DIR && \
  git checkout services/db1000n.service >/dev/null 2>&1 && \
  git checkout services/distress.service >/dev/null 2>&1 && \
  git checkout services/mhddos.service >/dev/null 2>&1 && \
  git pull --all

  SERVICES=('mhddos' 'distress' 'db1000n')
  for SERVICE in "${!SERVICES[@]}"; do
    source "${SCRIPT_DIR}/utils/${SERVICES[SERVICE]}.sh"
    regenerate_"${SERVICES[SERVICE]}"_service_file
  done
  echo -e "$(trans "${GREEN}ADSS успішно оновлено${NC}")"
}