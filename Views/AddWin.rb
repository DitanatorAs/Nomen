require 'glimmer-dsl-libui'
require_relative 'MainWin'
require_relative '../Services/database_service'

class AddWindow
  include Glimmer

  def initialize
    @window = window('ADD', 500, 300, true) {

      vertical_box {

        # Кнопка Back
        vertical_box {
          stretchy false
          horizontal_box {
            button('← Back') { 
              stretchy false
              on_clicked do
                @window.destroy
                MainMenu.new.show
              end
            }
          }
        }

        # Заглушка
        vertical_box { stretchy false }

        # Выпадающий список
        horizontal_box {
          stretchy false
          vertical_box {
            stretchy false
            label("Выберите тип операции"){stretchy false}
            @operation_type = combobox { |c|
              items ['Поставка', 'Реализация']
              selected 0
              stretchy false
            }
          }
          horizontal_box { stretchy true }
        } 
        
        # Область ввода
        horizontal_box {
          stretchy false
        # Левая колонка: Name + Date
          vertical_box {
            padded true
            # Выпадающий список с номенклатурой
            label('Номенклатура')
            @nomenclature = combobox { 
              stretchy true
              items LogicAddWin.getNomenList
              selected 0
            }
            label('Дата (ДД.ММ.ГГГГ)')
            @date = entry { stretchy true }
          }
          # Правая колонка: Количество и price
          vertical_box {
            padded true
            stretchy true
            label('Количество')
            @quantity = entry { stretchy true }
            label('Цена за ед.')
            @price = entry { stretchy true }
          }
        }
        
        # Кнопка ADD
        vertical_box {
          horizontal_box {stretchy true}
          horizontal_box {
            horizontal_box {stretchy true}
            horizontal_box {stretchy true}
            button('Add') { 
              stretchy true
              on_clicked do
                # Добавление новой записи в таблицу
                LogicAddWin.add_record(@operation_type.selected_item,  @nomenclature.selected_item, @date.text, @quantity.text, @price.text)    
                # Очистка полей 
                @date.text = ''
                @quantity.text = ''
                @price.text = ''            
              rescue => e
                msg_box_error('Ошибка', "#{e.message}")
                quit
              end
            }
            horizontal_box {stretchy false}
          }
          horizontal_box {stretchy true}
        }

      }
    }

  # Отловщик ошибок
  rescue => e
    msg_box_error('Ошибка', "#{e.message}")
    quit
  end

  def show
    @window&.show
  end

end

class LogicAddWin
  include Glimmer

  # Получение списка номенклатуры
  def self.getNomenList
    Database_service.execute_query('SELECT "Name" FROM public."Номенклатура"').map { |row| row['Name'] }
  end

  # Добавление новой записи в таблицу
  def self.add_record(operation_type, nomenclature, date, quantity, price)

    unless all_fields_filled?(operation_type, nomenclature, date, quantity, price)
      msg_box_error('Ошибка валидации', 'Пожалуйста, заполните все поля!')
      return false
    end

    unless valid_date?(date)
      msg_box_error('Ошибка валидации', 'Некорректная дата!')
      return false
    end

    unless valid_positive_integer?(quantity)
      msg_box_error('Ошибка валидации', 'Ячейка "Количество" заполнено неверно!')
      return false
    end

    unless valid_positive_integer?(price)
      msg_box_error('Ошибка валидации', 'Ячейка "Цена за ед." заполнено неверно!')
      return false
    end

    # Определение типа операции
    table_name = (operation_type == 'Поставка') ? 'Поставки' : 'Реализации'
    # Формирование SQL запроса
    query = "INSERT INTO public.\"#{table_name}\" (\"Name\", \"Date\", \"Quantity\", \"Price\") VALUES ($1, $2, $3, $4)"
    params = [nomenclature, date, quantity.to_i, price.to_i]
    begin
      Database_service.execute_query(query, params)
      msg_box('Успех', "Запись успешно добавлена в таблицу '#{table_name}'")
    rescue => e
      msg_box_error('Ошибка', "#{e.message}")
    end
  end

  def self.valid_date?(date_str)
    begin
      # Парсим дату в формате ДД.ММ.ГГГГ
      day, month, year = date_str.strip.split('.').map(&:to_i)
      # Проверка базовых диапозонов
      return false if day.nil? || month.nil? || year.nil?
      return false if year < 1 || month < 1 || month > 12 || day < 1
      # Дополнительная проверка на корректность чисел
      days_in_month = case month
        when 1, 3, 5, 7, 8, 10, 12 then 31
        when 4, 6, 9, 11 then 30
        when 2
        # Проверка на високосный год
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) ? 29 : 28
        else 0
      end
      return false if day > days_in_month
      # Создаем объект Date для дополнительной валидации
      date = Date.new(year, month, day)
      # Проверка, что дата не позже сегодняшней
      return false if date > Date.today
      true
    rescue ArgumentError, Date::Error
      false
    end
  end

  # Все поля заполнены ? 
  def self.all_fields_filled?(operation_type, nomenclature, date, quantity, price)
    return false if operation_type.nil? || operation_type.strip.empty?
    return false if nomenclature.nil? || nomenclature.strip.empty?
    return false if date.nil? || date.strip.empty?
    return false if quantity.nil? || quantity.strip.empty?
    return false if price.nil? || price.strip.empty?
    true
  end

  # Проверка на то, что число целое, положительное
  def self.valid_positive_integer?(str)
    # Проверка, что строка состоит только из цифр
    str = str.strip
    return false unless str.match?(/^\d+$/)
    # Чило не может начинаться с нуля
    return false if str.length > 1 && str[0] == '0'
    # Проверка, что число не отрицательное и не ноль
    return false if str.to_i <= 0
    true
  end

end