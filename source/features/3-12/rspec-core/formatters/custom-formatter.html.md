# Custom formatters

RSpec ships with general purpose output formatters. You can tell RSpec which
  one to use using the [`--format` command line option](../command-line/format-option).

  When RSpec's built-in output formatters don't, however, give you everything
  you need, you can write your own custom formatter and tell RSpec to use that
  one instead. The simplest way is to subclass RSpec's `BaseTextFormatter`, and
  then override just the methods that you want to modify.

## Custom formatter

_Given_ a file named "custom_formatter.rb" with:

```ruby
class CustomFormatter
  # This registers the notifications this formatter supports, and tells
  # us that this was written against the RSpec 3.x formatter API.
  RSpec::Core::Formatters.register self, :example_started

  def initialize(output)
    @output = output
  end

  def example_started(notification)
    @output << "example: " << notification.example.description
  end
end
```

_And_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "my group" do
  specify "my example" do
  end
end
```

_When_ I run `rspec example_spec.rb --require ./custom_formatter.rb --format CustomFormatter`

_Then_ the output should contain "example: my example"

_And_ the exit status should be 0.
