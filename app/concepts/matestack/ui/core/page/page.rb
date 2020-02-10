module Matestack::Ui::Core::Page
  class Page < Trailblazer::Cell

    include ActionView::Helpers::TranslationHelper
    include Matestack::Ui::Core::Cell
    include Matestack::Ui::Core::ApplicationHelper
    include Matestack::Ui::Core::ToCell
    include Matestack::Ui::Core::HasViewContext
    include Matestack::Ui::Core::HasScopedI18n

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"

    extend ViewName::Flat

    def self.prefixes
      _prefixes = super
      modified_prefixes = _prefixes.map do |prefix|
        prefix_parts = prefix.split("/")

        if prefix_parts.last.include?(self.name.split("::")[-1].downcase)
          prefix_parts[0..-2].join("/")
        else
          prefix
        end

      end

      return modified_prefixes + _prefixes
    end

    def self.views_dir
      return ""
    end

    def initialize(model=nil, options={})
      super
      generate_page_name
      set_app_class
      @nodes = {}
      @cells = {}
      options[:controller_instance].instance_variables.each do |controller_instance_var_key|
        unless controller_instance_var_key.to_s.start_with?("@_")
          self.instance_variable_set(controller_instance_var_key, options[:controller_instance].instance_variable_get(controller_instance_var_key))
        end
      end
    end

    def prepare
      true
    end

    def components(&block)
      @nodes = Matestack::Ui::Core::PageNode.build(self, nil, context[:params], &block)
    end

    def nodes_to_cell
      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
      end
    end

    def partial(&block)
      return block
    end

    def slot(&block)
      Matestack::Ui::Core::PageNode.build(self, nil, context[:params], &block)
    end

    def isolate(&block)
      return block
    end


    def show(component_key=nil, only_page=false)
      prepare
      return resolve_isolated_component(component_key) if !component_key.nil? && component_key.include?("isolate")

      response

      render_mode = nil
      render_mode = :only_page if only_page == true
      render_mode = :render_page_with_app if !@app_class.nil? && only_page == false
      render_mode = :only_page if @app_class.nil? && only_page == false
      render_mode = :render_component if !component_key.nil?

      case render_mode

      when :only_page
        nodes_to_cell
        render :page
      when :render_page_with_app
        concept(@app_class).call(:show, @page_id, @nodes)
      when :render_component
        begin
          render_child_component component_key
        rescue => e
          raise "Component '#{component_key}' could not be resolved, because of #{e},\n#{e.backtrace.join("\n")}"
        end
      end
    end

    def page_id
      @custom_page_id ||= @page_id
    end

    def render_child_component component_key
      if component_key.include?("__")
        keys_array = component_key.gsub("__", "__components__").split("__").map {|k| k.to_s}
        page_content_keys = keys_array.select{|key| key.match(/^page_content_/)}
        if page_content_keys.any?
          keys_array = keys_array.drop(keys_array.find_index(page_content_keys[0])+2)
        end
        if @nodes.dig(*keys_array) == nil
          rest = []
          while @nodes.dig(*keys_array) == nil
            rest << keys_array.pop
          end
          node = @nodes.dig(*keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
          return cell.render_child_component component_key, rest.reverse[1..-1]
        else
          node = @nodes.dig(*keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
          return cell.render_content
        end
      else
        node = @nodes[component_key]
        cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
        return cell.render_content
      end
    end


    private

      def resolve_isolated_component component_key
        keys_array = component_key.gsub("__", "__components__").split("__").map {|k| k.to_s}
        isolate_keys = keys_array.select{|key| key.match(/^isolate_/)}
        keys_array = keys_array.drop(keys_array.find_index(isolate_keys[0])+2)
        isolated_scope_method = keys_array[0]
        if isolated_scope_method.include?("(")
          isolated_scope_method_name = isolated_scope_method.split("(").first
          isolated_scope_method_argument = isolated_scope_method.split("(").last.split(")").first
          isolated_scope_method_argument = JSON.parse(isolated_scope_method_argument)
          isolated_block = self.send(isolated_scope_method_name, isolated_scope_method_argument.with_indifferent_access)
        else
          isolated_block = self.send(isolated_scope_method)
        end
        nodes = Matestack::Ui::Core::PageNode.build(
          self, nil, context[:params], &isolated_block
        )
        node = nodes.dig(*keys_array.drop(2))
        cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"], node["cached_params"])
        return cell.render_content
      end

      def generate_page_name
        name_parts = self.class.name.split("::").map { |name| name.underscore }
        @page_id = name_parts.join("_")
      end

      def set_app_class
        class_name = self.class.name
        name_parts = class_name.split("::")
        if name_parts.count <= 2
          @app_class = nil
          return
        end

        app_name = "#{name_parts[1]}"
        begin
          app_class = Apps.const_get(app_name)
          if app_class.is_a?(Class)
            @app_class = app_class
          else
            require_dependency "apps/#{app_name.underscore}"
            app_class = Apps.const_get(app_name)
            if app_class.is_a?(Class)
              @app_class = app_class
            else
              @app_class = nil
            end
          end
        rescue
          @app_class = nil
        end
      end

  end
end
