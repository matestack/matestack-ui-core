class Demo::VueJs::Components::StaticComponent < Matestack::Ui::Component

  required :foo

  def response
    plain "A simple Static Component with given input foo: #{context.foo}"

    br
    br

    plain DateTime.now

    br
    br

    onclick emit: "hooray" do
      button "emit hooray"
    end

    action path: "/", method: :get, success: { transition: { path: demo_vue_js_second_page_path }} do
      button "click me"
    end

    toggle show_on: "hooray" do
      plain "yessss"
    end

    br
    br

    action path: "/", method: :post do
      button "click me again"
    end

    br
    br

    transition path: demo_vue_js_first_page_path do
      button "First Page"
    end



  end

end
