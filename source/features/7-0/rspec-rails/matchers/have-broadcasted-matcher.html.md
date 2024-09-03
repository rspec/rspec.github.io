# `have_broadcasted_to` matcher

The `have_broadcasted_to` (also aliased as `broadcast_to`) matcher is used
  to check if a message has been broadcasted to a given stream.

## Background

_Given_ action cable testing is available.

## Checking stream name

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with stream name" do
    expect {
      ActionCable.server.broadcast(
        "notifications", { text: "Hello!" }
      )
    }.to have_broadcasted_to("notifications")
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the examples should all pass.

## Checking passed message to stream

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with message" do
    expect {
      ActionCable.server.broadcast(
        "notifications", { text: "Hello!" }
      )
    }.to have_broadcasted_to("notifications").with(text: 'Hello!')
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the examples should all pass.

## Checking that message passed to stream matches

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with message" do
    expect {
      ActionCable.server.broadcast(
        "notifications", { text: 'Hello!', user_id: 12 }
      )
    }.to have_broadcasted_to("notifications").with(a_hash_including(text: 'Hello!'))
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the examples should all pass.

## Checking passed message with block

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with message" do
    expect {
      ActionCable.server.broadcast(
        "notifications", { text: 'Hello!', user_id: 12 }
      )
    }.to have_broadcasted_to("notifications").with { |data|
      expect(data['user_id']).to eq 12
    }
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the examples should all pass.

## Using alias method

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with stream name" do
    expect {
      ActionCable.server.broadcast(
        "notifications", { text: 'Hello!' }
      )
    }.to broadcast_to("notifications")
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the examples should all pass.

## Checking broadcast to a record

_Given_ a file named "spec/channels/chat_channel_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe ChatChannel, type: :channel do
  it "matches with stream name" do
    user = User.new(42)

    expect {
      ChatChannel.broadcast_to(user, text: 'Hi')
    }.to have_broadcasted_to(user)
  end
end
```

_And_ a file named "app/models/user.rb" with:

```ruby
class User < Struct.new(:name)
  def to_gid_param
    name
  end
end
```

_When_ I run `rspec spec/channels/chat_channel_spec.rb`

_Then_ the example should pass.

## Checking broadcast to a record in non-channel spec

_Given_ a file named "spec/models/broadcaster_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "broadcasting" do
  it "matches with stream name" do
    user = User.new(42)

    expect {
      ChatChannel.broadcast_to(user, text: 'Hi')
    }.to broadcast_to(ChatChannel.broadcasting_for(user))
  end
end
```

_And_ a file named "app/models/user.rb" with:

```ruby
class User < Struct.new(:name)
  def to_gid_param
    name
  end
end
```

_When_ I run `rspec spec/models/broadcaster_spec.rb`

_Then_ the example should pass.
