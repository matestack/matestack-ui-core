class Apps::ComponentsTestsWithApp < App::Cell::App

  def response
    components {
      page_content
    }
  end

end
