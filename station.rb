class Station
  include Accessors
  include InstanceCounter
  include Validation
  attr_reader :trains, :title, :type_class

  attr_accessor_with_history :abc
  strong_attr_accessor :cde, Station

  validate :title, :presence
  validate :type_class, :type, "Station"

  @@stations = []

  def self.all
    @@stations
  end

  def initialize(title)
    @title = title
    @type_class = self.class
    validate!
    @trains = []
    register_instance
    @@stations << self
  end

  def add_train(train)
    @trains << train
  end

  def delete_train(train)
    puts "Поезд № #{train.number} отправлен со станции #{title}"
    trains.delete_if { |train_go| train_go == train }
  end

  def each_train
    index = 0
    while index < @trains.length
      yield @trains[index]
      index += 1
    end
  end
end
