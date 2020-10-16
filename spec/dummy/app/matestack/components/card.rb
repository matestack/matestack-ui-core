class Components::Card < Matestack::Ui::StaticComponent

  def response
    li id: "my-component" do
      plain "card"
    end
  end

end
