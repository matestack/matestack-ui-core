Rails.application.routes.draw do

  root to: 'demo_core#first'

  scope :demo do
    scope :core do
      get :first, to: 'demo_core#first', as: :demo_core_first_page
      get :second, to: 'demo_core#second', as: :demo_core_second_page
    end
  end

end
