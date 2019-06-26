class Pages::MyApp::MyFirstPage < Matestack::Ui::Page
  #
  # def prepare
  #   @count = DummyModel.all.count
  # end

  def response
    components {
      heading size: 2, text: "This is Page 1"

      div id: "some-id", class: "some-class" do
        plain "hello from page 1"
      end
      onclick emit: "test" do
        button text: "rerender"
      end
      async defer: true, url_params: context[:params] do
        partial :my_deferred_scope
      end
    }
  end

  def my_deferred_scope
    @count = DummyModel.all.count
    partial {
      div do
        plain "#{@count}"
      end
    }
  end


end
