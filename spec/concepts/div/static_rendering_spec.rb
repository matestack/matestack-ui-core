describe "a div", type: :feature, js: true do
  # before :each do
  #   User.make(email: 'user@example.com', password: 'password')
  # end

  def visit_page
    visit '/components_tests/div'
  end

  def within_main_page_div &block
    within("#pages_components_tests_div_test") do
      yield
    end
  end

  it "can be rendered without any options and block" do
    visit_page
    within_main_page_div do
      div = all('div')[0]
      expect(div[:id]).to eq("")
      expect(div[:class]).to eq("")
      expect(div.text).to eq("")
    end
  end

  it "can be rendered without any options but with content" do
    visit_page
    within_main_page_div do
      div = all('div')[1]
      expect(div[:id]).to eq("")
      expect(div[:class]).to eq("")
      expect(div.text).to eq("div content")
    end
  end

  it "can be rendered with class and id option and content" do
    visit_page
    within_main_page_div do
      div = all('div')[2]
      expect(div[:id]).to eq("my-id")
      expect(div[:class]).to eq("my-class")
      expect(div.text).to eq("div content")
    end
  end
end
