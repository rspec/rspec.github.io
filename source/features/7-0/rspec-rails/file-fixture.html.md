# Using `file_fixture`

Rails 5 adds simple access to sample files called file fixtures.
  File fixtures are normal files stored in spec/fixtures/files by default.

  File fixtures are represented as +Pathname+ objects.
  This makes it easy to extract specific information:

  ```ruby
  file_fixture("example.txt").read # get the file's content
  file_fixture("example.mp3").size # get the file size
  ```

  You can customize files location by setting
  ```ruby
  RSpec.configure do |config|
    config.file_fixture_path = "spec/custom_directory"
  end
  ```

## Reading file content from fixtures directory

_And_ a file named "spec/fixtures/files/sample.txt" with:

```
Hello
```

_And_ a file named "spec/lib/file_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "file" do
  it "reads sample file" do
    expect(file_fixture("sample.txt").read).to eq("Hello")
  end
end
```

_When_ I run `rspec spec/lib/file_spec.rb`

_Then_ the examples should all pass.

## Creating a ActiveStorage::Blob from a file fixture

_Given_ a file named "spec/fixtures/files/sample.txt" with:

```
Hello
```

_And_ a file named "spec/lib/fixture_set_blob.rb" with:

```ruby
require "rails_helper"

RSpec.describe "blob" do
  it "creates a blob from a sample file" do
    expect(ActiveStorage::FixtureSet.blob(filename: "sample.txt")).to include("sample.txt")
  end
end
```

_When_ I run `rspec spec/lib/fixture_set_blob.rb`

_Then_ the examples should all pass.
