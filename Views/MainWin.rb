require 'glimmer-dsl-libui'
require_relative 'ViewWin'
require_relative 'AddWin'

class MainMenu
  include Glimmer

  def initialize
    @window = window('Главное окно', 500, 300, true) {

      # Надпись "главное окно"
      vertical_box {
        horizontal_box {
          vertical_box { stretchy true }
          label('Главное меню') {stretchy false}
          vertical_box { stretchy true }
        }

        # Кнопки
        horizontal_box {
          horizontal_box { stretchy true }
          vertical_box{
            button('Просмотр данных') { 
              stretchy false
              on_clicked do
                @window.destroy
                ViewWindow.new.show
              end
            }
            vertical_box { stretchy false }
            button('Внесение данных') { 
              stretchy false
              on_clicked do
                @window.destroy
                AddWindow.new.show
              end
            }
          }
          horizontal_box { stretchy true }
        }

        # Заглушки для отступа
        horizontal_box { stretchy true }
        vertical_box { stretchy true }
        
      }
    }
  end

  def show
    @window.show
  end
end