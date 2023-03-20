# Using `filter_run_when_matching`

You can configure a _conditional_ filter that only applies if there are any matching
  examples using `config.filter_run_when_matching`. This is commonly used for focus
  filtering:

  ```ruby
  RSpec.configure do |c|
    c.filter_run_when_matching :focus
  end
  ```

  This configuration allows you to filter to specific examples or groups by tagging
  them with `:focus` metadata. When no example or groups are focused (which should be
  the norm since it's intended to be a temporary change), the filter will be ignored.

  RSpec also provides aliases--`fit`, `fdescribe` and `fcontext`--as a shorthand for
  `it`, `describe` and `context` with `:focus` metadata, making it easy to temporarily
  focus an example or group by prefixing an `f`.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |c|
  c.filter_run_when_matching :focus
end
```

_And_ a file named ".rspec" with:

```
--require spec_helper
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "A group" do
  it "has a passing example" do
  end

  context "a nested group" do
    it "also has a passing example" do
    end
  end
end
```

## The filter is ignored when nothing is focused

_When_ I run `rspec --format doc`

_Then_ it should pass with "2 examples, 0 failures"

_And_ the output should contain:

```
A group
  has a passing example
  a nested group
    also has a passing example
```

## Examples can be focused with `fit`

_Given_ I have changed `it "has a passing example"` to `fit "has a passing example"` in "spec/example_spec.rb"

_When_ I run `rspec --format doc`

_Then_ it should pass with "1 example, 0 failures"

_And_ the output should contain:

```
A group
  has a passing example
```

## Groups can be focused with `fdescribe` or `fcontext`

_Given_ I have changed `context` to `fcontext` in "spec/example_spec.rb"

_When_ I run `rspec --format doc`

_Then_ it should pass with "1 example, 0 failures"

_And_ the output should contain:

```
A group
  a nested group
    also has a passing example
```
