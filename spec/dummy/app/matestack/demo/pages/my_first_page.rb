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
    # heading size: 2, text: "This is Page 1"

    # div id: "some-id", class: "some-class" do
    #   plain "hello from page 1"
    # end


    # my_card
    # my_demo_card

    # foo_fancy_stuff title: 'Huhu'


    # ul do
    #   async update_on: "test_model_created, test_model_deleted", position: "end", id: "my-list" do
    #   end
    # end
    
    ul do
      cable id: 'foo', append_on: 'test_model_created', prepend_on: 'test_model_prepend', 
        delete_on: 'test_model_deleted', update_on: 'test_model_updated',
        replace_on: 'test_model_replace' do
        DummyModel.all.each do |instance|
          my_list_item item: instance
        end
      end
    end
  end



end
