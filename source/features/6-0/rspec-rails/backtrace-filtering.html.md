# Backtrace filtering

The following configuration setting will filter out lines in backtraces
  that come from Rails gems in order to reduce the noise in test failure output:

  ```ruby
  RSpec.configure do |config|
    config.filter_rails_from_backtrace!
  end
  ```

  `rspec` will always show the full backtrace output when run with
  the `--backtrace` commandline option.

## Background (Using `filter_rails_from_backtrace!`)

_Given_ a file named "spec/failing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.configure do |config|
  config.filter_rails_from_backtrace!
end

RSpec.describe "Controller", type: :controller do
  controller do
    def index
      raise "Something went wrong."
    end
  end

  describe "GET index" do
    it "raises an error" do
      get :index
    end
  end
end
```

## Using the bare `rspec` command

_When_ I run `rspec`

_Then_ the output should contain "1 example, 1 failure"

_And_ the output should not contain "activesupport".

## Using `rspec --backtrace`

_When_ I run `rspec --backtrace`

_Then_ the output should contain "1 example, 1 failure"

_And_ the output should contain "activesupport".
