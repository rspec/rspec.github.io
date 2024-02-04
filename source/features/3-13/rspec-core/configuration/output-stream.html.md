# Custom output stream

Define a custom output stream (default `$stdout`).  Aliases: `:output`,
  `:out`.

  ```ruby
  RSpec.configure { |c| c.output_stream = File.open('saved_output', 'w') }
  ```

## Background

_Given_ a file named "spec/spec_helper.rb" with:

```ruby
RSpec.configure { |c| c.output_stream = File.open('saved_output', 'w') }
```

## Redirecting output

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require 'spec_helper'
RSpec.describe "an example" do
  it "passes" do
    true
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the file "saved_output" should contain "1 example, 0 failures".
