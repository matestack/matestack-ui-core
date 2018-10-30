Rails.application.routes.draw do

  scope :components_tests do
    get "/:key", to: 'components_tests#resolve', as: "components_tests"
  end

end
