class Pages::FormTests::InputTest < Page::Cell::Page

  def response
    components {
      if context[:params][:no_config]
        form
      end
      if context[:params][:invalid_config]
        form invalid_form_config
      end
      if context[:params][:valid_config]
        form valid_form_config, :include do
          form_input id: "my-id", class: "my-class", key: :my_key, type: :text
          form_submit do
            button id: "submit-button", text: "submit"
          end
        end
      end
    }
  end

  def invalid_form_config
    return {
      for: :my_object
    }
  end

  def valid_form_config
    if context[:params][:transition]
      return {
        for: :my_object,
        path: :submit_path,
        method: :post,
        success: {
          transition: {
            path: :back_path,
            params: {
              param_one: "transition param"
            }
          }
        }
      }
    end
    return {
      for: :my_object,
      path: :submit_path,
      method: :post
    }
  end

end
