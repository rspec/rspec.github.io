# Using named routes

Routing specs have access to named routes.

## Access named route

_Given_ a file named "spec/routing/widget_routes_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes to the widgets controller", type: :routing do
  it "routes a named route" do
    expect(:get => new_widget_path).
      to route_to(:controller => "widgets", :action => "new")
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.
