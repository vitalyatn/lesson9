class PassengerTrain < Train
  attr_reader :type
  def initialize(number)
    super
    @type = 'пассажирский'
    register_instance
  end

  def add_wagon(wagon)
    if wagon.is_a? PassengerWagon
      super
    else
      'Данный тип вагона нельзя добавить к пассажирскому поезду!'
    end
  end
end
