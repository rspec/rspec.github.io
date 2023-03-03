# Custom deprecation stream

Define a custom output stream for warning about deprecations (default
  `$stderr`).

  ```ruby
  RSpec.configure do |c|
    c.deprecation_stream = File.open('deprecations.txt', 'w')
  end
  ```

  or

  ```ruby
  RSpec.configure { |c| c.deprecation_stream = 'deprecations.txt' }
  ```

  or pass `--deprecation-out`

## Background

_Given_ a file named "lib/foo.rb" with:

```ruby
class Foo
  def bar
    RSpec.deprecate "Foo#bar"
  end
end
```

## Default - print deprecations to `$stderr`

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "foo"

RSpec.describe "calling a deprecated method" do
  example { Foo.new.bar }
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the output should contain "Deprecation Warnings:\n\nFoo#bar is deprecated".

## Configure using the path to a file

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "foo"

RSpec.configure {|c| c.deprecation_stream = 'deprecations.txt' }

RSpec.describe "calling a deprecated method" do
  example { Foo.new.bar }
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the output should not contain "Deprecation Warnings:"

_But_ the output should contain "1 deprecation logged to deprecations.txt"

_And_ the file "deprecations.txt" should contain "Foo#bar is deprecated".

## Configure using a `File` object

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "foo"

RSpec.configure do |c|
  c.deprecation_stream = File.open('deprecations.txt', 'w')
end

RSpec.describe "calling a deprecated method" do
  example { Foo.new.bar }
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the output should not contain "Deprecation Warnings:"

_But_ the output should contain "1 deprecation logged to deprecations.txt"

_And_ the file "deprecations.txt" should contain "Foo#bar is deprecated".

## Configure using the CLI `--deprecation-out` option

_Given_ a file named "spec/example_spec.rb" with:

```ruby
require "foo"
RSpec.describe "calling a deprecated method" do
  example { Foo.new.bar }
end
```

_When_ I run `rspec spec/example_spec.rb --deprecation-out deprecations.txt`

_Then_ the output should not contain "Deprecation Warnings:"

_But_ the output should contain "1 deprecation logged to deprecations.txt"

_And_ the file "deprecations.txt" should contain "Foo#bar is deprecated".
