# Mocking with `rspec`

RSpec uses its own mocking framework by default. You can also configure it
  explicitly if you wish.

## Passing message expectation

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "mocking with RSpec" do
  it "passes when it should" do
    receiver = double('receiver')
    expect(receiver).to receive(:message)
    receiver.message
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Failing message expectation

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "mocking with RSpec" do
  it "fails when it should" do
    receiver = double('receiver')
    expect(receiver).to receive(:message)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain "1 example, 1 failure".

## Failing message expectation in pending example (remains pending)

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "failed message expectation in a pending example" do
  it "is listed as pending" do
    pending
    receiver = double('receiver')
    expect(receiver).to receive(:message)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain "1 example, 0 failures, 1 pending"

_And_ the exit status should be 0.

## Passing message expectation in pending example (fails)

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "passing message expectation in a pending example" do
  it "fails with FIXED" do
    pending
    receiver = double('receiver')
    expect(receiver).to receive(:message)
    receiver.message
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain "FIXED"

_Then_ the output should contain "1 example, 1 failure"

_And_ the exit status should be 1.

## Accessing `RSpec.configuration.mock_framework.framework_name`

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "RSpec.configuration.mock_framework.framework_name" do
  it "returns :rspec" do
    expect(RSpec.configuration.mock_framework.framework_name).to eq(:rspec)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.

## Doubles may be used in generated descriptions

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec
end

RSpec.describe "Testing" do
  # Examples with no descriptions will default to RSpec-generated descriptions
  it do
    foo = double("Test")
    expect(foo).to be foo
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the examples should all pass.
