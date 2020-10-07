class Components::MyListItem < Matestack::Ui::Component

  requires :item

  def response
    li id: "item-#{item.id}" do
      plain item.title
      onclick emit: "test" do
        button text: "test"
      end
    end
  end

end
