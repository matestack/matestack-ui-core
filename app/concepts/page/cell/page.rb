module Page::Cell
  class Page < Trailblazer::Cell

    include ActionView::Helpers::TranslationHelper
    include ::Cell::Haml
    include ::Basemate::Ui::Core::ApplicationHelper
    include ::Shared::Utils::ToCell

    view_paths << "#{Basemate::Ui::Core::Engine.root}/app/concepts"

    def initialize(model=nil, options={})
      super
      generate_page_name
      @nodes = {}
      @cells = {}
      options[:controller_instance].instance_variables.each do |controller_instance_var_key|
        unless controller_instance_var_key.to_s.start_with?("@_")
          self.instance_variable_set(controller_instance_var_key, options[:controller_instance].instance_variable_get(controller_instance_var_key))
        end
      end
      prepare
      response
    end

    def prepare
      true
    end

    def components(&block)
      @nodes = ::Page::Utils::PageNode.build(self, &block)

      @nodes.each do |key, node|
        @cells[key] = to_cell(key, node["component_name"], node["config"], node["argument"], node["components"])
      end
    end

    def partial(&block)
      ::Page::Utils::PageNode.build(self, &block)
    end

    def show(component_key=nil, app_key=nil)
      if app_key.nil? && component_key.nil?
        render :page
      elsif !app_key.nil? && component_key.nil?
        concept(App::Cell::App).call(:show) do
          render :page
        end
      elsif !component_key.nil?
        if component_key.include?("__")
          keys_array = component_key.gsub("__", "__components__").split("__").map {|k| k.to_s}
          node = @nodes.dig(*keys_array)
          cell = to_cell(component_key, node["component_name"], node["config"], node["components"])
          return cell.render_content
        else
          return @cells.dig(component_key).render_content
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


  end

end
