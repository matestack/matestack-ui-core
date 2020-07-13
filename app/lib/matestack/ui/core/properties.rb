module Matestack::Ui::Core::Properties

  class PropertyMissingException < StandardError
  end

  class PropertyOverwritingExistingMethodException < StandardError
  end

  # prepend the initializer and add class methods
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
    base.send :prepend, Initializer
  end
  
  # initializer calls super and creates instance methods for defined required and optional properties afterwards
  module Initializer
    def initialize(model=nil, options={})
      super
      required_hooks
      optional_hooks
    end
  end
  
  module ClassMethods
    # define optinoal properties for custom components with `optional :foo, :bar`
    def optional(*properties)
      add_properties_to_list(optional_properties, properties)
    end
  
    # define required properties for custom components with `requires :title, :foo, :bar`
    def requires(*properties)
      add_properties_to_list(requires_properties, properties)
    end

    def add_properties_to_list(list, properties)
      properties.each do |property| 
        if property.is_a? Hash 
          property.each { |tmp_property| list.push(tmp_property) }
        else
          list.push(property) 
        end
      end
    end
  
    # array of properties created from the component
    def optional_properties
      @component_properties ||= []
    end
  
    # array of required properties from the component
    def requires_properties
      @requires_properties ||= []
    end
  end

  def optional_hooks
    self.class.optional_properties.compact.each do |prop|
      if prop.is_a? Array
        hash = prop.flatten
        options[hash.last[:as]] = options[hash.first]
        prop = hash.last[:as]
      end
      raise PropertyOverwritingExistingMethodException, "Optional property #{prop} would overwrite already defined instance method for #{self.class}" if self.respond_to? prop
      send(:define_singleton_method, prop) do 
        options[prop]
      end
    end
  end

  def required_hooks
    self.class.requires_properties.compact.each do |prop|
      if prop.is_a? Array
        hash = prop.flatten
        options[hash.last[:as]] = options[hash.first]
        prop = hash.last[:as]
      end
      raise PropertyMissingException, "Required property #{prop} is missing for #{self.class}" if self.send(:options)[prop].nil?
      raise PropertyOverwritingExistingMethodException, "Required property #{prop} would overwrite already defined instance method for #{self.class}" if self.respond_to? prop
      send(:define_singleton_method, prop) do
        options[prop]
      end
    end
  end

end