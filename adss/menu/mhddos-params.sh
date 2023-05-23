#!/bin/bash

initiate() {
    declare -A params;
    declare langs;

    read -p "Юзер ІД: " user_id

    if [[ -z "$user_id" ]]; then
      user_id=" "
    fi

    params[user-id]=$user_id
    read -p "Мова (ua | en | es | de | pl | it): " lang

    languages=("ua" "en" "es" "de" "pl" "it")
    while [[ ! "${languages[*]}" =~ "$lang" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Мова (ua | en | es | de | pl | it): " lang
    done

    params[lang]=$lang

    read -p "Кількість копій (auto | X): " copies

    while ! [[ $copies =~ ^[0-9]+$ || "$copies" == "auto" ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Кількість копій (auto | X): " copies
    done

    params[copies]=$copies
    read -p "VPN (false | true): " vpn

     while ! [[ $vpn == false || $vpn == true ]]
      do
        echo "Будь ласка введіть правильні значення"
        read -p "VPN (false | true): " vpn
      done

    params[vpn]=$vpn

    if [[ $vpn == true ]]; then
      read -p "VPN percents (1-100): " vpn_percents

      while (( $vpn_percents < 1 || $vpn_percents > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "VPN percents (1-100): " vpn_percents
      done

      params[vpn-percents]=$vpn_percents
    else
      params[vpn-percents]=" "
    fi


    read -p "Threads: " threads

    while ! [[ $threads =~ ^[0-9]+$ ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Threads: " threads
    done

    params[threads]=$threads

    read -p "Проксі (шлях до файлу або веб-ресурсу): " proxies
    proxies=$(echo $proxies  | sed 's/\//\\\//g')

    if [[ -z "$proxies" ]]; then
      proxies=" "
    fi

    params[proxies]=$proxies

    source "${SCRIPT_DIR}/utils/mhddos.sh"

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"

    	  if [[ -n "$value" ]]; then
    	    write_variable "$i" "$value"
    	  fi
    done
    regenerate_service_file
    echo -e "${GREEN}Успішно виконано${NC}"
}
