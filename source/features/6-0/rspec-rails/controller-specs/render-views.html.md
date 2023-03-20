# Using `render_views`

You can tell a controller example group to render views with the
  `render_views` declaration in any individual group, or globally.

## Use `render_views` directly in a single group

_Given_ a file named "spec/controllers/widgets_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe WidgetsController, type: :controller do
  render_views

  describe "GET index" do
    it "has a widgets related heading" do
      get :index
      expect(response.body).to match /<h1>.*widgets/im
    end
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.

## Use `render_views` on and off in nested groups

_Given_ a file named "spec/controllers/widgets_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe WidgetsController, type: :controller do
  context "with render_views" do
    render_views

    describe "GET index" do
      it "renders the actual template" do
        get :index
        expect(response.body).to match /<h1>.*widgets/im
      end
    end

    context "with render_views(false) nested in a group with render_views" do
      render_views false

      describe "GET index" do
        it "renders the RSpec generated template" do
          get :index
          expect(response.body).to eq("")
        end
      end
    end
  end

  context "without render_views" do
    describe "GET index" do
      it "renders the RSpec generated template" do
        get :index
        expect(response.body).to eq("")
      end
    end
  end

  context "with render_views again" do
    render_views

    describe "GET index" do
      it "renders the actual template" do
        get :index
        expect(response.body).to match /<h1>.*widgets/im
      end
    end
  end
end
```

_When_ I run `rspec spec --order default --format documentation`

_Then_ the output should contain:

```ruby
WidgetsController
  with render_views
    GET index
      renders the actual template
    with render_views(false) nested in a group with render_views
      GET index
        renders the RSpec generated template
  without render_views
    GET index
      renders the RSpec generated template
  with render_views again
    GET index
      renders the actual template
```

## Use `render_views` globally

_Given_ a file named "spec/support/render_views.rb" with:

```ruby
RSpec.configure do |config|
  config.render_views
end
```

_And_ a file named "spec/controllers/widgets_controller_spec.rb" with:

```ruby
require "rails_helper"
require "support/render_views"

RSpec.describe WidgetsController, type: :controller do
  describe "GET index" do
    it "renders the index template" do
      get :index
      expect(response.body).to match /<h1>.*widgets/im
    end
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.
