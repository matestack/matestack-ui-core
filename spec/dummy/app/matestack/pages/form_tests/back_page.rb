class Pages::FormTests::BackPage < Page::Cell::Page

  def response
    components {
      plain "transition successful, got params #{context[:params]}"
    }
  end

end
