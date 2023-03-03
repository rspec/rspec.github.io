# `--example` option

Use the `--example` (or `-e`) option to filter examples by name.

  The argument is matched against the full description of the example, which is
  the concatenation of descriptions of the group (including any nested groups)
  and the example.

  This allows you to run a single uniquely named example, all examples with
  similar names, all the examples in a uniquely named group, etc, etc.

  You can also use the option more than once to specify multiple example
  matches.

  Note: description-less examples that have generated descriptions (typical when using the [one-liner syntax](../subject/one-liner-syntax)) cannot be directly filtered with this option, because it is necessary to execute the example to generate the description, so RSpec is unable to use the not-yet-generated description to decide whether or not to execute an example. You can, of course, pass part of a group's description to select all examples defined in the group (including those that have no description).

## Background

_Given_ a file named "first_spec.rb" with:

```ruby
RSpec.describe "first group" do
  it "first example in first group" do; end
  it "second example in first group" do; end
end
```

_And_ a file named "second_spec.rb" with:

```ruby
RSpec.describe "second group" do
  it "first example in second group" do; end
  it "second example in second group" do; end
end
```

_And_ a file named "third_spec.rb" with:

```ruby
RSpec.describe "third group" do
  it "first example in third group" do; end
  context "nested group" do
    it "first example in nested group" do; end
    it "second example in nested group" do; end
  end
end
```

_And_ a file named "fourth_spec.rb" with:

```ruby
RSpec.describe Array do
  describe "#length" do
    it "is the number of items" do
      expect(Array.new([1,2,3]).length).to eq 3
    end
  end
end
```

## No matches

_When_ I run `rspec . --example nothing_like_this`

_Then_ the process should succeed even though no examples were run.

## Match on one word

_When_ I run `rspec . --example example`

_Then_ the examples should all pass.

## One match in each context

_When_ I run `rspec . --example 'first example'`

_Then_ the examples should all pass.

## One match in one file using just the example name

_When_ I run `rspec . --example 'first example in first group'`

_Then_ the examples should all pass.

## One match in one file using the example name and the group name

_When_ I run `rspec . --example 'first group first example in first group'`

_Then_ the examples should all pass.

## All examples in one group

_When_ I run `rspec . --example 'first group'`

_Then_ the examples should all pass.

## One match in one file with group name

_When_ I run `rspec . --example 'second group first example'`

_Then_ the examples should all pass.

## All examples in one group including examples in nested groups

_When_ I run `rspec . --example 'third group'`

_Then_ the examples should all pass.

## Match using `ClassName#method_name` form

_When_ I run `rspec . --example 'Array#length'`

_Then_ the examples should all pass.

## Multiple applications of example name option

_When_ I run `rspec . --example 'first group' --example 'second group' --format d`

_Then_ the examples should all pass

_And_ the output should contain all of these:

|                                |
|--------------------------------|
| first example in first group   |
| second example in first group  |
| first example in second group  |
| second example in second group |

_And_ the output should not contain any of these:

|                                             |
|---------------------------------------------|
| first example in third group                |
| nested group first example in nested group  |
| nested group second example in nested group |
