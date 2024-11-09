# Views are stubbed by default

By default, controller specs stub views with a template that renders an empty
  string instead of the views in the app. This allows you specify which view
  template an action should try to render regardless of whether the template
  compiles cleanly.

  NOTE: unlike rspec-rails-1.x, the real template must exist.

## Expect a template that is rendered by controller action (passes)

_Given_ a file named "spec/controllers/widgets_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe WidgetsController, type: :controller do
  describe "index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
      expect(response.body).to eq ""
    end
    it "renders the widgets/index template" do
      get :index
      expect(response).to render_template("widgets/index")
      expect(response.body).to eq ""
    end
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.

## Expect a template that is not rendered by controller action (fails)

_Given_ a file named "spec/controllers/widgets_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe WidgetsController, type: :controller do
  describe "index" do
    it "renders the 'new' template" do
      get :index
      expect(response).to render_template("new")
    end
  end
end
```

_When_ I run `rspec spec`

_Then_ the output should contain "1 example, 1 failure".

## Expect empty templates to render when view path is changed at runtime (passes)

_Given_ a file named "spec/controllers/things_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe ThingsController, type: :controller do
  describe "custom_action" do
    it "renders an empty custom_action template" do
      controller.prepend_view_path 'app/views'
      controller.append_view_path 'app/views'
      get :custom_action
      expect(response).to render_template("custom_action")
      expect(response.body).to eq ""
    end
  end
end
```

_Given_ a file named "app/controllers/things_controller.rb" with:

```ruby
class ThingsController < ActionController::Base
  layout false
  def custom_action
  end
end
```

_Given_ a file named "app/views/things/custom_action.html.erb" with:

```

```

_When_ I run `rspec spec`

_Then_ the examples should all pass.

## Expect a template to render the real template with render_views when view path is changed at runtime

_Given_ a file named "spec/controllers/things_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe ThingsController, type: :controller do
  render_views

  it "renders the real custom_action template" do
    controller.prepend_view_path 'app/views'
    get :custom_action
    expect(response).to render_template("custom_action")
    expect(response.body).to match(/template for a custom action/)
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.
