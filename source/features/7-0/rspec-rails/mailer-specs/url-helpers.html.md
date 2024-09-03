# URL helpers in mailer examples

Mailer specs are marked by `type: :mailer` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/mailers`.

## Using URL helpers with default options

_Given_ a file named "config/initializers/mailer_defaults.rb" with:

```ruby
Rails.configuration.action_mailer.default_url_options = { :host => 'example.com' }
```

_And_ a file named "spec/mailers/notifications_spec.rb" with:

```ruby
require 'rails_helper'

RSpec.describe NotificationsMailer, type: :mailer do
  it 'should have access to URL helpers' do
    expect { gadgets_url }.not_to raise_error
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.

## Using URL helpers without default options

_Given_ a file named "config/initializers/mailer_defaults.rb" with:

```ruby
# no default options
```

_And_ a file named "spec/mailers/notifications_spec.rb" with:

```ruby
require 'rails_helper'

RSpec.describe NotificationsMailer, type: :mailer do
  it 'should have access to URL helpers' do
    expect { gadgets_url :host => 'example.com' }.not_to raise_error
    expect { gadgets_url }.to raise_error
  end
end
```

_When_ I run `rspec spec`

_Then_ the examples should all pass.
