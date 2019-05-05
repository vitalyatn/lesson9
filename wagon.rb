class Wagon
  include Manufacturer
  include Accessors
  attr_reader :id, :type, :occupied_space

  WAGON_OVERFLOW = 'Ошибка!Нет свободного места'.freeze

  def initialize(id, total_space)
    @id = id
    @occupied_space = 0
    @total_space = total_space
  end

  def take_space(value = 1)
    if free_space < value
      raise WAGON_OVERFLOW
    else
      @occupied_space += value
    end
  end

  def free_space
    @total_space - @occupied_space
  end

  def message
    " номер вагона:#{@id}
      \r   тип вагона: #{@type}"
  end
end
