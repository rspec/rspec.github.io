# `<file>:<line_number>` (line number appended to file path)

To run one or more examples or groups, you can append the line number to the
  path, e.g.

  ```bash
  $ rspec path/to/example_spec.rb:37
  ```

## Background

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "outer group" do

  it "first example in outer group" do

  end

  it "second example in outer group" do

  end

  describe "nested group" do

    it "example in nested group" do

    end

  end

end
```

_And_ a file named "example2_spec.rb" with:

```ruby
RSpec.describe "yet another group" do
  it "first example in second file" do
  end
  it "second example in second file" do
  end
end
```

_And_ a file named "one_liner_spec.rb" with:

```ruby
RSpec.describe 9 do

  it { is_expected.to be > 8 }

  it { is_expected.to be < 10 }

end
```

## Nested groups - outer group on declaration line

_When_ I run `rspec example_spec.rb:1 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_And_ the output should contain "first example in outer group"

_And_ the output should contain "example in nested group".

## Nested groups - outer group inside block before example

_When_ I run `rspec example_spec.rb:2 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_And_ the output should contain "first example in outer group"

_And_ the output should contain "example in nested group".

## Nested groups - inner group on declaration line

_When_ I run `rspec example_spec.rb:11 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "example in nested group"

_And_ the output should not contain "second example in outer group"

_And_ the output should not contain "first example in outer group".

## Nested groups - inner group inside block before example

_When_ I run `rspec example_spec.rb:12 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "example in nested group"

_And_ the output should not contain "second example in outer group"

_And_ the output should not contain "first example in outer group".

## Two examples - first example on declaration line

_When_ I run `rspec example_spec.rb:3 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "first example in outer group"

_But_ the output should not contain "second example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - first example inside block

_When_ I run `rspec example_spec.rb:4 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "first example in outer group"

_But_ the output should not contain "second example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - first example on end

_When_ I run `rspec example_spec.rb:5 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "first example in outer group"

_But_ the output should not contain "second example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - first example after end but before next example

_When_ I run `rspec example_spec.rb:6 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "first example in outer group"

_But_ the output should not contain "second example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - second example on declaration line

_When_ I run `rspec example_spec.rb:7 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - second example inside block

_When_ I run `rspec example_spec.rb:7 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "example in nested group".

## Two examples - second example on end

_When_ I run `rspec example_spec.rb:7 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "example in nested group".

## Specified multiple times for different files

_When_ I run `rspec example_spec.rb:7 example2_spec.rb:4 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_And_ the output should contain "second example in second file"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "nested group"

_And_ the output should not contain "first example in second file".

## Specified multiple times for the same file with multiple arguments

_When_ I run `rspec example_spec.rb:7 example_spec.rb:11 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_And_ the output should contain "nested group"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "second file".

## Specified multiple times for the same file with a single argument

_When_ I run `rspec example_spec.rb:7:11 --format doc`

_Then_ the examples should all pass

_And_ the output should contain "second example in outer group"

_And_ the output should contain "nested group"

_But_ the output should not contain "first example in outer group"

_And_ the output should not contain "second file".

## Matching one-liners

_When_ I run `rspec one_liner_spec.rb:3 --format doc`

_Then_ the examples should all pass

_Then_ the output should contain "is expected to be > 8"

_But_ the output should not contain "is expected to be < 10".
