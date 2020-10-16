require_relative 'matestack_wrapper_app'
require_relative 'matestack_wrapper_page'
require_relative 'matestack_transition_page'

class MatestackComponentsController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app MatestackWrapperApp

  def matestack_components_test
    render MatestackWrapperPage
  end

  def matestack_transition_test
    render MatestackTransitionPage
  end
end
