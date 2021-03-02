class Demo::App < Matestack::Ui::App

  def response
    html do
      head do
        unescape csrf_meta_tags
        unescape javascript_pack_tag('application')
      end
    end
    body do
      matestack do
        h1 'App'
        yield
      end
    end
  end

end