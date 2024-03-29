# Allowing messages

[Test doubles](./test-doubles) are "strict" by default -- messages that have not been specifically
  allowed or expected will trigger an error. Use `allow(...).to receive(...)` to configure
  which messages the double is allowed to receive. You can also use `allow(...).to
  receive_messages(...)` to configure allowed messages (and return values) in bulk.

## Allowed messages return nil by default

_Given_ a file named "allow_message_spec.rb" with:

```ruby
RSpec.describe "allow" do
  it "returns nil from allowed messages" do
    dbl = double("Some Collaborator")
    allow(dbl).to receive(:foo)
    expect(dbl.foo).to be_nil
  end
end
```

_When_ I run `rspec allow_message_spec.rb`

_Then_ the examples should all pass.

## Messages can be allowed in bulk using `receive_messages`

_Given_ a file named "receive_messages_spec.rb" with:

```ruby
RSpec.describe "receive_messages" do
  it "configures return values for the provided messages" do
    dbl = double("Some Collaborator")
    allow(dbl).to receive_messages(:foo => 2, :bar => 3)
    expect(dbl.foo).to eq(2)
    expect(dbl.bar).to eq(3)
  end
end
```

_When_ I run `rspec receive_messages_spec.rb`

_Then_ the examples should all pass.
