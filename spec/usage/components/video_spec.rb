require_relative '../../support/utils'
include Utils

describe 'Video Component', type: :feature, js: true do

  it 'Renders a video tag on the page' do
     class ExamplePage < Matestack::Ui::Page
       def response
         components {
           video path: 'corgi.mp4', width: 500, height: 300
         }
       end
     end

     visit '/example'
     expect(page).to have_xpath("//video[contains(@src,'corgi.mp4') and @width='500' and @height='300']")
  end
end
