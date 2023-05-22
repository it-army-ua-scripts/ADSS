get_package_manager() {
    source "${SCRIPT_DIR}/utils/definitions.sh"
	  PACKAGE_MANAGER=""

    case $(get_distribution) in
            debian | ubuntu)
                PACKAGE_MANAGER="apt-get"
            ;;
            fedora)
                PACKAGE_MANAGER="dnf"
            ;;
            centos)
                PACKAGE_MANAGER="yum"
            ;;
    esac

    echo "$PACKAGE_MANAGER"
}

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
