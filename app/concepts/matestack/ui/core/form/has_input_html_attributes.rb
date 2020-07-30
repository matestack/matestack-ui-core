module Matestack::Ui::Core::Form::HasInputHtmlAttributes

  def self.included(base)
    base.class_eval do
      html_attributes(
        :accept, :alt, :autocomplete, :autofocus, :checked, :dirname, :disabled, :form, :formaction, 
        :formenctype, :formmethod, :formnovalidate, :formtarget, :height, :list, :max, :maxlength, :min, :minlength, 
        :multiple, :name, :pattern, :placeholder, :readonly, :required, :size, :src, :step, :type, :value, :width
      )
    end
  end

end