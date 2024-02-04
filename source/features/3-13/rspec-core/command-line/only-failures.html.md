# Using the `--only-failures` option

The `--only-failures` option filters what examples are run so that only those that failed the last time they ran are executed. To use this option, you first have to configure `config.example_status_persistence_file_path`, which RSpec will use to store the status of each example the last time it ran.

  There's also a `--next-failure` option, which is shorthand for `--only-failures --fail-fast --order defined`. It allows you to repeatedly focus on just one of the currently failing examples, then move on to the next failure, etc.

  Either of these options can be combined with another a directory or file name; RSpec will run just the failures from the set of loaded examples.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |c|
  c.example_status_persistence_file_path = "examples.txt"
end
```

_And_ a file named ".rspec" with:

```
--require spec_helper
--order random
--format documentation
```

_And_ a file named "spec/array_spec.rb" with:

```ruby
RSpec.describe 'Array' do
  it "checks for inclusion of 1" do
    expect([1, 2]).to include(1)
  end

  it "checks for inclusion of 2" do
    expect([1, 2]).to include(2)
  end

  it "checks for inclusion of 3" do
    expect([1, 2]).to include(3) # failure
  end
end
```

_And_ a file named "spec/string_spec.rb" with:

```ruby
RSpec.describe 'String' do
  it "checks for inclusion of 'foo'" do
    expect("food").to include('foo')
  end

  it "checks for inclusion of 'bar'" do
    expect("food").to include('bar') # failure
  end

  it "checks for inclusion of 'baz'" do
    expect("bazzy").to include('baz')
  end

  it "checks for inclusion of 'foobar'" do
    expect("food").to include('foobar') # failure
  end
end
```

_And_ a file named "spec/passing_spec.rb" with:

```ruby
puts "Loading passing_spec.rb"

RSpec.describe "A passing spec" do
  it "passes" do
    expect(1).to eq(1)
  end
end
```

_And_ I have run `rspec` once, resulting in "8 examples, 3 failures".

## Running `rspec --only-failures` loads only spec files with failures and runs only the failures

_When_ I run `rspec --only-failures`

_Then_ the output from "rspec --only-failures" should contain "3 examples, 3 failures"

_And_ the output from "rspec --only-failures" should not contain "Loading passing_spec.rb".

## Combine `--only-failures` with a file name

_When_ I run `rspec spec/array_spec.rb --only-failures`

_Then_ the output should contain "1 example, 1 failure"

_When_ I run `rspec spec/string_spec.rb --only-failures`

_Then_ the output should contain "2 examples, 2 failures".

## Use `--next-failure` to repeatedly run a single failure

_When_ I run `rspec --next-failure`

_Then_ the output should contain "1 example, 1 failure"

_And_ the output should contain "checks for inclusion of 3"

_When_ I fix "spec/array_spec.rb" by replacing "to include(3)" with "not_to include(3)"

_And_ I run `rspec --next-failure`

_Then_ the output should contain "2 examples, 1 failure"

_And_ the output should contain "checks for inclusion of 3"

_And_ the output should contain "checks for inclusion of 'bar'"

_When_ I fix "spec/string_spec.rb" by replacing "to include('bar')" with "not_to include('bar')"

_And_ I run `rspec --next-failure`

_Then_ the output should contain "2 examples, 1 failure"

_And_ the output should contain "checks for inclusion of 'bar'"

_And_ the output should contain "checks for inclusion of 'foobar'"

_When_ I fix "spec/string_spec.rb" by replacing "to include('foobar')" with "not_to include('foobar')"

_And_ I run `rspec --next-failure`

_Then_ the output should contain "1 example, 0 failures"

_And_ the output should contain "checks for inclusion of 'foobar'"

_When_ I run `rspec --next-failure`

_Then_ the output should contain "All examples were filtered out".

## Running `rspec --only-failures` with spec files that pass doesn't run anything

_When_ I run `rspec spec/passing_spec.rb --only-failures`

_Then_ it should pass with "0 examples, 0 failures".

## Clear error given when using `--only-failures` without configuring `example_status_persistence_file_path`

_Given_ I have not configured `example_status_persistence_file_path`

_When_ I run `rspec --only-failures`

_Then_ it should fail with "To use `--only-failures`, you must first set `config.example_status_persistence_file_path`.".
