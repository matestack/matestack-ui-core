class Components::Mycomponent::Cell::Mycomponent < Component::Cell::Static

  def response
    components {
      plain "This is a custom static component!"
    }
  end

end
