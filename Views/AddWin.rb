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
            combobox { |c|
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
            combobox { 
              stretchy true
              items LogicAddWin.getNomenList
              selected 0
            }
            label('Дата')
            entry { stretchy true }
          }
          # Правая колонка: Количество и price
          vertical_box {
            padded true
            stretchy true
            label('Количество')
            entry { stretchy true }
            label('Цена за ед.')
            entry { stretchy true }
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

  def self.getNomenList
    Database_service.execute_query('SELECT "Name" FROM public."Номенклатура"').map { |row| row['Name'] }
  end

end