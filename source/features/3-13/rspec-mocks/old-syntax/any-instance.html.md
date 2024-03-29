# `any_instance`

`any_instance` is the old way to stub or mock any instance of a class but carries the baggage of a global monkey patch on all classes.
  Note that we [generally recommend against](../working-with-legacy-code/any-instance) using this feature.

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

## Stub a method on any instance of a class

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "Stubbing a method with any_instance" do
  it "returns the specified value on any instance of the class" do
    Object.any_instance.stub(:foo).and_return(:return_value)

    o = Object.new
    expect(o.foo).to eq(:return_value)
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the examples should all pass.

## Stub multiple methods on any instance of a class

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "Stubbing multiple methods with any_instance" do
  it "returns the specified values for the given messages" do
    Object.any_instance.stub(:foo => 'foo', :bar => 'bar')

    o = Object.new
    expect(o.foo).to eq('foo')
    expect(o.bar).to eq('bar')
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the examples should all pass.

## Stubbing any instance of a class with specific arguments

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "Stubbing any instance with arguments" do
  it "returns the stubbed value when arguments match" do
    Object.any_instance.stub(:foo).with(:param_one, :param_two).and_return(:result_one)
    Object.any_instance.stub(:foo).with(:param_three, :param_four).and_return(:result_two)

    o = Object.new
    expect(o.foo(:param_one, :param_two)).to eq(:result_one)
    expect(o.foo(:param_three, :param_four)).to eq(:result_two)
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the examples should all pass.

## Block implementation is passed the receiver as first arg

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "Stubbing any instance of a class" do
  it 'yields the receiver to the block implementation' do
    String.any_instance.stub(:slice) do |value, start, length|
      value[start, length]
    end

    expect('string'.slice(2, 3)).to eq('rin')
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the examples should all pass.

## Expect a message on any instance of a class

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "Expecting a message on any instance of a class" do
  before do
    Object.any_instance.should_receive(:foo)
  end

  it "passes when an instance receives the message" do
    Object.new.foo
  end

  it "fails when no instance receives the message" do
    Object.new.to_s
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ it should fail with the following output:

|                                                                                    |
|------------------------------------------------------------------------------------|
| 2 examples, 1 failure                                                              |
| Exactly one instance should have received the following message(s) but didn't: foo |
