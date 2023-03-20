# `stub_chain`

`stub_chain` is the old way to [allow a message chain](../working-with-legacy-code/message-chains) but carries the
  baggage of a global monkey patch on all objects. As with
  `receive_message_chain`, use with care; we recommend treating usage of `stub_chain` as a
  code smell.

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

## Use `stub_chain` on a double

_Given_ a file named "spec/stub_chain_spec.rb" with:

```ruby
RSpec.describe "Using stub_chain on a double" do
  let(:dbl) { double }

  example "using a string and a block" do
    dbl.stub_chain("foo.bar") { :baz }
    expect(dbl.foo.bar).to eq(:baz)
  end

  example "using symbols and a hash" do
    dbl.stub_chain(:foo, :bar => :baz)
    expect(dbl.foo.bar).to eq(:baz)
  end

  example "using symbols and a block" do
    dbl.stub_chain(:foo, :bar) { :baz }
    expect(dbl.foo.bar).to eq(:baz)
  end
end
```

_When_ I run `rspec spec/stub_chain_spec.rb`

_Then_ the examples should all pass.

## Use `stub_chain` on any instance of a class

_Given_ a file named "spec/stub_chain_spec.rb" with:

```ruby
RSpec.describe "Using any_instance.stub_chain" do
  example "using a string and a block" do
    Object.any_instance.stub_chain("foo.bar") { :baz }
    expect(Object.new.foo.bar).to eq(:baz)
  end

  example "using symbols and a hash" do
    Object.any_instance.stub_chain(:foo, :bar => :baz)
    expect(Object.new.foo.bar).to eq(:baz)
  end

  example "using symbols and a block" do
    Object.any_instance.stub_chain(:foo, :bar) { :baz }
    expect(Object.new.foo.bar).to eq(:baz)
  end
end
```

_When_ I run `rspec spec/stub_chain_spec.rb`

_Then_ the examples should all pass.
