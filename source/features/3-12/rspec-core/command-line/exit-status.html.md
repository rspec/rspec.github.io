# `--failure-exit-code` option (exit status)

The `rspec` command exits with an exit status of 0 if all examples pass, and 1
  if any examples fail. The failure exit code can be overridden using the
  `--failure-exit-code` option.

## A passing spec with the default exit code

_Given_ a file named "ok_spec.rb" with:

```ruby
RSpec.describe "ok" do
  it "passes" do
  end
end
```

_When_ I run `rspec ok_spec.rb`

_Then_ the exit status should be 0

_And_ the examples should all pass.

## A failing spec with the default exit code

_Given_ a file named "ko_spec.rb" with:

```ruby
RSpec.describe "KO" do
  it "fails" do
    raise "KO"
  end
end
```

_When_ I run `rspec ko_spec.rb`

_Then_ the exit status should be 1

_And_ the output should contain "1 example, 1 failure".

## A nested failing spec with the default exit code

_Given_ a file named "nested_ko_spec.rb" with:

```ruby
RSpec.describe "KO" do
  describe "nested" do
    it "fails" do
      raise "KO"
    end
  end
end
```

_When_ I run `rspec nested_ko_spec.rb`

_Then_ the exit status should be 1

_And_ the output should contain "1 example, 1 failure".

## Exit with 0 when no examples are run

_Given_ a file named "a_no_examples_spec.rb" with:

```ruby

```

_When_ I run `rspec a_no_examples_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "0 examples".

## A failing spec and `--failure-exit-code` is 42

_Given_ a file named "ko_spec.rb" with:

```ruby
RSpec.describe "KO" do
  it "fails" do
    raise "KO"
  end
end
```

_When_ I run `rspec --failure-exit-code 42 ko_spec.rb`

_Then_ the exit status should be 42

_And_ the output should contain "1 example, 1 failure".
