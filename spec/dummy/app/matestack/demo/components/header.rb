class Demo::Components::Header < ApplicationComponent

  optional :user

  def response
    h1 'This is a header'
    [1,2].each do |number|
      slot :first, number
    end
    slot :user
    toggle show_on: 'show', hide_on: 'hide' do
      div do
        h2 ctx.user
      end
    end
    isolate_test rerender_on: 'isolate', public_options: { foo: :bar }
  end

end