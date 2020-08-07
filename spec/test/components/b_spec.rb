require_relative "../support/utils"
include Utils

describe 'B Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple b
        b do
          plain 'I am simple'
        end
        # enhanced b
        b id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <b>I am simple</b>
      <b id="my-id" class="my-class">I am enhanced</b>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple b
        b text: 'I am simple'
        # enhanced b
        b id: 'my-id', class: 'my-class',text: 'I am enhanced'        
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <b>I am simple</b>
      <b id="my-id" class="my-class">I am enhanced</b>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
