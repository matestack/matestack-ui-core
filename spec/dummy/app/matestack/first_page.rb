class FirstPage < Matestack::Ui::Page

  def response
    h1 'First page with new logic!'
    abbr title: 'test'

    rails_render partial: '/some_partial', locals: { foo: 1 }
    rails_render file: '/some_view', locals: { foo: 1 }
  end

end