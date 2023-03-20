# Inclusion filters

You can constrain which examples are run by declaring an inclusion filter.
  The most common use case is to focus on a subset of examples as you're focused
  on a particular problem. You can also specify metadata using only symbols.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |c|
  c.filter_run_including :focus => true
end
```

## Focus on an example

_Given_ a file named "spec/sample_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "something" do
  it "does one thing" do
  end

  it "does another thing", :focus => true do
  end
end
```

_When_ I run `rspec spec/sample_spec.rb --format doc`

_Then_ the output should contain "does another thing"

_And_ the output should not contain "does one thing".

## Focus on a group

_Given_ a file named "spec/sample_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "group 1", :focus => true do
  it "group 1 example 1" do
  end

  it "group 1 example 2" do
  end
end

RSpec.describe "group 2" do
  it "group 2 example 1" do
  end
end
```

_When_ I run `rspec spec/sample_spec.rb --format doc`

_Then_ the output should contain "group 1 example 1"

_And_ the output should contain "group 1 example 2"

_And_ the output should not contain "group 2 example 1".

## `before`/`after(:context)` hooks in unmatched example group are not run

_Given_ a file named "spec/before_after_all_inclusion_filter_spec.rb" with:

```ruby
require "spec_helper"

RSpec.describe "group 1", :focus => true do
  before(:context) { puts "before all in focused group" }
  after(:context)  { puts "after all in focused group"  }

  it "group 1 example" do
  end
end

RSpec.describe "group 2" do
  before(:context) { puts "before all in unfocused group" }
  after(:context)  { puts "after all in unfocused group"  }

  context "context 1" do
    it "group 2 context 1 example 1" do
    end
  end
end
```

_When_ I run `rspec ./spec/before_after_all_inclusion_filter_spec.rb`

_Then_ the output should contain "before all in focused group"

_And_ the output should contain "after all in focused group"

_And_ the output should not contain "before all in unfocused group"

_And_ the output should not contain "after all in unfocused group".

## Use symbols as metadata

_Given_ a file named "symbols_as_metadata_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.filter_run :current_example
end

RSpec.describe "something" do
  it "does one thing" do
  end

  it "does another thing", :current_example do
  end
end
```

_When_ I run `rspec symbols_as_metadata_spec.rb --format doc`

_Then_ the output should contain "does another thing"

_And_ the output should not contain "does one thing".
