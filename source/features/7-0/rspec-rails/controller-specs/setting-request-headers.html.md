# Setting request headers

We recommend you to switch to request specs instead of controller specs if you want to set
  headers in your call.  If you still want to set headers in controller specs, you can use
  `request.headers` as mentioned below.

## Setting a header value in a controller spec

_Given_ a file named "spec/controllers/application_controller_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def show
      if request.headers["Authorization"] == "foo"
        head :ok
      else
        head :forbidden
      end
    end
  end

  before do
    routes.draw { get "show" => "anonymous#show" }
  end

  context "valid Authorization header" do
    it "returns a 200" do
      request.headers["Authorization"] = "foo"

      get :show

      expect(response).to have_http_status(:ok)
    end
  end

  context "invalid Authorization header" do
    it "returns a 403" do
      request.headers["Authorization"] = "bar"

      get :show

      expect(response).to have_http_status(:forbidden)
    end
  end
end
```

_When_ I run `rspec spec`

_Then_ the example should pass.
