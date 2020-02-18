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

    it "can even pass a block" do
      pending "Okay the DSL layer has to take care of blocks/procs"
      subject.add_child child_class do
        4 + 4
      end

      expect(child.model).to be_a(Proc)
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
  end
end
