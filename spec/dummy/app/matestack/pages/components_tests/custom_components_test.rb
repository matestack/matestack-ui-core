require_relative "../../../../../support/components"

class Pages::ComponentsTests::CustomComponentsTest < Page::Cell::Page


  def response
    components {
      mycomponent
    }
  end

end
