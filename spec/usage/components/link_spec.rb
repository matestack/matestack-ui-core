require_relative '../../support/utils'
include Utils

describe 'Link Component', type: :feature, js: true do

  it 'Example 1 - Text Option' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link path: "https://matestack.org", text: 'here'
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="https://matestack.org">here</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

  it 'Example 2 - Yield' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link path: "https://matestack.org" do
              plain 'here'
            end
          end

        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="https://matestack.org">here</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

  it 'Example 3 - Target' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link path: "https://matestack.org", target: "_blank" do
              plain 'here'
            end
          end

        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="https://matestack.org" target="_blank">here</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

  it 'Example 4 - Rails Routing' do

    Rails.application.routes.append do
      get '/some_link_test_path', to: 'page_test#my_action', as: 'link_test'
    end
    Rails.application.reload_routes!

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link path: :link_test_path do
              plain 'here'
            end
          end

        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="/some_link_test_path">here</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

  it 'Example 5 - Rails Routing using symbols' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link text: 'Click', path: :inline_edit_path
          end
        }
      end

    end

    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="/my_app/inline_edit">Click</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

  it 'Example 6 - Rails Routing using symbols with params' do

    class ExamplePage < Matestack::Ui::Page

      def response
        components {
          div id: "foo", class: "bar" do
            link path: :single_endpoint_path, params: {number: 1}, text: 'Call API endpoint 1'
          end

        }
      end

    end
    visit "/example"

    static_output = page.html

    expected_static_output = <<~HTML
    <div id="foo" class="bar">
      <a href="/api/data/1">Call API endpoint 1</a>
    </div>
    HTML

    expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  end

end
