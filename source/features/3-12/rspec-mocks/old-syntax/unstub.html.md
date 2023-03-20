# Using `unstub`

`unstub` removes a method stub, essentially cleaning up the method
  stub early, rather than waiting for the cleanup that runs at the end
  of the example. The newer non-monkey-patching syntax does not have a direct
  equivalent but in most situations you can achieve the same behavior using
  [`and_call_original`](../configuring-responses/calling-the-original-implementation). The difference is that `obj.unstub(:foo)` completely cleans up the `foo`
  method stub, whereas `allow(obj).to receive(:foo).and_call_original` continues to
  observe calls to the method (important when you are using [spies](../basics/spies)), which could affect the
  method's behavior if it does anything with `caller` as it will include additional rspec stack
  frames.

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :should
  end
end
```

_And_ a file named ".rspec" with:

```
--require spec_helper
```

## Unstub a method

_Given_ a file named "spec/unstub_spec.rb" with:

```ruby
RSpec.describe "Unstubbing a method" do
  it "restores the original behavior" do
    string = "hello world"
    string.stub(:reverse) { "hello dlrow" }

    expect {
      string.unstub(:reverse)
    }.to change { string.reverse }.from("hello dlrow").to("dlrow olleh")
  end
end
```

_When_ I run `rspec spec/unstub_spec.rb`

_Then_ the examples should all pass.
