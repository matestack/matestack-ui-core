# used in specs only, look for the demo app here: ./demo/app.rb

class App < Matestack::Ui::Layout

  def response
    matestack_vue_js_app do
      page_switch do
        yield
      end
    end
  end

end
