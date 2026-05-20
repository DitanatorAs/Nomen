require 'glimmer-dsl-libui'
require_relative 'Views/MainWin' 
require_relative 'Services/database_service'
require 'pg'

begin
  # Получаем настройки из отдельного файла
  config = Database_service.settings

  # Устанавливаем соединение
  conn = PG.connect(config)

  puts "Успешное подключение к PostgreSQL!"
  puts "Версия сервера: #{conn.server_version}"

  # Пример запроса
  result = conn.exec_params('SELECT version()')
  puts "Результат запроса: #{result[0]['version']}"

rescue PG::Error => e
  puts "Ошибка подключения: #{e.message}"
ensure
  # Всегда закрываем соединение
  conn&.close
  puts "Соединение закрыто."
end

MainMenu.new.show