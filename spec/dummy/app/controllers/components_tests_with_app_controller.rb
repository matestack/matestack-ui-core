class ComponentsTestsWithAppController < ApplicationController

  include Basemate::Ui::Core::ApplicationHelper

  def static_rendering_test
    responder_for(Pages::ComponentsTestsWithApp::StaticRenderingTest)
  end

end
