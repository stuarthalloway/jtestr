
module JtestR
  class Configuration
    def initialize
      @values = { }
    end
    
    def evaluate(config_string,file = "<eval>")
      before = local_variables
      after = instance_eval <<VAL, file, 0
#{config_string}
local_variables
VAL
      if before != after
        warn "you have assigned a value to a variable in your configuration. that might not do what you want."
      end
      nil
    end

    def configuration_value(name)
      value = @values[name.to_sym]
      if value
        value = value.first
      end
      value
    end

    def configuration_values(name)
      @values[name.to_sym] || []
    end
    
    def []=(name, value)
      @values[name.to_sym] = value
    end
    
    def method_missing(name, *args, &block)
      existing = @values.include?(name.to_sym)
      @values[name.to_sym] ||= []
      values = (args + (block.nil? ? [] : [block]))
      @values[name.to_sym] = [true] if values.empty? && !existing
      @values[name.to_sym] = @values[name.to_sym] + values unless values.empty?
      @values[name.to_sym]
    end
  end
end
