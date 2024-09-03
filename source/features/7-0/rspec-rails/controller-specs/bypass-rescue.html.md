# Using `bypass_rescue`

Use `bypass_rescue` to bypass both Rails' default handling of errors in
  controller actions, and any custom handling declared with a `rescue_from`
  statement.

  This lets you specify details of the exception being raised, regardless of
  how it might be handled upstream.

## Background

_Given_ a file named "spec/controllers/gadgets_controller_spec_context.rb" with:

```ruby
class AccessDenied < StandardError; end

class ApplicationController < ActionController::Base
  rescue_from AccessDenied, :with => :access_denied

  private

  def access_denied
    redirect_to "/401.html"
  end
end
```

## Standard exception handling using `rescue_from`

_Given_ a file named "spec/controllers/gadgets_controller_spec.rb" with:

```ruby
require "rails_helper"

require 'controllers/gadgets_controller_spec_context'

RSpec.describe GadgetsController, type: :controller do
  before do
    def controller.index
      raise AccessDenied
    end
  end

  describe "index" do
    it "redirects to the /401.html page" do
      get :index
      expect(response).to redirect_to("/401.html")
    end
  end
end
```

_When_ I run `rspec spec/controllers/gadgets_controller_spec.rb`

_Then_ the examples should all pass.

## Bypass `rescue_from` handling with `bypass_rescue`

_Given_ a file named "spec/controllers/gadgets_controller_spec.rb" with:

```ruby
require "rails_helper"

require 'controllers/gadgets_controller_spec_context'

RSpec.describe GadgetsController, type: :controller do
  before do
    def controller.index
      raise AccessDenied
    end
  end

  describe "index" do
    it "raises AccessDenied" do
      bypass_rescue
      expect { get :index }.to raise_error(AccessDenied)
    end
  end
end
```

_When_ I run `rspec spec/controllers/gadgets_controller_spec.rb`

_Then_ the examples should all pass.
