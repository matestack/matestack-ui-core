# basemate core component: Action

This component is used to perform actions. It renders a `<span>` tag around optional content.

## Parameters
The basemate action expects at least a path and a method. Depending on what you want to achieve, it can take params, data and success reactions as options.

#### # path
Specify which path should be addressed by the request. The path takes regular Rails route paths. E.g. the update\_task\_path:

```ruby
path: :update_task_path
```

#### # params (optional unless path requires it)
Specifies which params should be sent to the path with the request in a Ruby hash:

```ruby
params: {
  id: task.id
}
```

#### # method
The HTTP method to use for the specific action. E.g. put to update:

```ruby
method: :put
```

##### So far, the example sends a get request to update\_task\_path(id: task.id)

#### # data (optional)
Ruby hash that will be turned into a JSON payload for post requests.

#### # success (optional)
A hash which specifies which element should be affected how by a successful action. E.g. is rerendering the task div on success:

```ruby
success: {
  tasks: :rerender # all elements with id task
}
```

#### # notify (optional, true by default)
Boolean that specifies whether you want notifications on this actions.

## Example

The following example renders the latest 5 tasks.

They get display with their name and a button next to them to toggle between complete/not completed.

If the button gets clicked the specific task gets updated by id. After the request gets a OK (200) Response header, the tasks\_container div gets rerendered.

```ruby
@task = Task.last(5)
# ...
div id: "task_container", dynamic: true do
  @tasks.each do |task|
    div class: "#{ 'done' if task.done }" do
      plain task.name
      # the method "action_config" returns the hash
      action action_config(task) do
        if task.done
          button text: "not completed"
        else
          button text: "completed"
        end
      end
    end
  end
end

# we use this action_config method to keep our code clean
def action_config task
  return {
    method: :put,
    path: :update_task_path,
    params: { id: task.id },
    # this data hash is sent to the backend
    data: {
      task: {
        done: !task.done
      }
    },
    success: {
      task_container: :rerender
    },
  }
end
```
