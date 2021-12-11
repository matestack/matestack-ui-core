Rails.application.routes.draw do

  # dummy app routes

  root to: 'demo#first'

  scope :demo do
    get :first, to: 'demo#first', as: :first_page
    get :second, to: 'demo#second', as: :second_page
  end

  # routes used within specs

  get '/example', to: 'example#page'
  get '/base_example', to: 'example#base'

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
