class Demo::Core::Pages::FirstPage < Matestack::Ui::Page

  def response
    h2 "First page"

    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/core/pages/first_page.rb"
    end

    # you can call components on pages:
    Demo::Core::Components::StaticComponent.call(foo: "bar")
  end

end
