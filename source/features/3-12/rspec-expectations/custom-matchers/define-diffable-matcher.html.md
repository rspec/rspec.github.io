# Defining a diffable matcher

When a matcher is defined as diffable, the output will include a diff of the submitted objects when the objects are more than simple primitives.

## Define a diffable matcher (with diff-lcs 1.4)

_Given_ a file named "diffable_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :be_just_like do |expected|
  match do |actual|
    actual == expected
  end

  diffable
end

RSpec.describe "two\nlines" do
  it { is_expected.to be_just_like("three\nlines") }
end
```

_When_ I run `rspec ./diffable_matcher_spec.rb`

_Then_ it should fail with:

```
       Diff:
       @@ -1 +1 @@
       -three
       +two
```

## Define a diffable matcher (with diff-lcs 1.3)

_Given_ a file named "diffable_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :be_just_like do |expected|
  match do |actual|
    actual == expected
  end

  diffable
end

RSpec.describe "two\nlines" do
  it { is_expected.to be_just_like("three\nlines") }
end
```

_When_ I run `rspec ./diffable_matcher_spec.rb`

_Then_ it should fail with:

```
       Diff:
       @@ -1,3 +1,3 @@
       -three
       +two
        lines
```

## Redefine actual (with diff-lcs 1.4.4)

Sometimes is necessary to overwrite actual to make diffing work, e.g. if `actual` is a name of a file you want to read from. For this to work you need to overwrite `@actual` in your matcher.

_Given_ a file named "redefine_actual_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    @actual = File.read(actual).chomp

    values_match? expected, @actual
  end

  diffable
end

RSpec.describe 'Compare files' do
  context 'when content is equal' do
    it { expect('data.txt').to have_content 'Data' }
  end

  context 'when files are different' do
    it { expect('data.txt').to have_content "No\nData\nhere" }
  end
end
```

_And_ a file named "data.txt" with:

```
Data
```

_When_ I run `rspec ./redefine_actual_matcher_spec.rb --format documentation`

_Then_ the exit status should not be 0

_And_ the output should contain:

```
2 examples, 1 failure
```

_And_ the output should contain:

```
       @@ -1,4 +1,2 @@
       -No
        Data
       -here
```

## Redefine actual (with diff-lcs 1.3)

_Given_ a file named "redefine_actual_matcher_spec.rb" with:

```ruby
RSpec::Matchers.define :have_content do |expected|
  match do |actual|
    @actual = File.read(actual).chomp

    values_match? expected, @actual
  end

  diffable
end

RSpec.describe 'Compare files' do
  context 'when content is equal' do
    it { expect('data.txt').to have_content 'Data' }
  end

  context 'when files are different' do
    it { expect('data.txt').to have_content "No\nData\nhere" }
  end
end
```

_And_ a file named "data.txt" with:

```
Data
```

_When_ I run `rspec ./redefine_actual_matcher_spec.rb --format documentation`

_Then_ the exit status should not be 0

_And_ the output should contain:

```
2 examples, 1 failure
```

_And_ the output should contain:

```
       @@ -1,4 +1,2 @@
       -No
        Data
       -here
```
