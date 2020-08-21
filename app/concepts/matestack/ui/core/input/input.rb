module Matestack::Ui::Core::Input
  class Input < Matestack::Ui::Core::Component::Static
    
    html_attributes :accept, :alt, :autocomplete, :autofocus, :checked, :dirname, :disabled, :form, :formaction, 
      :formenctype, :formmethod, :formnovalidate, :formtarget, :height, :list, :max, :maxlength, :min, :minlength, 
      :multiple, :name, :pattern, :placeholder, :readonly, :required, :size, :src, :step, :type, :value, :width

    def type
      options[:type]
    end

  end
end
