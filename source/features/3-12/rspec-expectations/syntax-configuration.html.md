# Syntax Configuration

The primary syntax provided by rspec-expectations is based on
  the `expect` method, which explicitly wraps an object or block
  of code in order to set an expectation on it.

  There's also an older `should`-based syntax, which relies upon `should` being
  monkey-patched onto every object in the system. However, this syntax can at times lead to
  some surprising failures, since RSpec does not own every object in the system and cannot
  guarantee that it will always work consistently.

  We recommend you use the `expect` syntax unless you have a specific reason you prefer the
  `should` syntax. We have no plans to ever completely remove the `should` syntax but starting
  in RSpec 3, a deprecation warning will be issued if you do not explicitly enable it, with the
  plan to disable it by default in RSpec 4 (and potentially move it into an external gem).

  If you have an old `should`-based project that you would like to upgrade to the `expect`,
  check out [transpec](http://yujinakayama.me/transpec/), which can perform the conversion automatically for you.

## Background

_Given_ a file named "spec/syntaxes_spec.rb" with:

```ruby
require 'spec_helper'

RSpec.describe "using the should syntax" do
  specify { 3.should eq(3) }
  specify { 3.should_not eq(4) }
  specify { lambda { raise "boom" }.should raise_error("boom") }
  specify { lambda { }.should_not raise_error }
end

RSpec.describe "using the expect syntax" do
  specify { expect(3).to eq(3) }
  specify { expect(3).not_to eq(4) }
  specify { expect { raise "boom" }.to raise_error("boom") }
  specify { expect { }.not_to raise_error }
end
```

## Both syntaxes are available by default

_Given_ a file named "spec/spec_helper.rb" with:

```ruby

```

_When_ I run `rspec`

_Then_ the examples should all pass

_And_ the output should contain "Using `should` from rspec-expectations' old `:should` syntax without explicitly enabling the syntax is deprecated".

## Disable should syntax

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end
```

_When_ I run `rspec`

_Then_ the output should contain all of these:

|                           |
|---------------------------|
| 8 examples, 4 failures    |
| undefined method `should' |

## Disable expect syntax

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = :should
  end
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end
```

_When_ I run `rspec`

_Then_ the output should contain all of these:

|                           |
|---------------------------|
| 8 examples, 4 failures    |
| undefined method `expect' |

## Explicitly enable both syntaxes

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end
end
```

_When_ I run `rspec`

_Then_ the examples should all pass

_And_ the output should not contain "deprecated".
