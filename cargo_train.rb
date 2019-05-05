class CargoTrain < Train
  attr_reader :type
  def initialize(number)
    super
    @type = 'грузовой'
    register_instance
  end

  def add_wagon(wagon)
    if wagon.is_a? CargoWagon
      super
    else
      'Данный тип вагона нельзя добавить к грузовому поезду!'
    end
  end
end
