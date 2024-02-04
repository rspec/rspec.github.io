# Setting an error exit code

Use the `error_exit_code` option to set a custom exit code when RSpec fails outside an example.

  ```ruby
  RSpec.configure { |c| c.error_exit_code = 42 }
  ```

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.error_exit_code = 42 }
```

## A erroring spec with the default exit code

_Given_ a file named "spec/typo_spec.rb" with:

```ruby
RSpec.escribe "something" do # intentional typo
  it "works" do
    true
  end
end
```

_When_ I run `rspec spec/typo_spec.rb`

_Then_ the exit status should be 1.

## A erroring spec with a custom exit code

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

_And_ the exit status should be 42.

## Success running specs spec with a custom error exit code defined

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
