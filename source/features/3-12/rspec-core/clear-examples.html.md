# Running specs multiple times with different runner options in the same process

Use `clear_examples` command to clear all example groups between different
  runs in the same process. It:

  - clears all example groups
  - restores inclusion and exclusion filters set by configuration
  - clears inclusion and exclusion filters set by previous spec run (via runner)
  - resets all time counters (start time, load time, duration, etc.)
  - resets different counts of examples (all examples, pending and failed)

  ```ruby
  require "spec_helper"

  RSpec::Core::Runner.run([... some parameters ...])

  RSpec.clear_examples

  RSpec::Core::Runner.run([... different parameters ...])
  ```

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.filter_run_when_matching :focus => true
  config.filter_run_excluding :slow => true
end
```

_Given_ a file named "spec/truth_spec.rb" with:

```ruby
require 'spec_helper'

RSpec.describe "truth" do
  describe true do
    it "is truthy" do
      expect(true).to be_truthy
    end

    it "is not falsy" do
      expect(true).not_to be_falsy
    end
  end

  describe false do
    it "is falsy" do
      expect(false).to be_falsy
    end

    it "is truthy" do
      expect(false).not_to be_truthy
    end
  end
end
```

## Running specs multiple times in the same process

_Given_ a file named "scripts/multiple_runs.rb" with:

```ruby
require 'rspec/core'

RSpec::Core::Runner.run(['spec'])
RSpec.clear_examples
RSpec::Core::Runner.run(['spec'])
```

_When_ I run `ruby scripts/multiple_runs.rb`

_Then_ the output should match:

```
4 examples, 0 failures
.*
4 examples, 0 failures
```

## Running specs multiple times in the same process with different parameters

_Given_ a file named "spec/bar_spec.rb" with:

```ruby
require 'spec_helper'

RSpec.describe 'bar' do
  subject(:bar) { :focused }

  it 'is focused', :focus do
    expect(bar).to be(:focused)
  end
end
```

_Given_ a file named "scripts/different_parameters.rb" with:

```ruby
require 'rspec/core'

RSpec::Core::Runner.run(['spec'])
RSpec.clear_examples
RSpec::Core::Runner.run(['spec/truth_spec.rb:4'])
RSpec.clear_examples
RSpec::Core::Runner.run(['spec', '-e', 'fals'])
```

_When_ I run `ruby scripts/different_parameters.rb`

_Then_ the output should match:

```
1 example, 0 failures
.*
2 examples, 0 failures
.*
3 examples, 0 failures
```
