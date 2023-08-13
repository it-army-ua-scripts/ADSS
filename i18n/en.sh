#!/bin/bash

declare -A localization=(
  ["Встановити докер"]="Install Docker"
  
  ["Неправильний вхідний параметр!"]="Invalid input parameter!"
  ["${RED}Не знайдено папку '$directory'.${NC}"]="${RED}'$directory' folder not found.${NC}"
  
  ["Вимкнути автозапуск MHDDOS"]="Disable autostart for MHDDOS"
  ["Увімкнути автозапуск MHDDOS"]="Enable autostart for MHDDOS"
  ["Вимкнути автозапуск DB1000N"]="Disable autostart for DB1000N"
  ["Увімкнути автозапуск DB1000N"]="Enable autostart for DB1000N"
  ["Вимкнути автозапуск DISTRESS"]="Disable autostart for DISTRESS"
  ["Увімкнути автозапуск DISTRESS"]="Enable autostart for DISTRESS"
  ["Повернутись назад"]="Go back"
  ["Налаштування автозапуску"]="Autostart settings"
  
  ["Зупиняємо атаку"]="Stopping the attack"
  ["Атака зупинена"]="Attack stopped"
  ["${GREEN}Запущено $service${NC}"]="${GREEN}$service$ started${NC}"
  ["${GRAY}Нажміть будь яку клавішу щоб продовжити${NC}"]="${GRAY}Press any key to continue${NC}"
  ["Немає запущених процесів"]="No processes running"
  ["Статус атаки"]="Attack status"
  ["Зупинити атаку"]="Stop an attack"
  ["Управління ддос інструментами"]="DDOS tool management"
  ["Встановлення ддос інструментів"]="Install DDOS tools"
  ["Управління ддос інструментами"]="Manage DDOS tools"

  ["${GREEN}Для збору особистої статистики та відображення у лідерборді на офіційному сайті.${NC}"]="${GREEN}To gather personal statistics and display on the leaderboard on the official website.${NC}"
  ["${GREEN}Надається Telegram ботом ${ORANGE}@itarmy_stat_bot${NC}${NC}"]="${GREEN}Provided by the Telegram bot ${ORANGE}@itarmy_stat_bot${NC}${NC}"
  ["${GREEN}Щоб пропустити, натисніть Enter${NC}"]="${GREEN}To skip, press Enter${NC}"

  ["Розширення портів"]="Port extension"
  ["Налаштування безпеки"]="Security settings"
  ["Головне меню"]="Main menu"
  ["Налаштування фаєрвола"]="Firewall settings"
  ["Налаштування захисту від брутфорса"]="Bruteforce protection settings"
  ["Вихід"]="Exit"
  ["Оберіть опцію:"]="Choose an option:"
  ["ДДОС інструменти не встановлено"]="No DDOS tools installed"

  ["Встановлення захисту"]="Install protection"
  ["Налаштування захисту"]="Protection settings"

  ["Налаштування безпеки"]="Security settings"
  ["DB1000N додано до автозавантаження"]="DB1000N added to autostart"
  ["DB1000N видалено з автозавантаження"]="DB1000N removed from autostart"
  ["MHDDOS додано до автозавантаження"]="MHDDOS added to autostart"
  ["MHDDOS видалено з автозавантаження"]="MHDDOS removed from autostart"
  ["DISTRESS додано до автозавантаження"]="DISTRESS added to autostart"
  ["DISTRESS видалено з автозавантаження"]="DISTRESS removed from autostart"
  ["DB1000N не встановлений, будь ласка встановіть і спробуйте знову"]="DB1000N is not installed, please install and try again"
  ["MHDDOS не встановлений, будь ласка встановіть і спробуйте знову"]="MHDDOS is not installed, please install and try again"
  ["DISTRESS не встановлений, будь ласка встановіть і спробуйте знову"]="DISTRESS is not installed, please install and try again"
  
  ["Зупинка DB1000N"]="Stop DB1000N"
  ["Запуск DB1000N"]="Start DB1000N"
  ["Зупинка MHDDOS"]="Stop MHDDOS"
  ["Запуск MHDDOS"]="Start MHDDOS"
  ["Зупинка DISTRESS"]="Stop DISTRESS"
  ["Запуск DISTRESS"]="Start DISTRESS"
  
  ["Налаштування DB1000N"]="DB1000N settings"
  ["Статус DB1000N"]="DB1000N status"
  ["Налаштування MHDDOS"]="MHDDOS settings"
  ["Статус MHDDOS"]="MHDDOS status"
  ["Налаштування DISTRESS"]="DISTRESS settings"
  ["Статус DISTRESS"]="DISTRESS status"

  ["Встановлюємо DB1000N"]="Installing DB1000N"
  ["DB1000N успішно встановлено"]="DB1000N installed successfully"
  ["Встановлюємо MHDDOS"]="Installing MHDDOS"
  ["MHDDOS успішно встановлено"]="MHDDOS installed successfully"
  ["Встановлюємо DISTRESS"]="Installing DISTRESS"
  ["DISTRESS успішно встановлено"]="DISTRESS installed successfully"
  
  ["Встановлюємо Docker"]="Installing Docker"
  ["Docker успішно встановлено"]="Docker installed successfully"
  
  ["Встановлюємо Fail2ban"]="Installing Fail2ban"
  ["Fail2ban успішно встановлено"]="Fail2ban installed successfully"
  ["Налаштовуємо Fail2ban"]="Setting Fail2ban"
  ["Fail2ban успішно налаштовано"]="Fail2ban set up successfully"
  ["Fail2ban не встановлений, будь ласка встановіть і спробуйте знову"]="Fail2ban is not installed, please install and try again"
  ["Увімкнути захист від брутфорсу"]="Enable brute force protection"
  ["Вимкнути захист від брутфорсу"]="Disable brute force protection"
  ["Fail2ban успішно увімкнено"]="Fail2ban successfully enabled"
  ["Fail2ban успішно вимкнено"]="Fail2ban successfully disabled"

  ["Встановлюємо UFW фаєрвол"]="Installing UFW firewall"
  ["Фаєрвол UFW встановлено і деактивовано"]="UFW firewall installed and deactivated"
  ["Фаєрвол UFW налаштовано і активовано"]="UFW firewall set up and activated"
  ["UFW не встановлений, будь ласка встановіть і спробуйте знову"]="UFW is not installed, please install and try again"
  ["Налаштовуємо UFW фаєрвол"]="Setting UFW firewall"  
  ["Увімкнути фаервол"]="Enable UFW firewall"
  ["Вимкнути фаервол"]="Disable UFW firewall"
  ["UFW успішно увімкнено"]="UFW successfully enabled"
  ["UFW успішно вимкнено"]="UFW successfully disabled"

  ["${GRAY}Залиште пустим якщо хочите видалити пераметри${NC}"]="${GRAY}Leave blank if you want to delete parameters${NC}"
  ["Автооновлення (1 | 0): "]="Autoupdate (1 | 0): "
  ["Будь ласка введіть правильні значення"]="Please enter the correct values"
  ["Проксі (шлях до файлу або веб-ресурсу): "]="Proxy (path to file or web resource): "
  ["Масштабування (1 | X): "]="Scaling (1 | X): "
  ["Список проксі у форматі ${ORANGE}protocol://ip:port${NC} або ${ORANGE}ip:port${NC}"]="List of proxies in ${ORANGE}protocol://ip:port${NC} or ${ORANGE}ip:port${NC} format"
  ["Укажіть протокол, якщо формат ${ORANGE}ip:port${NC}"]="Specify the protocol if the format is ${ORANGE}ip:port${NC}"
  ["Протокол проксі (socks5, socks4, http): "]="Proxy protocol (socks5, socks4, http): "

  ["Відсоткове співвідношення використання власної IP адреси (0-100): "]="Percentage of personal IP address usage (0-100): "
  ["Увімкнути UDP flood (1 | 0): "]="Enable UDP flood (1 | 0): "
  ["Кількість підключень Tor (0-100): "]="Number of Tor connections (0-100): "
  ["Кількість створювачів завдань (4096): "]="Number of task creators (4096): "

  ["Відсутня реалізація MHDDOS для x86 архітектури, що відповідає 32-бітній розрядності"]="There's no MHDDOS implementation for the x86 architecture that corresponds to the 32-bit variant"
  ["Неможливо визначити розрядность операційної системи"]="Unable to determine the operating system's bit depth"

  ["Юзер ІД: "]="User ID: "
  ["Мова (ua | en | es | de | pl | it): "]="Language (ua | en | es | de | pl | it): "
  ["Кількість копій (auto | X): "]="Number of copies (auto | X): "
  ["Успішно виконано"]="Execution successful"

  ["Порти успішно розширено"]="Ports successfully extended"
  ["Наразі всі порти розширено"]="All ports are currently extended"
  ["Не можливо виконати дію"]="Unable to perform the action"

  ["${GREEN}Перевіряємо наявленість оновлень${NC}"]="${GREEN}Checking for updates${NC}"
  ["${GREEN}Оновляємо ADSS${NC}"]="${GREEN}Updating ADSS${NC}"
  ["${GREEN}ADSS успішно оновлено${NC}"]="${GREEN}ADSS updated successfully${NC}"
  ["Встановлена версія = ${ORANGE}$current_version${NC}"]="Installed Version = ${ORANGE}$current_version${NC}"
  ["Актуальна версія = ${ORANGE}$remote_version${NC}"]="Latest Version = ${ORANGE}$remote_version${NC}"

)

export localization