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
      options = model.dup if options.empty? && model.is_a?(Hash)
      # required_hooks(options)
      # optional_hooks(options)
      set_values(options) unless options[:skip_set_values]
      super
    end
  end
  
  module ClassMethods

    def inherited(subclass)
      super
      # self.new(nil, skip_set_values: true)
      subclass.property_keys *self.all_property_keys
      subclass.all_required_properties.concat(self.all_required_properties)
      subclass.created_properties.concat(self.created_properties)
    end
    
    # contains all property keys, or property hashes regardless of wheter they are optional or required
    # used in order to initialize values of properties correctly for subclasses and make properties inheritable
    def all_property_keys
      @all_properties.flatten!&.uniq! if defined? @all_properties
      @all_properties ||= []
    end

    def all_required_properties
      @all_required_properties ||= []
    end

    def created_properties
      @created_properties ||= []
    end

    # add property keys to array containing all property keys
    def property_keys(*attributes)
      attributes.each do |attribute|
        if attribute.is_a?(Hash)
          attribute.each do |temp|
            all_property_keys.push({ "#{temp.first}": temp.last})
          end
        else
          all_property_keys.push(attribute) 
        end
      end
    end

    # define optinoal properties for custom components with `optional :foo, :bar`
    def optional(*properties)
      property_keys *properties
      add_properties_to_list(optional_properties, properties)
      optional_hooks
    end
  
    # define required properties for custom components with `requires :title, :foo, :bar`
    def requires(*properties)
      property_keys *properties
      add_properties_to_list(requires_properties, properties)
      required_hooks
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
      @optional_properties ||= []
    end
  
    # array of required properties from the component
    def requires_properties
      @requires_properties ||= []
    end

    def optional_hooks
      self.optional_properties.compact.each do |prop|
        prop = extract_property_key({}, prop)
        define_getter_and_setter_for_property(prop)
      end
    end

    def required_hooks
      self.requires_properties.compact.each do |prop|
        prop = extract_property_key({}, prop)
        self.all_required_properties.push(prop).uniq!
        define_getter_and_setter_for_property(prop)
      end
    end

    def extract_property_key(options, prop)
      if prop.is_a?(Array) || prop.is_a?(Hash)
        hash = prop.flatten
        prop = hash.last[:as]
      end
      prop
    end

    def define_getter_and_setter_for_property(prop)
      self.created_properties.push(prop)
      self.send(:define_method, prop) do 
        self.instance_variable_get(:"@#{prop}")
      end
      self.send(:define_method, :"#{prop}=") do |value|
        self.instance_variable_set(:"@#{prop}", value)
      end
    end

    def method_added(name)
      if all_property_keys.include?(name) && !created_properties.include?(name)
        raise PropertyOverwritingExistingMethodException, "Property \"#{name}\" would overwrite already defined instance method for #{self}"
      end
    end
  end

  def set_values(options)
    self.class.all_property_keys.compact.each do |prop|
      value_key = prop
      prop = extract_property_key(options, prop)
      if self.class.all_required_properties.include?(prop) && options[prop].nil?
        raise PropertyMissingException, "Required property #{prop} is missing for #{self.class}" 
      end
      send(:"#{prop}=", options[prop])
    end
  end

  # returns property key and sets alias if hash with as option is given
  def extract_property_key(options, prop)
    if prop.is_a?(Array) || prop.is_a?(Hash)
      hash = prop.flatten
      options[hash.last[:as]] = options[hash.first]
      prop = hash.last[:as]
    end
    prop
  end

end