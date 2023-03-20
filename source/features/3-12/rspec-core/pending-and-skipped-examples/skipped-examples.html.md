# Using `skip` with examples

RSpec offers a number of ways to indicate that an example should be skipped
  and not executed.

## No implementation provided

_Given_ a file named "example_without_block_spec.rb" with:

```ruby
RSpec.describe "an example" do
  it "is a skipped example"
end
```

_When_ I run `rspec example_without_block_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain "Not yet implemented"

_And_ the output should contain "example_without_block_spec.rb:2".

## Skipping using `skip`

_Given_ a file named "skipped_spec.rb" with:

```ruby
RSpec.describe "an example" do
  skip "is skipped" do
  end
end
```

_When_ I run `rspec skipped_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is skipped
     # No reason given
     # ./skipped_spec.rb:2
```

## Skipping using `skip` inside an example

_Given_ a file named "skipped_spec.rb" with:

```ruby
RSpec.describe "an example" do
  it "is skipped" do
    skip
  end
end
```

_When_ I run `rspec skipped_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is skipped
     # No reason given
     # ./skipped_spec.rb:2
```

## Temporarily skipping by prefixing `it`, `specify`, or `example` with an x

_Given_ a file named "temporarily_skipped_spec.rb" with:

```ruby
RSpec.describe "an example" do
  xit "is skipped using xit" do
  end

  xspecify "is skipped using xspecify" do
  end

  xexample "is skipped using xexample" do
  end
end
```

_When_ I run `rspec temporarily_skipped_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "3 examples, 0 failures, 3 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is skipped using xit
     # Temporarily skipped with xit
     # ./temporarily_skipped_spec.rb:2

  2) an example is skipped using xspecify
     # Temporarily skipped with xspecify
     # ./temporarily_skipped_spec.rb:5

  3) an example is skipped using xexample
     # Temporarily skipped with xexample
     # ./temporarily_skipped_spec.rb:8
```

## Skipping using metadata

_Given_ a file named "skipped_spec.rb" with:

```ruby
RSpec.describe "an example" do
  example "is skipped", :skip => true do
  end
end
```

_When_ I run `rspec skipped_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is skipped
     # No reason given
     # ./skipped_spec.rb:2
```

## Skipping using metadata with a reason

_Given_ a file named "skipped_with_reason_spec.rb" with:

```ruby
RSpec.describe "an example" do
  example "is skipped", :skip => "waiting for planets to align" do
    raise "this line is never executed"
  end
end
```

_When_ I run `rspec skipped_with_reason_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the output should contain:

```
Pending: (Failures listed here are expected and do not affect your suite's status)

  1) an example is skipped
     # waiting for planets to align
     # ./skipped_with_reason_spec.rb:2
```
