# Using the current example

You can reference the example object, and access its metadata, using the block
  argument provided to: `it`, `subject`, `let`, and the `before`, `after`, and
  `around` hooks.

## Access the `example` object from within an example

_Given_ a file named "spec/example_spec.rb" with:

```ruby
RSpec.describe "example as block arg to it, before, and after" do
  before do |example|
    expect(example.description).to eq("is the example object")
  end

  after do |example|
    expect(example.description).to eq("is the example object")
  end

  it "is the example object" do |example|
    expect(example.description).to eq("is the example object")
  end
end

RSpec.describe "example as block arg to let" do
  let(:the_description) do |example|
    example.description
  end

  it "is the example object" do |example|
    expect(the_description).to eq("is the example object")
  end
end

RSpec.describe "example as block arg to subject" do
  subject do |example|
    example.description
  end

  it "is the example object" do |example|
    expect(subject).to eq("is the example object")
  end
end

RSpec.describe "example as block arg to subject with a name" do
  subject(:the_subject) do |example|
    example.description
  end

  it "is the example object" do |example|
    expect(the_subject).to eq("is the example object")
    expect(subject).to eq("is the example object")
  end
end
```

_When_ I run `rspec spec/example_spec.rb`

_Then_ the example should pass.
