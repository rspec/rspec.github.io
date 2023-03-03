# Defining a matcher supporting block expectations

When you wish to support block expectations (e.g. `expect { ... }.to matcher`) with
  your custom matchers you must specify this. You can do this manually (or determinately
  based on some logic) by defining a `supports_block_expectation?` method or by using
  the DSL's `supports_block_expectations` shortcut method.

## Define a block matcher manually

_Given_ a file named "block_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :support_blocks do
  match do |actual|
    actual.is_a? Proc
  end

  def supports_block_expectations?
    true # or some logic
  end
end

RSpec.describe "a custom block matcher" do
  specify { expect { }.to support_blocks }
end
```

_When_ I run `rspec ./block_matcher_spec.rb`

_Then_ the example should pass.

## Define a block matcher using shortcut

_Given_ a file named "block_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :support_blocks do
  match do |actual|
    actual.is_a? Proc
  end

  supports_block_expectations
end

RSpec.describe "a custom block matcher" do
  specify { expect { }.to support_blocks }
end
```

_When_ I run `rspec ./block_matcher_spec.rb`

_Then_ the example should pass.

## Define a block matcher using shortcut

_Given_ a file named "block_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :support_blocks_with_errors do
  match(:notify_expectation_failures => true) do |actual|
    actual.call
    true
  end

  supports_block_expectations
end

RSpec.describe "a custom block matcher" do
  specify do
    expect {
      expect(true).to eq false
    }.to support_blocks_with_errors
  end
end
```

_When_ I run `rspec ./block_matcher_spec.rb`

_Then_ it should fail with:

```
Failures:

  1) a custom block matcher is expected to support blocks with errors
     Failure/Error: expect(true).to eq false

       expected: false
            got: true

       (compared using ==)
```
