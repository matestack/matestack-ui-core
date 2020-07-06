class Demo::Components::Card < Matestack::Ui::StaticComponent

  def response
    components {
      div class: "my-component" do
        plain "demo card!"
      end
    }
  end

end
