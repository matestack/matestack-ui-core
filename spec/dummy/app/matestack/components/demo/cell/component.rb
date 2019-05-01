class Components::Demo::Cell::Component < Component::Cell::Dynamic

  def response
    components {
      div id: "my-component" do
        heading size: 2, text: @options[:heading_text]
        button attributes: {"@click": "callApi()"} do
          plain "Call API"
        end
        ul do
          li attributes: {"v-for": "item in data"} do
            plain "{{item}}"
          end
        end
      end
    }
  end

end
