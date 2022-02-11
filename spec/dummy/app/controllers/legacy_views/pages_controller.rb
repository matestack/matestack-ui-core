# used in specs

class LegacyViews::PagesController < ApplicationController
  include Matestack::Ui::Core::Helper

  layout 'legacy_views'

  def viewcontext_custom_component
  end

end
