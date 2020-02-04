describe "XSS behavior", type: :feature, js: true do

  describe "injection in heading as an example" do
    it "escapes the evil script" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            heading text: XSS::EVIL_SCRIPT
          }
        end
      end

      visit "/example"

      static_output = page.html
      expect(static_output).to include("<h1>\n#{XSS::ESCAPED_EVIL_SCRIPT}\n</h1>")
    end

    it "does not escape when we specifically say #html_safe" do
      class ExamplePage < Matestack::Ui::Page
        def response
          components {
            heading text: XSS::EVIL_SCRIPT.html_safe
          }
        end
      end

      # gotta accept our injected alert
      accept_alert do
        visit "/example"
      end

      # for reasons beyond me Chrome seems to remove our injected script tag,
      # but since we accepted an alert to get here this test should be fine
    end

    it "escapes the evil when injecting into attributes" do
      class ExamplePage < Matestack::Ui::Page

        def response
          components {
            heading text: "Be Safe!", id: "something-\"#{XSS::EVIL_SCRIPT}"
          }
        end

      end

      visit "/example"

      expect(page.html).to include("id=\"something-&quot;<script>alert('hello');</script>")
    end
  end
end
