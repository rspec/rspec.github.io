# `stub`

`stub` is the old way to [allow messages](../basics/allowing-messages) but carries the baggage of a
  global monkey patch on all objects. It supports the same fluent
  interface for [setting constraints](../setting-constraints) and [configuring responses](../configuring-responses). You can also pass `stub` a hash
  of message/return-value pairs, which acts like `allow(obj).to receive_messages(hash)`,
  but does not support further customization through the fluent interface.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end
```

_And_ a file named ".rspec" with:

```
--require spec_helper
```

## Stub a method

_Given_ a file named "spec/stub_spec.rb" with:

```ruby
RSpec.describe "Stubbing a method" do
  it "configures how the object responds" do
    dbl = double
    dbl.stub(:foo).and_return(13)
    expect(dbl.foo).to eq(13)
  end
end
```

_When_ I run `rspec spec/stub_spec.rb`

_Then_ the examples should all pass.

## Stub multiple methods by passing a hash

_Given_ a file named "spec/stub_multiple_methods_spec.rb" with:

```ruby
RSpec.describe "Stubbing multiple methods" do
  it "stubs each named method with the given return value" do
    dbl = double
    dbl.stub(:foo => 13, :bar => 10)
    expect(dbl.foo).to eq(13)
    expect(dbl.bar).to eq(10)
  end
end
```

_When_ I run `rspec spec/stub_multiple_methods_spec.rb`

_Then_ the examples should all pass.
