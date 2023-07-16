#!/bin/bash

declare -A localization=(
  ["Встановити докер"]="Install docker"
  
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
  ["Зупинити атаку"]="Stop attack"
  ["Управління ддос інструментами"]="DDOS tool management"
  ["Встановлення ддос інструментів"]="Install DDOS tools"
  ["Управління ддос інструментами"]="Manage DDOS tools"


  ["Для збору особистої статистики та відображення у лідерборді на офіційному сайті."]="To gather personal statistics and display on the leaderboard on the official website."
  ["Надається Telegram ботом"]="Provided by Telegram bot"
  ["Щоб пропустити, натисніть Enter"]="To skip, press Enter"
  ["Встановити докер"]="Install Docker"
  ["Розширення портів"]="Port extension"
  ["Налаштування безпеки"]="Security settings"
  ["Головне меню"]="Main menu"
  ["Налаштування фаєрвола"]="Firewall settings"
  ["Налаштування захисту від брутфорса"]="Bruteforce protection settings"
  ["Вихід"]="Exit"
  ["Оберіть опцію:"]="Choose an option:"


  ["Встановлення захисту"]="Install protection"
  ["Налаштування захисту"]="Protection settings"

  ["Налаштування безпеки"]="Security settings"
  ["DB1000N додано до автозавантаження"]="DB1000N added to autostart"
  ["DB1000N видалено з автозавантаження"]="DB1000N removed from autostart"
  ["MHDDOS додано до автозавантаження"]="MHDDOS added to autostart"
  ["MHDDOS видалено з автозавантаження"]="MHDDOS removed from autostart"
  ["DISTRESS додано до автозавантаження"]="DISTRESS added to autostart"
  ["DISTRESS видалено з автозавантаження"]="DISTRESS removed from autostart"
  ["DB1000N не встановлений, будь ласка встановіть і спробуйте знову"]="is not installed, please install and try again"
  ["MHDDOS не встановлений, будь ласка встановіть і спробуйте знову"]="is not installed, please install and try again"
  ["DISTRESS не встановлений, будь ласка встановіть і спробуйте знову"]="is not installed, please install and try again"
  
  ["Зупинка DB1000N"]="Stopping DB1000N"
  ["Запуск DB1000N"]="Starting DB1000N"
  ["Зупинка MHDDOS"]="Stopping MHDDOS"
  ["Запуск MHDDOS"]="Starting MHDDOS"
  ["Зупинка DISTRESS"]="Stopping DISTRESS"
  ["Запуск DISTRESS"]="Starting DISTRESS"
  
  ["Налаштування DB1000N"]="DB1000N settings"
  ["Статус DB1000N"]="DB1000N status"
  ["Налаштування MHDDOS"]="MHDDOS settings"
  ["Статус MHDDOS"]="MHDDOS status"
  ["Налаштування DISTRESS"]="DISTRESS settings"
  ["Статус DISTRESS"]="DISTRESS status"

  ["Встановлюємо DB1000N"]="Installing DB1000N"
  ["DB1000N успішно встановлено"]="DB1000N installed successfully"
  ["Встановлюємо DB1000N"]="Installing MHDDOS"
  ["DB1000N успішно встановлено"]="MHDDOS installed successfully"
  ["Встановлюємо DB1000N"]="Installing DISTRESS"
  ["DB1000N успішно встановлено"]="DISTRESS installed successfully"
  
  ["${GRAY}Залиште пустим якщо хочите видалити пераметри${NC}"]="${GRAY}Leave blank if you want to delete parameters${NC}"
  ["Автооновлення (1 | 0): "]="Autoupdate (1 | 0): "
  ["Будь ласка введіть правильні значення"]="Please enter the correct values"
  ["Проксі (шлях до файлу або веб-ресурсу): "]="Proxy (path to file or web resource)): "
  ["Масштабування (1 | X): "]="Scaling (1 | X): "


  ["Відсоткове співвідношення використання власної IP адреси (0-100)"]="Percentage of own IP address use (0-100)"
  ["Кількість підключень Tor (0-100)"]="Number of Tor connections (0-100)"
  ["Кількість створювачів завдань (4096)"]="Number of task creators (4096)"





  ["Налаштовуємо"]="Setting"
  


  ["Відсутня реалізація MHDDOS для x86 архітектури, що відповідає 32-бітній розрядності"]="No MHDDOS implementation for x86 architecture, which corresponds to 32-bit"
  ["Неможливо визначити розрядность операційної системи"]="Unable to determine the operating system's bitness"

  ["Юзер ІД"]="User ID"
  ["Мова"]="Language"
  ["Кількість копій"]="Number of copies"
  ["Успішно виконано"]="Execution successful"


  ["Порти успішно розширено"]="Ports successfully extended"
  ["Наразі всі порти розширено"]="All ports are currently extended"
  ["Не можливо виконати дію"]="Unable to perform action"
  ["UFW фаєрвол"]="UFW firewall"
  ["Фаєрвол UFW встановлено і деактивовано"]="UFW firewall installed and deactivated"



  ["Фаєрвол UFW налаштовано і активовано"]="UFW firewall set up and activated"
  ["Перевіряємо наявленість оновлень"]="Checking for updates"
  ["Оновляємо ADSS"]="Updating ADSS"
  ["ADSS успішно оновлено"]="ADSS updated successfully"


)

export localization