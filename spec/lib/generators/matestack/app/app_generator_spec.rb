require 'generator_spec'
require 'generators/matestack/app/app_generator'

describe Matestack::Generators::AppGenerator, type: :generator do
  let(:dummy) { File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', 'dummy')) }
  let(:dummy_copy) { File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', 'dummy_copy')) }

  before :each do
    FileUtils.cp_r dummy, dummy_copy
  end

  after :each do
    FileUtils.rm_rf dummy
    FileUtils.cp_r dummy_copy, dummy
    FileUtils.rm_rf dummy_copy
  end

  destination Rails.root

  it "creates an example app" do
    run_generator %w(my_example_app)

    assert_file "app/matestack/apps/my_example_app.rb", /class Apps::MyExampleApp < Matestack::Ui::App\b/
  end

  it "creates an example app with --all_inclusive flag" do
    run_generator %w(my_example_app --all_inclusive)

    assert_file "app/matestack/apps/my_example_app.rb", /class Apps::MyExampleApp < Matestack::Ui::App\b/
    assert_file "app/controllers/my_example_app_controller.rb", /class MyExampleAppController < ApplicationController\b/
    assert_file "config/routes.rb", /my_example_app\b/
    assert_file "app/matestack/pages/my_example_app/example_page.rb", /class Pages::MyExampleApp::ExamplePage < Matestack::Ui::Page\b/
  end

end
