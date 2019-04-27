class Pages::MyApp::MyFirstPage < Page::Cell::Page

  def response
    components {
      div do
        plain "hello from page 1"
      end
    }
  end

end
