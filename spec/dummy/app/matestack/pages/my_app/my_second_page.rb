class Pages::MyApp::MySecondPage < Page::Cell::Page

  def prepare
    @technologies = ["Rails", "Vue.js", "Trailblazer", "Rspec", "Capybara"]
  end

  def response
    components{
      div id: "technologies" do
        ul do
          @technologies.each do |technology|
            li do
              plain "matestack uses #{technology}"
            end
          end
        end
      end
    }
  end

end
