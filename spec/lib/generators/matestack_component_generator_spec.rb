require "generator_spec"
require 'generators/matestack_component/matestack_component_generator'

describe MatestackComponentGenerator, type: :generator do
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

  it "creates a custom static component" do
    run_generator %w(example_component)

    assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::StaticComponent\b/
  end

  it "creates a custom dynamic component" do
    run_generator %w(example_component --dynamic)

    assert_file "app/matestack/components/example_component.rb", /class Components::ExampleComponent < Matestack::Ui::DynamicComponent\b/
    assert_file "app/matestack/components/example_component.js", /custom-example_component\b/
  end

end
