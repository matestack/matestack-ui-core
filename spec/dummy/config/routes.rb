Rails.application.routes.draw do

  scope :components_tests do
    get "static_rendering_test/:component", to: 'components_tests#static_rendering_test', as: "components_tests"
    get "custom_components_test", to: 'components_tests#custom_components_test'
  end

  scope :components_tests_with_app do
    get "static_rendering_test/:component", to: 'components_tests_with_app#static_rendering_test', as: "components_tests_with_app"
  end

  scope :form_tests do
    get "input", to: 'form_tests#input'
    post "submit", to: 'form_tests#submit'
    get "back", to: 'form_tests#back'
  end

end
