# Custom settings

Extensions like rspec-rails can add their own configuration settings.

## Simple setting (with defaults)

_Given_ a file named "additional_setting_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.add_setting :custom_setting
end

RSpec.describe "custom setting" do
  it "is nil by default" do
    expect(RSpec.configuration.custom_setting).to be_nil
  end

  it "is exposed as a predicate" do
    expect(RSpec.configuration.custom_setting?).to be(false)
  end

  it "can be overridden" do
    RSpec.configuration.custom_setting = true
    expect(RSpec.configuration.custom_setting).to be(true)
    expect(RSpec.configuration.custom_setting?).to be(true)
  end
end
```

_When_ I run `rspec ./additional_setting_spec.rb`

_Then_ the examples should all pass.

## Default to `true`

_Given_ a file named "additional_setting_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.add_setting :custom_setting, :default => true
end

RSpec.describe "custom setting" do
  it "is true by default" do
    expect(RSpec.configuration.custom_setting).to be(true)
  end

  it "is exposed as a predicate" do
    expect(RSpec.configuration.custom_setting?).to be(true)
  end

  it "can be overridden" do
    RSpec.configuration.custom_setting = false
    expect(RSpec.configuration.custom_setting).to be(false)
    expect(RSpec.configuration.custom_setting?).to be(false)
  end
end
```

_When_ I run `rspec ./additional_setting_spec.rb`

_Then_ the examples should all pass.

## Overridden in a subsequent `RSpec.configure` block

_Given_ a file named "additional_setting_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.add_setting :custom_setting
end

RSpec.configure do |c|
  c.custom_setting = true
end

RSpec.describe "custom setting" do
  it "returns the value set in the last configure block to get eval'd" do
    expect(RSpec.configuration.custom_setting).to be(true)
  end

  it "is exposed as a predicate" do
    expect(RSpec.configuration.custom_setting?).to be(true)
  end
end
```

_When_ I run `rspec ./additional_setting_spec.rb`

_Then_ the examples should all pass.
