require_relative '../../support/utils'
include Utils

describe 'Video Component', type: :feature, js: true do

  it 'Renders a simple video tag on the page' do
     class ExamplePage < Matestack::Ui::Page
       def response
         components {
           video path: 'corgi.mp4', width: 500, height: 300
         }
       end
     end

     visit '/example'

     expect(page).to have_xpath("//video[@width='500' and @height='300']")
     expect(page).to have_content('Your browser does not support the video tag.')
  end

  it 'Renders a video tag with more attributes on the page' do
     class ExamplePage < Matestack::Ui::Page
       def response
         components {
           video path: 'corgi.mp4', width: 500, height: 300,  autoplay: true, controls: true, loop: true, muted: true, playsinline: false, preload: 'auto'
         }
       end
     end

     visit '/example'

     expect(page).to have_xpath("//video[@width='500' and @height='300' and @autoplay and @controls and @loop and @muted and @preload='auto']")
     expect(page).to have_content('Your browser does not support the video tag.')
  end
end
