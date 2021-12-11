# used in specs

class Components::LegacyViews::Pages::Action < Matestack::Ui::Component
  required :time

  def response
    div id: 'foobar' do
      paragraph 'Im a custom component'
      action success_action_config do
        button 'See Success'
      end
      action redirect_action_config do
        button 'Redirect to inline action'
      end
      action_in_partial
      toggle show_on: 'action_successful', id: 'async-action-success' do
        plain "Action was successful {{ event.data.time }}"
      end
      toggle show_on: 'action_failed', id: 'async-action-failure' do
        plain "Action has failed {{ event.data.time }}"
      end
      paragraph 'header called from inside custom component'
      rails_render template: 'demo/header', foo: 'Bar'
    end
  end

  private

  def action_in_partial
    action failure_action_config do
      button 'See Failure'
    end
  end

  def success_action_config
    {
      method: :post,
      path: legacy_views_success_path,
      data: {
        time: ctx.time
      },
      success: {
        emit: 'action_successful'
      }
    }
  end

  def failure_action_config
    {
      method: :post,
      path: legacy_views_failure_path,
      data: {
        time: ctx.time
      },
      failure: {
        emit: 'action_failed'
      }
    }
  end

  def redirect_action_config
    {
      method: :post,
      path: legacy_views_success_path,
      data: {
        time: ctx.time
      },
      success: {
        redirect: {
          path: legacy_views_action_inline_path
        }
      }
    }
  end

end
