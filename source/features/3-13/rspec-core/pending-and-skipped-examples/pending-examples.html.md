# Using `pending` with examples

RSpec offers a number of different ways to indicate that an example is
  disabled pending some action.

## `pending` any arbitrary reason with a failing example

_Given_ a file named "pending_without_block_spec.rb" with:

```ruby
RSpec.describe "an example" do
  it "is implemented but waiting" do
    pending("something else getting finished")
    fail
  end
end
```

_When_ I run `rspec pending_without_block_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is implemented but waiting
     # something else getting finished
```

## `pending` any arbitrary reason with a passing example

_Given_ a file named "pending_with_passing_example_spec.rb" with:

```ruby
RSpec.describe "an example" do
  it "is implemented but waiting" do
    pending("something else getting finished")
    expect(1).to be(1)
  end
end
```

_When_ I run `rspec pending_with_passing_example_spec.rb`

_Then_ the exit status should not be 0

_And_ the output should contain "1 example, 1 failure"

_And_ the output should contain "FIXED"

_And_ the output should contain "Expected pending 'something else getting finished' to fail. No error was raised."

_And_ the output should contain "pending_with_passing_example_spec.rb:2".

## `pending` for an example that is currently passing

_Given_ a file named "pending_with_passing_block_spec.rb" with:

```ruby
RSpec.describe "an example" do
  pending("something else getting finished") do
    expect(1).to eq(1)
  end
end
```

_When_ I run `rspec pending_with_passing_block_spec.rb`

_Then_ the exit status should not be 0

_And_ the output should contain "1 example, 1 failure"

_And_ the output should contain "FIXED"

_And_ the output should contain "Expected pending 'No reason given' to fail. No error was raised."

_And_ the output should contain "pending_with_passing_block_spec.rb:2".

## `pending` for an example that is currently passing with a reason

_Given_ a file named "pending_with_passing_block_spec.rb" with:

```ruby
RSpec.describe "an example" do
  example("something else getting finished", :pending => 'unimplemented') do
    expect(1).to eq(1)
  end
end
```

_When_ I run `rspec pending_with_passing_block_spec.rb`

_Then_ the exit status should not be 0

_And_ the output should contain "1 example, 1 failure"

_And_ the output should contain "FIXED"

_And_ the output should contain "Expected pending 'unimplemented' to fail. No error was raised."

_And_ the output should contain "pending_with_passing_block_spec.rb:2".
