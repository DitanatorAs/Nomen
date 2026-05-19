require 'glimmer-dsl-libui'
require_relative 'MainWin'

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
            label('Номенклатура')
            entry { stretchy true }
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
  end

  def show
    @window.show
  end
end