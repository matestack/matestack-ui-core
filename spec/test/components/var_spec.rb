require_relative '../support/utils'
include Utils

describe 'Var Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # example 1
        var id: "foo", class: "bar" do
          plain 'I get yielded'
        end
        # example 2
        var id: "foo", class: "bar", text: 'I am text'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <var id="foo" class="bar">I get yielded</var>
      <var id="foo" class="bar">I am text</var>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
