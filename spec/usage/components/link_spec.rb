require_relative '../../support/utils'
include Utils

describe 'Link Component', type: :feature, js: true do
  # does not work at all. Maybe a problem with the dummy application?
  # it 'Example 1' do
  #
  #   class ExamplePage < Page::Cell::Page
  #
  #     def response
  #       components {
  #         div id: "foo", class: "bar" do
  #           link path: "https://matestack.org", text: 'here'
  #         end
  #         # div id: "foo", class: "bar" do
  #         #   link path: "https://matestack.org" do
  #         #     plain 'here'
  #         #   end
  #         # end
  #
  #       }
  #     end
  #
  #   end
  #
  #   visit "/example"
  #
  #   sleep 500
  #   static_output = page.html
  #
  #   expected_static_output = <<~HTML
  #   <div id="foo" class="bar">
  #     <a href="https://matestack.org">here</a>
  #   </div>
  #   HTML
  #
  #   expect(stripped(static_output)).to ( include(stripped(expected_static_output)) )
  # end

end
