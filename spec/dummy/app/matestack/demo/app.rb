class Demo::App < Matestack::Ui::App

  def response
    html do
      head do
        unescape csrf_meta_tags
        plain Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag('application').html_safe
      end
      body do
        matestack do
          h1 'App'
          yield
        end
      end
    end
  end

end