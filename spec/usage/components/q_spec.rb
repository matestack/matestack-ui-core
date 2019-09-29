require_relative "../../support/utils"
include Utils

describe "Q Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          #simple q
          q

          #simple q with attributes
          q id: "my-id", class: "my-class"

          #nested q
          q do
            q id: "my-nested-q"
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <q></q>

    <q id="my-id" class="my-class"></q>

    <q>
      <q id="my-nested-q"></q>
    </q>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
