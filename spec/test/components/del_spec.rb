require_relative "../support/utils"
include Utils
RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 10_000
describe 'Del Component', type: :feature, js: true do

  it 'Example 1 - yield, no options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple del
        del cite: 'http://citeurl.com', datetime: '2019-01-01T00:00:00Z' do
          plain 'I am simple'
        end
        # enhanced del
        del id: 'my-id', class: 'my-class', cite: 'http://citeurl.com', datetime: '2019-01-01T00:00:00Z' do
          plain 'I am enhanced'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <del cite=\"http://citeurl.com\" datetime=\"2019-01-01T00:00:00Z\">I am simple</del>
      <del id=\"my-id\" class=\"my-class\" cite=\"http://citeurl.com\" datetime=\"2019-01-01T00:00:00Z\">I am enhanced</del>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'Example 2 - render options[:text]' do

    class ExamplePage < Matestack::Ui::Page
      def response
        # simple del
        del cite: 'http://citeurl.com', datetime: '2019-01-01T00:00:00Z', text: 'I am simple'
        # enhanced del
        del id: 'my-id', class: 'my-class', cite: 'http://citeurl.com', datetime: '2019-01-01T00:00:00Z', text: 'I am enhanced'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <del cite=\"http://citeurl.com\" datetime=\"2019-01-01T00:00:00Z\">I am simple</del>
      <del id=\"my-id\" class=\"my-class\" cite=\"http://citeurl.com\" datetime=\"2019-01-01T00:00:00Z\">I am enhanced</del>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
