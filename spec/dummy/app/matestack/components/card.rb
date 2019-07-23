class Components::Card < Matestack::Ui::StaticComponent

  def response
    components {
      div id: "my-component" do
        plain "card"
      end
    }
  end

end
