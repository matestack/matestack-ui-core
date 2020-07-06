require_relative "../../../../../support/utils"
include Utils

describe "Page", type: :feature, js: true do

  before :all do
    Rails.application.routes.append do
      scope "page_orchestrates_components_spec" do
        get '/page_test', to: 'page_test#my_action', as: 'page_test_action'
      end
    end
    Rails.application.reload_routes!
  end

  it "wraps page content with a specific dom structure"

end
