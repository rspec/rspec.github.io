# Conditional Filters

The `:if` and `:unless` metadata keys can be used to filter examples without
  needing to configure an exclusion filter.

## Implicit `:if` filter

_Given_ a file named "implicit_if_filter_spec.rb" with:

```ruby
RSpec.describe ":if => true group", :if => true do
  it(":if => true group :if => true example", :if => true) { }
  it(":if => true group :if => false example", :if => false) { }
  it(":if => true group no :if example") { }
end

RSpec.describe ":if => false group", :if => false do
  it(":if => false group :if => true example", :if => true) { }
  it(":if => false group :if => false example", :if => false) { }
  it(":if => false group no :if example") { }
end

RSpec.describe "no :if group" do
  it("no :if group :if => true example", :if => true) { }
  it("no :if group :if => false example", :if => false) { }
  it("no :if group no :if example") { }
end
```

_When_ I run `rspec implicit_if_filter_spec.rb --format doc`

_Then_ the output should contain all of these:

|                                        |
|----------------------------------------|
| :if => true group :if => true example  |
| :if => true group no :if example       |
| :if => false group :if => true example |
| no :if group :if => true example       |
| no :if group no :if example            |

_And_ the output should not contain any of these:

|                                         |
|-----------------------------------------|
| :if => true group :if => false example  |
| :if => false group :if => false example |
| :if => false group no :if example       |
| no :if group :if => false example       |

## Implicit `:unless` filter

_Given_ a file named "implicit_unless_filter_spec.rb" with:

```ruby
RSpec.describe ":unless => true group", :unless => true do
  it(":unless => true group :unless => true example", :unless => true) { }
  it(":unless => true group :unless => false example", :unless => false) { }
  it(":unless => true group no :unless example") { }
end

RSpec.describe ":unless => false group", :unless => false do
  it(":unless => false group :unless => true example", :unless => true) { }
  it(":unless => false group :unless => false example", :unless => false) { }
  it(":unless => false group no :unless example") { }
end

RSpec.describe "no :unless group" do
  it("no :unless group :unless => true example", :unless => true) { }
  it("no :unless group :unless => false example", :unless => false) { }
  it("no :unless group no :unless example") { }
end
```

_When_ I run `rspec implicit_unless_filter_spec.rb --format doc`

_Then_ the output should contain all of these:

|                                                 |
|-------------------------------------------------|
| :unless => true group :unless => false example  |
| :unless => false group :unless => false example |
| :unless => false group no :unless example       |
| no :unless group :unless => false example       |
| no :unless group no :unless example             |

_And_ the output should not contain any of these:

|                                                |
|------------------------------------------------|
| :unless => true group :unless => true example  |
| :unless => true group no :unless example       |
| :unless => false group :unless => true example |
| no :unless group :unless => true example       |

## Combining implicit filter with explicit inclusion filter

_Given_ a file named "explicit_inclusion_filter_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.filter_run :focus => true
end

RSpec.describe "group with :focus", :focus => true do
  it("focused example") { }
  it("focused :if => true example", :if => true) { }
  it("focused :if => false example", :if => false) { }
  it("focused :unless => true example", :unless => true) { }
  it("focused :unless => false example", :unless => false) { }
end

RSpec.describe "group without :focus" do
  it("unfocused example") { }
  it("unfocused :if => true example", :if => true) { }
  it("unfocused :if => false example", :if => false) { }
  it("unfocused :unless => true example", :unless => true) { }
  it("unfocused :unless => false example", :unless => false) { }
end
```

_When_ I run `rspec explicit_inclusion_filter_spec.rb --format doc`

_Then_ the output should contain all of these:

|                                  |
|----------------------------------|
| focused example                  |
| focused :if => true example      |
| focused :unless => false example |

_And_ the output should not contain any of these:

|                                 |
|---------------------------------|
| focused :if => false example    |
| focused :unless => true example |
| unfocused                       |

## Combining implicit filter with explicit exclusion filter

_Given_ a file named "explicit_exclusion_filter_spec.rb" with:

```ruby
RSpec.configure do |c|
  c.filter_run_excluding :broken => true
end

RSpec.describe "unbroken group" do
  it("included example") { }
  it("included :if => true example", :if => true) { }
  it("included :if => false example", :if => false) { }
  it("included :unless => true example", :unless => true) { }
  it("included :unless => false example", :unless => false) { }
end

RSpec.describe "broken group", :broken => true do
  it("excluded example") { }
  it("excluded :if => true example", :if => true) { }
  it("excluded :if => false example", :if => false) { }
  it("excluded :unless => true example", :unless => true) { }
  it("excluded :unless => false example", :unless => false) { }
end
```

_When_ I run `rspec explicit_exclusion_filter_spec.rb --format doc`

_Then_ the output should contain all of these:

|                                   |
|-----------------------------------|
| included example                  |
| included :if => true example      |
| included :unless => false example |

_And_ the output should not contain any of these:

|                                  |
|----------------------------------|
| included :if => false example    |
| included :unless => true example |
| excluded                         |

## The :if and :unless exclusions stay in effect when there are explicit inclusions

_Given_ a file named "if_and_unless_spec.rb" with:

```ruby
RSpec.describe "Using inclusions" do
  context "inclusion target" do
    it "is filtered out by :if", :if => false do
    end

    it 'is filtered out by :unless', :unless => true do
    end

    it 'is still run according to :if', :if => true do
    end

    it 'is still run according to :unless', :unless => false do
    end
  end
end
```

_When_ I run `rspec if_and_unless_spec.rb --format doc -e 'inclusion target'`

_Then_ the output should contain all of these:

|                                   |
|-----------------------------------|
| is still run according to :if     |
| is still run according to :unless |

_And_ the output should not contain any of these:

|                            |
|----------------------------|
| is filtered out by :if     |
| is filtered out by :unless |
