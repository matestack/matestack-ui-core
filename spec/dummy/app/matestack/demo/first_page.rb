class Demo::FirstPage < ApplicationPage

  optional :user

  def response
    Demo::Components::Header.(slots: { first: method(:a_slot), user: method(:stuff) })
    header slots: { first: method(:a_slot), user: method(:stuff) }, user: 'Nils', foo: :bar
    h1 'First page with new logic!', data: { foo: :bar }
    transition 'Second Page', path: second_path
    abbr title: 'test'

    isolate_test rerender_on: 'isolate', public_options: { foo: :bar }, defer: 1000

    rails_render partial: '/some_partial', locals: { foo: 1 }
    rails_render template: '/some_view', locals: { foo: 1 }

    # integrating toggle component
    toggle show_on: 'show' do
      div 'I am toggable'
    end

    div class: 'foo', 'foo'=>123 do
      plain 'Hello'
    end

    div do
      plain content
    end

    onclick emit: 'show', data: { foo: :bar } do
      button 'Klick!'
    end

    async id: 'time', rerender_on: 'show' do
      div ::Time.now
      async id: 'another-time', rerender_on: 'time' do
        div ::Time.now, style: 'margin: 10px;'
        async id: 'another-time-2', rerender_on: 'time-2' do
          div ::Time.now, style: 'margin: 20px;'
        end
      end
    end

    onclick emit: 'time', data: { foo: :bar } do
      button 'Inner Time'
    end

    onclick emit: 'time-2', data: { foo: :bar } do
      button 'Inner Time 2'
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
    div content
    paragraph number
  end

  def stuff
    b ctx.user
  end

  def content
    'Slot with method content'
  end

end
