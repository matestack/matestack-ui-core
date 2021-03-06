Rails.application.routes.draw do

  # mount Matestack::Ui::Core::Engine, at: '/matestack'

  root to: 'demo#first'
  get :second, to: 'demo#second', as: :second
  post :action, to: 'demo#action', as: :action

  get :speed, to: 'demo#speed', as: :speed
  get :rails_speed, to: 'demo#index', as: :rails_speed
  # root to: 'my_app#my_first_page'

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
  get '/base_example', to: 'example#base'

  scope :my_app do
    get 'my_first_page', to: 'my_app#my_first_page'
    get 'my_second_page', to: 'my_app#my_second_page'
    get 'my_third_page', to: 'my_app#my_third_page'
    get 'my_fourth_page', to: 'my_app#my_fourth_page'
    get 'my_fifth_page', to: 'my_app#my_fifth_page'
    get 'my_sixth_page', to: 'my_app#my_sixth_page'
    get 'collection', to: 'my_app#collection'
    get 'inline_edit', to: 'my_app#inline_edit'

    get 'rails_view_and_partial', to: 'my_app#rails_view_and_partial'

    post 'some_action', to: 'my_app#some_action'
    post 'form_action', to: 'my_app#form_action'
    post 'inline_form_action/:id', to: 'my_app#inline_form_action', as: "inline_form_action"

    delete 'delete_dummy_model', to: 'my_app#delete_dummy_model'
  end

  scope :api do
    get 'data', to: 'api#data'
    get 'data/:number', to: 'api#single_endpoint', as: "single_endpoint"
  end

  namespace :legacy_views do
    get 'action_inline', to: 'pages#action_inline'
    get 'action_custom_component', to: 'pages#action_custom_component'
    get 'async_inline', to: 'pages#async_inline'
    get 'async_custom_component', to: 'pages#async_custom_component'
    get 'collection_inline', to: 'pages#collection_inline'
    get 'collection_custom_component', to: 'pages#collection_custom_component'
    get 'form_inline', to: 'pages#form_inline'
    get 'form_custom_component', to: 'pages#form_custom_component'
    get 'onclick_custom_component', to: 'pages#onclick_custom_component'
    get 'isolated_custom_component', to: 'pages#isolated_custom_component'
    get 'viewcontext_custom_component', to: 'pages#viewcontext_custom_component'
    post 'success', to: 'pages#success'
    post 'failure', to: 'pages#failure'
    post 'create', to: 'pages#create'
  end

end
