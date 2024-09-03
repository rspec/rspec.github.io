# `have_enqueued_mail` matcher

The `have_enqueued_mail` (also aliased as `enqueue_mail`) matcher is used to check if given mailer was enqueued.

## Background

_Given_ active job is available.

## Checking mailer class and method name

_Given_ a file named "spec/mailers/user_mailer_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe NotificationsMailer do
  it "matches with enqueued mailer" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      NotificationsMailer.signup.deliver_later
    }.to have_enqueued_mail(NotificationsMailer, :signup)
  end
end
```

_When_ I run `rspec spec/mailers/user_mailer_spec.rb`

_Then_ the examples should all pass.

## Checking mailer enqueued time

_Given_ a file named "spec/mailers/user_mailer_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe NotificationsMailer do
  it "matches with enqueued mailer" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      NotificationsMailer.signup.deliver_later(wait_until: Date.tomorrow.noon)
    }.to have_enqueued_mail.at(Date.tomorrow.noon)
  end
end
```

_When_ I run `rspec spec/mailers/user_mailer_spec.rb`

_Then_ the examples should all pass.

## Checking mailer arguments

_Given_ a file named "app/mailers/my_mailer.rb" with:

```ruby
class MyMailer < ApplicationMailer

  def signup(user = nil)
    @user = user

    mail to: "to@example.org"
  end
end
```

_Given_ a file named "spec/mailers/my_mailer_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe MyMailer do
  it "matches with enqueued mailer" do
    ActiveJob::Base.queue_adapter = :test
    # Works with plain args
    expect {
      MyMailer.signup('user').deliver_later
    }.to have_enqueued_mail(MyMailer, :signup).with('user')
  end
end
```

_When_ I run `rspec spec/mailers/my_mailer_spec.rb`

_Then_ the examples should all pass.

## Parameterize the mailer

_Given_ a file named "app/mailers/my_mailer.rb" with:

```ruby
class MyMailer < ApplicationMailer

  def signup
    @foo = params[:foo]

    mail to: "to@example.org"
  end
end
```

_Given_ a file named "spec/mailers/my_mailer_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe MyMailer do
  it "matches with enqueued mailer" do
    ActiveJob::Base.queue_adapter = :test
    # Works with named parameters
    expect {
      MyMailer.with(foo: 'bar').signup.deliver_later
    }.to have_enqueued_mail(MyMailer, :signup).with(a_hash_including(params: {foo: 'bar'}))
  end
end
```

_When_ I run `rspec spec/mailers/my_mailer_spec.rb`

_Then_ the examples should all pass.

## Parameterize and pass an argument to the mailer

_Given_ a file named "app/mailers/my_mailer.rb" with:

```ruby
class MyMailer < ApplicationMailer

  def signup(user)
    @user = user
    @foo = params[:foo]

    mail to: "to@example.org"
  end
end
```

_Given_ a file named "spec/mailers/my_mailer_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe MyMailer do
  it "matches with enqueued mailer" do
    ActiveJob::Base.queue_adapter = :test
    # Works also with both, named parameters match first argument
    expect {
      MyMailer.with(foo: 'bar').signup('user').deliver_later
    }.to have_enqueued_mail(MyMailer, :signup).with(params: {foo: 'bar'}, args: ['user'])
  end
end
```

_When_ I run `rspec spec/mailers/my_mailer_spec.rb`

_Then_ the examples should all pass.
