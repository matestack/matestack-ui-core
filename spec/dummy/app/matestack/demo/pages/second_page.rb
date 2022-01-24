class Demo::Pages::SecondPage < Matestack::Ui::Page

  def response
    h2 "Second Page"
    paragraph do
      plain "play around! --> spec/dummy/app/matestack/demo/pages/second_page.rb"
    end

    # you can call components on pages:
    Demo::Components::StaticComponent.call(foo: "baz")

    action path: ssr_call_path, method: :post do
      button "click me for ssr"
    end

    br

    div ref:"test" do
      plain "foo"
    end

    cable id: 'cable-foo', replace_on: "some_server_event" do
      plain DateTime.now
    end

    br
    br

    matestack_form form_config_1 do
      div do
        plain "{{vc.data.some_key}}"
        form_input key: :some_key, type: :text, init: "foo"
      end
      div do
        form_input key: :some_other_key, type: :text
      end
      div do
        form_input key: :file_1, type: :file, id: "file-1-input"
      end
      div do
        form_select id: "my-array-test-dropdown", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
      end
      form_select key: :some_select, options: [1, 2, 3], init: 1
      form_radio id: "my-hash-test-radio", key: :hash_input, options: { "Hash Option 1": 1, "Hash Option 2": 2 }, init: 1
      button "submit", type: :submit
    end

    matestack_form form_config_2 do
      div do
        form_checkbox id: "init-as-boolean-from-config", key: :bar, label: 'Boolean Value from Config', init: true
      end
      div do
        form_input key: :some_key, type: :text, init: "bar"
      end
      div do
        form_input key: :some_other_key, type: :text
      end
      div do
        form_select id: "my-array-test-dropdown", key: :array_input, options: ["Array Option 1","Array Option 2"], init: "Array Option 1"
      end
      form_select key: :some_select, options: [1, 2, 3], init: 1
      button "submit", type: :submit
    end
  end

  def form_config_1
    {
      for: :some_object,
      path: form_submit_path,
      method: :post,
      multipart: true
    }
  end

  def form_config_2
    {
      for: :some_object,
      path: form_submit_path,
      method: :post
    }
  end

end
