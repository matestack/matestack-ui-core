class App < Matestack::Ui::App

  def response
    html do
      head do
        unescape csrf_meta_tags
        unescape Matestack::Ui::Core::Context.controller.view_context.javascript_pack_tag(:application)
      end
    end
    body do
      matestack do
        yield
      end
    end
  end

end