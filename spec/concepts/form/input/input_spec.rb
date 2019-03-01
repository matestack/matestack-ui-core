describe "form input", type: :feature, js: true do

  describe "validation of config"

  describe "basic rendering" do

    it "should get rendered without any options" do
      visit "/form_tests/input?valid_config=true"

      expect(page).to have_css('form input')
    end

    it "should get rendered with id and class" do
      visit "/form_tests/input?valid_config=true"

      expect(page).to have_xpath("//form/input[@id='my-id']")
      expect(page).to have_xpath("//form/input[@class='my-class']")
    end

  end

  describe "API interaction" do

    it "should send data to a given backend API, if successful sets input to nil" do
      visit "/form_tests/input?valid_config=true"
      fill_in 'my-id', :with => 'hello'

      input_element = page.find(:xpath, "//form/input[@id='my-id']")
      input_element.native.send_keys(:return)

      expect(find_field('my-id').value).to eq ''
    end

    it "should send data to a given backend API, if not successful leaves input as is and renders errors" do
      visit "/form_tests/input?valid_config=true"
      fill_in 'my-id', :with => 'world'

      input_element = page.find(:xpath, "//form/input[@id='my-id']")
      input_element.native.send_keys(:return)

      expect(find_field('my-id').value).to eq 'world'
      expect(page).to have_content "should be hello"
    end

  end

  describe "transition" do

    it "should send data to a given backend API, if successful can perform a transition" do
      visit "/form_tests/input?valid_config=true&transition=true"
      fill_in 'my-id', :with => 'hello'

      input_element = page.find(:xpath, "//form/input[@id='my-id']")
      input_element.native.send_keys(:return)

      expect(page).to have_content "transition successful"
      expect(page).to have_content '"param_one"=>"transition param"'
    end

  end

  # describe "notify" do
  #
  #   it "should send data to a given backend API, if successful can perform a transition" do
  #     visit "/form_tests/input?valid_config=true&notify=true"
  #     fill_in 'my-id', :with => 'hello'
  #
  #     input_element = page.find(:xpath, "//form/input[@id='my-id']")
  #     input_element.native.send_keys(:return)
  #
  #     expect(page).to have_content "submit successful"
  #   end
  #
  # end

end
