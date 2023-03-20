# Use `rspec-core` without `rspec-mocks` or `rspec-expectations`

It is most common to use rspec-core with rspec-mocks and rspec-expectations,
  and rspec-core will take care of loading those libraries automatically if
  available, but rspec-core can be used just fine without either of those
  gems installed.

## Use only rspec-core when only it is installed

_Given_ only rspec-core is installed

_And_ a file named "core_only_spec.rb" with:

```ruby
RSpec.describe "Only rspec-core is available" do
  it "it fails when an rspec-mocks API is used" do
    dbl = double("MyDouble")
  end

  it "it fails when an rspec-expectations API is used" do
    expect(1).to eq(1)
  end
end
```

_When_ I run `rspec core_only_spec.rb`

_Then_ the output should contain "2 examples, 2 failures".
