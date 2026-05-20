require 'json'
require 'pg'

module Database_service
  # путь к конфиг файлу подключения к БД
  CONFIG_PATH = File.join('Configurations', '/', 'database.json')

  # Загрузка параметров из JSON-файла
  def self.settings
    @settings ||= begin
      unless File.exist?(CONFIG_PATH)
        raise "Конфигурационный файл не найден: #{CONFIG_PATH}"
      end
      JSON.parse(File.read(CONFIG_PATH), symbolize_names: true)
    end
  end

  # Установка соединения с БД
  def self.connect
    conn = PG.connect(settings)
    if block_given?
      begin
        yield(conn)
      ensure
        conn.close
      end
    else
      conn
    end
  end

  # Выполнение запроса с автоматическим закрытием соединения
  def self.execute_query(sql, params = [])
    connect do |conn|
      conn.exec_params(sql, params)
    end
  end

end