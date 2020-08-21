class Demo::Pages::MySecondPage < Matestack::Ui::Page

  def prepare
    @technologies = ["Rails", "Vue.js", "Trailblazer", "Rspec", "Capybara"]
  end

  def response
    heading size: 2, text: "This is Page 2"

    some_fancy_card

    div id: "technologies" do
      ul do
        @technologies.each do |technology|
          li do
            plain "matestack uses #{technology}"
          end
        end
      end
    end
  end

end
