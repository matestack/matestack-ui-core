Rails.application.routes.draw do
  mount Basemate::Ui::Core::Engine => "/basemate-ui-core"
end
