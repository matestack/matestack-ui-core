Rails.application.routes.draw do

  root to: 'demo_vue_js#first'

  scope :demo do
    scope :core do
      get :first, to: 'demo_core#first', as: :demo_core_first_page
      get :second, to: 'demo_core#second', as: :demo_core_second_page
    end
  end

  scope :demo do
    scope :vue_js do
      get :first, to: 'demo_vue_js#first', as: :demo_vue_js_first_page
      get :second, to: 'demo_vue_js#second', as: :demo_vue_js_second_page
      post :ssr_call, to: 'demo_vue_js#ssr_call', as: :demo_vue_js_ssr_call
      post :form_submit, to: 'demo_vue_js#form_submit', as: :demo_vue_js_form_submit
    end
  end

end
