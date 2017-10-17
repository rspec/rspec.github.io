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
from all over the world. This release includes over 127 commits and 31
merged pull requests from 27 different contributors!

It's worth noting: this is a smaller release than usual, as we wanted to get our
Rails System Testing integration to you as quickly as possible.

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

## Stats:

### Combined:

* **Total Commits**: 127
* **Merged pull requests**: 31
* **27 contributors**: Aaron Rosenberg, Alex Shi, Alyssa Ross, Britni Alexander, Dave Woodall, Devon Estes, Hisashi Kamezawa, Ian Ker-Seymer, James Adam, Jim Kingdon, Jon Rowe, Levi Robertson, Myron Marston, Pat Allan, RustyNail, Ryan Lue, Sam Phippen, Samuel Cochran, Sergei Trofimovich, Takeshi Arabiki, Thomas Hart, Tobias Pfeiffer, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, Zhong Zheng, oh_rusty_nail

### rspec-core:

* **Total Commits**: 40
* **Merged pull requests**: 10
* **11 contributors**: Devon Estes, Ian Ker-Seymer, Jon Rowe, Levi Robertson, Myron Marston, Pat Allan, Sam Phippen, Takeshi Arabiki, Thomas Hart, Tobias Pfeiffer, Yuji Nakayama

### rspec-expectations:

* **Total Commits**: 13
* **Merged pull requests**: 2
* **5 contributors**: Jim Kingdon, Myron Marston, Pat Allan, Sam Phippen, Yuji Nakayama

### rspec-mocks:

* **Total Commits**: 14
* **Merged pull requests**: 2
* **6 contributors**: Aaron Rosenberg, Myron Marston, Pat Allan, Sam Phippen, Yuji Nakayama, Zhong Zheng

### rspec-rails:

* **Total Commits**: 38
* **Merged pull requests**: 9
* **16 contributors**: Alex Shi, Alyssa Ross, Britni Alexander, Dave Woodall, Hisashi Kamezawa, James Adam, Jon Rowe, Myron Marston, RustyNail, Ryan Lue, Sam Phippen, Samuel Cochran, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, oh_rusty_nail

### rspec-support:

* **Total Commits**: 22
* **Merged pull requests**: 8
* **6 contributors**: Jon Rowe, Myron Marston, Pat Allan, Sam Phippen, Sergei Trofimovich, Yuji Nakayama

## Docs

### API Docs

* [rspec-core](/documentation/3.7/rspec-core/)
* [rspec-expectations](/documentation/3.7/rspec-expectations/)
* [rspec-mocks](/documentation/3.7/rspec-mocks/)
* [rspec-rails](/documentation/3.7/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release notes:

### RSpec Core
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0...v3.7.0)

Enhancements:

* Add `-n` alias for `--next-failure`. (Ian Ker-Seymer, #2434)
* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #2425, #2427, #2437)
* Do not run `:context` hooks for example groups that have been skipped.
  (Devon Estes, #2442)
* Add `errors_outside_of_examples_count` to the JSON formatter.
  (Takeshi Arabiki, #2448)

Bug Fixes:

* Improve compatibility with frozen string literal flag. (#2425, Pat Allan)

### RSpec Expectations
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #997)

## RSpec Mocks
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #1165)

Bug Fixes:

* Fix `hash_including` and `hash_excluding` so that they work against
  subclasses of `Hash`. (Aaron Rosenberg, #1167)

## RSpec Rails
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0...v3.7.0)

Bug Fixes:

* Prevent "template not rendered" log message from erroring in threaded
  environments. (Samuel Cochran, #1831)
* Correctly generate job name in error message. (Wojciech Wnętrzak, #1814)

Enhancements:

* Allow `be_a_new(...).with(...)` matcher to accept matchers for
  attribute values. (Britni Alexander, #1811)
* Only configure RSpec Mocks if it is fully loaded. (James Adam, #1856)
* Integrate with `ActionDispatch::SystemTestCase`. (Sam Phippen, #1813)

## RSpec Support
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0...v3.7.0)

Enhancements:

* Improve compatibility with `--enable-frozen-string-literal` option
  on Ruby 2.3+. (Pat Allan, #320)
* Add `Support.class_of` for extracting class of any object.
  (Yuji Nakayama, #325)

Bug Fixes:

* Fix recursive const support to not blow up when given buggy classes
  that raise odd errors from `#to_str`. (Myron Marston, #317)
