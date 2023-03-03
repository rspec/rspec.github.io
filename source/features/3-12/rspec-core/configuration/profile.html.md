# Profiling examples (`--profile`)

The `--profile` command line option (available from `RSpec.configure` as
  `#profile_examples`), when set, will cause RSpec to dump out a list of your
  slowest examples. By default, it prints the 10 slowest examples, but you can
  set it to a different value to have it print more or fewer slow examples. If
  `--fail-fast` option is used together with `--profile` and there is a failure,
  slow examples are not shown.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby

```

_And_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "something" do
  it "sleeps for 0.1 seconds (example 1)" do
    sleep 0.1
    expect(1).to eq(1)
  end

  it "sleeps for 0 seconds (example 2)" do
    expect(2).to eq(2)
  end

  it "sleeps for 0.15 seconds (example 3)" do
    sleep 0.15
    expect(3).to eq(3)
  end

  it "sleeps for 0.05 seconds (example 4)" do
    sleep 0.05
    expect(4).to eq(4)
  end

  it "sleeps for 0.05 seconds (example 5)" do
    sleep 0.05
    expect(5).to eq(5)
  end

  it "sleeps for 0.05 seconds (example 6)" do
    sleep 0.05
    expect(6).to eq(6)
  end

  it "sleeps for 0.05 seconds (example 7)" do
    sleep 0.05
    expect(7).to eq(7)
  end

  it "sleeps for 0.05 seconds (example 8)" do
    sleep 0.05
    expect(8).to eq(8)
  end

  it "sleeps for 0.05 seconds (example 9)" do
    sleep 0.05
    expect(9).to eq(9)
  end

  it "sleeps for 0.05 seconds (example 10)" do
    sleep 0.05
    expect(10).to eq(10)
  end

  it "sleeps for 0.05 seconds (example 11)" do
    sleep 0.05
    expect(11).to eq(11)
  end
end
```

## By default does not show profile

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should not contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should not contain "example 3"

_And_ the output should not contain "example 4"

_And_ the output should not contain "example 5"

_And_ the output should not contain "example 6"

_And_ the output should not contain "example 7"

_And_ the output should not contain "example 8"

_And_ the output should not contain "example 9"

_And_ the output should not contain "example 10"

_And_ the output should not contain "example 11".

## Setting `profile_examples` to true shows 10 examples

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.profile_examples = true }
```

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should contain "Top 10 slowest examples"

_And_ the output should contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should contain "example 3"

_And_ the output should contain "example 4"

_And_ the output should contain "example 5"

_And_ the output should contain "example 6"

_And_ the output should contain "example 7"

_And_ the output should contain "example 8"

_And_ the output should contain "example 9"

_And_ the output should contain "example 10"

_And_ the output should contain "example 11".

## Setting `profile_examples` to 2 shows 2 examples

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.profile_examples = 2 }
```

_When_ I run `rspec spec`

_Then_ the examples should all pass

_And_ the output should contain "Top 2 slowest examples"

_And_ the output should contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should contain "example 3"

_And_ the output should not contain "example 4"

_And_ the output should not contain "example 5"

_And_ the output should not contain "example 6"

_And_ the output should not contain "example 7"

_And_ the output should not contain "example 8"

_And_ the output should not contain "example 9"

_And_ the output should not contain "example 10"

_And_ the output should not contain "example 11".

## Setting profile examples through CLI using `--profile`

_When_ I run `rspec spec --profile 2`

_Then_ the examples should all pass

_And_ the output should contain "Top 2 slowest examples"

_And_ the output should contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should contain "example 3"

_And_ the output should not contain "example 4"

_And_ the output should not contain "example 5"

_And_ the output should not contain "example 6"

_And_ the output should not contain "example 7"

_And_ the output should not contain "example 8"

_And_ the output should not contain "example 9"

_And_ the output should not contain "example 10"

_And_ the output should not contain "example 11".

## Using `--no-profile` overrules config options

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.profile_examples = true }
```

_When_ I run `rspec spec --no-profile`

_Then_ the examples should all pass

_And_ the output should not contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should not contain "example 3"

_And_ the output should not contain "example 4"

_And_ the output should not contain "example 5"

_And_ the output should not contain "example 6"

_And_ the output should not contain "example 7"

_And_ the output should not contain "example 8"

_And_ the output should not contain "example 9"

_And_ the output should not contain "example 10"

_And_ the output should not contain "example 11".

## Using `--profile` with `--fail-fast` shows slow examples if everything passes

_When_ I run `rspec spec --fail-fast --profile`

_Then_ the examples should all pass

_And_ the output should contain "Top 10 slowest examples"

_And_ the output should contain "example 1"

_And_ the output should not contain "example 2"

_And_ the output should contain "example 3"

_And_ the output should contain "example 4"

_And_ the output should contain "example 5"

_And_ the output should contain "example 6"

_And_ the output should contain "example 7"

_And_ the output should contain "example 8"

_And_ the output should contain "example 9"

_And_ the output should contain "example 10"

_And_ the output should contain "example 11".

## Using `--profile` shows slow examples even in case of failures

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "something" do
  it "sleeps for 0.1 seconds (example 1)" do
    sleep 0.1
    expect(1).to eq(1)
  end

  it "fails" do
    fail
  end
end
```

_When_ I run `rspec spec --profile`

_Then_ the output should contain "2 examples, 1 failure"

_And_ the output should contain "Top 2 slowest examples"

_And_ the output should contain "example 1".

## Using `--profile` with `--fail-fast` doesn't show slow examples in case of failures

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "something" do
  it "sleeps for 0.1 seconds (example 1)" do
    sleep 0.1
    expect(1).to eq(1)
  end

  it "fails" do
    fail
  end
end
```

_When_ I run `rspec spec --fail-fast --profile`

_Then_ the output should not contain "Top 2 slowest examples"

_And_ the output should not contain "example 1".

## Using `--profile` with slow before hooks includes hook execution time

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "slow before context hook" do
  before(:context) do
    sleep 0.2
  end

  context "nested" do
    it "example" do
      expect(10).to eq(10)
    end
  end
end

RSpec.describe "slow example" do
  it "slow example" do
    sleep 0.1
    expect(10).to eq(10)
  end
end
```

_When_ I run `rspec spec --profile 1`

_Then_ the output should report "slow before context hook" as the slowest example group.
