class CargoWagon < Wagon
  attr_reader

  def initialize(id, volume)
    super
    @type = 'грузовой'
  end

  def message
    "#{super}
    \r   количество свободного места: #{free_space} тонн
    \r   количество занятого места: #{@occupied_space} тонн"
  end
end
