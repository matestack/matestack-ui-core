include Utils

# In parts here Button and Plain are used as example for a working class,
# especially around DSL registrations.
# Elsewhere anonymous classes are used to not interfere with the other parts of
# the system too much.
describe Matestack::Ui::Core::Component::Base do
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
      expect(child.model).to eq(text: "Hello World")
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

        expect(child.model).to eq text: "My Button"
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

        expect(button.model).to eq id: "foo", class: "bar"

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

      it "calls the block without fail" do
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
  end
end
