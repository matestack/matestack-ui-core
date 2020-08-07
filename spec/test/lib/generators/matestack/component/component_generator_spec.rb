# require "generator_spec"
# require 'generators/matestack/component/component_generator'
#
# describe Matestack::Generators::ComponentGenerator, type: :generator do
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
#   it "creates a custom static component" do
#     run_generator %w(example_component)
#
#     assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::StaticComponent\b/
#   end
#
#   it "creates a custom dynamic component" do
#     run_generator %w(example_component --dynamic)
#
#     assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::DynamicComponent\b/
#     assert_file "app/matestack/components/example_component.js", /custom-example_component\b/
#   end
#
#   it "creates a haml file with the haml option" do
#     run_generator %w(example_component --haml)
#
#     assert_file "app/matestack/components/example_component.haml", %r{.example_component{@tag_attributes}}
#     assert_file "app/matestack/components/example_component.haml", /This is your custom ExampleComponent component/
#   end
#
#   it "creates a scss file with the scss option" do
#     run_generator %w(example_component --scss)
#
#     assert_file "app/matestack/components/example_component.scss", %r{// your styles for the component ExampleComponent go here}
#   end
#
#   it "creates a custom component in the right namespace" do
#     run_generator %w(example_component --namespace example_namespace --dynamic --scss --haml)
#
#     assert_file "app/matestack/components/example_namespace/example_component.rb", /class Components::ExampleNamespace::ExampleComponent < Matestack::Ui::DynamicComponent/
#     assert_file "app/matestack/components/example_namespace/example_component.js", /custom-example_namespace-example_component/
#     assert_file "app/matestack/components/example_namespace/example_component.js", %r{require example_namespace/example_component}
#     assert_file "app/matestack/components/example_namespace/example_component.haml"
#     assert_file "app/matestack/components/example_namespace/example_component.scss"
#   end
#
# end
