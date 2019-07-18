class Pages::MyApp::MyFirstPage < Matestack::Ui::Page

  def prepare
    @foo = "bar"
  end

  def response
    components {
      heading size: 2, text: "This is Page 1"

      div id: "some-id", class: "some-class" do
        plain "hello from page 1 #{@foo}"
      end
      onclick emit: "my_event" do
        button text: "click"
      end

      sleep 1

      isolate :my_isolated_scope

      isolate :my_other_isolated_scope

      DummyModel.all.each do |dummy|
        isolate :my_isolated_item, cached_params: { id: dummy.id }
      end
    }
  end

  def my_isolated_scope
    @dummy = DummyModel.first
    isolated {
      async rerender_on: "my_event" do
        div id: "some-id", class: "some-class" do
          plain "hello from isolated scope #{@foo} #{@dummy.title}"
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

  def my_other_isolated_scope
    @dummy = DummyModel.last
    isolated {
      async rerender_on: "my_event" do
        div id: "some-id", class: "some-class" do
          plain "hello from other isolated scope #{@foo} #{@dummy.title}"
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end

  def my_isolated_item cached_params
    @dummy = DummyModel.find cached_params[:id]
    isolated {
      async rerender_on: "my_event" do
        div id: "some-id", class: "some-class" do
          plain "hello from isolated item scope #{@foo} #{@dummy.title}"
          plain "#{DateTime.now.strftime('%Q')}"
        end
      end
    }
  end


end
