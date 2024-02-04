# `route_to` matcher

The `route_to` matcher specifies that a request (verb + path) is routable.
  It is most valuable when specifying routes other than standard RESTful
  routes.

      expect(get("/")).to route_to("welcome#index") # new in 2.6.0

      or

      expect(:get => "/").to route_to(:controller => "welcome")

## Passing route spec with shortcut syntax

_Given_ a file named "spec/routing/widgets_routing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes for Widgets", type: :routing do
  it "routes /widgets to the widgets controller" do
    expect(get("/widgets")).
      to route_to("widgets#index")
  end
end
```

_When_ I run `rspec spec/routing/widgets_routing_spec.rb`

_Then_ the examples should all pass.

## Passing route spec with verbose syntax

_Given_ a file named "spec/routing/widgets_routing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes for Widgets", type: :routing do
  it "routes /widgets to the widgets controller" do
    expect(:get => "/widgets").
      to route_to(:controller => "widgets", :action => "index")
  end
end
```

_When_ I run `rspec spec/routing/widgets_routing_spec.rb`

_Then_ the examples should all pass.

## Route spec for a route that doesn't exist (fails)

_Given_ a file named "spec/routing/widgets_routing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes for Widgets", type: :routing do
  it "routes /widgets/foo to the /foo action" do
    expect(get("/widgets/foo")).to route_to("widgets#foo")
  end
end
```

_When_ I run `rspec spec/routing/widgets_routing_spec.rb`

_Then_ the output should contain "1 failure".

## Route spec for a namespaced route with shortcut specifier

_Given_ a file named "spec/routing/admin_routing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes for Widgets", type: :routing do
  it "routes /admin/accounts to the admin/accounts controller" do
    expect(get("/admin/accounts")).
      to route_to("admin/accounts#index")
  end
end
```

_When_ I run `rspec spec/routing/admin_routing_spec.rb`

_Then_ the examples should all pass.

## Route spec for a namespaced route with verbose specifier

_Given_ a file named "spec/routing/admin_routing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "routes for Widgets", type: :routing do
  it "routes /admin/accounts to the admin/accounts controller" do
    expect(get("/admin/accounts")).
      to route_to(:controller => "admin/accounts", :action => "index")
  end
end
```

_When_ I run `rspec spec/routing/admin_routing_spec.rb`

_Then_ the examples should all pass.
