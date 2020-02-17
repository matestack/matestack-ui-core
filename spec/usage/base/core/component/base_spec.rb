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
end
