# Setting the `fail_fast` option

Use the `fail_fast` option to tell RSpec to abort the run after N failures:

## `fail_fast` with no failures (runs all examples)

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure {|c| c.fail_fast = 1}
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "something" do
  it "passes" do
  end

  it "passes too" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the examples should all pass.

## `fail_fast` with first example failing (only runs the one example)

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure {|c| c.fail_fast = 1}
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "something" do
  it "fails" do
    fail
  end

  it "passes" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb -fd`

_Then_ the output should contain "1 example, 1 failure".

## `fail_fast` with multiple files, second example failing (only runs the first two examples)

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure {|c| c.fail_fast = 1}
```

_And_ a file named "spec/example_1_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "something" do
  it "passes" do
  end

  it "fails" do
    fail
  end
end

RSpec.describe "something else" do
  it "fails" do
    fail
  end
end
```

_And_ a file named "spec/example_2_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "something" do
  it "passes" do
  end
end

RSpec.describe "something else" do
  it "fails" do
    fail
  end
end
```

_When_ I run `rspec spec`

_Then_ the output should contain "2 examples, 1 failure".

## `fail_fast 2` with 1st and 3rd examples failing (only runs the first 3 examples)

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure {|c| c.fail_fast = 2}
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
require "spec_helper"
RSpec.describe "something" do
  it "fails once" do
    fail
  end

  it "passes once" do
  end

  it "fails twice" do
    fail
  end

  it "passes" do
  end
end
```

_When_ I run `rspec spec/example_spec.rb -fd`

_Then_ the output should contain "3 examples, 2 failures".
