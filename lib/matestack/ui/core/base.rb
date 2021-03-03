require_relative 'tag_helper'

module Matestack
  module Ui
    module Core
      class Base
        include ActionView::Helpers::TagHelper
        # include Webpacker::Helper
        include ActionView::Helpers::AssetTagHelper

        include Matestack::Ui::Core::Properties
        include Matestack::Ui::Core::TagHelper

        CORE_COMPONENTS = [
          Matestack::Ui::Core::Base,
        ]

        attr_accessor :html_tag, :text, :options, :parent, :escape, :bind_to_parent

        def initialize(html_tag = nil, text = nil, options = {}, &block)
          self.bind_to_parent = ([:without_parent].include?(html_tag) ? false : true)
          self.slots = self.options.delete(:slots) if self.options
          # extract_options(text, options) is called in properties
          self.html_tag = html_tag if self.bind_to_parent
          self.escape = self.options.delete(:escape) || true
          self.parent = Matestack::Ui::Core::Context.parent
          self.parent.children << self if self.parent if self.bind_to_parent
          Matestack::Ui::Core::Context.parent = self
          # create children
          create_children(&block)
          Matestack::Ui::Core::Context.parent = self.parent
          self
        end

        # check if text is given and set text and options accordingly
        def extract_options(text, options)
          if text.is_a? Hash
            self.options = text
            warn "[DEPRECATION] passing text with option :text is deprecated. Please pass text as first argument." if self.options.has_key?(:text)
            self.text = self.options.delete(:text)
          else
            self.text = text
            self.options = options || {}
          end
        end

        # create child items by either running the response method if exists or executing the block
        # overwrite if needed (like in pages or apps)
        def create_children(&block)
          if respond_to?(:response)
            self.response &block
          else 
            instance_eval &block if block_given?
          end
        end

        def self.call(text = nil, options = {}, &block)
          self.new(nil, text, options, &block).render_content
        end

        def children
          @children ||= []
        end

        def render_content
          if children.empty?
            child_content = self.escape ? ERB::Util.html_escape(text) : text if text
          else
            child_content = children.map { |child| child.render_content }.join.html_safe
          end
          result = ''
          if self.html_tag
            result = tag.public_send(self.html_tag, child_content, self.options || {})
          else
            result = child_content
          end
          result
        end

        def params
          Matestack::Ui::Core::Context.params || ActionController::Parameters.new({})
        end

        def method_missing(name, *args, &block)
          parent = self
          while parent.present? && CORE_COMPONENTS.include?(parent.class)
            return parent.send(name, *args, &block) if parent.respond_to?(name)
            parent = parent.parent
          end
          return parent.send(name, *args, &block) if parent.respond_to?(name)
          return Matestack::Ui::Core::Context.controller.view_context.send(name, *args, &block) if Matestack::Ui::Core::Context.controller.view_context.respond_to?(name, true)
          return raise NameError, "#{name} is not defined for #{parent}", caller
        end

      end
    end
  end
end