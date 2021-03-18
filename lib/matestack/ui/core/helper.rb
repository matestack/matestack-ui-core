module Matestack
  module Ui
    module Core
      module Helper
        
        def self.included(base)
          base.extend ClassMethods
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
            if app && params[:only_page].nil? && params[:component_key].nil? && params[:component_class].nil?
              render_app app, page, options
            else
              if params[:component_key] && params[:component_class].nil?
                render_component app, page, params[:component_key], options
              elsif params[:component_class]
                if params[:component_key]
                  render_component nil, params[:component_class].constantize, params[:component_key], JSON.parse(params[:public_options] || '{}')
                else 
                  render html: params[:component_class].constantize.(public_options: JSON.parse(params[:public_options] || '{}'))
                end
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
        
        def render_component(app, page, component_key, options)
          app ? app.new(options) { page.new(options) } : page.new(options) # create page structure in order to later access registered async components
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