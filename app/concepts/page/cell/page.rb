module Page::Cell
  class Page < Trailblazer::Cell

    include ActionView::Helpers::TranslationHelper
    include ::Cell::Haml
    include ::Matestack::Ui::Core::ApplicationHelper
    include ::Shared::Utils::ToCell

    view_paths << "#{Matestack::Ui::Core::Engine.root}/app/concepts"

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
      @nodes = ::Page::Utils::PageNode.build(self, nil, &block)
    end

    def nodes_to_cell
      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"])
      end
    end

    def partial(&block)
      return block
      # ::Page::Utils::PageNode.build(self, included, &block)
    end

    def slot(&block)
      # return block
      ::Page::Utils::PageNode.build(self, nil, &block)
    end


    def show(component_key=nil, only_page=false)
      prepare
      response

      render_mode = nil
      render_mode = :only_page if only_page == true
      render_mode = :render_page_with_app if !@app_class.nil? && only_page == false
      render_mode = :only_page if @app_class.nil? && only_page == false
      render_mode = :render_component if !component_key.nil?

      case render_mode

      when :only_page
        nodes_to_cell
        # keys_array = ["div_2","components", "partial_1", "components", "form_1"]
        # puts @nodes.dig(*keys_array)
        render :page
      when :render_page_with_app
        concept(@app_class).call(:show, @page_id, @nodes)
      when :render_component
        if component_key.include?("__")
          keys_array = component_key.gsub("__", "__components__").split("__").map {|k| k.to_s}
          page_content_keys = keys_array.select{|key| key.match(/^page_content_/)}
          if page_content_keys.any?
            keys_array = keys_array.drop(keys_array.find_index(page_content_keys[0])+2)
          end
          node = @nodes.dig(*keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"])
          return cell.render_content
        else
          node = @nodes[component_key]
          cell = to_cell(component_key, node["component_name"], node["config"], node["argument"], node["components"], node["included_config"])
          return cell.render_content
        end
      end
    end


    def page_id
      @custom_page_id ||= @page_id
    end

    private

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
