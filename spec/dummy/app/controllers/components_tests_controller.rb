class ComponentsTestsController < ApplicationController

  include Basemate::Ui::Core::ApplicationHelper

  def resolve
    page_class = Object.const_get("Pages::ComponentsTests::#{params[:key].camelcase}Test")
    responder_for(page_class)
  end

end
