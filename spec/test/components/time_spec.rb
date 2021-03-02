require_relative '../support/utils'
include Utils

describe 'Time Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple time tag
        paragraph do
          plain 'This should show '
          time class: 'my-simple-time' do
            plain '12:00'
          end
        end
        # time tag with timestamp
        paragraph id: 'my-parent-paragraph' do
          plain 'Today is '
          time id: 'example-timestamp', datetime: DateTime.new(2019,2,12,10,38,39,'+02:00') do
            plain 'July 7'
          end
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <p>This should show <time class="my-simple-time">12:00</time></p>
      <p id="my-parent-paragraph">
        Today is <time id="example-timestamp" datetime="2019-02-12T10:38:39+02:00">July 7</time>
      </p>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
