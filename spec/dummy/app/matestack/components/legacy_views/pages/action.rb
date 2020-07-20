class Components::LegacyViews::Pages::Action < Matestack::Ui::StaticComponent
  requires time: { as: :my_time }

  def response
    div id: 'foobar' do
      paragraph text: 'Im a custom component'
      action success_action_config do 
        button text: 'See Success'
      end
      action redirect_action_config do 
        button text: 'Redirect to inline action'
      end
      action_in_partial
      async show_on: 'action_successful', id: 'async-action-success' do
        plain "Action was successful {{ event.data.time }}"
      end
      async show_on: 'action_failed', id: 'async-action-failure' do
        plain "Action has failed {{ event.data.time }}"
      end
    end
  end

  private

  def action_in_partial
    action failure_action_config do 
      button text: 'See Failure'
    end
  end

  def success_action_config
    {
      method: :post,
      path: :legacy_views_success_path,
      data: {
        time: my_time
      },
      success: {
        emit: 'action_successful'
      }
    }
  end

  def failure_action_config
    {
      method: :post,
      path: :legacy_views_failure_path,
      data: {
        time: my_time
      },
      failure: {
        emit: 'action_failed'
      }
    }
  end

  def redirect_action_config
    {
      method: :post,
      path: :legacy_views_success_path,
      data: {
        time: my_time
      },
      success: {
        redirect: {
          path: :legacy_views_action_inline_path
        }
      }
    }
  end

end