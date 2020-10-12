class Demo::Pages::MyFirstPage < Matestack::Ui::Page
  include Matestack::Ui::Core::Collection::Helper

  def prepare
    @my_model = DummyModel.last
    @my_collection = set_collection({
      id: "my-first-collection",
      data: DummyModel.all,
    })
  end

  def response
    heading size: 2, text: "This is Page 1"

    div id: "some-id", class: "some-class" do
      plain "hello from page 1"
    end


    my_card
    my_demo_card

    foo_fancy_stuff title: 'Huhu'


    collection_content @my_collection.config do

    end


    # ul do
    #   async update_on: "test_model_created, test_model_deleted", position: "end", id: "my-list" do
    #     DummyModel.all.each do |instance|
    #       my_list_item item: instance
    #     end
    #   end
    # end

    # ul do
    #   cable append_on: 'test_model_created', delete_on: 'test_model_deleted', update_on: 'test_model_updated' do
    #     # stuff
    #   end
    # end
  end



end
