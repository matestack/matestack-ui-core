module Matestack::Ui::Core::HtmlAttributes

  HTML_GLOBAL_ATTRIBUTES = [
    :accesskey, :class, :contenteditable, :data, :dir, :draggable, 
    :hidden, :id, :lang, :spellcheck, :style, :tabindex, :title, :translate
  ]

  HTML_EVENT_ATTRIBUTES = [
    :onafterprint, :onbeforeprint, :onbeforeunload, :onerror, :onhashchange, :onload, :onmessage, 
    :onoffline, :ononline, :onpagehide, :onpageshow, :onpopstate, :onresize, :onstorage, :onunload
  ]

  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods

    def inherited(subclass)
      super
      subclass.html_attributes *self.allowed_html_attributes
    end

    def html_attributes(*attributes)
      attributes.each do |attribute|
        allowed_html_attributes.push(attribute)
      end
    end

    def allowed_html_attributes
      @allowed_html_attributes.flatten!&.uniq! if defined? @allowed_html_attributes
      @allowed_html_attributes ||= []
    end

  end

  def html_attributes
    options.slice(*self.class.allowed_html_attributes).merge((options[:attributes] || {}))
  end

end