describe "form input", type: :feature, js: true do

  it "should get rendered without any options" do
    visit "/form_tests/input"

    expect(page).to have_css('form input')
  end

  it "should get rendered with id and class" do
    visit "/form_tests/input"

    expect(page).to have_xpath("//form/input[@id='my-id']")
    expect(page).to have_xpath("//form/input[@class='my-class']")
  end

  it "should send data to a given backend API" do
    visit "/form_tests/input"
    fill_in 'my-id', :with => 'my-input-text'

    input_element = page.find(:xpath, "//form/input[@id='my-id']")
    input_element.native.send_keys(:return)

    # expect input field to be empty afterwards
    # expect database result according to input
    # --> implement backend api
  end

end
