require_relative 'matestack_wrapper_layout'
require_relative 'matestack_wrapper_page'

class MatestackComponentsController < ApplicationController
  include Matestack::Ui::Core::Helper

  matestack_layout MatestackWrapperLayout

  def matestack_components_test
    render MatestackWrapperPage
  end

  def matestack_transition_test
    render MatestackTransitionPage
  end
end
