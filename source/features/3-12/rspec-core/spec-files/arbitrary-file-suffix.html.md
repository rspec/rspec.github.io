# Using an arbitrary file suffix

## `.spec`

_Given_ a file named "a.spec" with:

```ruby
RSpec.describe "something" do
  it "does something" do
    expect(3).to eq(3)
  end
end
```

_When_ I run `rspec a.spec`

_Then_ the examples should all pass.
