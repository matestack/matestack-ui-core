Rails.application.routes.draw do

  scope :components_tests do
    get "static_rendering_test/:component", to: 'components_tests#static_rendering_test', as: "components_tests"
  end

  scope :components_tests_with_app do
    get "static_rendering_test/:component", to: 'components_tests_with_app#static_rendering_test', as: "components_tests_with_app"
  end

  scope :form_tests do
    get "input", to: 'form_tests#input'
  end

end
