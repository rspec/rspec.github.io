# `--fail-fast` option

Use the `--fail-fast` option to tell RSpec to stop running the test suite on
  the first failed test.

  You may add a parameter to tell RSpec to stop running the test suite after N
  failed tests, for example: `--fail-fast=3`.

  You can also specify `--no-fail-fast` to turn it off (default behaviour).

## Background

_Given_ a file named "fail_fast_spec.rb" with:

```ruby
RSpec.describe "fail fast" do
  it "passing test" do; end
  it "1st failing test" do
    fail
  end
  it "2nd failing test" do
    fail
  end
  it "3rd failing test" do
    fail
  end
  it "4th failing test" do
    fail
  end
  it "passing test" do; end
end
```

## Using `--fail-fast`

_When_ I run `rspec . --fail-fast`

_Then_ the output should contain ".F"

_Then_ the output should not contain ".F.".

## Using `--fail-fast=3`

_When_ I run `rspec . --fail-fast=3`

_Then_ the output should contain ".FFF"

_Then_ the output should not contain ".FFFF.".

## Using `--no-fail-fast`

_When_ I run `rspec . --no-fail-fast`

_Then_ the output should contain ".FFFF.".
