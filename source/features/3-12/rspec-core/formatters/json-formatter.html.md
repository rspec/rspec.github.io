# The JSON formatter

## Formatting example names for retry

_Given_ a file named "various_spec.rb" with:

```ruby
RSpec.describe "Various" do
  it "fails" do
    expect("fail").to eq("succeed")
  end

  it "succeeds" do
    expect("succeed").to eq("succeed")
  end

  it "pends"
end
```

_When_ I run `rspec various_spec.rb --format j`

_Then_ the output should contain all of these:

|                                                       |
|-------------------------------------------------------|
| "summary_line":"3 examples, 1 failure, 1 pending"     |
| "examples":[                                          |
| "description":"fails"                                 |
| "full_description":"Various fails"                    |
| "status":"failed"                                     |
| "file_path":"./various_spec.rb"                       |
| "line_number":2                                       |
| "exception":{                                         |
| "class":"RSpec::Expectations::ExpectationNotMetError" |

_And_ the exit status should be 1.
