require 'rails_core_spec_helper'

describe "XSS behavior", type: :feature, js: true do
  include CoreSpecUtils

  describe "injection in heading as an example" do
    it "escapes the evil script" do
      matestack_render do
        h1 XSS::EVIL_SCRIPT
      end
      expect(page).to have_selector('h1', text: XSS::EVIL_SCRIPT)
      expect_alert false
    end

    it "does not escape when we specifically say #html_safe" do
      matestack_render do
        h1 XSS::EVIL_SCRIPT.html_safe
      end
      # gotta accept our injected alert
      accept_alert do
        expect_alert true
      end
    end

    # note that `heading do "string" end` doesn't work and you
    # should rather use `heading do plain "string" end`
    # Why the hell is this tested then?
    # Well if that behavior changed I'd like to have a reminder
    # here to catch it. Call me overly cautious.
    it "escaping won't be broken in block form (if it worked)" do
      matestack_render do
        h1 do
          XSS::EVIL_SCRIPT
        end
      end
      expect_alert false
      static_output = page.html
      expect(static_output).not_to include("alert(")
    end

    it "escapes the evil when injecting into attributes" do
      matestack_render do
        h1 "Be Safe!", id: "something-\">#{XSS::EVIL_SCRIPT}"
      end
      expect_alert false
      # expect(page.html).to include("id=\"something-&quot;&gt;&lt;script&gt;alert('hello');&lt;/script&gt;")
    end
  end



  def expect_alert(alert)
    @alert = true
    begin
      page.driver.browser.switch_to.alert
    rescue
      @alert = false
    end
    expect(@alert).to be(alert)
  end
end
