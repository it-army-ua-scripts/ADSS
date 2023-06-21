get_distribution() {
	lsb_dist=""

	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
		lsb_dist=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')
	fi

	echo $lsb_dist
}

validate_os() {
  operation_systems=("ubuntu" "fedora" "debian" "centos")

  os_exists=0

  for element in "${operation_systems[@]}"; do
    if [[ "$element" == "$(get_distribution)" ]]; then
      os_exists=1
      break
    fi
  done

  if [[ os_exists -eq 0 ]]; then
    dialog --keep-tite --msgbox 'Операційну систему не знайдено. Доступні ubuntu, fedora, debian, centos' 0 0
    clear
    exit 0
  fi
}