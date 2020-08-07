require_relative '../support/utils'
include Utils

describe 'Video Component', type: :feature, js: true do

  it 'Renders a simple video tag on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        video path: 'corgi.mp4', type: "mp4", width: 500, height: 300
      end
    end

    visit '/example'
    expected_html_output = <<~HTML
      <video height="300" width="500">
        <source src="#{ActionController::Base.helpers.asset_path('corgi.mp4')}" type="video/mp4" />
        Your browser does not support the video tag.
      </video>
    HTML
  end

  it 'Renders a video tag with more attributes on the page' do
    class ExamplePage < Matestack::Ui::Page
      def response
        video path: 'corgi.mp4', type: "mp4", width: 500, height: 300,  autoplay: true, controls: true, loop: true, muted: true, playsinline: false, preload: 'auto'
      end
    end

    visit '/example'
    static_output = page.html
    expected_html_output = <<~HTML
      <video autoplay="autoplay" controls="controls" height="300" loop="loop" muted="muted" preload="auto" width="500">
        <source src="#{ActionController::Base.helpers.asset_path('corgi.mp4')}" type="video/mp4" />
        Your browser does not support the video tag.
      </video>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_html_output))
  end
end
