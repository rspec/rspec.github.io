# `--require` option

Use the `--require` (or `-r`) option to specify a file to require before
  running specs.

## Using the `--require` option

_Given_ a file named "logging_formatter.rb" with:

```ruby
require "rspec/core/formatters/base_text_formatter"
require 'delegate'

class LoggingFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def initialize(output)
    super LoggingIO.new(output)
  end

  class LoggingIO < SimpleDelegator
    def initialize(output)
      @file = File.new('rspec.log', 'w')
      super
    end

    def puts(*args)
      [@file, __getobj__].each { |out| out.puts(*args) }
    end

    def close
      @file.close
    end
  end
end
```

_And_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "an embarrassing situation" do
  it "happens to everyone" do
  end
end
```

_When_ I run `rspec --require ./logging_formatter.rb --format LoggingFormatter`

_Then_ the output should contain "1 example, 0 failures"

_And_ the file "rspec.log" should contain "1 example, 0 failures"

_And_ the exit status should be 0.
