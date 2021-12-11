class Demo::App < Matestack::Ui::App

  def response
    h1 "Demo App"

    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/app.rb"
    end

    nav do
      transition path: first_page_path do
        button "First Page"
      end
      transition path: second_page_path do
        button "Second Page"
      end
    end

    main do
      yield
    end
  end

end
