class Pages::MyApp::MyThirdPage < Matestack::Ui::Page

  def response
    components {
      div do
        heading size: 2, text: "This is Page 3"

        action my_action_config do
          button text: "Click me!"
        end

        br
        br

        async rerender_on: "my_action_succeeded" do
          div id: "my-div" do
            plain DateTime.now.strftime("%Q")
          end
        end

        br

        async show_on: "my_action_succeeded", hide_after: 2000 do
          plain "action succeeded!"
        end
      end
    }
  end

  def my_action_config
    {
      method: :post,
      path: :some_action_path,
      success: {
        emit: "my_action_succeeded"
      }
    }
  end

end
