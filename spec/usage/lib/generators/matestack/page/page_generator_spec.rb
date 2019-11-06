require 'generator_spec'
require 'generators/matestack/page/page_generator'

describe Matestack::Generators::PageGenerator, type: :generator do
  let(:dummy) { File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', '..', 'dummy')) }
  let(:dummy_copy) { File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', '..', 'dummy_copy')) }

  before :each do
    FileUtils.cp_r dummy, dummy_copy
  end

  after :each do
    FileUtils.rm_rf dummy
    FileUtils.cp_r dummy_copy, dummy
    FileUtils.rm_rf dummy_copy
  end

  destination Rails.root

  it "creates example page" do
    run_generator %w(my_example_page --app_name my_app)

    assert_file "app/matestack/pages/my_app/my_example_page.rb", /class Pages::MyApp::MyExamplePage < Matestack::Ui::Page\b/
    assert_file "config/routes.rb", /my_app#my_example_page/
  end

  it 'create example page with namespace' do
    run_generator %w(my_example_page --app_name my_app --namespace sample_namespace)

    assert_file "app/matestack/pages/my_app/sample_namespace/my_example_page.rb", /class Pages::SampleNamespace::MyApp::MyExamplePage < Matestack::Ui::Page\b/
    assert_file "config/routes.rb", %r{my_app/sample_namespace/my_example_page}
    assert_file "config/routes.rb", /my_app#my_example_page/
  end

  it 'create example page with controller_action' do
    run_generator %w(my_example_page --app_name my_app --controller_action custom#action)

    assert_file "app/matestack/pages/my_app/my_example_page.rb", /class Pages::MyApp::MyExamplePage < Matestack::Ui::Page\b/
    assert_file "config/routes.rb", /custom#action/
  end

  it 'create example page with namespace and controller_action' do
    run_generator %w(my_example_page --app_name my_app --namespace sample_namespace --controller_action custom#action)

    assert_file "app/matestack/pages/my_app/sample_namespace/my_example_page.rb", /class Pages::SampleNamespace::MyApp::MyExamplePage < Matestack::Ui::Page\b/
    assert_file "config/routes.rb", %r{my_app/sample_namespace/my_example_page}
    assert_file "config/routes.rb", /custom#action/
  end

end
