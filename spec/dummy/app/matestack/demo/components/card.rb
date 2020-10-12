class Demo::Components::Card < Matestack::Ui::StaticComponent

  def response
    div class: "my-component" do
      plain "demo card!"
    end
  end

end
