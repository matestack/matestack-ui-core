Rails.application.routes.draw do
  mount Matestack::Ui::Core::Engine => "/matestack-ui-core"
end
