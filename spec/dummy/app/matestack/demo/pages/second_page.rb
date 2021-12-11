class Demo::Pages::SecondPage < Matestack::Ui::Page

  def response
    h2 "Second Page"
    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/pages/second_page.rb"
    end

    # you can call components on pages:
    Demo::Components::StaticComponent.call(foo: "baz")
  end

end
