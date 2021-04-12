class Demo::Index < Matestack::Ui::Page

  def response
    h1 'Test'
    100.times do
      div do
        div do
          div do
            div do
              div do
                div do
                  b 'Nested Content'
                end
              end
            end
          end
        end
      end
    end
    100.times do |i|
      # Demo::Components::SomeComponent.(name: i)
      some_component name: i
    end
  end

end