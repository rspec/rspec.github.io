# Using `rspec-mocks` on its own outside of RSpec (standalone mode)

`require "rspec/mocks/standalone"` to expose the API at the top level (e.g. `main`) outside
  the RSpec environment in a REPL like IRB or in a one-off script.

## Allow a message outside RSpec

_Given_ a file named "example.rb" with:

```ruby
require "rspec/mocks/standalone"

greeter = double("greeter")
allow(greeter).to receive(:say_hi) { "Hello!" }
puts greeter.say_hi
```

_When_ I run `ruby example.rb`

_Then_ the output should contain "Hello!".

## Expect a message outside RSpec

_Given_ a file named "example.rb" with:

```ruby
require "rspec/mocks/standalone"

greeter = double("greeter")
expect(greeter).to receive(:say_hi)

RSpec::Mocks.verify
```

_When_ I run `ruby example.rb`

_Then_ it should fail with the following output:

|                                        |
|----------------------------------------|
| (Double "greeter").say_hi(*(any args)) |
| RSpec::Mocks::MockExpectationError     |
| expected: 1 time with any arguments    |
| received: 0 times with any arguments   |
