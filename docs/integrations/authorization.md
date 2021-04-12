# Authorization \[WIP\]

At [matestack](https://matestack.io), we have had good experiences using matestack with [Pundit](https://github.com/varvet/pundit). [CanCanCan](https://github.com/CanCanCommunity/cancancan), another very popular authorization library in Rails, is also supported, as shown below!

Both Pundit and CanCanCan use pure Ruby and focus on the model and controller layer, so they are compatible to matestack's UI library.

## Example 1: Pundit

Here we see how Pundit defines policies and we can check for them in the controller action, just before matestack's `responder_for`!

A Pundit example in `app/policies/user_policy.rb`:

```ruby
class UserPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def show?
    user.is_visible?
  end

end
```

Matestack's `app/controllers/user_controller.rb`:

```ruby
class UserController < ApplicationController

  matestack_app UserApp

  def show
    @user = User.find_by(id: params[:id])
    authorize @user # checking Pundit policy
    render UserApp::Pages::Show # matestack page responder
  end

end
```

## Example 2: CanCanCan

Here we see how CanCanCan defines abilities and we can check for them in the controller action, just before matestack's `responder_for`!

CanCanCan's `app/models/ability.rb` example, borrowed from their guides:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, :all # permissions for every user, even if not logged in    
    # [...]
  end

end
```

Matestack's `app/controllers/user_controller.rb`:

```ruby
class UserController < ApplicationController

  matestack_app UserApp

  def show
    @user = User.find_by(id: params[:id])
    authorize! :read, @user # checking for CanCanCan ability
    render UserApp::Pages::Show # matestack page responder
  end

end
```

