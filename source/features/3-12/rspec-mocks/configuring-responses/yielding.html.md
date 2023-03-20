# Yielding

Use `and_yield` to make the test double yield the provided arguments when it receives the
  message. If the caller does not provide a block, or the caller's block does not accept the
  provided arguments, an error will be raised. If you want to yield multiple times, chain
  multiple `and_yield` calls together.

## Yield an argument

_Given_ a file named "yield_arguments_spec.rb" with:

```ruby
RSpec.describe "Making it yield arguments" do
  it "yields the provided args" do
    dbl = double
    allow(dbl).to receive(:foo).and_yield(2, 3)

    x = y = nil
    dbl.foo { |a, b| x, y = a, b }
    expect(x).to eq(2)
    expect(y).to eq(3)
  end
end
```

_When_ I run `rspec yield_arguments_spec.rb`

_Then_ the examples should all pass.

## It fails when the caller does not provide a block

_Given_ a file named "no_caller_block_spec.rb" with:

```ruby
RSpec.describe "Making it yield" do
  it "fails when the caller does not provide a block" do
    dbl = double
    allow(dbl).to receive(:foo).and_yield(2, 3)
    dbl.foo
  end
end
```

_When_ I run `rspec no_caller_block_spec.rb`

_Then_ it should fail with:

```
#<Double (anonymous)> asked to yield |[2, 3]| but no block was passed
```

## It fails when the caller's block does not accept the provided arguments

_Given_ a file named "arg_mismatch_spec.rb" with:

```ruby
RSpec.describe "Making it yield" do
  it "fails when the caller's block does not accept the provided arguments" do
    dbl = double
    allow(dbl).to receive(:foo).and_yield(2, 3)
    dbl.foo { |x| }
  end
end
```

_When_ I run `rspec arg_mismatch_spec.rb`

_Then_ it should fail with:

```
#<Double (anonymous)> yielded |2, 3| to block with arity of 1
```

## Yield multiple times

_Given_ a file named "yield_multiple_times_spec.rb" with:

```
RSpec.describe "Making it yield multiple times" do
  it "yields the specified args in succession" do
    yielded = []

    dbl = double
    allow(dbl).to receive(:foo).and_yield(1).and_yield(2).and_yield(3)
    dbl.foo { |x| yielded << x }

    expect(yielded).to eq([1, 2, 3])
  end
end
```

_When_ I run `rspec yield_multiple_times_spec.rb`

_Then_ the examples should all pass.
