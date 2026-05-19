require 'glimmer-dsl-libui'
require_relative 'MainWin'

class ViewWindow
  include Glimmer

  def initialize
    @window = window('Просмотр', 500, 300, true) {
      
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
            label("Выберите таблицу для просмотра "){stretchy false}
            combobox { |c|
              items ['Номенклатура', 'Поставки', 'Реализации']
              selected 0
              stretchy false
            }
          }
          horizontal_box { stretchy true }
        }
        
        # Сама таблица данных
        table {
        stretchy true
        text_column('ID')
        text_column('Имя')
        cell_rows []
      }

      }
    }
  end

  def show
    @window.show
  end

end