# `raise_error` matcher

Use the `raise_error` matcher to specify that a block of code raises an error. The most
  basic form passes if any error is thrown:

  ```ruby
  expect { raise StandardError }.to raise_error
  ```

  You can use `raise_exception` instead if you prefer that wording:

  ```ruby
  expect { 3 / 0 }.to raise_exception
  ```

  `raise_error` and `raise_exception` are functionally interchangeable, so use the one that
  makes the most sense to you in any given context.

  In addition to the basic form, above, there are a number of ways to specify details of an
  error/exception:

  ```ruby
  expect { raise "oops" }.to raise_error
  expect { raise "oops" }.to raise_error(RuntimeError)
  expect { raise "oops" }.to raise_error("oops")
  expect { raise "oops" }.to raise_error(/op/)
  expect { raise "oops" }.to raise_error(RuntimeError, "oops")
  expect { raise "oops" }.to raise_error(RuntimeError, /op/)
  expect { raise "oops" }.to raise_error(an_instance_of(RuntimeError).and having_attributes(message: "oops"))
  ```

## Expecting any error

_Given_ a file named "example_spec" with:

```
RSpec.describe "calling a missing method" do
  it "raises" do
    expect { Object.new.foo }.to raise_error
  end
end
```

_When_ I run `rspec example_spec`

_Then_ the example should pass.

## Expecting a specific error

_Given_ a file named "example_spec" with:

```
RSpec.describe "calling a missing method" do
  it "raises" do
    expect { Object.new.foo }.to raise_error(NameError)
  end
end
```

_When_ I run `rspec example_spec`

_Then_ the example should pass.

## Matching a message with a string

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "matching error message with string" do
  it "matches the error message" do
    expect { raise StandardError, 'this message exactly'}.
      to raise_error('this message exactly')
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the example should pass.

## Matching a message with a regexp

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "matching error message with regex" do
  it "matches the error message" do
    expect { raise StandardError, "my message" }.
      to raise_error(/my mess/)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the example should pass.

## Matching a message with `with_message`

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "matching error message with regex" do
  it "matches the error message" do
    expect { raise StandardError, "my message" }.
      to raise_error.with_message(/my mess/)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the example should pass.

## Matching a class + message with string

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "matching error message with string" do
  it "matches the error message" do
    expect { raise StandardError, 'this message exactly'}.
      to raise_error(StandardError, 'this message exactly')
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the example should pass.

## Matching a class + message with regexp

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "matching error message with regex" do
  it "matches the error message" do
    expect { raise StandardError, "my message" }.
      to raise_error(StandardError, /my mess/)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the example should pass.

## Setting expectations on error object passed to block

_Given_ a file named "example_spec" with:

```
RSpec.describe "#foo" do
  it "raises NameError" do
    expect { Object.new.foo }.to raise_error { |error|
      expect(error).to be_a(NameError)
    }
  end
end
```

_When_ I run `rspec example_spec`

_Then_ the example should pass.

## Setting expectations on an error object with chained matchers

_Given_ a file named "example_spec" with:

```
RSpec.describe "composing matchers" do
  it "raises StandardError" do
    expect { raise StandardError, "my message" }.
      to raise_error(an_instance_of(StandardError).and having_attributes({"message" => "my message"}))
  end
end
```

_When_ I run `rspec example_spec`

_Then_ the example should pass.

## Expecting no error at all

_Given_ a file named "example_spec" with:

```
RSpec.describe "#to_s" do
  it "does not raise" do
    expect { Object.new.to_s }.not_to raise_error
  end
end
```

_When_ I run `rspec example_spec`

_Then_ the example should pass.
