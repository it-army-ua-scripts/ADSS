init() {

    menu=$1
    selected_index=0

  display_menu() {
      clear

      for i in "${!menu[@]}"; do
          if [ $i -eq $selected_index ]; then
              echo -e "${GREEN}>> ${menu[$i]}${NC}"
          else
              echo "   ${menu[$i]}"
          fi
      done
  }

  while true; do
      display_menu

      read -s -n 1 key

      case "$key" in
          "A")
              selected_index=$((selected_index - 1))
              if [ $selected_index -lt 0 ]; then
                  selected_index=$(( ${#menu[@]} - 1 ))
              fi
              ;;
          "B")
              selected_index=$((selected_index + 1))
              if [ $selected_index -ge ${#menu[@]} ]; then
                  selected_index=0
              fi
              ;;
          '')
  #            selected_item="${menu[$selected_index]}"
              return $selected_index
              break
              ;;
      esac
  done
}

