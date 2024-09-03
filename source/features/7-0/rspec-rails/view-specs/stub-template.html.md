# Using `stub_template`

In order to isolate view specs from the partials rendered by the primary
  view, rspec-rails (since 2.2) provides the stub_template method.

## Stub a template that does not exist

_Given_ a file named "spec/views/gadgets/list.html.erb_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "gadgets/list" do
  it "renders the gadget partial for each gadget" do
    assign(:gadgets, [
      double(:name => "First"),
      double(:name => "Second")
    ])
    stub_template "gadgets/_gadget.html.erb" => "<%= gadget.name %><br/>"
    render
    expect(rendered).to match /First/
    expect(rendered).to match /Second/
  end
end
```

_And_ a file named "app/views/gadgets/list.html.erb" with:

```
<%= render :partial => "gadget", :collection => @gadgets %>
```

_When_ I run `rspec spec/views/gadgets/list.html.erb_spec.rb`

_Then_ the examples should all pass.

## Stub a template that exists

_Given_ a file named "spec/views/gadgets/edit.html.erb_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "gadgets/edit" do
  before(:each) do
    @gadget = assign(:gadget, Gadget.create!)
  end

  it "renders the form partial" do
    stub_template "gadgets/_form.html.erb" => "This content"
    render
    expect(rendered).to match /This content/
  end
end
```

_When_ I run `rspec spec/views/gadgets/edit.html.erb_spec.rb`

_Then_ the examples should all pass.
