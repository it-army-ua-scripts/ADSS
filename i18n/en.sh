#!/bin/bash

declare -A localization=(
  ["Встановити докер"]="Install Docker"

  ["Неправильний вхідний параметр!"]="Invalid input parameter!"
  ["Не знайдено папку '$directory'."]="'$directory' folder not found."

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
  ["Запущено"]="Started"
  ["Нажміть будь яку клавішу щоб продовжити"]="Press any key to continue"
  ["Немає запущених процесів"]="No processes running"
  ["Статус атаки"]="Attack status"
  ["Зупинити атаку"]="Stop an attack"
  ["Управління ддос інструментами"]="DDOS tool management"
  ["Встановлення ддос інструментів"]="Install DDOS tools"
  ["Управління ддос інструментами"]="Manage DDOS tools"

  ["Для збору особистої статистики та відображення у лідерборді на офіційному сайті."]="To gather personal statistics and display on the leaderboard on the official website."
  ["Надається Telegram ботом"]="Provided by the Telegram bot"
  ["Щоб пропустити, натисніть Enter"]="To skip, press Enter"

  ["Розширення портів"]="Port extension"
  ["Налаштування безпеки"]="Security settings"
  ["Головне меню"]="Main menu"
  ["Налаштування фаєрвола"]="Firewall settings"
  ["Вихід"]="Exit"
  ["Оберіть опцію:"]="Choose an option:"
  ["ДДОС інструменти не встановлено"]="No DDOS tools installed"

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

  ["Залишіть пустим якщо бажаєте видалити пераметри"]="Leave blank if you want to delete parameters"
  ["Автооновлення (1 | 0): "]="Autoupdate (1 | 0): "
  ["Будь ласка введіть правильні значення"]="Please enter the correct values"
  ["Проксі (шлях до файлу або веб-ресурсу): "]="Proxy (path to file or web resource): "
  ["Масштабування (1 | X): "]="Scaling (1 | X): "
  ["Список проксі у форматі"]="List of proxies in format"
  ["або"]="or"
  ["Укажіть протокол, якщо формат"]="Specify the protocol if the format is"
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

  ["Перевіряємо наявленість оновлень"]="Checking for updates"
  ["Оновляємо ADSS"]="Updating ADSS"
  ["ADSS успішно оновлено"]="ADSS updated successfully"
  ["Встановлена версія"]="Installed Version"
  ["Актуальна версія"]="Latest Version"

  ["Назва інтерфейсу (ensXXX, ethX, тощо.)"]="Interface name (ensXXX, ethX, etc.)"
  ["Інтерфейс: "]="Interface: "
  ["IP адреса кожного інтерфейсу через пробіл."]="IP addresses of each interface, space separated."
  ["Інтерфейси: "]="Interfaces: "
  ["ADSS успішно видалено"]="ADSS was deleted successfully"

  ["Чекаємо на сервіс..."]="Wait for the service..."
)

export localization
