# `--warnings` option (run with warnings enabled)

Use the `--warnings` option to run specs with warnings enabled.

## 

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe do
  it 'generates warning' do
    $undefined
  end
end
```

_When_ I run `rspec --warnings example_spec.rb`

_Then_ the output should contain "warning".

## 

_Given_ a file named "example_spec.rb" with:

```ruby
def foo(**kwargs)
  kwargs
end

RSpec.describe do
 it "should warn about keyword arguments with 'rspec -w'" do
   expect(foo({a: 1})).to eq({a: 1})
  end
end
```

_When_ I run `rspec -w example_spec.rb`

_Then_ the output should contain "warning".

## 

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe do
  it 'generates warning' do
    $undefined
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should not contain "warning".
