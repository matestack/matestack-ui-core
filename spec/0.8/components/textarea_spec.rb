require_relative '../../support/utils'
include Utils

describe 'Textarea Component', type: :feature, js: true do

  it 'Example 1' do

    class ExamplePage < Matestack::Ui::Page
      def response
        textarea
        textarea cols: 2, maxlength: 20
        textarea text: 'Prefilled'
      end
    end

    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
    <textarea></textarea>
    <textarea cols="2" maxlength="20"></textarea>
    <textarea>Prefilled</textarea>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
