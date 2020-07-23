module Matestack::Ui::Core::Form::Utils

  def input_key
    "data['#{key.to_s}']"
  end

  def error_key
    "errors['#{key.to_s}']"
  end

  def input_wrapper
    case input_for
    when nil
      return nil
    when Symbol, String
      return input_for
    end
    if input_for.respond_to?(:model_name)
      return input_for.model_name.singular
    end
  end

  def attr_key
    if input_wrapper.nil?
      return "#{key.to_s}#{'[]' if multiple}"
    else
      return "#{input_wrapper}.#{key.to_s}#{'[]' if multiple}"
    end
  end

  def init_value
    return init unless init.nil?

    unless input_for.nil?
      value = parse_value(input_for.send key)
    else
      unless @included_config.nil? && @included_config[:for].nil?
        if @included_config[:for].respond_to?(key)
          value = parse_value(@included_config[:for].send key)
        else
          @included_config[:for][key] if @included_config[:for].is_a?(Hash)
        end
      end
    end
  end

  def parse_value(value)
    value
  end

end