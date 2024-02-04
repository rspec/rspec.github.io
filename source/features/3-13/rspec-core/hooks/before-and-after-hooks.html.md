# `before` and `after` hooks

Use `before` and `after` hooks to execute arbitrary code before and/or after
  the body of an example is run:

  ```ruby
  before(:example) # run before each example
  before(:context) # run one time only, before all of the examples in a group

  after(:example) # run after each example
  after(:context) # run one time only, after all of the examples in a group
  ```

  `before` and `after` blocks are called in the following order:

  ```ruby
  before :suite
  before :context
  before :example
  after  :example
  after  :context
  after  :suite
  ```

  A bare `before` or `after` hook defaults to the `:example` scope.

  `before` and `after` hooks can be defined directly in the example groups they
  should run in, or in a global `RSpec.configure` block. Note that the status of
  the example does not affect the hooks.

  **WARNING:** Setting instance variables are not supported in `before(:suite)`.

  **WARNING:** Mocks are only supported in `before(:example)`.

  **WARNING:** `around` hooks will execute *before* any `before` hooks, and *after*
  any `after` hooks regardless of the context they were defined in.

  Note: the `:example` and `:context` scopes are also available as `:each` and
  `:all`, respectively. Use whichever you prefer.

## Define `before(:example)` block

_Given_ a file named "before_example_spec.rb" with:

```ruby
require "rspec/expectations"

class Thing
  def widgets
    @widgets ||= []
  end
end

RSpec.describe Thing do
  before(:example) do
    @thing = Thing.new
  end

  describe "initialized in before(:example)" do
    it "has 0 widgets" do
      expect(@thing.widgets.count).to eq(0)
    end

    it "can accept new widgets" do
      @thing.widgets << Object.new
    end

    it "does not share state across examples" do
      expect(@thing.widgets.count).to eq(0)
    end
  end
end
```

_When_ I run `rspec before_example_spec.rb`

_Then_ the examples should all pass.

## Define `before(:context)` block in example group

_Given_ a file named "before_context_spec.rb" with:

```ruby
require "rspec/expectations"

class Thing
  def widgets
    @widgets ||= []
  end
end

RSpec.describe Thing do
  before(:context) do
    @thing = Thing.new
  end

  describe "initialized in before(:context)" do
    it "has 0 widgets" do
      expect(@thing.widgets.count).to eq(0)
    end

    it "can accept new widgets" do
      @thing.widgets << Object.new
    end

    it "shares state across examples" do
      expect(@thing.widgets.count).to eq(1)
    end
  end
end
```

_When_ I run `rspec before_context_spec.rb`

_Then_ the examples should all pass

_When_ I run `rspec before_context_spec.rb:15`

_Then_ the examples should all pass.

## Failure in `before(:context)` block

_Given_ a file named "before_context_spec.rb" with:

```ruby
RSpec.describe "an error in before(:context)" do
  before(:context) do
    raise "oops"
  end

  it "fails this example" do
  end

  it "fails this example, too" do
  end

  after(:context) do
    puts "after context ran"
  end

  describe "nested group" do
    it "fails this third example" do
    end

    it "fails this fourth example" do
    end

    describe "yet another level deep" do
      it "fails this last example" do
      end
    end
  end
end
```

_When_ I run `rspec before_context_spec.rb --format documentation`

_Then_ the output should contain "5 examples, 5 failures"

_And_ the output should contain:

```
an error in before(:context)
  fails this example (FAILED - 1)
  fails this example, too (FAILED - 2)
  nested group
    fails this third example (FAILED - 3)
    fails this fourth example (FAILED - 4)
    yet another level deep
      fails this last example (FAILED - 5)
after context ran
```

_When_ I run `rspec before_context_spec.rb:9 --format documentation`

_Then_ the output should contain "1 example, 1 failure"

_And_ the output should contain:

```
an error in before(:context)
  fails this example, too (FAILED - 1)
```

## Failure in `after(:context)` block

_Given_ a file named "after_context_spec.rb" with:

```ruby
RSpec.describe "an error in after(:context)" do
  after(:context) do
    raise StandardError.new("Boom!")
  end

  it "passes this example" do
  end

  it "passes this example, too" do
  end
end
```

_When_ I run `rspec after_context_spec.rb`

_Then_ it should fail with:

```
An error occurred in an `after(:context)` hook.
Failure/Error: raise StandardError.new("Boom!")

StandardError:
  Boom!
# ./after_context_spec.rb:3
```

## A failure in an example does not affect hooks

_Given_ a file named "failure_in_example_spec.rb" with:

```ruby
RSpec.describe "a failing example does not affect hooks" do
  before(:context) { puts "before context runs" }
  before(:example) { puts "before example runs" }
  after(:example) { puts "after example runs" }
  after(:context) { puts "after context runs" }

  it "fails the example but runs the hooks" do
    raise "An Error"
  end
end
```

_When_ I run `rspec failure_in_example_spec.rb`

_Then_ it should fail with:

```
before context runs
before example runs
after example runs
Fafter context runs
```

## Define `before` and `after` blocks in configuration

