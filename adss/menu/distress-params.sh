#!/bin/bash

initiate() {
    declare -A params;
    declare langs;

    read -p "Юзер ІД: " user_id

    if [[ -z "$user_id" ]]; then
      user_id=" "
    fi

    params[user_id]=$user_id
    

    read -p "Відсоткове співвідношення використання власноъ IP адреси (0-100): " use_my_ip

      while (( $use_my_ip < 0 || $use_my_ip > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "Відсоткове співвідношення використання власноъ IP адреси (0-100): " use_my_ip
      done

    params[use_my_ip]=$use_my_ip


    read -p "Кількість підключень Tor (0-100): " use_tor

      while (( $use_tor < 0 || $use_tor > 100 ))
      do
        echo "Будь ласка введіть правильні значення"
        read -p "Кількість підключень Tor (0-100): " use_tor
      done

    params[use_tor]=$use_tor


    read -p "Кількість створювачів завдань (4096): " concurrency

    while ! [[ $concurrency =~ ^[0-9]+$ ]]
    do
      echo "Будь ласка введіть правильні значення"
      read -p "Кількість створювачів завдань (4096): " concurrency
    done

    params[concurrency]=$concurrency
	

    source "${SCRIPT_DIR}/utils/distress.sh"

    for i in "${!params[@]}"; do
    	  value="${params[$i]}"

    	  if [[ -n "$value" ]]; then
    	    write_variable "$i" "$value"
    	  fi
    done
    regenerate_service_file
    echo -e "${GREEN}Успішно виконано${NC}"
}
