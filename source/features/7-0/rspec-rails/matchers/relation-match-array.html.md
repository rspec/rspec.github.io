# ActiveRecord::Relation match array

The `match_array` matcher can be used with an `ActiveRecord::Relation`
  (scope). The assertion will pass if the scope would return all of the
  elements specified in the array on the right hand side.

## An example spec with relation match_array matcher

_Given_ a file named "spec/models/widget_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe Widget do
  let!(:widgets) { Array.new(3) { Widget.create } }

  subject { Widget.all }

  it "returns all widgets in any order" do
    expect(subject).to match_array(widgets)
  end
end
```

_When_ I run `rspec spec/models/widget_spec.rb`

_Then_ the examples should all pass.
