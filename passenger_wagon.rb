class PassengerWagon < Wagon
  def initialize(id, places)
    super
    @type = 'пассажирский'
  end

  def message
    "#{super}
    \r   количество свободных мест: #{free_space}
    \r   количество занятых мест: #{@occupied_space}"
  end
end
