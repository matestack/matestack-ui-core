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
  get '/example_turbolinks', to: 'example#turbolinks'

  scope :my_app do
    get 'my_first_page', to: 'my_app#my_first_page'
    get 'my_second_page', to: 'my_app#my_second_page'
    get 'my_third_page', to: 'my_app#my_third_page'
    get 'my_fourth_page', to: 'my_app#my_fourth_page'
    get 'my_fifth_page', to: 'my_app#my_fifth_page'
    get 'my_sixth_page', to: 'my_app#my_sixth_page'
    get 'collection', to: 'my_app#collection'
    get 'inline_edit', to: 'my_app#inline_edit'

    post 'some_action', to: 'my_app#some_action'
    post 'form_action', to: 'my_app#form_action'
    post 'inline_form_action/:id', to: 'my_app#inline_form_action', as: "inline_form_action"

    delete 'delete_dummy_model', to: 'my_app#delete_dummy_model'
  end

  scope :api do
    get 'data', to: 'api#data'
    get 'data/:number', to: 'api#single_endpoint', as: "single_endpoint"
  end

end
