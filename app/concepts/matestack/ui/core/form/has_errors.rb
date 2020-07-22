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
    unless errors == false
      self.send(wrapper_tag, class: wrapper_class, attributes: { 'v-if': error_key }) do
        self.send(error_tag, class: error_class, attributes: { 'v-for': "error in #{error_key}" }) do
          plain '{{ error }}'
        end
      end
    end
  end

  def wrapper_tag
    tag = errors.is_a?(Hash) ? errors.dig(:wrapper, :tag) : :span
    tag || :span
  end

  def wrapper_class
    klaas = errors.is_a?(Hash) ? errors.dig(:wrapper, :class) : 'errors'
    klaas || 'errors'
  end

  def error_tag
    tag = errors.is_a?(Hash) ? errors.dig(:tag) : :span
    tag || :span
  end

  def error_class
    tag = errors.is_a?(Hash) ? errors.dig(:class) : 'error'
    tag || 'error'
  end
  
end