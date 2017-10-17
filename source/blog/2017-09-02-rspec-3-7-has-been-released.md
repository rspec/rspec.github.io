--
title: RSpec 3.7 has been released!
author: Sam Phippen
---

RSpec 3.7 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be an easy
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over xxx commits and yyy
merged pull requests from zzz different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Rails: `ActionDispatch::SystemTest` integration (System specs)

In Rails 5.1, a new kind of test was added, called system test. These tests wrap
capybara and Rails to allow for a full stack testing experience from frontend
javascript all the way down to your database.

For a long time, RSpec has had [Feature Specs](https://relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec)
which provide a smiliar integration. There are a few important differences
between feature specs and system specs that are worth enumerating:

1. If you use a javascript enabled driver (like selenium or poltergeist) with
   feature specs your tests run in a different **process** than your Rails app.
   This means that your tests and your code under test cannot share a database
   transaction, and so you cannot use RSpec's built in mechanism to roll back
   database changes, instead requiring a gem like [database
   cleaner](https://github.com/DatabaseCleaner/database_cleaner). With system
   tests, the Rails team has done the hard work to ensure that this is not the
   case, and so you can safely use RSpec's mechanism, without needing an extra
   gem.
2. RSpec's feature specs defaults to using the `Rack::Test` capybara driver. If
   you want to use a javascript enabled test browser, it is on you to manage the
   capybara configuration. For a long time this has proven to be something that
   is tricky to get correct with more advanced integrations like selenium.
   System specs default to using selenium. The difficulty of the configuration
   is hidden by rails, which manipulates capybara and webdriver with chrome on
   your behalf.

As such, we are recommending that users on Rails 5.1 prefer writing system specs
over feature specs for full application integration testing. We'd like to give a
special thanks to [Eileen Uchitelle](https://twitter.com/eileencodes) who lead
the implementation of this feature in Rails.

TODO: usual stats block
