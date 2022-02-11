class Demo::Core::Pages::SecondPage < Matestack::Ui::Page

  def response
    h2 "Second Page"

    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/core/pages/second_page.rb"
    end

    # you can call components on pages:
    Demo::Core::Components::StaticComponent.call(foo: "baz")
  end

end
