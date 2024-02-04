# Configuring pending failure output

Configure the format of pending examples output with an option (defaults to `:full`):

  ```ruby
  RSpec.configure do |c|
    c.pending_failure_output = :no_backtrace
  end
  ```

  Allowed options are `:full`, `:no_backtrace` and `:skip`.

## Background

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "something" do
  pending "will never happen again" do
    expect(Time.now.year).to eq(2021)
  end
end
```

## By default outputs backtrace and details

_Given_ a file named "spec/spec_helper.rb" with:

```ruby

```

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should contain "Pending: (Failures listed here are expected and do not affect your suite's status)"

_And_ the output should contain "1) something will never happen again"

_And_ the output should contain "expected: 2021"

_And_ the output should contain "./spec/example_spec.rb:5".

## Setting `pending_failure_output` to `:no_backtrace` hides the backtrace

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.pending_failure_output = :no_backtrace }
```

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should contain "Pending: (Failures listed here are expected and do not affect your suite's status)"

_And_ the output should contain "1) something will never happen again"

_And_ the output should contain "expected: 2021"

_And_ the output should not contain "./spec/example_spec.rb:5".

## Setting `pending_failure_output` to `:skip` hides the backtrace

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.pending_failure_output = :skip }
```

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should not contain "Pending: (Failures listed here are expected and do not affect your suite's status)"

_And_ the output should not contain "1) something will never happen again"

_And_ the output should not contain "expected: 2021"

_And_ the output should not contain "./spec/example_spec.rb:5".
