class Demo::Components::Header < ApplicationComponent

  optional :user
 
  def response
    toggle hide_after: 3000 do
      div do
        h2 'THIS SHOULD HIDE AFTER 3 SECONDS'
      end
    end
    isolate_test rerender_on: 'isolate', public_options: { foo: :bar }
  end
 
 end
 