# used in specs

class Components::LegacyViews::Pages::Viewcontext < Matestack::Ui::Component

  def response
    div id: "my-component" do
      if view_context.view_renderer.instance_of?(ActionView::Renderer)
        plain "has access to ActionView Context"
      end
      plain link_to "Test Link", "/some/page" # calling an ActionView Url Helper here
      plain time_ago_in_words(3.minutes.from_now) # calling an ActionView Date Helper here
      plain "root_path: #{root_path}" # calling a Path Helper here
    end
  end

end
