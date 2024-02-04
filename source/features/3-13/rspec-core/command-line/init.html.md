# `--init` option

Use the `--init` option on the command line to generate conventional files for
  an RSpec project. It generates a `.rspec` and `spec/spec_helper.rb` with some
  example settings to get you started.

  These settings treat the case where you run an individual spec file
  differently, using the documentation formatter if no formatter has been
  explicitly set.

## Generate `.rspec`

_When_ I run `rspec --init`

_Then_ the following files should exist:

|        |
|--------|
| .rspec |

_And_ the output should contain "create   .rspec".

## `.rspec` file already exists

_Given_ a file named ".rspec" with:

```
--force-color
```

_When_ I run `rspec --init`

_Then_ the output should contain "exist   .rspec".

## Accept and use the recommended settings in `spec_helper` (which are initially commented out)

_Given_ I have a brand new project with no files

_And_ I have run `rspec --init`

_When_ I accept the recommended settings by removing `=begin` and `=end` from `spec_helper.rb`

_And_ I create "spec/addition_spec.rb" with the following content:

```ruby
RSpec.describe "Addition" do
  it "works" do
    expect(1 + 1).to eq(2)
  end
end
```

_And_ I create "spec/subtraction_spec.rb" with the following content:

```ruby
RSpec.describe "Subtraction" do
  it "works" do
    expect(1 - 1).to eq(0)
  end
end
```

_Then_ the output from `rspec` should not be in documentation format

_But_ the output from `rspec spec/addition_spec.rb` should be in documentation format

_But_ the output from `rspec spec/addition_spec.rb --format progress` should not be in documentation format

_And_ the output from `rspec --pattern 'spec/*ction_spec.rb'` should indicate it ran only the subtraction file

_And_ the output from `rspec --exclude-pattern 'spec/*dition_spec.rb'` should indicate it ran only the subtraction file.
