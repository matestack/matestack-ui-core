require 'rails_core_spec_helper'

describe 'Action View Integration', type: :feature do
  include CoreSpecUtils

  it "using non-block view helpers via plain" do
    class ExamplePage < Matestack::Ui::Page
      def response
        link_to "Test Link without plain", "/some/page" # calling an ActionView Url Helper here
        plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here

        span id: "time-ago-in-words-example" do
          plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
        end

        span id: "path-helper-example" do
          plain "root_path: #{root_path}" # calling a Path Helper here
        end
      end
    end

    visit "/example"

    expect(page).not_to have_selector("a[href='/some/page']", text: "Test Link without plain")
    expect(page).to have_selector("a[href='/some/page']", text: "Test Link")
    expect(page).to have_selector("span#time-ago-in-words-example", text: "3 minutes")
    expect(page).to have_selector("span#path-helper-example", text: "root_path: /")
  end

  it "using block view helpers via plain do ... end and matestack_to_s" do
    class ExamplePage < Matestack::Ui::Page
      def response
        # not working, missing plain wrapper and matestack_to_s
        link_to "/some/page" do
          span do
            plain "link content in block without wrapping plain and matestack_to_s"
          end
        end
        # not working, missing matestack_to_s
        plain do
          link_to "/some/page" do
            span do
              plain "link content in block with wrapping plain but without matestack_to_s"
            end
          end
        end
        # working
        plain do
          link_to "/some/page" do
            matestack_to_s do
              span do
                plain "link content in block with wrapping plain and matestack_to_s"
              end
            end
          end
        end
      end
    end

    visit "/example"

    expect(page).not_to have_selector("a[href='/some/page'] > span", text: "link content in block without wrapping plain and matestack_to_s")
    expect(page).not_to have_selector("a[href='/some/page'] > span", text: "link content in block with wrapping plain but without matestack_to_s")
    expect(page).to have_selector("a[href='/some/page'] > span", text: "link content in block with wrapping plain and matestack_to_s")
  end

  it "using block view helpers via plain do ... end and matestack_to_s and block variables" do
    class ExamplePage < Matestack::Ui::Page
      def response
        plain do
          form_with url: "/some_path" do |f|
            matestack_to_s do
              plain f.text_field :foo
              br
              div class: "some-input-wrapper" do
                plain f.text_field :bar
              end
              br
              some_partial_rendering_view_helpers(f)
              br
              some_partial
              br
              plain f.submit
            end
          end
        end
      end

      def some_partial
        div class: "some-partial" do
          plain "text from partial"
        end
      end

      def some_partial_rendering_view_helpers f
        div class: "some-input-wrapper-in-partial" do
          plain f.text_field :baz
        end
      end
    end

    visit "/example"

    expect(page).to have_selector("form[action='/some_path'] > input#foo[type='text']")
    expect(page).to have_selector("form[action='/some_path'] > div.some-input-wrapper > input#bar[type='text']")
    expect(page).to have_selector("form[action='/some_path'] > div.some-input-wrapper-in-partial > input#baz[type='text']")
    expect(page).to have_selector("form[action='/some_path'] > div.some-partial", text: "text from partial")
    expect(page).to have_selector("form[action='/some_path'] > input[type='submit']")
  end

end
