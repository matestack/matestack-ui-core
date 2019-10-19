require "generator_spec"
require 'generators/matestack/component/component_generator'

describe Matestack::Generators::ComponentGenerator, type: :generator do
  let(:dummy) {File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', 'dummy'))}
  let(:dummy_copy) {File.expand_path(File.join(__FILE__, '..', '..', '..', '..', '..', 'dummy_copy'))}

  before :each do
    FileUtils.cp_r dummy, dummy_copy
  end

  after :each do
    FileUtils.rm_rf dummy
    FileUtils.cp_r dummy_copy, dummy
    FileUtils.rm_rf dummy_copy
  end

  destination Rails.root

  it "creates a custom static component" do
    run_generator %w(example_component)

    assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::StaticComponent\b/
  end

  it "creates a custom dynamic component" do
    run_generator %w(example_component --dynamic)

    assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::DynamicComponent\b/
    assert_file "app/matestack/components/example_component.js", /custom-example_component\b/
  end

  it "creates a haml file with the haml option" do
    run_generator %w(example_component --haml)

    assert_file "app/matestack/components/example_component.haml", %r{.example_component{@tag_attributes}}
    assert_file "app/matestack/components/example_component.haml", /This is your custom ExampleComponent component/
  end

  it "creates a scss file with the scss option" do
    run_generator %w(example_component --scss)

    assert_file "app/matestack/components/example_component.scss", %r{// your styles for the component ExampleComponent go here}
  end

  it "creates a custom component in the right namespace" do
    run_generator %w(example_component --namespace example_namespace --dynamic --scss --haml)

    assert_file "app/matestack/components/example_namespace/example_component.rb", /class Components::ExampleNamespace::ExampleComponent < Matestack::Ui::DynamicComponent/
    assert_file "app/matestack/components/example_namespace/example_component.js", /custom-example_namespace-example_component/
    assert_file "app/matestack/components/example_namespace/example_component.js", %r{require example_namespace/example_component}
    assert_file "app/matestack/components/example_namespace/example_component.haml"
    assert_file "app/matestack/components/example_namespace/example_component.scss"
  end

end
