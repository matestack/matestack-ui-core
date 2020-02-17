# Tested through its instance, the other functions are thoroughly
# used elsewhere
describe Matestack::Ui::Core::Component::Registry do
  let(:dsl_module) { Module.new }
  let(:instance) { Matestack::Ui::Core::Component::Registry::Instance.new(dsl_module)}
  let(:component_class) { Class.new }
  let(:component_class2) { Class.new }
  let(:dsl_class) do
    my_module = dsl_module
    Class.new do
      include my_module

      # interface
      def add_child(*args)
      end
    end
  end
  let(:dsl_instance) do
    instance = dsl_class.new
    allow(instance).to receive(:add_child)
    instance
  end

  describe "#register_component" do
    it "registers a new dsl function on the module" do
      instance.register_component(:foo, component_class)

      expect(dsl_module.public_instance_methods(false)).to eq [:foo]
    end

    it "methods work on the dsl instance" do
      instance.register_component(:magic, component_class)

      dsl_instance.magic
      dsl_instance.magic 2, 3

      expect(dsl_instance).to have_received(:add_child).with(component_class, nil)
      expect(dsl_instance).to have_received(:add_child).with(component_class, 2, 3, nil)
    end

    it "can give you an overview of the registered components" do
      instance.register_component(:foo, component_class)
      instance.register_component(:bar, component_class2)

      expect(instance.registered_components).to eq(
        foo: component_class,
        bar: component_class2
      )
    end

    it "registering multiple components and also with aliases" do
      instance.register_component(:foo, component_class)
      instance.register_component(:bar, component_class2)
      instance.register_component(:other_foo, component_class)

      dsl_instance.foo :foo
      dsl_instance.other_foo 2
      dsl_instance.bar

      expect(dsl_instance).to have_received(:add_child).with(component_class, :foo, nil)
      expect(dsl_instance).to have_received(:add_child).with(component_class, 2, nil)
      expect(dsl_instance).to have_received(:add_child).with(component_class2, nil)
    end

    it "handles simple blocks appropriately" do
      instance.register_component(:block_me, component_class)

      dsl_instance.block_me { 2 + 2 }

      expect(dsl_instance).to have_received(:add_child).with(component_class, Proc)
    end

    it "handles arguments + block appropriately" do
      instance.register_component(:block_me2, component_class)

      dsl_instance.block_me2 arg: "great" do 42 end

      expect(dsl_instance).to have_received(:add_child).with(component_class, {arg: "great"}, Proc)
    end

    describe "warnings & errors when trying to redefine" do
      # Rather easy to implement, left for later
    end
  end
end
