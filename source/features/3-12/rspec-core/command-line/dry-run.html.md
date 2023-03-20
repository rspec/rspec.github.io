# `--dry-run` option

Use the `--dry-run` option to have RSpec print your suite's formatter output
  without running any examples or hooks.

## Using `--dry-run`

_Given_ a file named "spec/dry_run_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.before(:suite) { puts "before suite" }
  c.after(:suite)  { puts "after suite"  }
end

RSpec.describe "dry run" do
  before(:context) { fail }
  before(:example) { fail }

  it "fails in example" do
    fail
  end

  after(:example) { fail }
  after(:context) { fail }
end
```

_When_ I run `rspec --dry-run`

_Then_ the output should contain "1 example, 0 failures"

_And_ the output should not contain "before suite"

_And_ the output should not contain "after suite".
