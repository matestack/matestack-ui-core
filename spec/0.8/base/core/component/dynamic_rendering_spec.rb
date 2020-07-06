require_relative "../../../../support/utils"
include Utils

describe "Component", type: :feature, js: true do

  before :all do

    class ComponentTestController < ActionController::Base
      layout "application"

      include Matestack::Ui::Core::ApplicationHelper

      def my_action
        render ExamplePage
      end

    end

    Rails.application.routes.append do
      scope "component_dynamic_rendering_spec" do
        get '/component_test', to: 'component_test#my_action', as: 'component_test_action'
      end
    end
    Rails.application.reload_routes!

  end

  describe "dynamic components" do

    it "render a component tag when inherit from 'Matestack::Ui::DynamicComponent'"

  end

end
