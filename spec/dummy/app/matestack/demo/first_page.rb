class Demo::FirstPage < Matestack::Ui::Page

  def response
    # Demo::Components::Header.()
    header slots: { first: a_slot(1), second: a_slot(3) }
    h1 'First page with new logic!'
    transition path: second_path do
      button 'Second Page'
    end
    abbr title: 'test'

    rails_render partial: '/some_partial', locals: { foo: 1 }
    rails_render file: '/some_view', locals: { foo: 1 }

    # integrating toggle component
    toggle show_on: 'show' do
      div 'I am toggable'
    end

    onclick emit: 'show', data: { foo: :bar } do
      button 'Klick!'
    end

  end

  def a_slot(number)
    slot do
      div content
      paragraph number
    end
  end

  def content
    'Slot with method content'
  end

end