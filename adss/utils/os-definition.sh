get_distribution() {
	lsb_dist=""

	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	else
	    echo "Операційну систему не знайдено"
	    exit 1
	fi
	
    lsb_dist=$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')

	echo $lsb_dist
}
