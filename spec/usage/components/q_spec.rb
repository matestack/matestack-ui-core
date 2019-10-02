require_relative "../../support/utils"
include Utils

describe "Q Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          #simple q
          q text: "A simple quote"

          # enhanced q
          q id: 'my-id', class: 'my-class', cite: 'www.matestack.org/example' do
            plain 'This is a enhanced q with text'
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <q>A simple quote</q>

    <q id="my-id" class="my-class"></q>

    <q cite="www.matestack.org/example" id="my-id" class="my-class">This is a enhanced q with text</q>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
