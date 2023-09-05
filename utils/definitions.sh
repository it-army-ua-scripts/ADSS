get_distribution() {
  lsb_dist=""

  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
    lsb_dist=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')
  fi

  echo $lsb_dist
}
