require_relative 'accessors'
require_relative 'valid'
require_relative 'validation'
require_relative 'instance_counter'
require_relative 'manufacturer'
require_relative 'station'
require_relative 'route'
require_relative 'train'
require_relative 'wagon'
require_relative 'cargo_train'
require_relative 'cargo_wagon'
require_relative 'passenger_train'
require_relative 'passenger_wagon'

class Controller
  def initialize
    @stations = []
    @trains = []
    @routes = []
    @wagon = []
  end

  def list_of_trains
    puts 'Доступные поезда:'
    @trains.each.with_index(1) do |train, index|
      puts "#{index}: номер: '#{train.number}', тип: #{train.type}"
    end
  end

  def list_of_stations
    puts 'Доступные станции:'
    @stations.each.with_index(1) do |station, index|
      puts "#{index} - #{station.title}"
    end
  end

  def list_of_routes
    puts 'Доступные маршруты:'
    @routes.each.with_index(1) do |route, index|
      print "#{index} : #{route.start_station.title} - #{route.end_station.title} ПОЛНЫЙ МАРШРУТ:"
      route = route.stations
      route.each { |station| print "#{station.title} - " }
      puts ''
    end
  end

  def select_train
    puts 'Выберите поезд'
    list_of_trains
    train = @trains[Integer(gets) - 1]
    train.valid?
    train
  rescue ArgumentError => e
    puts "Неверный формат ввода:#{e.message}"
    retry
  rescue RuntimeError, NoMethodError => e
    puts "Поезд не существует:#{e.message}"
    retry
  end

  def select_station
    puts 'Выберите станцию'
    list_of_stations
    station = @stations[Integer(gets) - 1]
    station.valid?
    station
  rescue ArgumentError => e
    puts "Неверный формат ввода:#{e.message}"
    retry
  rescue RuntimeError, NoMethodError => e
    puts "Станция не существует:#{e.message}"
    retry
  end

  def select_route
    puts 'Выберите маршрут'
    list_of_routes
    route = @routes[Integer(gets) - 1]
    route.valid?
    route
  rescue ArgumentError => e
    puts "Неверный формат ввода:#{e.message}"
    retry
  rescue RuntimeError, NoMethodError => e
    puts "Маршрут не существует:#{e.message}"
    retry
  end

  def select_wagon(train)
    puts 'Выберите вагон'
    train.wagons.each { |wagon| print wagon.id.to_s + ' ' }
    puts ''
    wagon_number = Integer(gets)
    index_wagon = train.wagons.index { |wagon| wagon.id == wagon_number }
    train.wagons[index_wagon]
  rescue ArgumentError => e
    puts "Неверный формат ввода:#{e.message}"
    retry
  rescue TypeError => e
    puts "Вагон не существует:#{e.message}"
    retry
  end

  def add_station
    loop do
      puts 'Введите название станции'
      title = gets.chomp
      @stations << Station.new(title)
      puts "Добавить еще станцию?(введите 'д' или 'н' )"
      break if gets.chomp == 'н'
    end
  rescue RuntimeError => e
    puts "#{e.inspect}.Попробуйте снова!"
    retry
  end

  def add_train
    loop do
      puts "Какой тип поезда вы хотите создать?
      \rп - пассажирский, г -грузовой."
      train_type = gets.chomp
      raise ArgumentError, 'Неверные данные.' unless 'пг'.include? train_type

      puts 'Введите номер поезда:'
      number_train = gets.chomp
      @trains << if train_type == 'п'
                   PassengerTrain.new(number_train)
                 else
                   CargoTrain.new(number_train)
                 end
      puts "Добавить еще поезд?(введите 'д' или 'н' )"
      break if gets.chomp == 'н'
    end
  rescue RuntimeError, ArgumentError => e
    puts e.message
    retry
  end

  def add_route
    puts "\nВыберите начальную станцию"
    start_station = select_station
    puts 'Выберите конечную станцию'
    end_station = select_station
    @routes << Route.new(start_station, end_station)
    puts "Маршрут создан!
    \rДобавить промежуточные станции? (введите 'д' или 'н' )"
    user_answer = gets.chomp
    if user_answer == 'д'
      loop do
        puts 'Выберите промежуточную станцию'
        middle_station = select_station
        @routes.last.add_station(middle_station)
        puts "Добавить еще станцию? (введите 'д' или 'н')"
        break if gets.chomp == 'н'
      end
    end
  end

  def add_wagon
    train = select_train
    puts "Выбран поезд: #{train.number}, тип: #{train.type}"
    loop do
      puts 'Укажите номер вагона'
      number_wagon = Integer(gets)
      if train.is_a? PassengerTrain
        puts  'Укажите колличество мест'
        places = Integer(gets)
        wagon = PassengerWagon.new(number_wagon, places)
      else
        puts  'Укажите объем вагона'
        volume = Integer(gets)
        wagon = CargoWagon.new(number_wagon, volume)
      end
      train.add_wagon(wagon)
      puts "Добавить еще вагон? (введите 'д' или 'н')"
      break if gets.chomp == 'н'
    end
  rescue StandartError => e
    puts "#{e.message} Попробуйте еще раз!"
    retry
  end

  def delete_wagon
    train = select_train
    puts "Выбран поезд: #{train.number}, тип: #{train.type}"
    wagon = select_wagon(train)
    train.delete_wagon(wagon)
  end

  def add_route_to_train
    train = select_train
    route = select_route
    train.add_route(route)
    puts 'Маршрут к поезду добавлен!'
  end

  def move_train
    train = select_train
    puts 'Куда перемещаем? в-вперед, н-назад'
    move = gets.chomp
    if move == 'в'
      train.forward
    elsif move == 'н'
      train.back
    else
      puts 'Неизвестное направление'
    end
  end

  def info_station
    @stations.each do |station|
      puts station.title
      station.each_train do |train|
        puts " Номер поезда - #{train.number}, тип - #{train.type}, кол-во вагонов - #{train.wagons.length}"
        train.each_wagon do |wagon|
          puts wagon.message.to_s
        end
      end
    end
  end

  def wagon_manipulation
    train = select_train
    wagon = select_wagon(train)
    begin
      if wagon.is_a? PassengerWagon
        puts "Количество свободных мест: #{wagon.free_space}"
        puts "Количество занятых мест: #{wagon.occupied_space} "
        puts "Купить билет?(введите 'д' или 'н')"
        if gets.chomp == 'д'
          wagon.take_space
          puts 'Билет куплен!'
        end
      else
        puts "Количество свободного объема: #{wagon.free_space}"
        puts "Количество занятого объема: #{wagon.occupied_space} "
        puts "Добавить груз?(введите 'д' или 'н')"
        if gets.chomp == 'д'
          puts 'Введите объем добавляемого груза'
          wagon.take_space(gets.to_f)
          puts 'Груз добавлен!'
        end
      end
    rescue StandartError => e
      puts "#{e.message} Попробуйте еще раз!"
      retry
    end
  end

  def main_menu
    puts "Выберите действие, которое вы хотите сделать
          1 - создать станции
          2 - создать поезд
          3 - создать маршрут
          4 - назначить маршрут поезду
          5 - добавить вагоны к поезду
          6 - отцепить вагон от поезда
          7 - манипуляции с вагоном
          8 - переместить поезд по маршруту (вперед, назад)
          9 - посмотреть список станций и список поездов на станции
          0 - выход"
  end

  def standart
    # 8 станций, 10 - поездов, 9 маршрутов
    @stations << Station.new('москва')
    @stations << Station.new('амурск')
    @stations << Station.new('хабаровск')
    @stations << Station.new('владивосток')
    @stations << Station.new('оренбург')
    @stations << Station.new('красноярск')
    @stations << Station.new('омск')
    @stations << Station.new('комсомольск-на-амуре')

    @trains << PassengerTrain.new('ппз-12')
    @trains << CargoTrain.new('гпз-22')
    @trains << PassengerTrain.new('ппз-66')
    @trains << CargoTrain.new('гпз-77')
    @trains << PassengerTrain.new('ппз-55')
    @trains << CargoTrain.new('гпз-44')
    @trains << PassengerTrain.new('ппз-33')
    @trains << CargoTrain.new('гпз-22')
    @trains << PassengerTrain.new('ппз-11')
    @trains << CargoTrain.new('гпз-99')

    @wagon << PassengerWagon.new(1, 25)
    @wagon << PassengerWagon.new(2, 25)
    @wagon << PassengerWagon.new(3, 25)
    @wagon << PassengerWagon.new(4, 25)
    @wagon << PassengerWagon.new(5, 25)
    @wagon << CargoWagon.new(1, 1200)
    @wagon << CargoWagon.new(2, 1200)
    @wagon << CargoWagon.new(3, 1200)
    @wagon << CargoWagon.new(4, 1200)
    @wagon << CargoWagon.new(5, 1200)

    @wagon[0].take_space
    @wagon[0].take_space
    @wagon[0].take_space
    @wagon[0].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[1].take_space
    @wagon[5].take_space(324.5)
    @wagon[5].take_space(324.5)
    @wagon[6].take_space(400)
    @wagon[7].take_space(900)

    @trains[0].add_wagon(@wagon[0])
    @trains[0].add_wagon(@wagon[1])
    @trains[0].add_wagon(@wagon[2])
    @trains[0].add_wagon(@wagon[3])
    @trains[0].add_wagon(@wagon[4])

    @trains[1].add_wagon(@wagon[5])
    @trains[1].add_wagon(@wagon[6])
    @trains[1].add_wagon(@wagon[7])
    @trains[1].add_wagon(@wagon[8])
    @trains[1].add_wagon(@wagon[9])

    @trains[2].add_wagon(@wagon[0])
    @trains[2].add_wagon(@wagon[1])
    @trains[2].add_wagon(@wagon[2])
    @trains[2].add_wagon(@wagon[3])
    @trains[2].add_wagon(@wagon[4])

    @trains[3].add_wagon(@wagon[5])
    @trains[3].add_wagon(@wagon[6])
    @trains[3].add_wagon(@wagon[7])
    @trains[3].add_wagon(@wagon[8])
    @trains[3].add_wagon(@wagon[9])

    @routes << Route.new(@stations[0], @stations[2])
    @routes.last.add_station(@stations[1])
    @routes << Route.new(@stations[0], @stations[3])
    @routes.last.add_station(@stations[2])
    @routes << Route.new(@stations[0], @stations[4])
    @routes.last.add_station(@stations[5])
    @routes << Route.new(@stations[1], @stations[2])
    @routes.last.add_station(@stations[3])
    @routes << Route.new(@stations[1], @stations[7])
    @routes.last.add_station(@stations[6])
    @routes << Route.new(@stations[1], @stations[6])
    @routes.last.add_station(@stations[7])
    @routes << Route.new(@stations[2], @stations[5])
    @routes.last.add_station(@stations[4])
    @routes << Route.new(@stations[4], @stations[2])
    @routes.last.add_station(@stations[5])
    @routes << Route.new(@stations[7], @stations[2])
    @routes.last.add_station(@stations[1])

    @trains[0].add_route(@routes[0])
    @trains[1].add_route(@routes[1])
    @trains[2].add_route(@routes[2])
    @trains[3].add_route(@routes[3])
    @trains[4].add_route(@routes[4])
    @trains[5].add_route(@routes[5])
    @trains[6].add_route(@routes[0])
    @trains[7].add_route(@routes[6])
    @trains[8].add_route(@routes[7])
    @trains[9].add_route(@routes[8])
  end

  def run
    standart
    loop do
      main_menu
      act = gets.chomp.to_i
      break if act.zero?

      case act
      when 1
        add_station
      when 2
        add_train
      when 3
        add_route
      when 4
        add_route_to_train
      when 5
        add_wagon
      when 6
        delete_wagon
      when 7
        wagon_manipulation
      when 8
        move_train
      when 9
        info_station
      else
        puts 'Неизвестное действие'
      end
    end
  end
end

Controller.new.run
