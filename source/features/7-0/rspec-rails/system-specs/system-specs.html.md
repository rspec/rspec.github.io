# System specs

System specs are RSpec's wrapper around Rails' own
  [system tests](https://guides.rubyonrails.org/testing.html#system-testing).

  > System tests allow you to test user interactions with your application,
  > running tests in either a real or a headless browser. System tests use
  > Capybara under the hood.
  >
  > By default, system tests are run with the Selenium driver, using the
  > Chrome browser, and a screen size of 1400x1400. The next section explains
  > how to change the default settings.

  System specs are marked by setting type to :system, e.g. `type: :system`.

  The Capybara gem is automatically required, and Rails includes it in
  generated application Gemfiles. Configure a webserver (e.g.
  `Capybara.server = :webrick`) before attempting to use system specs.

  RSpec **does not** use your `ApplicationSystemTestCase` helper. Instead it
  uses the default `driven_by(:selenium)` from Rails. If you want to override
  this behaviour you need to call `driven_by` in your specs.

  This can either be done manually in the spec files themselves or
  you can use the configuration helpers to do this for every system spec,
  for example by adding the following to `spec/rails_helper.rb`:

  ```ruby
  RSpec.configure do |config|
    ...
    config.before(type: :system) do
      driven_by :selenium_headless # Or your preferred default driver
    end
    ...
  end
  ```

  System specs run in a transaction. So unlike feature specs with
  javascript, you do not need [DatabaseCleaner](https://github.com/DatabaseCleaner/database_cleaner).

## System specs driven by rack_test

_Given_ a file named "spec/system/widget_system_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "Widget management", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "enables me to create widgets" do
    visit "/widgets/new"

    fill_in "Name", :with => "My Widget"
    click_button "Create Widget"

    expect(page).to have_text("Widget was successfully created.")
  end
end
```

_When_ I run `rspec spec/system/widget_system_spec.rb`

_Then_ the exit status should be 0

_And_ the output should contain "1 example, 0 failures".

## The ActiveJob queue_adapter can be changed

_Given_ a file named "spec/system/some_job_system_spec.rb" with:

```ruby
require "rails_helper"

class SomeJob < ActiveJob::Base
  cattr_accessor :job_ran

  def perform
    @@job_ran = true
  end
end

RSpec.describe "spec/system/some_job_system_spec.rb", type: :system do
  describe "#perform_later" do
    before do
      ActiveJob::Base.queue_adapter = :inline
    end

    it "perform later SomeJob" do
      expect(ActiveJob::Base.queue_adapter).to be_an_instance_of(ActiveJob::QueueAdapters::InlineAdapter)

      SomeJob.perform_later

      expect(SomeJob.job_ran).to eq(true)
    end
  end
end
```

_When_ I run `rspec spec/system/some_job_system_spec.rb`

_Then_ the example should pass.

## System specs driven by selenium_chrome_headless

_Given_ a file named "spec/system/widget_system_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe "Widget management", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  it "enables me to create widgets" do
    visit "/widgets/new"

    fill_in "Name", :with => "My Widget"
    click_button "Create Widget"

    expect(page).to have_text("Widget was successfully created.")
  end
end
```

_When_ I run `rspec spec/system/widget_system_spec.rb`

_Then_ the output should contain "1 example, 0 failures"

_And_ the output should not contain "starting Puma"

_And_ the exit status should be 0.
