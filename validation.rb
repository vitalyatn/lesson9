module Validation
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def validate(name, *args)
      validates_name = "@validates".to_sym
      instance_variable_set(validates_name, {}) unless instance_variable_defined?(validates_name)
      instance_variable_get(validates_name)[name] = *args
    end
  end

  module InstanceMethods

    def validate!
      self.class.instance_variable_get("@validates".to_sym).each do |name, args|
        send("validate_#{args[0]}", name, *args[1, args.size])
      end
      true
    end

    def valid?
      validate!
    rescue ArgumentError
      false
    end

    private

    def validate_presence(name)
      value = instance_variable_get("@#{name}")
      raise "Аргумент не может быть nil или пустой строкой" if value.nil? || value.empty?
    end

    def validate_format(name, format, message = "Неверный формат")
      value = instance_variable_get("@#{name}")
      raise ArgumentError, message unless value =~ format
    end

    def validate_type(name, type, message = "Некорректный тип")
      type_class = instance_variable_get("@#{name}").to_s
      raise ArgumentError, message if type_class != type
    end

  end
end
