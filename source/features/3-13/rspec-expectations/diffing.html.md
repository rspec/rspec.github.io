# Diffing

When appropriate, failure messages will automatically include a diff.

## Diff for a multiline string

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "a multiline string" do
  it "is like another string" do
    expected = <<-EXPECTED
this is the
  expected
    string
EXPECTED
    actual = <<-ACTUAL
this is the
  actual
    string
ACTUAL
    expect(actual).to eq(expected)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain:

```
       Diff:
       @@ -1,4 +1,4 @@
        this is the
       -  expected
       +  actual
            string
```

## Diff for a multiline string and a regexp on diff-lcs 1.4

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "a multiline string" do
  it "is like another string" do
    expected = /expected/m
    actual = <<-ACTUAL
this is the
  actual
    string
ACTUAL
    expect(actual).to match expected
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain:

```
       Diff:
       @@ -1,3 +1,5 @@
       -/expected/m
       +this is the
       +  actual
       +    string
```

## Diff for a multiline string and a regexp on diff-lcs 1.3

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "a multiline string" do
  it "is like another string" do
    expected = /expected/m
    actual = <<-ACTUAL
this is the
  actual
    string
ACTUAL
    expect(actual).to match expected
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should contain:

```
       Diff:
       @@ -1,2 +1,4 @@
       -/expected/m
       +this is the
       +  actual
       +    string
```

## No diff for a single line strings

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "a single line string" do
  it "is like another string" do
    expected = "this string"
    actual   = "that string"
    expect(actual).to eq(expected)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should not contain "Diff:".

## No diff for numbers

_Given_ a file named "example_spec.rb" with:

```ruby
RSpec.describe "a number" do
  it "is like another number" do
    expect(1).to eq(2)
  end
end
```

_When_ I run `rspec example_spec.rb`

_Then_ the output should not contain "Diff:".
