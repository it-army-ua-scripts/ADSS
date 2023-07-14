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
  ["Запущено"]="started"
  ["Нажміть будь яку клавішу щоб продовжити"]="Press any key to continue"
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


  ["Встановлення захисту"]="Install protection"
  ["Налаштування захисту"]="Protection settings"

  ["Налаштування безпеки"]="Security settings"
  ["додано до автозавантаження"]="added to autostart"
  ["видалено з автозавантаження"]="removed from autostart"
  ["не встановлений, будь ласка встановіть і спробуйте знову"]="is not installed, please install and try again"
  
  ["Зупинка"]="Stopping"
  ["Запуск"]="Starting"
  
  ["Налаштування"]="settings"
  ["Статус"]="status"

  ["Встановлюємо"]="Installing"
  
  ["успішно встановлено"]="installed successfully"
  
  ["Залиште пустим якщо хочите видалити пераметри"]="Leave blank if you want to delete parameters"
  ["Автооновлення"]="Autoupdate"
  ["Будь ласка введіть правильні значення"]="Please enter the correct values"
  ["Проксі (шлях до файлу або веб-ресурсу)"]="Proxy (path to file or web resource)"
  ["Масштабування"]="Scaling"


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