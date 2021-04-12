require_relative '../../support/utils'
include Utils

describe 'Properties Mechanism', type: :feature, js: true do

  before :all do
    class PropertyComponent < Matestack::Ui::Component
      required :title
      required :foo
      optional :description, :bar
      optional :text

      def response
        paragraph ctx.title
        paragraph ctx.foo
        paragraph ctx.description
        paragraph ctx.bar
        paragraph ctx.text
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
      expect(page).to have_content("required property 'title' is missing for 'PropertyComponent'")
    end

    it 'should raise exception if other required property is missing' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title'
        end
      end

      visit '/example'
      expect(page).to have_content("required property 'foo' is missing for 'PropertyComponent'")
    end
  end

  describe 'defining properties' do
    it 'should define instance methods for required properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo'
        end
      end
      visit '/example'
      expect(page).to have_content('Title')
      expect(page).to have_content('Foo')
      prop_component = PropertyComponent.new(nil, title: 'Title', foo: 'Foo')
      expect(prop_component.context.respond_to?(:title)).to be(true)
      expect(prop_component.context.respond_to?(:foo)).to be(true)
    end

    it 'should define context with instance methods for optional properties' do
      class ExamplePage < Matestack::Ui::Page
        def response
          property_component title: 'Title', foo: 'Foo', description: 'Description', bar: 'Bar'
        end
      end
      visit '/example'
      expect(page).to have_content('Description')
      expect(page).to have_content('Bar')
      prop_component = PropertyComponent.new(nil, title: 'Title', foo: 'Foo')
      expect(prop_component.context.respond_to?(:description)).to be(true)
      expect(prop_component.context.respond_to?(:bar)).to be(true)
    end
  end

  it 'should be accesible in prepare' do
    class SetupComponent < Matestack::Ui::Component
      required :title, :desc
      def prepare
        @foo = ctx.title
        @bar = ctx.desc
      end
      def response
        plain @foo
        paragraph @foo
        paragraph @bar
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
      def response
        div do
          slot :first
          slot :second
        end
      end
      register_self_as :slot_component
    end

    class ExamplePage < Matestack::Ui::Page
      def response
        slot_component slots: { first: method(:some_slot), second: method(:other_slot) }
      end

      def some_slot
        paragraph 'Foo'
      end

      def other_slot
        paragraph 'bar'
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

  it 'should inherit optional attributes' do
    class Component < Matestack::Ui::Component
      optional :foobar, :response
      def response
      end
    end
    class AnotherComponent < Component
      optional :custom
    end
    another_component = AnotherComponent.new(nil, custom: 'hi', foobar: 'foobar', response: 'response')
    component = Component.new(nil, foobar: 'Foobar', response: 'Response')
    expect(another_component.context.respond_to? :custom).to be(true)
    expect(another_component.context.custom).to eq('hi')
    expect(another_component.context.respond_to? :foobar).to be(true)
    expect(another_component.context.foobar).to eq('foobar')
    expect(another_component.context.respond_to? :response).to be(true)
    expect(another_component.context.response).to eq('response')
    expect(component.context.respond_to? :foobar).to be(true)
    expect(component.context.respond_to? :response).to be(true)
  end

  it 'should inherit required attributes' do
    class Component < Matestack::Ui::Component
      required :foobar, :response
      def response
      end
    end
    class AnotherComponent < Component
      required :custom2
    end
    another_component = AnotherComponent.new(nil, custom2: 'hi', foobar: 'foobar', response: 'response')
    component = Component.new(nil, foobar: 'Foobar', response: 'Response')
    expect(another_component.context.respond_to? :custom2).to be(true)
    expect(another_component.context.custom2).to eq('hi')
    expect(another_component.context.respond_to? :foobar).to be(true)
    expect(another_component.context.foobar).to eq('foobar')
    expect(another_component.context.respond_to? :response).to be(true)
    expect(another_component.context.response).to eq('response')
    expect(component.context.respond_to? :foobar).to be(true)
    expect(component.context.respond_to? :response).to be(true)
  end

  it 'should do something :D' do
    class Component2 < Matestack::Ui::Component
      optional :foobar
    end
    class AnotherComponent2 < Component2
      optional :foobar
    end
    another_component = AnotherComponent2.new(nil, foobar: 'another_component')
    expect(another_component.context.respond_to? :foobar).to be(true)
    expect(another_component.context.foobar).to eq('another_component')
    component = Component2.new(nil, foobar: 'component')
    expect(component.context.respond_to? :foobar).to be(true)
    expect(component.context.foobar).to eq('component')
  end

  it 'should create instance method with given alias name for required properties' do
    class AliasPropertyComponent < Matestack::Ui::Component
      required method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    class AnotherAliasPropertyComponent < Matestack::Ui::Component
      required :bla, method: { as: :my_method }, response: { as: :test }
      def response
      end
    end
    component = AliasPropertyComponent.new(nil, method: 'Its my method', response: 'Response')
    another_component = AnotherAliasPropertyComponent.new(nil, bla: 'hi', method: 'Its my method', response: 'Response')
    expect(component.context.respond_to? :my_method).to be(true)
    expect(component.context.my_method).to eq('Its my method')
    expect(component.context.respond_to? :test).to be(true)
    expect(component.context.test).to eq('Response')
    expect(another_component.context.bla).to eq('hi')
    expect(another_component.context.my_method).to eq('Its my method')
    expect(another_component.context.test).to eq('Response')
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
    component = OptionalAliasPropertyComponent.new(nil, method: 'Its my method', response: 'Response')
    another_component = AnotherOptionalAliasPropertyComponent.new(nil, bla: 'hi', method: 'its my method', response: 'response')
    expect(component.context.respond_to? :my_method).to be(true)
    expect(component.context.my_method).to eq('Its my method')
    expect(component.context.respond_to? :test).to be(true)
    expect(component.context.test).to eq('Response')
    expect(another_component.context.bla).to eq('hi')
    expect(another_component.context.my_method).to eq('its my method')
    expect(another_component.context.test).to eq('response')
    expect(component.context.test).to eq('Response')
  end

end
