class Demo::Core::Layout < Matestack::Ui::Layout

  def response
    h1 "Demo Core App"

    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/core/app.rb"
    end

    nav do
      a path: demo_core_first_page_path do
        button "First Page"
      end
      a path: demo_core_second_page_path do
        button "Second Page"
      end
    end

    main do
      yield
    end
  end

end
