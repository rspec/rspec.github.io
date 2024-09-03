# Global namespace DSL

RSpec has a few top-level constructs that allow you to begin describing
  behaviour:

  * `RSpec.describe`: Define a named context for a group of examples.

  * `RSpec.shared_examples`: Define a set of shared examples that can later be
    included in an example group.

  * `RSpec.shared_context`: define some common context (using `before`, `let`,
    helper methods, etc) that can later be included in an example group.

  Historically, these constructs have been available directly off of the main
  object, so that you could use these at the start of a file without the
  `RSpec.` prefix. They have also been available off of any class or module so
  that you can scope your examples within a particular constant namespace.

  RSpec 3 now provides an option to disable this global monkey patching:

  ```ruby
  config.expose_dsl_globally = false
  ```

  For backwards compatibility it defaults to `true`.

## By default RSpec allows the DSL to be used globally

_Given_ a file named "spec/example_spec.rb" with:

```ruby
describe "specs here" do
  it "passes" do
  end
end
```

_When_ I run `rspec`

_Then_ the output should contain "1 example, 0 failures".

## By default rspec/autorun allows the DSL to be used globally

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require 'rspec/autorun'
describe "specs here" do
  it "passes" do
  end
end
```

_When_ I run `ruby spec/example_spec.rb`

_Then_ the output should contain "1 example, 0 failures".

## When exposing globally is disabled the top level DSL no longer works

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.configure { |c| c.expose_dsl_globally = false }
describe "specs here" do
  it "passes" do
  end
end
```

_When_ I run `rspec`

_Then_ the output should contain %R{undefined method (`|')describe'}.

## Regardless of setting

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.configure { |c| c.expose_dsl_globally = true }
RSpec.describe "specs here" do
  it "passes" do
  end
end
```

_When_ I run `rspec`

_Then_ the output should contain "1 example, 0 failures".
