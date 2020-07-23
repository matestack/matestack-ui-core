require_relative "../../support/utils"
include Utils

describe 'Ins Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple ins
        ins do
          plain 'I am simple'
        end
        # enhanced ins
        ins id: 'my-id', class: 'my-class' do
          plain 'I am enhanced'
        end
        # ins with cite and datetime
        ins cite: 'example.html', datetime: '2008-05-25T17:25:00Z' do
          plain 'I have cite and datetime'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <ins>I am simple</ins>
      <ins id="my-id" class="my-class">I am enhanced</ins>
      <ins cite="example.html" datetime="2008-05-25T17:25:00Z">I have cite and datetime</ins>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple ins
        ins text: 'I am simple'
        # enhanced ins
        ins id: 'my-id', class: 'my-class', text: 'I am enhanced'
        # ins with cite and datetime
        ins cite: 'example.html', datetime: '2008-05-25T17:25:00Z', text: 'I have cite and datetime'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <ins>I am simple</ins>
      <ins id="my-id" class="my-class">I am enhanced</ins>
      <ins cite="example.html" datetime="2008-05-25T17:25:00Z">I have cite and datetime</ins>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
