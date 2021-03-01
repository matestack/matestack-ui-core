module Matestack
  module Ui
    module Core
      module Helper
        
        def self.included(base)
          base.extend ClassMethods
          base.class_eval do
            include ComponentRegistry
          end
        end
        
        module ClassMethods
          def inherited(subclass)
            subclass.matestack_app(@matestack_app)
            super
          end
          
          def matestack_app(app = nil)
            @matestack_app = app ? app : @matestack_app
          end
        end
        
        def render(*args)
          if args.first.is_a?(Class) && args.first.ancestors.include?(Base)
            setup_context
            raise 'expected a hash as second argument' unless args.second.is_a?(Hash) || args.second.nil?
            options = args.second || {}
            app = options.delete(:app) || self.class.matestack_app
            page = args.first
            if app && params[:only_page].nil? && params[:component_key].nil?
              render_app app, page, options
            else
              if params[:component_key]
                render_component page, params[:component_key], options
              else
                render_page page, options
              end
            end
          else
            super
          end
        end
        
        def render_app(app, page, options)
          render html: app.new(options) { page.new(options) }.render_content.html_safe, layout: false
        end
        
        def render_page(page, options)
          render html: page.new(options).render_content.html_safe, layout: false
        end
        
        def render_component(page, component_key, options)
          page.new(options)
          render html: Matestack::Ui::Core::Context.async_components[component_key].render_content.html_safe, layout: false
        end
        
        def setup_context
          Matestack::Ui::Core::Context.params = self.params
          Matestack::Ui::Core::Context.controller = self
        end
        
      end
    end
  end
end