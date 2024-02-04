# Defining arbitrary helper methods

You can define methods in any example group using Ruby's `def` keyword or
  `define_method` method. These _helper_ methods are exposed to examples in the
  group in which they are defined and groups nested within that group, but not
  parent or sibling groups.

## Use a method defined in the same group

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "an example" do
  def help
    :available
  end

  it "has access to methods defined in its group" do
    expect(help).to be(:available)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Use a method defined in a parent group

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "an example" do
  def help
    :available
  end

  describe "in a nested group" do
    it "has access to methods defined in its parent group" do
      expect(help).to be(:available)
    end
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.
