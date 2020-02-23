describe "Turbolinks", type: :feature, js: true do
  describe "when turbolinks is enabled" do
    it "enables the main Vue component on turbolinks:ready" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            heading text: "Hello world"
          }
        end
      end

      visit "/example_turbolinks"

      static_output = page.html
      expect(static_output).to include("<h1></h1>")
    end
  end

  describe "when turbolinks is not enabled" do
    it "enables the main Vue component on page load" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            heading text: XSS::EVIL_SCRIPT
          }
        end
      end

      visit "/example"

      static_output = page.html
      expect(static_output).to include("<h1></h1>")
    end
  end
end
