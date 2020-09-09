require_relative '../../support/utils'
include Utils

describe 'Properties Mechanism', type: :feature, js: true do

  before :all do
    class PropertyComponent < Matestack::Ui::Component
      requires :title
      requires :foo
      optional :description, :bar
      optional :text

      def response
        paragraph text: title
        paragraph text: foo
        paragraph text: description
        paragraph text: bar
        paragraph text: text
      end

      register_self_as :property_component
    end
  end

  describe 'missing requires' do
    it 'should raise exception if required property is missing' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component
        end
      end

      visit '/example'
      expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyMissingException.to_s)
      expect(page).to have_content('Required property title is missing for PropertyComponent')
    end

    it 'should raise exception if other required property is missing' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title'
        end
      end

      visit '/example'
      expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyMissingException.to_s)
      expect(page).to have_content('Required property foo is missing for PropertyComponent')
    end
  end

  describe 'defining methods' do
    it 'should define instance methods for required properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo'
        end
      end
      visit '/example'
      expect(page).to have_content('Title')
      expect(page).to have_content('Foo')
      prop_component = PropertyComponent.new(title: 'Title', foo: 'Foo')
      expect(prop_component.respond_to?(:title)).to be(true)
      expect(prop_component.respond_to?(:foo)).to be(true)
    end

    it 'should define instance methods for optional properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo', description: 'Description', bar: 'Bar'
        end
      end
      visit '/example'
      expect(page).to have_content('Description')
      expect(page).to have_content('Bar')
      prop_component = PropertyComponent.new(title: 'Title', foo: 'Foo')
      expect(prop_component.respond_to?(:description)).to be(true)
      expect(prop_component.respond_to?(:bar)).to be(true)
    end
  end

  it 'should raise exception if required property overwrites existing method' do
    class TempPropertyComponent < Matestack::Ui::Component
      requires :response
      def response
      end
      register_self_as :temp_property_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        temp_property_component response: 'Foobar'
      end
    end

    visit '/example'
    expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyOverwritingExistingMethodException.to_s)
    expect(page).to have_content('Required property "response" would overwrite already defined instance method for TempPropertyComponent')
  end

  it 'should raise exception if optional property overwrites existing method' do
    class TempOptionalPropertyComponent < Matestack::Ui::Component
      optional :response
      def response
      end
      register_self_as :temp_optional_property_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        temp_optional_property_component response: 'Foobar'
      end
    end

    visit '/example'
    expect(page).to have_content(Matestack::Ui::Core::Properties::PropertyOverwritingExistingMethodException.to_s)
    expect(page).to have_content('Optional property "response" would overwrite already defined instance method for TempOptionalPropertyComponent')
  end

  it 'should create instance method with given alias name for required properties' do
    class AliasPropertyComponent < Matestack::Ui::Component
      requires method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    class AnotherAliasPropertyComponent < Matestack::Ui::Component
      requires :bla, method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    component = AliasPropertyComponent.new(method: 'Its my method', response: 'Response')
    another_component = AnotherAliasPropertyComponent.new(bla: 'hi', method: 'Its my method', response: 'Response')
    expect(component.respond_to? :my_method).to be(true)
    expect(component.my_method).to eq('Its my method')
    expect(component.respond_to? :test).to be(true)
    expect(component.test).to eq('Response')
    expect(another_component.bla).to eq('hi')
    expect(another_component.my_method).to eq('Its my method')
    expect(another_component.test).to eq('Response')
  end

  it 'should create instance method with given alias name for optional properties' do
    class OptionalAliasPropertyComponent < Matestack::Ui::Component
      optional method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    class AnotherOptionalAliasPropertyComponent < Matestack::Ui::Component
      optional :bla, method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    component = OptionalAliasPropertyComponent.new(method: 'Its my method', response: 'Response')
    another_component = AnotherOptionalAliasPropertyComponent.new(bla: 'hi', method: 'Its my method', response: 'Response')
    expect(component.respond_to? :my_method).to be(true)
    expect(component.my_method).to eq('Its my method')
    expect(component.respond_to? :test).to be(true)
    expect(component.test).to eq('Response')
    expect(another_component.bla).to eq('hi')
    expect(another_component.my_method).to eq('Its my method')
    expect(another_component.test).to eq('Response')
  end

  it 'should be accesible in setup' do
    class SetupComponent < Matestack::Ui::Component
      requires :title, :desc
      def setup
        @foo = title
      end
      def prepare
        @bar = desc
      end
      def response
        plain @foo
        paragraph text: @foo
        paragraph text: @bar
      end
      register_self_as :setup_component
    end
    class ExamplePage < Matestack::Ui::Page
      def response
        setup_component title: 'Foo', desc: 'Bar'
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <p>Foo</p>
      <p>Bar</p>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'should work with slots' do
    class SlotComponent < Matestack::Ui::Component
      requires slot: { as: :some_slot }
      optional :other_slot
      def response
        div do
          slot some_slot
          slot other_slot
        end
      end
      register_self_as :slot_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        slot_component slot: some_slot, other_slot: other_slot
      end

      def some_slot
        slot do
          paragraph text: 'Foo'
        end
      end

      def other_slot
        slot do
          paragraph text: 'bar'
        end
      end
    end

    visit '/example'
    static_output = page.html
    expected_static_output = <<~HTML
      <div>
        <p>Foo</p>
        <p>bar</p>
      </div>
    HTML
    expect(stripped(static_output)).to include(stripped(expected_static_output))
  end

  it 'should be inheritable' do
    class Component < Matestack::Ui::Component
      optional :foobar, response: { as: :test }
      def response
      end
    end
    class AnotherComponent < Component
      optional :custom
    end
    component = Component.new(foobar: 'Foobar', response: 'Response')
    another_component = AnotherComponent.new(custom: 'hi', foobar: 'foobar', response: 'response')
    expect(component.respond_to? :foobar).to be(true)
    expect(component.respond_to? :test).to be(true)
    expect(another_component.respond_to? :custom).to be(true)
    expect(another_component.custom).to eq('hi')
    expect(another_component.respond_to? :foobar).to be(true)
    expect(another_component.foobar).to eq('foobar')
    expect(another_component.respond_to? :test).to be(true)
    expect(another_component.test).to eq('response')
  end

end
