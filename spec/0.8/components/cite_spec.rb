require_relative "../../support/utils"
include Utils

describe 'Cite Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple cite
        cite do
          plain 'I am simple'
        end
        # enhanced cite
        cite id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
    <cite>I am simple</cite>
    <cite id="my-id" class="my-class">I am enhanced</cite>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple cite
        cite text: 'I am simple'
        # enhanced cite
        cite id: 'my-id', class: 'my-class', text: 'I am enhanced'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
    <cite>I am simple</cite>
    <cite id="my-id" class="my-class">I am enhanced</cite>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
