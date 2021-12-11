class Demo::Pages::FirstPage < Matestack::Ui::Page

  def response
    h2 "First page"
    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/pages/first_page.rb"
    end

    # you can call components on pages:
    Demo::Components::StaticComponent.call(foo: "bar")
  end

end
