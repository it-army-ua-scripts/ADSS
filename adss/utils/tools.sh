#!/bin/bash

install_tools() {

    source "${SCRIPT_DIR}/utils/definitions.sh"

    sudo "$(get_package_manager)" update -y
    sudo "$(get_package_manager)" install -y \
        zip \
        unzip \
        gnupg \
        ca-certificates \
        curl
}
