require_relative '../support/utils'
include Utils

describe "XSS behavior", type: :feature, js: true do

  describe "injection in heading as an example" do
    it "escapes the evil script" do
      class ExamplePage < Matestack::Ui::Page
        def response
          heading text: XSS::EVIL_SCRIPT
        end
      end

      visit "/example"
      static_output = page.html
      expect(static_output).to include("<h1>#{XSS::ESCAPED_EVIL_SCRIPT}</h1>")
    end

    it "does not escape when we specifically say #html_safe" do
      class ExamplePage < Matestack::Ui::Page
        def response
          heading text: XSS::EVIL_SCRIPT.html_safe
        end
      end

      # gotta accept our injected alert
      accept_alert do
        visit "/example"
      end

      # for reasons beyond me Chrome seems to remove our injected script tag,
      # but since we accepted an alert to get here this test should be fine
    end

    # note that `heading do "string" end` doesn't work and you
    # should rather use `heading do plain "string" end`
    # Why the hell is this tested then?
    # Well if that behavior changed I'd like to have a reminder
    # here to catch it. Call me overly cautious.
    it "escaping won't be broken in block form (if it worked)" do
      class ExamplePage < Matestack::Ui::Page
        def response
          heading do
            XSS::EVIL_SCRIPT
          end
        end
      end

      visit "/example"
      static_output = page.html
      expect(static_output).not_to include("alert(")
    end

    it "escapes the evil when injecting into attributes" do
      class ExamplePage < Matestack::Ui::Page
        def response
          heading text: "Be Safe!", id: "something-\">#{XSS::EVIL_SCRIPT}"
        end
      end

      visit "/example"
      expect(page.html).to include("id=\"something-&quot;&gt;&lt;script&gt;alert('hello');&lt;/script&gt;")
    end
  end
end
