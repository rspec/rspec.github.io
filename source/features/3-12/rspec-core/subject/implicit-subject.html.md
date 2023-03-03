# Implicitly defined subject

If the first argument to an example group is a class, an instance of that
  class is exposed to each example in that example group via the `subject`
  method.

  While the examples below demonstrate how `subject` can be used as a
  user-facing concept, we recommend that you reserve it for support of custom
  matchers and/or extension libraries that hide its use from examples.

## `subject` exposed in top level group

_Given_ a file named "top_level_subject_spec.rb" with:

```ruby
RSpec.describe Array do
  it "should be empty when first created" do
    expect(subject).to be_empty
  end
end
```

_When_ I run `rspec ./top_level_subject_spec.rb`

_Then_ the examples should all pass.

## `subject` in a nested group

_Given_ a file named "nested_subject_spec.rb" with:

```ruby
RSpec.describe Array do
  describe "when first created" do
    it "should be empty" do
      expect(subject).to be_empty
    end
  end
end
```

_When_ I run `rspec nested_subject_spec.rb`

_Then_ the examples should all pass.

## `subject` in a nested group with a different class (innermost wins)

_Given_ a file named "nested_subject_spec.rb" with:

```ruby
class ArrayWithOneElement < Array
  def initialize(*)
    super
    unshift "first element"
  end
end

RSpec.describe Array do
  describe ArrayWithOneElement do
    context "referenced as subject" do
      it "contains one element" do
        expect(subject).to include("first element")
      end
    end
  end
end
```

_When_ I run `rspec nested_subject_spec.rb`

_Then_ the examples should all pass.
