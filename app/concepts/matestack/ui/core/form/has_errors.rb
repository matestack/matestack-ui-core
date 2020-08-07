module Matestack::Ui::Core::Form::HasErrors

  def self.included(base)
    base.class_eval do
      optional :errors
    end
  end

  def error_key
    "errors['#{key.to_s}']"
  end

  # error partial
  # overwrite render_errors to customize error rendering
  def render_errors
    unless @included_config[:errors] == false && (errors == false || errors.nil?) || errors == false
      self.send(wrapper_tag, class: wrapper_class, attributes: { 'v-if': error_key }) do
        self.send(error_tag, class: error_class, attributes: { 'v-for': "error in #{error_key}" }) do
          plain '{{ error }}'
        end
      end
    end
  end

  def wrapper_tag
    tag = get_error_config(@included_config[:errors], :wrapper, :tag) || :span
    tag = get_error_config(errors, :wrapper, :tag) || tag
  end

  def wrapper_class
    klass = get_error_config(@included_config[:errors], :wrapper, :class) || 'errors'
    klass = get_error_config(errors, :wrapper, :class) || klass
  end

  def error_tag
    tag = get_error_config(@included_config[:errors], :tag) || :span
    tag = get_error_config(errors, :tag) || tag
  end

  def error_class
    klass = get_error_config(@included_config[:errors], :class) || 'error'
    klass = get_error_config(errors, :class) || klass
  end

  def input_error_class
    klass = get_error_config(@included_config[:errors], :input, :class) || 'error'
    klass = get_error_config(errors, :input, :class) || klass
  end

  def get_error_config(hash, *keys)
    hash.dig(*keys) if hash.is_a?(Hash) && hash.dig(*keys)
  end
  
end