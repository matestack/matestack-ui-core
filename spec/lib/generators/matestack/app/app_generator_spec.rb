require 'generator_spec'
require 'generators/matestack/app/app_generator'

describe Matestack::Generators::AppGenerator, type: :generator do
  let(:dummy_routes) { 'spec/dummy/config/routes.rb' }
  let(:dummy_routes_copy) { 'spec/dummy/tmp/config/routes.rb' }

  before :each do
    FileUtils.mkdir 'spec/dummy/tmp/config' if !File.exists?('spec/dummy/tmp/config')
    FileUtils.cp dummy_routes, dummy_routes_copy
  end

  after :each do
    FileUtils.rm_rf('spec/dummy/tmp/app') if File.exists?('spec/dummy/tmp/app')
  end

  destination "#{Rails.root}/tmp"

  it "creates an example app" do
    run_generator %w(my_example_app)

    assert_file "app/matestack/apps/my_example_app.rb", /class Apps::MyExampleApp < Matestack::Ui::App\b/
  end

  it "creates an example app with --all_inclusive flag" do
    run_generator %w(my_example_app --all_inclusive)

    assert_file "app/matestack/apps/my_example_app.rb", /class Apps::MyExampleApp < Matestack::Ui::App\b/
    assert_file "app/controllers/my_example_app_controller.rb", /class MyExampleAppController < ApplicationController\b/
    assert_file "config/routes.rb", /my_example_app\b/
    # assert_file "app/matestack/pages/my_example_app/example_page.rb", /class Pages::MyExampleApp::ExamplePage < Matestack::Ui::Page\b/
  end

end
