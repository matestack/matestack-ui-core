require_relative 'vue_js_layout'

class ExampleController < ApplicationController
  include Matestack::Ui::Core::Helper

  layout "application_vue_js"
  matestack_layout VueJsLayout

  def page
    render ExamplePage
  end

  def base
    render BaseExamplePage
  end

end
