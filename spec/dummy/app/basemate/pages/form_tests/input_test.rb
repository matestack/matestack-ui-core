class Pages::FormTests::InputTest < Page::Cell::Page

  def response
    components {
      form do
        input id: "my-id", class: "my-class"
        submit do
          button id: "submit-button", text: "submit"
        end
      end
    }
  end

end
