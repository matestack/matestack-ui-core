module Matestack::Ui::Core::Textarea
  class Textarea < Matestack::Ui::Core::Component::Static

    html_attributes :autofocus, :cols, :dirname, :disabled, :form, :maxlength, 
      :name, :placeholder, :readonly, :required, :rows, :wrap

    optional :text

  end
end
