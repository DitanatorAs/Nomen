require 'glimmer-dsl-libui'
require_relative 'MainWin'
require_relative '../Services/database_service'

class ViewWindow
  include Glimmer

  def initialize
    @current_index = 0

    @window = window('Просмотр', 500, 300, true) {
      vertical_box {

        # Кнопка Back
        horizontal_box {
          stretchy false
          button('← Back') { 
            stretchy false
            on_clicked do
              @window.destroy
              MainMenu.new.show
            end
          }
        }
      
        # Заглушка
        vertical_box { stretchy false }

        # Выпадающий список
        horizontal_box {
          stretchy false
          vertical_box {
            stretchy false
            label("Выберите таблицу для просмотра") { stretchy false }
            
            @combobox = combobox {
              items ['Номенклатура', 'Поставки', 'Реализации']
              selected 0
              stretchy false
              
              on_selected do |c|
                load_data_from_db(c.selected)
              end
            } 
          }
          horizontal_box { stretchy true }
        }
        
        # Сама таблица данных
        @table = table {
          stretchy true
          text_column('')
          text_column('')
          text_column('')
          text_column('')
          text_column('')
        }
      }
    }
    
    load_data_from_db(0)
  end

  def show
    @window.show
  end
  
  private

  def load_data_from_db(index)
    table_name = get_table_name_by_index(index)
    sql = get_sql_query(index)
    headers = get_table_headers(index)

    begin

      result = Database_service.execute_query(sql)

      data = result.map do |row|
        case index
        when 0 # Номенклатура
          [
            (row['Name'] || '').to_s,
            (row['Quantity'] || '').to_s,
            '', '', '' # Остальные колонки пустые
          ]
        when 1, 2 # Поставки и Реализации
          [
            (row['ID'] || '').to_s,
            (row['Name'] || '').to_s,
            (row['Quantity'] || '').to_s,
            (row['Date'] || '').to_s,
            (row['Price'] || '').to_s
          ]
        else
          ['', '', '', '', '']
        end
      end

      update_table(data)

    rescue => e
      error_msg = "#{e.class}: #{e.message}"
      puts error_msg
      update_table([['Ошибка', error_msg]])
    end
  end

  def update_table(data_array)
    return unless @table # Защита от вызова до инициализации
    @table.cell_rows.clear
    
    data_array.each do |row|
      safe_row = row.map { |cell| cell.nil? ? '' : cell.to_s }
      safe_row += [''] * (5 - safe_row.size) if safe_row.size < 5
      @table.cell_rows << safe_row.take(5)
    end
  end

  def get_table_name_by_index(index)
    case index
    when 0 then '"Номенклатура"'
    when 1 then '"Поставки"'
    else '"Реализации"'
    end
  end
  def get_sql_query(index)
    case index
    when 0
      "SELECT \"Name\", \"Quantity\" FROM \"Номенклатура\" ORDER BY \"Name\" ASC"
    when 1
      "SELECT \"ID\", \"Name\", \"Quantity\", \"Date\", \"Price\" FROM \"Поставки\" ORDER BY \"ID\" ASC"
    else
      "SELECT \"ID\", \"Name\", \"Quantity\", \"Date\", \"Price\" FROM \"Реализации\" ORDER BY \"ID\" ASC"
    end
  end

  def get_table_headers(index)
    case index
      when 0
        ['Наименование', 'Количество', '', '', '']
      when 1
        ['ID', 'Наименование', 'Количество', 'Дата', 'Цена']
      else
        ['ID', 'Клиент', 'Количество', 'Дата', 'Сумма']
    end
  end
end