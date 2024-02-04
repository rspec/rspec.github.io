# The basic structure (`describe`/`it`)

RSpec is a DSL for creating executable examples of how code is expected to
  behave, organized in groups. It uses the words "describe" and "it" so we can
  express concepts like a conversation:

      "Describe an account when it is first opened."
      "It has a balance of zero."

  The `describe` method creates an example group.  Within the block passed to
  `describe` you can declare nested groups using the `describe` or `context`
  methods, or you can declare examples using the `it` or `specify` methods.

  Under the hood, an example group is a class in which the block passed to
  `describe` or `context` is evaluated. The blocks passed to `it` are evaluated
  in the context of an _instance_ of that class.

## One group, one example

_Given_ a file named "sample_spec.rb" with:

```ruby
RSpec.describe "something" do
  it "does something" do
  end
end
```

_When_ I run `rspec sample_spec.rb -fdoc`

_Then_ the output should contain:

```
something
  does something
```

## Nested example groups (using `context`)

_Given_ a file named "nested_example_groups_spec.rb" with:

```ruby
RSpec.describe "something" do
  context "in one context" do
    it "does one thing" do
    end
  end

  context "in another context" do
    it "does another thing" do
    end
  end
end
```

_When_ I run `rspec nested_example_groups_spec.rb -fdoc`

_Then_ the output should contain:

```
something
  in one context
    does one thing
  in another context
    does another thing
```
