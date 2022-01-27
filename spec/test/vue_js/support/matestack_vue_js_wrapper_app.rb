class MatestackVueJsWrapperApp < Matestack::Ui::Layout
  def response
    matestack_vue_js_app do
      app_body
      page_switch do
        yield
      end
    end
  end

  def app_body

  end

end
