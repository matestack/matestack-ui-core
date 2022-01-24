class Demo::Pages::FirstPage < Matestack::Ui::Page

  def response
    h2 "First page"

    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/pages/first_page.rb"
    end

    # you can call components on pages:
    Demo::Components::StaticComponent.call(foo: "bar")

    onclick emit: "foo" do
      button "emit foo"
    end

    async rerender_on: "foo", id: "some-async" do
      div do
        plain DateTime.now
      end
    end
  end

end
