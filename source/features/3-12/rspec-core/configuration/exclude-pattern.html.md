# Using the `--exclude_pattern` option

Use the `--exclude-pattern` option to tell RSpec to skip looking for specs in files
  that match the pattern specified.

## Background

_Given_ a file named "spec/models/model_spec.rb" with:

```ruby
RSpec.describe "two specs here" do
  it "passes" do
  end

  it "passes too" do
  end
end
```

_And_ a file named "spec/features/feature_spec.rb" with:

```ruby
RSpec.describe "only one spec" do
  it "passes" do
  end
end
```

## By default, RSpec runs files that match `"**/*_spec.rb"`

_When_ I run `rspec`

_Then_ the output should contain "3 examples, 0 failures".

## The `--exclude-pattern` flag makes RSpec skip matching files

_When_ I run `rspec --exclude-pattern "**/models/*_spec.rb"`

_Then_ the output should contain "1 example, 0 failures".

## The `--exclude-pattern` flag can be used to pass in multiple patterns, separated by comma

_When_ I run `rspec --exclude-pattern "**/models/*_spec.rb, **/features/*_spec.rb"`

_Then_ the output should contain "0 examples, 0 failures".

## The `--exclude-pattern` flag accepts shell style glob unions

_When_ I run `rspec --exclude-pattern "**/{models,features}/*_spec.rb"`

_Then_ the output should contain "0 examples, 0 failures".

## The `--exclude-pattern` flag can be used with the `--pattern` flag

_When_ I run `rspec --pattern "spec/**/*_spec.rb" --exclude-pattern "spec/models/*_spec.rb"`

_Then_ the output should contain "1 example, 0 failures".
