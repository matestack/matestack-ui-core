require_relative 'matestack_vue_js_wrapper_app'
require_relative 'matestack_vue_js_wrapper_page'
require_relative 'matestack_transition_page'

class MatestackVueJsComponentsController < ApplicationController
  include Matestack::Ui::Core::Helper

  layout "application_vue_js"
  matestack_layout MatestackVueJsWrapperApp

  def matestack_components_test
    render MatestackVueJsWrapperPage
  end

  def matestack_transition_test
    render MatestackTransitionPage
  end
end
