require_relative "../../../support/utils"
include Utils

# In parts here Button and Plain are used as example for a working class,
# especially around DSL registrations.
# Elsewhere anonymous classes are used to not interfere with the other parts of
# the system too much.
describe Matestack::Ui::Core::Base do

  describe "#initialize" do
    # TODO: This seems to be the existing semantics
    it "sets @options to the hash if passed after parent" do
      instance = described_class.new id: "something"

      expect(instance.model).to eq id: "something"
      expect(instance.instance_variable_get(:@options)).to eq id: "something"
    end
  end

  describe "#add_child" do
    let(:child_class) { described_class }
    let(:child) { subject.children.first }

    it "has the component available in its children" do
      subject.add_child child_class

      expect(subject.children).to include(child_class)
    end

    it "can pass some arguments" do
      subject.add_child child_class, text: "Hello World"

      expect(child).to be_a child_class
      expect(child.model).to include(text: "Hello World")
    end

    it "can even pass a block that's being evaluated" do
      accessible_child_class = child_class
      subject.add_child child_class do
        add_child accessible_child_class, "Content"
      end

      expect(child.children.size).to eq 1
      grand_child = child.children.first

      expect(grand_child.model).to eq "Content"
    end

    it "child with block with 2 children" do
      accessible_child_class = child_class
      subject.add_child child_class do
        add_child accessible_child_class, "1"
        add_child accessible_child_class, "2"
      end

      expect(child.children.size).to eq 2
      expect(child.children.map(&:model)).to eq ["1", "2"]
    end
  end

  describe "DSLing" do
    context "call self defined methods" do
      let(:custom_component_class) do
        Class.new(described_class) do
          include Matestack::Ui::Core::DSL

          def body
            my_button
          end

          private

          def my_button
            button text: "My Button"
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "calls the custom function without fail" do
        custom_component.body

        expect(custom_component.children.size).to eq 1
        child = custom_component.children.first

        expect(child.model).to include text: "My Button"
      end
    end

    context "DSLing with blocks" do
      let(:custom_component_class) do
        Class.new(described_class) do
          include Matestack::Ui::Core::DSL

          def body
            button id: 'foo', class: 'bar' do
              plain "Click me"
            end
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "calls the block without fail" do
        custom_component.body

        expect(custom_component.children.size).to eq 1
        button = custom_component.children.first

        expect(button.model).to include id: "foo", class: "bar"

        expect(button.children.size).to eq 1
        plain = button.children.first
        expect(plain.model).to eq "Click me"
      end
    end

    context "mixing blocks and custom methods" do
      let(:custom_component_class) do
        Class.new(described_class) do
          def body
            button do
              warning_text
            end
          end

          def warning_text
            plain "WARNING! WARNING!"
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "creates the right structure" do
        custom_component.body

        expect(custom_component.children.size).to eq 1
        button = custom_component.children.first

        expect(button.children.size).to eq 1
        plain = button.children.first
        expect(plain.model).to eq "WARNING! WARNING!"
      end
    end

    context "variable access" do
      let(:custom_component_class) do
        Class.new(described_class) do
          def body
            @message = "1"
            message = "2"

            plain @message
            plain message
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "has access to both variables and creates elements accordingly" do
        custom_component.body

        expect(custom_component.children.map(&:model)).to eq ["1", "2"]
      end
    end

    context "variable access mixed with blocks" do
      let(:custom_component_class) do
        Class.new(described_class) do
          def body
            @message = "1"
            message = "2"

            button do
              plain @message
              plain message
            end
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "has access to both variables and creates elements accordingly" do
        custom_component.body

        expect(custom_component.children.size).to eq 1
        button = custom_component.children.first

        expect(button.children.map(&:model)).to eq ["1", "2"]
      end
    end

    context "nesting blocks within blocks!" do
      let(:custom_component_class) do
        Class.new(described_class) do
          def response
            div do
              div do
                button "hey"
                button "you"
              end
              button "outer"
            end
          end
        end
      end

      let(:custom_component) { custom_component_class.new }

      it "creates the right structure" do
        custom_component.response

        expect(custom_component.children.size).to eq 1
        div1 = custom_component.children.first

        expect(div1.children.size).to eq 2
        div2 = div1.children.first
        expect(div2.children.size).to eq 2
        expect(div2.children.map(&:model)).to eq ["hey", "you"]

        outer_button = div1.children.last
        expect(outer_button.model).to eq "outer"
      end
    end

  end

  describe "#to_html" do
    it "can get the HTML of a simple Plain" do
      plain = Matestack::Ui::Core::Plain::Plain.new("42")

      expect(plain.to_html).to eq "42"
    end

    it "can get the HTML of a simple button" do
      button = Matestack::Ui::Core::Button::Button.new(nil, text: "Render!")

      expect(stripped(button.to_html)).to eq "<button>Render!</button>"
    end

    it "can nest components" do
      button = Matestack::Ui::Core::Button::Button.new
      button.add_child Matestack::Ui::Core::Plain::Plain, "PlainContent"

      expect(stripped(button.to_html)).to eq "<button>PlainContent</button>"
    end

    it "yo I heard you like buttons so I put buttons into your buttons" do
      # yes that's nonsense but still worth testing

      button = Matestack::Ui::Core::Button::Button.new
      # TODO: take care of that nil view model child thingy?
      button.add_child Matestack::Ui::Core::Button::Button, nil, text: "Yo!"

      expect(stripped(button.to_html)).to eq "<button><button>Yo!</button></button>"
    end

    context "component only relying on other components" do
      let(:component_class) do
        Class.new(Matestack::Ui::Core::Component::Static) do
          def response
            button do
              plain "Hello"
            end
          end

          def self.name
            # TODO: trailbalzer-cells crashes here in some unneeded controller
            # path lookup that seems to be invoked on render...
            # /home/tobi/.asdf/installs/ruby/2.6.5/lib/ruby/gems/2.6.0/gems/trailblazer-cells-0.0.3/lib/trailblazer/cell.rb:36:in `controller_path
            "SomeName"
          end
        end
      end

      it "renders correctly" do
        instance = component_class.new
        instance.response

        expect(stripped(instance.to_html)).to eq "<button>Hello</button>"
      end

      it "renders correctly inside a button" do
        button = Matestack::Ui::Core::Button::Button.new
        button.add_child component_class

        expect(stripped(button.to_html)).to eq "<button><button>Hello</button></button>"
      end
    end
  end

  describe "#partial" do
    let(:partial_component) do
      Class.new(Matestack::Ui::Core::Component::Static) do
        def response
          partial :my_partial, "SomeText"
        end

        def self.name
          "SomeName"
        end

        private
        def my_partial(arg)
          partial do
            div do
              plain arg
            end
          end
        end
      end
    end

    it "can render the partial in the weird old way" do
      instance = partial_component.new
      instance.response

      expect(stripped(instance.to_html)).to eq "<div>SomeText</div>"
    end
  end

  describe "#slot" do
    context "simple slot" do
      let(:slot_component) do
        Class.new(described_class) do
          def response
            slot @options.fetch(:slot)
          end
        end
      end

      let(:slotting_component) do
        component_class = slot_component

        Class.new(described_class) do
          ComponentClass = component_class
          def response
            add_child ComponentClass, slot: slot { plain "Hi!" }
          end
        end
      end

      it "can set things into the slot without problems" do
        instance = slotting_component.new

        instance.response

        expect(instance.children.size).to eq 1
        component = instance.children.first

        expect(component).to be_a(slot_component)
        expect(component.children.size).to eq 1

        plain = component.children.first
        expect(plain.model).to eq "Hi!"
        expect(plain.children).to be_empty
      end
    end

    context "slots with nesting" do
      let(:slot_component) do
        Class.new(Matestack::Ui::Core::Component::Static) do
          def response
            div do
              slot @options.fetch(:slot)
              plain "Woop"
            end
          end

          def self.name
            "SomeOtherName"
          end
        end
      end

      let(:slotting_component) do
        component_class = slot_component

        Class.new(Matestack::Ui::Core::Component::Static) do
          ComponentClass2 = component_class
          def response
            plain "Wat?"
            div do
              plain "1"
              add_child ComponentClass2, slot: slot { plain "Hi!" }
              plain "2"
            end
          end

          def self.name
            "SomeName"
          end
        end
      end

      let(:div) { Matestack::Ui::Core::Div::Div }
      let(:plain) { Matestack::Ui::Core::Plain::Plain }

      it "creates the correct structure" do
        instance = slotting_component.new

        instance.response

        expect(stripped(instance.to_html)).to eq stripped <<~HTML
          Wat?
          <div>
            1
            <div>
              Hi!
              Woop
            </div>
            2
          </div>
        HTML
      end
    end

    context "slots have access to methods of the context they're defined in" do
      let(:slot_component) do
        Class.new(described_class) do
          def response
            slot @options.fetch(:slot)
          end
        end
      end

      let(:slotting_component) do
        component_class = slot_component

        Class.new(described_class) do
          ComponentClass3 = component_class
          def response
            add_child ComponentClass3, slot: slot { say_something }
          end

          def say_something
            plain "Something"
          end
        end
      end

      it "can set things into the slot without problems" do
        instance = slotting_component.new

        instance.response

        expect(instance.children.size).to eq 1
        component = instance.children.first

        expect(component).to be_a(slot_component)
        expect(component.children.size).to eq 1

        plain = component.children.first
        expect(plain.model).to eq "Something"
        expect(plain.children).to be_empty
      end
    end

    context "slots with even more nesting & using a slot twice" do
      let(:slot_component) do
        Class.new(Matestack::Ui::Core::Component::Static) do
          def response
            div do
              span do
                slot @options.fetch(:slot)
              end
              plain "Woop"
              div do
                slot @options.fetch(:slot)
              end
            end
          end

          def self.name
            "SomeOtherName"
          end
        end
      end

      let(:slotting_component) do
        component_class = slot_component

        Class.new(Matestack::Ui::Core::Component::Static) do
          ComponentClass4 = component_class
          def response
            plain "Wat?"
            div do
              plain "1"
              div do
                add_child ComponentClass4, slot: slot { plain "Hi!" }
                plain "2"
              end
              plain "3"
              span do
                plain "4"
              end
              plain "5"
            end
          end

          def self.name
            "SomeName"
          end
        end
      end

      let(:div) { Matestack::Ui::Core::Div::Div }
      let(:plain) { Matestack::Ui::Core::Plain::Plain }

      it "creates the correct structure" do
        instance = slotting_component.new

        instance.response

        expect(stripped(instance.to_html)).to eq stripped <<~HTML
          Wat?
          <div>
            1
            <div>
              <div>
                <span>
                  Hi!
                </span>
                Woop
                <div>
                  Hi!
                </div>
              </div>
              2
            </div>
            3
            <span>
              4
            </span>
            5
          </div>
        HTML
      end
    end
  end

  describe "#yield_components" do
    context "simple yield" do
      let(:yielding_component) do
        Class.new(described_class) do
          def response
            div do
              yield_components
            end
          end
        end
      end

      let(:using_component) do
        component_class = yielding_component

        Class.new(described_class) do
          YieldingClass = component_class
          def response
            div id: "outer" do
              add_child YieldingClass do
                plain "Inserted content"
              end
            end
          end
        end
      end

      it "can put the things in the assigned 'slot' without problems" do
        instance = using_component.new

        instance.response

        expect(instance.children.size).to eq 1
        outer_div = instance.children.first

        expect(outer_div.model).to include id: "outer"
        expect(outer_div.children.size).to eq 1

        yielding_component = outer_div.children.first
        expect(yielding_component.children.size).to eq 1

        inner_div = yielding_component.children.first
        expect(inner_div.children.size).to eq 1

        plain = inner_div.children.first
        expect(plain.model).to eq "Inserted content"
        expect(plain.children).to be_empty
      end
    end

    context "accessing methods only the using component as access to" do
      let(:yielding_component) do
        Class.new(described_class) do
          def response
            yield_components
          end
        end
      end

      let(:using_component) do
        component_class = yielding_component

        Class.new(described_class) do
          YieldingClass2 = component_class
          def response
            add_child YieldingClass2 do
              inserted_content
            end
          end

          def inserted_content
            plain "Inserted content"
          end
        end
      end

      it "can set things into the slot without problems" do
        instance = using_component.new

        instance.response

        expect(instance.children.size).to eq 1

        yielding_component = instance.children.first
        expect(yielding_component.children.size).to eq 1

        plain = yielding_component.children.first
        expect(plain.model).to eq "Inserted content"
      end
    end
  end
end
