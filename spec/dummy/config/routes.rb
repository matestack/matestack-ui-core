Rails.application.routes.draw do

  mount Matestack::Ui::Core::Engine, at: '/matestack'

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

  get '/example', to: 'example#page'

  scope :my_app do
    get 'my_first_page', to: 'my_app#my_first_page'
    get 'my_second_page', to: 'my_app#my_second_page'
    get 'my_third_page', to: 'my_app#my_third_page'
    get 'my_fourth_page', to: 'my_app#my_fourth_page'
    get 'my_fifth_page', to: 'my_app#my_fifth_page'
    get 'my_sixth_page', to: 'my_app#my_sixth_page'

    post 'some_action', to: 'my_app#some_action'
    post 'form_action', to: 'my_app#form_action'
  end

  scope :api do
    get 'data', to: 'api#data'
  end

end
