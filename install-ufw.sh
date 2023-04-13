
install_ufw(){
    echo -e "${GREEN}Встановлюємо UFW фаєрвол${NC}"

    case "$lsb_dist" in
            ubuntu | debian)
                sudo apt-get update -y && sudo apt-get install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default deny incoming
                sudo ufw default allow outgoing
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;
            fedora)
                sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default allow outgoing
                sudo ufw default deny incoming
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;

            centos)
                sudo dnf install epel-release -y && sudo dnf install ufw -y && sudo ufw disable
                echo "Фаєрвол UFW встановлено і деактивовано"
                sudo ufw default allow outgoing
                sudo ufw default deny incoming
                sudo ufw allow 22
                sudo ufw --force enable
                echo "Фаєрвол UFW налаштовано і активовано"
            ;;
    esac
}

install_ufw