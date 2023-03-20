# Using `run_all_when_everything_filtered`

Note: this feature has been superseded by
  [`filter_run_when_matching`](../filtering/filter-run-when-matching) and will be
  removed in a future version of RSpec.

  Use the `run_all_when_everything_filtered` option to tell RSpec to run all the
  specs in the case where you try to run a filtered list of specs but no specs
  match that filter. This works well when paired with an inclusion filter like
  `:focus => true`, as it will run all the examples when none match the
  inclusion filter.

  ```ruby
  RSpec.configure { |c| c.run_all_when_everything_filtered = true }
  ```

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure {|c| c.run_all_when_everything_filtered = true}
```

## By default, no specs are run if they are all filtered out by an inclusion tag

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "examples" do
  it "with no tag" do
  end

  it "with no tag as well" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb --tag some_tag`

_Then_ the output should contain "0 examples, 0 failures".

## Specs are still run if they are filtered out by an exclusion tag

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "examples" do
  it "with no tag" do
  end

  it "with no tag as well" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb --tag ~some_tag`

_Then_ the output should contain "2 examples, 0 failures".

## When the `run_all_when_everything_filtered` option is turned on, if there are any matches for the filtering tag, only those features are run

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "examples" do
  it "with no tag", :some_tag => true do
  end

  it "with no tag as well" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb --tag some_tag`

_Then_ the output should contain "1 example, 0 failures"

_And_ the output should contain "Run options: include {:some_tag=>true}".

## When the `run_all_when_everything_filtered` option is turned on, all the specs are run when the tag has no matches

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "examples" do
  it "with no tag" do
  end

  it "with no tag as well" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb --tag some_tag`

_Then_ the output should contain "2 examples, 0 failures"

_And_ the output should contain "All examples were filtered out; ignoring {:some_tag=>true}".
