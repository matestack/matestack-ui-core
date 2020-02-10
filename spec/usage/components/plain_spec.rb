require_relative "../../support/utils"
include Utils

describe "Plain Component", type: :feature, js: true do

  it "Example 1" do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          plain "Hello World!"
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    Hello World!
    HTML

    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  describe "XSSing" do
    it "doesn't allow script injection" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            plain XSS::EVIL_SCRIPT
          }
        end
      end

      visit "/example"

      expect(page.html).to include(XSS::ESCAPED_EVIL_SCRIPT)
    end

    it "allows injection when you say #html_safe" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            plain XSS::EVIL_SCRIPT.html_safe
          }
        end
      end

      # gotta accept our injected alert
      accept_alert do
        visit "/example"
      end

      # the script tag seems removed afterwards so we can't check against it here
    end
  end
end
