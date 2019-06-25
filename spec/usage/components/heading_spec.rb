require_relative "../../support/utils"
include Utils

describe "Heading Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          heading size: 1, id: "my-id", class: "my-class", text: "Heading"
          heading size: 2, id: "my-id", class: "my-class", text: "Heading"
          heading size: 3, id: "my-id", class: "my-class", text: "Heading"
          heading size: 4, id: "my-id", class: "my-class", text: "Heading"
          heading size: 5, id: "my-id", class: "my-class", text: "Heading"
          heading size: 6, id: "my-id", class: "my-class", text: "Heading"
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <h1 id="my-id" class="my-class">
      Heading
    </h1>
    <h2 id="my-id" class="my-class">
      Heading
    </h2>
    <h3 id="my-id" class="my-class">
      Heading
    </h3>
    <h4 id="my-id" class="my-class">
      Heading
    </h4>
    <h5 id="my-id" class="my-class">
      Heading
    </h5>
    <h6 id="my-id" class="my-class">
      Heading
    </h6>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it "Example 2" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          heading id: "my-id", class: "my-class", text: "Heading"
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <h1 id="my-id" class="my-class">
      Heading
    </h1>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it "Example 3" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          heading size:1, id: "my-id", class: "my-class" do
            plain "Heading"
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <h1 id="my-id" class="my-class">
      Heading
    </h1>
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

end
