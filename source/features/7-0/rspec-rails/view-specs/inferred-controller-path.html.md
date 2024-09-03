# View specs infer controller's path and action

## Infer controller path

_Given_ a file named "spec/views/widgets/new.html.erb_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "widgets/new" do
  it "infers the controller path" do
    expect(controller.request.path_parameters[:controller]).to eq("widgets")
    expect(controller.controller_path).to eq("widgets")
  end
end
```

_When_ I run `rspec spec/views`

_Then_ the examples should all pass.

## Infer action

_Given_ a file named "spec/views/widgets/new.html.erb_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "widgets/new" do
  it "infers the controller action" do
    expect(controller.request.path_parameters[:action]).to eq("new")
  end
end
```

_When_ I run `rspec spec/views`

_Then_ the examples should all pass.

## Do not infer action in a partial

_Given_ a file named "spec/views/widgets/_form.html.erb_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "widgets/_form" do
  it "includes a link to new" do
    expect(controller.request.path_parameters[:action]).to be_nil
  end
end
```

_When_ I run `rspec spec/views`

_Then_ the examples should all pass.