_Given_ a file named "befores_in_configuration_spec.rb" with:

```ruby
require "rspec/expectations"

RSpec.configure do |config|
  config.before(:example) do
    @before_example = "before example"
  end
  config.before(:context) do
    @before_context = "before context"
  end
end

RSpec.describe "stuff in before blocks" do
  describe "with :context" do
    it "should be available in the example" do
      expect(@before_context).to eq("before context")
    end
  end
  describe "with :example" do
    it "should be available in the example" do
      expect(@before_example).to eq("before example")
    end
  end
end
```

_When_ I run `rspec befores_in_configuration_spec.rb`

_Then_ the examples should all pass.

## `before`/`after` blocks are run in order

_Given_ a file named "ensure_block_order_spec.rb" with:

```ruby
require "rspec/expectations"

RSpec.describe "before and after callbacks" do
  before(:context) do
    puts "before context"
  end

  before(:example) do
    puts "before example"
  end

  before do
    puts "also before example but by default"
  end

  after(:example) do
    puts "after example"
  end

  after do
    puts "also after example but by default"
  end

  after(:context) do
    puts "after context"
  end

  it "gets run in order" do

  end
end
```

_When_ I run `rspec --format progress ensure_block_order_spec.rb`

_Then_ the output should contain:

```
before context
before example
also before example but by default
also after example but by default
after example
.after context
```

## `before`/`after` blocks defined in configuration are run in order

_Given_ a file named "configuration_spec.rb" with:

```ruby
require "rspec/expectations"

RSpec.configure do |config|
  config.before(:suite) do
    puts "before suite"
  end

  config.before(:context) do
    puts "before context"
  end

  config.before(:example) do
    puts "before example"
  end

  config.after(:example) do
    puts "after example"
  end

  config.after(:context) do
    puts "after context"
  end

  config.after(:suite) do
    puts "after suite"
  end
end

RSpec.describe "ignore" do
  example "ignore" do
  end
end
```

_When_ I run `rspec --format progress configuration_spec.rb`

_Then_ the output should contain:

```
before suite
before context
before example
after example
.after context
after suite
```

## `before`/`after` context blocks are run once

_Given_ a file named "before_and_after_context_spec.rb" with:

```ruby
RSpec.describe "before and after callbacks" do
  before(:context) do
    puts "outer before context"
  end

  example "in outer group" do
  end

  after(:context) do
    puts "outer after context"
  end

  describe "nested group" do
    before(:context) do
      puts "inner before context"
    end

    example "in nested group" do
    end

    after(:context) do
      puts "inner after context"
    end
  end

end
```

_When_ I run `rspec --format progress before_and_after_context_spec.rb`

_Then_ the examples should all pass

_And_ the output should contain:

```
outer before context
.inner before context
.inner after context
outer after context
```

_When_ I run `rspec --format progress before_and_after_context_spec.rb:14`

_Then_ the examples should all pass

_And_ the output should contain:

```
outer before context
inner before context
.inner after context
outer after context
```

_When_ I run `rspec --format progress before_and_after_context_spec.rb:6`

_Then_ the examples should all pass

_And_ the output should contain:

```
outer before context
.outer after context
```

## Nested examples have access to state set in outer `before(:context)`

_Given_ a file named "before_context_spec.rb" with:

```ruby
RSpec.describe "something" do
  before :context do
    @value = 123
  end

  describe "nested" do
    it "access state set in before(:context)" do
      expect(@value).to eq(123)
    end

    describe "nested more deeply" do
      it "access state set in before(:context)" do
        expect(@value).to eq(123)
      end
    end
  end

  describe "nested in parallel" do
    it "access state set in before(:context)" do
      expect(@value).to eq(123)
    end
  end
end
```

_When_ I run `rspec before_context_spec.rb`

_Then_ the examples should all pass.

## `before`/`after` context blocks have access to state

_Given_ a file named "before_and_after_context_spec.rb" with:

```ruby
RSpec.describe "before and after callbacks" do
  before(:context) do
    @outer_state = "set in outer before context"
  end

  example "in outer group" do
    expect(@outer_state).to eq("set in outer before context")
  end

  describe "nested group" do
    before(:context) do
      @inner_state = "set in inner before context"
    end

    example "in nested group" do
      expect(@outer_state).to eq("set in outer before context")
      expect(@inner_state).to eq("set in inner before context")
    end

    after(:context) do
      expect(@inner_state).to eq("set in inner before context")
    end
  end

  after(:context) do
    expect(@outer_state).to eq("set in outer before context")
  end
end
```

_When_ I run `rspec before_and_after_context_spec.rb`

_Then_ the examples should all pass.

## Exception in `before(:example)` is captured and reported as failure

_Given_ a file named "error_in_before_example_spec.rb" with:

```ruby
RSpec.describe "error in before(:example)" do
  before(:example) do
    raise "this error"
  end

  it "is reported as failure" do
  end
end
```

_When_ I run `rspec error_in_before_example_spec.rb`

_Then_ the output should contain "1 example, 1 failure"

_And_ the output should contain "this error".
