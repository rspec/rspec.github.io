# Run with `ruby` command

You can use the `ruby` command to run specs. You just need to require
  `rspec/autorun`.

  Generally speaking, you're better off using the `rspec` command, which avoids
  the complexity of `rspec/autorun` (e.g. no `at_exit` hook needed!), but some
  tools only work with the `ruby` command.

## Require `rspec/autorun` from a spec file

_Given_ a file named "example_spec.rb" with:

```ruby
require 'rspec/autorun'

RSpec.describe 1 do
  it "is < 2" do
    expect(1).to be < 2
  end

  it "has an intentional failure" do
    expect(1).to be > 2
  end
end
```

_When_ I run `ruby example_spec.rb`

_Then_ the output should contain "2 examples, 1 failure"

_And_ the output should contain "expect(1).to be > 2".
