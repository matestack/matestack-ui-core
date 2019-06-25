require "generator_spec"
require 'generators/matestack_page/matestack_page_generator'

describe MatestackPageGenerator, type: :generator do
  let(:dummy) {File.expand_path(File.join(__FILE__, '..', '..', '..', 'dummy'))}
  let(:dummy_copy) {File.expand_path(File.join(__FILE__, '..', '..', '..', 'dummy_copy'))}

  before :each do
    FileUtils.cp_r dummy, dummy_copy
  end

  after :each do
    FileUtils.rm_rf dummy
    FileUtils.cp_r dummy_copy, dummy
    FileUtils.rm_rf dummy_copy
  end

  destination Rails.root

  it "creates a test page" do
    run_generator %w(my_example_page my_app)

    assert_file "app/matestack/pages/my_app/my_example_page.rb", /class Pages::MyApp::MyExamplePage < Matestack::Page\b/
  end

end
