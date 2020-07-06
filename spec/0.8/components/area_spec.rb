require_relative "../../support/utils"
include Utils

describe "Address Component", type: :feature, js: true do
  it "Example 1 - yield a given block" do

    class ExamplePage < Matestack::Ui::Page
      def response
        area shape: :rect, coords: [1,2,3,4], href: '#', hreflang: 'de', media: "screen", rel: 'nofollow', target: :_blank
      end
    end
    
    visit "/example"
    static_output = page.html
    expected_static_output = <<~HTML
    <area coords="1,2,3,4" href="#" hreflang="de" media="screen" rel="nofollow" shape="rect" target="_blank" />
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
