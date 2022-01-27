class Demo::VueJs::Layout < Matestack::Ui::Layout

  def response
    h1 "Demo VueJs App"

    matestack_vue_js_app do

      paragraph do
        plain "play around! --> spec/dummy/app/matestack/demo/vue_js/app.rb"
      end

      nav do
        transition path: demo_vue_js_first_page_path do
          button "First Page"
        end
        transition path: demo_vue_js_second_page_path do
          button "Second Page"
        end
      end

      main do
        # TODO: inject optional loading state element here?
        page_switch do
          yield
        end
      end

    end
  end

end
