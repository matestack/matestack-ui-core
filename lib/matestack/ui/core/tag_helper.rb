require_relative 'slots'
require_relative 'plain_builder_wrapper'

module Matestack
  module Ui
    module Core
      module TagHelper
        extend Gem::Deprecate
        include Slots

        # can't take content or a block
        VOID_TAGS = %i[area base br col hr img input link meta param command keygen source]

        TAGS = [:a, :abbr, :acronym, :address, :applet, :area, :article, :aside, :audio, :b, :base, :basefont, :bdi, :bdo, :big, :blockquote, :body, :br, :button, :canvas, :caption, :center, :cite, :code, :col, :colgroup, :data, :datalist, :dd, :del, :details, :dfn, :dialog, :dir, :div, :dl, :dt, :em, :embed, :fieldset, :figcaption, :figure, :font, :footer, :form, :frame, :frameset, :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hr, :html, :i, :iframe, :img, :input, :ins, :kbd, :label, :legend, :li, :link, :main, :map, :mark, :meta, :meter, :nav, :noframes, :noscript, :object, :ol, :optgroup, :option, :output, :paragraph, :param, :picture, :pre, :progress, :q, :rp, :rt, :ruby, :s, :samp, :script, :section, :select, :small, :source, :span, :strike, :strong, :style, :sub, :summary, :sup, :svg, :table, :tbody, :td, :template, :textarea, :tfoot, :th, :thead, :time, :title, :tr, :track, :tt, :u, :ul, :var, :video, :wbr]

        DEFAULT_RAILS_PLAIN_METHODS_PATCH_MODULES = %w[ActionView::Helpers::UrlHelper ActionView::Helpers::AssetTagHelper]
        SUPPORTED_GEMS_PLAIN_METHODS = {
          simple: {
            :Kaminari => %w[paginate]
          },
          block: {
            :SimpleForm => %w[simple_form_for]
          }
        }

        DEFAULT_RAILS_PLAIN_BUILDER_METHODS_PATCH_MODULES = %w[
          form_with form_for
        ]

        VOID_TAGS.each do |tag|
          define_method tag do |options = {}|
            Matestack::Ui::Core::Base.new(tag, nil, options)
          end
        end

        TAGS.each do |tag|
          define_method tag do |text = nil, options = {}, &block|
            tag = :p if tag == :paragraph
            Matestack::Ui::Core::Base.new(tag, text, options, &block)
          end
        end

        def plain(text=nil, options=nil, &block)
          if block_given?
            Matestack::Ui::Core::Base.new(nil, yield, options)
          else
            Matestack::Ui::Core::Base.new(nil, text, options)
          end
        end

        def unescape(text)
          Matestack::Ui::Core::Base.new(nil, text&.html_safe, escape: false)
        end
        alias unescaped unescape

        # override image in order to implement automatically using rails assets path
        def img(text = nil, options = {}, &block)
          # if :src attribut given try to replace automatically
          if src = text.delete(:path)
            text[:src] = ActionController::Base.helpers.asset_path(src)
          end
          Matestack::Ui::Core::Base.new(:img, text, options, &block)
        end

        def a(text = nil, options = {}, &block)
          # if :path attribut given rename to href
          if text.is_a?(Hash)
            text[:href] = text.delete(:path) if text[:href].nil?
          else
            options[:href] = options.delete(:path) if options[:href].nil?
          end
          Matestack::Ui::Core::Base.new(:a, text, options, &block)
        end

        # support old heading component
        def heading(text = nil, options=nil, &block)
          if text.is_a?(Hash)
            options = text
          end

          case options[:size]
          when 1
            h1(text, options, &block)
          when 2
            h2(text, options, &block)
          when 3
            h3(text, options, &block)
          when 4
            h4(text, options, &block)
          when 5
            h5(text, options, &block)
          when 6
            h6(text, options, &block)
          else
            h1(text, options, &block)
          end
        end

        def rails_render(options = {})
          plain render options
        end

        def detached(text=nil, options=nil, &block)
          options = {} if options.nil?
          options[:detach_from_parent] = true
          Matestack::Ui::Core::Base.new(nil, text, options, &block)
        end

        def detached_to_s(text=nil, options=nil, &block)
          detached(text, options, &block).to_str
        end

        def self.register_plain_method(method, block: false)
          if block
            define_method method do |*args, **opts, &b|
              plain do
                super(*args, **opts) do |builder|
                  matestack_to_s do
                    b.call(PlainBuilderWrapper.new(self, builder))
                  end
                end
              end
            end
          else
            define_method method do |*args, **opts, &b|
              if b
                args.unshift(matestack_to_s { b.call })
              end

              plain { super(*args, **opts) }
            end
          end
        end

        DEFAULT_RAILS_PLAIN_METHODS_PATCH_MODULES.filter_map do |mod|
          next unless Object.const_defined?(mod)
          Object.const_get(mod).instance_methods(false)
        end.flatten.each { |method| register_plain_method(method) }

        DEFAULT_RAILS_PLAIN_BUILDER_METHODS_PATCH_MODULES.each do |method|
          register_plain_method(method, block: true)
        end

        SUPPORTED_GEMS_PLAIN_METHODS[:simple].each do |mod, methods|
          next unless Object.const_defined?(mod)
          methods.each do |method|
            register_plain_method(method)
          end
        end

        SUPPORTED_GEMS_PLAIN_METHODS[:block].each do |mod, methods|
          next unless Object.const_defined?(mod)
          methods.each do |method|
            register_plain_method(method, block: true)
          end
        end

        alias matestack_to_s detached_to_s

      end
    end
  end
end
