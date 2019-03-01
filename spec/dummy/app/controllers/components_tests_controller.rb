class ComponentsTestsController < ApplicationController

  include Basemate::Ui::Core::ApplicationHelper

  def static_rendering_test
    responder_for(Pages::ComponentsTests::StaticRenderingTest)
  end

  def custom_components_test
    responder_for(Pages::ComponentsTests::CustomComponentsTest)
  end

end
