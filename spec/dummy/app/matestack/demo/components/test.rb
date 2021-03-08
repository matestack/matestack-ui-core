class Demo::Components::Test < Matestack::Ui::VueJsComponent
  vue_name 'test-component'

  def response
    div id: "my-component" do
      button "@click": "emitMessage(\"some_event\", \"hello event bus!\")" do
        plain "click me!"
      end
    end
  end

end