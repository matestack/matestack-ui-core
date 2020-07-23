class FormTestController < TestController
  def success_submit
    render json: { message: "server says: form submitted successfully" }, status: 200
  end

  def success_submit_with_transition
    if params[:to_page].present?
      transition_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
    else
      transition_path = form_test_page_4_path(id: 42)
    end
    render json: {
      message: "server says: form submitted successfully",
      transition_to: transition_path
    }, status: 200
  end

  def failure_submit_with_transition
    if params[:to_page].present?
      transition_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
    else
      transition_path = form_test_page_4_path(id: 42)
    end
    render json: {
      message: "server says: form had errors",
      errors: { foo: ["seems to be invalid"] },
      transition_to: transition_path
    }, status: 400
  end

  def success_submit_with_redirect
    if params[:to_page].present?
      redirect_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
    else
      redirect_path = form_test_page_4_path(id: 42)
    end
    render json: {
      message: "server says: form submitted successfully",
      redirect_to: redirect_path
    }, status: 200
  end

  def failure_submit_with_redirect
    if params[:to_page].present?
      redirect_to_path = send("form_test_page_#{params[:to_page]}_path", {id: 42})
    else
      redirect_to_path = form_test_page_4_path(id: 42)
    end
    render json: {
      message: "server says: form had errors",
      errors: { foo: ["seems to be invalid"] },
      redirect_to: redirect_to_path
    }, status: 400
  end

  def failure_submit
    render json: {
      message: "server says: form had errors",
      errors: { foo: ["seems to be invalid"] }
    }, status: 400
  end
end