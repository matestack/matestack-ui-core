# require 'generator_spec'
# require 'generators/matestack/page/page_generator'
#
# describe Matestack::Generators::PageGenerator, type: :generator do
#   let(:dummy_routes) { 'spec/dummy/config/routes.rb' }
#   let(:dummy_routes_copy) { 'spec/dummy/tmp/config/routes.rb' }
#
#   before :each do
#     FileUtils.mkdir 'spec/dummy/tmp/config' if !File.exists?('spec/dummy/tmp/config')
#     FileUtils.cp dummy_routes, dummy_routes_copy
#   end
#
#   after :each do
#     FileUtils.rm_rf('spec/dummy/tmp/app') if File.exists?('spec/dummy/tmp/app')
#   end
#
#   destination "#{Rails.root}/tmp"
#
#   it "creates example page" do
#     run_generator %w(my_example_page --app_name my_app)
#
#     assert_file "app/matestack/pages/my_app/my_example_page.rb", /class Pages::MyApp::MyExamplePage < Matestack::Ui::Page\b/
#     assert_file "config/routes.rb", /my_app#my_example_page/
#   end
#
#   it 'create example page with namespace' do
#     run_generator %w(my_example_page --app_name my_app --namespace sample_namespace)
#
#     assert_file "app/matestack/pages/my_app/sample_namespace/my_example_page.rb", /class Pages::SampleNamespace::MyApp::MyExamplePage < Matestack::Ui::Page\b/
#     assert_file "config/routes.rb", %r{my_app/sample_namespace/my_example_page}
#     assert_file "config/routes.rb", /my_app#my_example_page/
#   end
#
#   it 'create example page with controller_action' do
#     run_generator %w(my_example_page --app_name my_app --controller_action custom#action)
#
#     assert_file "app/matestack/pages/my_app/my_example_page.rb", /class Pages::MyApp::MyExamplePage < Matestack::Ui::Page\b/
#     assert_file "config/routes.rb", /custom#action/
#   end
#
#   it 'create example page with namespace and controller_action' do
#     run_generator %w(my_example_page --app_name my_app --namespace sample_namespace --controller_action custom#action)
#
#     assert_file "app/matestack/pages/my_app/sample_namespace/my_example_page.rb", /class Pages::SampleNamespace::MyApp::MyExamplePage < Matestack::Ui::Page\b/
#     assert_file "config/routes.rb", %r{my_app/sample_namespace/my_example_page}
#     assert_file "config/routes.rb", /custom#action/
#   end
#
# end
