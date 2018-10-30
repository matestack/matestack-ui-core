class Pages::ComponentsTests::DivTest < Page::Cell::Page

  def response
    components {
      div

      div do
        plain "div content"
      end

      div class: "my-class", id: "my-id" do
        plain "div content"
      end
    }
  end

end
