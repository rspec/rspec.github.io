# Setting a failure exit code

Use the `failure_exit_code` option to set a custom exit code when RSpec fails.

  ```ruby
  RSpec.configure { |c| c.failure_exit_code = 42 }
  ```

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.failure_exit_code = 42 }
```

## A failing spec with the default exit code

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "something" do
  it "fails" do
    fail
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the exit status should be 1.

## A failing spec with a custom exit code

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require 'spec_helper'
RSpec.describe "something" do
  it "fails" do
    fail
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the exit status should be 42.

## An error running specs spec with a custom exit code

_Given_ a file named "spec/typo_spec.rb" with:

```ruby
require 'spec_helper'
RSpec.escribe "something" do # intentional typo
  it "works" do
    true
  end
end
```

_When_ I run `rspec spec/typo_spec.rb`

_Then_ the exit status should be 42.

## Success running specs spec with a custom exit code defined

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require 'spec_helper'
RSpec.describe "something" do
  it "works" do
    true
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the exit status should be 0.

## Exit with the default exit code when an `at_exit` hook is added upstream

_Given_ a file named "exit_at_spec.rb" with:

```ruby
require 'rspec/autorun'
at_exit { exit(0) }

RSpec.describe "exit 0 at_exit ignored" do
  it "does not interfere with the default exit code" do
    fail
  end
end
```

_When_ I run `ruby exit_at_spec.rb`

_Then_ the exit status should be 1.
