get_package_manager() {
    source "${SCRIPT_DIR}/utils/os-definition.sh"
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
