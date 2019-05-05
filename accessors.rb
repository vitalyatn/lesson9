module Accessors
 def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def attr_accessor_with_history(*names)
      names.each do |name|
        var_name = "@#{name}".to_sym
        arr_name = "@#{name}_history".to_sym
        instance_variable_set(arr_name, [])
        define_method(name) { instance_variable_get(var_name) }
        define_method("#{name}=".to_sym) do |value|
          instance_variable_set(var_name, value)
          instance_variable_set(arr_name, []) unless instance_variable_get(arr_name)
          instance_variable_get(arr_name) << value
        end
        define_method("#{name}_history".to_sym) {instance_variable_get(arr_name)}
      end
    end

    def strong_attr_accessor(name, class_type)
      var_name = "@#{name}".to_sym
       define_method(name) { instance_variable_get(var_name) }
        define_method("#{name}=".to_sym) do |value|
          if value.is_a? class_type
            instance_variable_set(var_name, value)
          else
            raise "Типы не совпадают!"
          end
      end
    end
  end
end
