require_relative '../../support/utils'
include Utils

describe 'Youtube Component', type: :feature, js: true do

  it 'Example 1' do
    class ExamplePage < Matestack::Ui::Page
      def response
        # simple youtube video
        youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I', class: 'iframe'
        # youtube video with start_at and no_controls
        youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I', start_at: 30, no_controls: true
        # youtube video with start_at and privacy_mode
        youtube height: 360, width: 360, yt_id: 'OY5AeGhgK7I', start_at: 30, privacy_mode: true
      end
    end

    visit '/example'
    static_output = page.html
    expect(page).to have_selector("iframe[src='https://www.youtube.com/embed/OY5AeGhgK7I'][class='iframe']")
    expect(page).to have_selector("iframe[src='https://www.youtube.com/embed/OY5AeGhgK7I?controls=0&amp;start=30']")
    expect(page).to have_selector("iframe[src='https://www.youtube-nocookie.com/embed/OY5AeGhgK7I?start=30']")
  end

end
