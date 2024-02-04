# Using `described_class`

If the first argument to an example group is a class, the class is exposed to
  each example in that example group via the `described_class()` method.

## Access the described class from the example

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe Symbol do
  it "is available as described_class" do
    expect(described_class).to eq(Symbol)
  end

  describe 'inner' do
    describe String do
      it "is available as described_class" do
        expect(described_class).to eq(String)
      end
    end
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the example should pass.
