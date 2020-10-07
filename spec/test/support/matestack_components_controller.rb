require_relative 'matestack_wrapper_app'
require_relative 'matestack_wrapper_page'

class MatestackComponentsController < ApplicationController
  include Matestack::Ui::Core::ApplicationHelper

  matestack_app MatestackWrapperApp

  def matestack_components_test
    render MatestackWrapperPage
  end
end
