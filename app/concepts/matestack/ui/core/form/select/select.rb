require_relative '../utils'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Select
  class Select < Matestack::Ui::Core::Component::Static
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasErrors

    requires :key
    requires options: { as: :select_options }

    def setup
      if @tag_attributes[:id].nil?
        @tag_attributes[:id] = attr_key
      end
    end

    def attr_key
      key.to_s
    end

    def option_values
      values = select_options if select_options.is_a?(Array)
      values = select_options.keys if select_options.is_a?(Hash)
      return values
    end

    def options_type
      return Integer if option_values.first.is_a?(Integer)
      return String if option_values.first.is_a?(String)
    end

    def model_binding

      if option_values.first.is_a?(Integer)
        return "v-model.number"
      else
        return "v-model"
      end
    end

    def init_value
      unless options[:init].nil?
        return options[:init]
      end

      unless options[:for].nil?
        value = options[:for].send(key)
        if [true, false].include? value
          value ? 1 : 0
        else
          return value
        end
      else
        unless @included_config.nil? && @included_config[:for].nil?
          if @included_config[:for].respond_to?(key)
            value = @included_config[:for].send(key)
            if [true, false].include? value
              value ? 1 : 0
            else
              return value
            end
          else
            if @included_config[:for].is_a?(Symbol) || @included_config[:for].is_a?(String)
              return nil
            end
            if @included_config[:for].is_a?(Hash)
              return @included_config[:for][key]
            end
          end
        end
      end
    end

    def id_for_option value
      return "#{@tag_attributes[:id]}_#{value}"
    end

  end
end
