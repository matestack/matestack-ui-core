class Demo::FirstPage < Matestack::Ui::Page

  def response
    # Demo::Components::Header.()
    header slots: { first: a_slot(1), second: a_slot(3) }, user: 'Nils'
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

    async id: 'time', rerender_on: 'show' do
      div Time.now
    end

    paragraph time_ago_in_words(1.minute.ago)

    action method: :post, path: action_path, success: { emit: 'success' }, confirm: true do
      div do
        button content
      end
    end

    cable id: 'test-cable', replace_on: :replace do
      div 'Start content'
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