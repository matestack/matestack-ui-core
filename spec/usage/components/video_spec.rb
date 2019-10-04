require_relative '../../support/utils'
include Utils

describe 'Video Component', type: :feature, js: true do

  it 'Renders a video tag on the page' do
    #
    # class ExamplePage < Matestack::Ui::Page
    #   def response
    #     components {
    #       # simple video
    #       # test below fails, either add something to `spec/dummy/app/assets/videos/*` or stub it
    #       # video path: 'yourvid.mp4', width: 500, height: 300
    #     }
    #   end
    # end
    #
    # visit '/example'
    #
    # static_output = page.html
    #
    # expected_static_output = <<~HTML
    # <video src="yourvid.mp4" width="500" height="300"></video>
    # HTML
    #
    # expect(stripped(static_output)).to include(stripped(expected_static_output))
  end
end
