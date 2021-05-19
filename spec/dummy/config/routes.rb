Rails.application.routes.draw do

  # dummy app routes

  root to: 'demo#first'

  scope :demo do
    get :first, to: 'demo#first', as: :first
    get :second, to: 'demo#second', as: :second
    post :action, to: 'demo#action', as: :action
    get :collection, to: 'demo#collection', as: :collection_demo
  end

  # routes used within specs

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
