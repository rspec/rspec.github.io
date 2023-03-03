# Hide Defined Constant

Use `hide_const` to remove a constant for the duration of a test.

## Hide top-level constant

_Given_ a file named "hide_const_spec.rb" with:

```ruby
FOO = 7

RSpec.describe "hiding FOO" do
  it "can hide FOO" do
    hide_const("FOO")
    expect { FOO }.to raise_error(NameError)
  end

  it "restores the hidden constant when the example completes" do
    expect(FOO).to eq(7)
  end
end
```

_When_ I run `rspec hide_const_spec.rb`

_Then_ the examples should all pass.

## Hide nested constant

_Given_ a file named "hide_const_spec.rb" with:

```ruby
module MyGem
  class SomeClass
    FOO = 7
  end
end

module MyGem
  RSpec.describe SomeClass do
    it "hides the nested constant when it is fully qualified" do
      hide_const("MyGem::SomeClass::FOO")
      expect { SomeClass::FOO }.to raise_error(NameError)
    end

    it "restores the hidden constant when the example completes" do
      expect(MyGem::SomeClass::FOO).to eq(7)
    end
  end
end
```

_When_ I run `rspec hide_const_spec.rb`

_Then_ the examples should all pass.

## Hiding undefined constant

_Given_ a file named "hide_const_spec.rb" with:

```ruby
RSpec.describe "hiding UNDEFINED_CONSTANT" do
  it "has no effect" do
    hide_const("UNDEFINED_CONSTANT")
    expect { UNDEFINED_CONSTANT }.to raise_error(NameError)
  end

  it "is still undefined after the example completes" do
    expect { UNDEFINED_CONSTANT }.to raise_error(NameError)
  end
end
```

_When_ I run `rspec hide_const_spec.rb`

_Then_ the examples should all pass.
