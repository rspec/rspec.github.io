# Configuring an expectation framework

By default, RSpec is configured to include rspec-expectations for expressing
  desired outcomes. You can also configure RSpec to use:

  * rspec/expectations (explicitly)
  * test/unit assertions
  * minitest assertions
  * any combination of the above libraries

  Note that when you do not use rspec-expectations, you must explicitly provide
  a description to every example. You cannot rely on the generated descriptions
  provided by rspec-expectations.

## Default configuration uses rspec-expectations

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec::Matchers.define :be_a_multiple_of do |factor|
  match do |actual|
    actual % factor == 0
  end
end

RSpec.describe 6 do
  it { is_expected.to be_a_multiple_of 3 }
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Configure rspec-expectations (explicitly)

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec
end

RSpec.describe 5 do
  it "is greater than 4" do
    expect(5).to be > 4
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Configure test/unit assertions

_Given_ rspec-expectations is not installed

_And_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :test_unit
end

RSpec.describe [1] do
  it "is equal to [1]" do
    assert_equal [1], [1], "expected [1] to equal [1]"
  end

  specify { assert_not_equal [1], [] }

  it "is equal to [2] (intentional failure)" do
    assert [1] == [2], "errantly expected [2] to equal [1]"
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should match:

```
     (Test::Unit::AssertionFailedError|Mini(T|t)est::Assertion):
       errantly expected \[2\] to equal \[1\]
```

_And_ the output should contain "3 examples, 1 failure".

## Configure minitest assertions

_Given_ rspec-expectations is not installed

_And_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :minitest
end

RSpec.describe "Object identity" do
  it "the an object is the same as itself" do
    x = [1]
    assert_same x, x, "expected x to be the same x"
  end

  specify { refute_same [1], [1] }

  it "is empty (intentional failure)" do
    assert_empty [1], "errantly expected [1] to be empty"
  end

  it "marks pending for skip method" do
    skip "intentionally"
  end
end
```

_When_ I run `rspec -b example_spec.rb`

_Then_ the output should match:

```
     MiniT|test::Assertion:
       errantly expected \[1\] to be empty
```

_And_ the output should contain "4 examples, 1 failure, 1 pending"

_And_ the output should not contain "Warning: you should require 'minitest/autorun' instead.".

## Configure rspec/expectations AND test/unit assertions

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec, :test_unit
end

RSpec.describe [1] do
  it "is equal to [1]" do
    assert_equal [1], [1], "expected [1] to equal [1]"
  end

  it "matches array [1]" do
    is_expected.to match_array([1])
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Configure rspec/expectations AND minitest assertions

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec, :minitest
end

RSpec.describe "Object identity" do
  it "two arrays are not the same object" do
    refute_same [1], [1]
  end

  it "an array is itself" do
    array = [1]
    expect(array).to be array
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Configure test/unit and minitest assertions

_Given_ rspec-expectations is not installed

_And_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :test_unit, :minitest
end

RSpec.describe [1] do
  it "is equal to [1]" do
    assert_equal [1], [1], "expected [1] to equal [1]"
  end

  specify { assert_not_equal [1], [] }

  it "the an object is the same as itself" do
    x = [1]
    assert_same x, x, "expected x to be the same x"
  end

  specify { refute_same [1], [1] }
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.
