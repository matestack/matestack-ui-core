# frozen_string_literal: true

require_relative '../support/utils'
include Utils

describe 'Em Component', type: :feature, js: true do
  it 'Example 1 - yield, no options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple em tag
        em do
          plain 'Emphasized text'
        end
        # enhanced em tag
        em id: 'my-id', class: 'my-class' do
          plain 'Enhanced emphasized text'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <em>Emphasized text</em>
      <em id="my-id" class="my-class">Enhanced emphasized text</em>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple em
        em text: 'Emphasized text'
        # enhanced em
        em id: 'my-id', class: 'my-class', text: 'Enhanced emphasized text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <em>Emphasized text</em>
      <em id="my-id" class="my-class">Enhanced emphasized text</em>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
