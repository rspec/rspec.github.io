# Transactional examples

By default rspec executes each individual example in a transaction.

  You can also explicitly enable/disable transactions the configuration
  property 'use_transactional_examples'.

## Run in transactions (default)

_Given_ a file named "spec/models/widget_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe Widget, type: :model do
  it "has none to begin with" do
    expect(Widget.count).to eq 0
  end

  it "has one after adding one" do
    Widget.create
    expect(Widget.count).to eq 1
  end

  it "has none after one was created in a previous example" do
    expect(Widget.count).to eq 0
  end
end
```

_When_ I run `rspec spec/models/widget_spec.rb`

_Then_ the examples should all pass.

## Run in transactions (explicit)

_Given_ a file named "spec/models/widget_spec.rb" with:

```ruby
require "rails_helper"

RSpec.configure do |c|
  c.use_transactional_examples = true
end

RSpec.describe Widget, type: :model do
  it "has none to begin with" do
    expect(Widget.count).to eq 0
  end

  it "has one after adding one" do
    Widget.create
    expect(Widget.count).to eq 1
  end

  it "has none after one was created in a previous example" do
    expect(Widget.count).to eq 0
  end
end
```

_When_ I run `rspec spec/models/widget_spec.rb`

_Then_ the examples should all pass.

## Disable transactions (explicit)

_Given_ a file named "spec/models/widget_spec.rb" with:

```ruby
require "rails_helper"

RSpec.configure do |c|
  c.use_transactional_examples = false
  c.order = "defined"
end

RSpec.describe Widget, type: :model do
  it "has none to begin with" do
    expect(Widget.count).to eq 0
  end

  it "has one after adding one" do
    Widget.create
    expect(Widget.count).to eq 1
  end

  it "has one after one was created in a previous example" do
    expect(Widget.count).to eq 1
  end

  after(:all) { Widget.destroy_all }
end
```

_When_ I run `rspec spec/models/widget_spec.rb`

_Then_ the examples should all pass.

## Run in transactions with fixture

_Given_ a file named "spec/models/thing_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe Thing, type: :model do
  fixtures :things
  it "fixture method defined" do
    things(:one)
  end
end
```

_Given_ a file named "spec/fixtures/things.yml" with:

```
one:
  name: MyString
```

_When_ I run `rspec spec/models/thing_spec.rb`

_Then_ the examples should all pass.
