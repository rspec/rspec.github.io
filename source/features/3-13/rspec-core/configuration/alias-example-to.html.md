# Create example aliases

Use `config.alias_example_to` to create new example group methods that define
  examples with the configured metadata. You can also specify metadata using
  only symbols.

## Use `alias_example_to` to define a custom example name

_Given_ a file named "alias_example_to_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.alias_example_to :task
end

RSpec.describe "a task example group" do
  task "does something" do
    expect(5).to eq(5)
  end
end
```

_When_ I run `rspec alias_example_to_spec.rb --format doc`

_Then_ the output should contain "does something"

_And_ the examples should all pass.

## Use `alias_example_to` to define a pending example

_Given_ a file named "alias_example_to_pending_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.alias_example_to :pit, :pending => "Pit alias used"
end

RSpec.describe "an example group" do
  pit "does something later on" do
    fail "not implemented yet"
  end
end
```

_When_ I run `rspec alias_example_to_pending_spec.rb --format doc`

_Then_ the output should contain "does something later on (PENDING: Pit alias used)"

_And_ the output should contain "0 failures".

## Use symbols as metadata

_Given_ a file named "use_symbols_as_metadata_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.alias_example_to :pit, :pending
end

RSpec.describe "an example group" do
  pit "does something later on" do
    fail "not implemented yet"
  end
end
```

_When_ I run `rspec use_symbols_as_metadata_spec.rb --format doc`

_Then_ the output should contain "does something later on (PENDING: No reason given)"

_And_ the output should contain "0 failures".
