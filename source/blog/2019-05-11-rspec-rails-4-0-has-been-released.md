---
title: RSpec Rails 4.0 has been released!
author: Benoit Tigeot, Jon Rowe and Phil Pirozhkov
---

RSpec Rails 4.0 has been released recently! Given our commitment to
[semantic versioning](http://semver.org/), this update come with 
breaking changes for people that are using Rails below 4.2. If we 
did introduce any bugs, please let us know, and we'll get 
a patch release out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 258 commits and 56
merged pull requests from 27 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

RSpec Rails was release with full support and many improvements for 
Rails 6.

### Breaking changes

This version no longer support Ruby bellow 2.3. We soft support
Rails 4.2 but we encourage you to use rspec-rails with Rails 5
at least.

### JRuby support

We very happy to support JRuby on this new release. You can now use
`rspec-rails` with Rails 5.2 and 6 and JRuby.

### Support for Action Cable

Using a [channel spec][1] it will be easy to test your Action Cable
channels. A `channels spec` is a thin wrapper for an
`ActionCable::Channel::TestCase`, and includes all of the behavior
and assertions that it provides, in addition to RSpec's own 
behavior and expectations.

It also includes helpers from `ActionCable::Connection::TestCase`
to make it possible to test connection behavior.

### Support for Action Mailbox

Rails 6 came with [Action Mailbox][2]. We can now test them using
`:mailbox` flag.

```ruby
```

TODO: We do no have feature test for this...

### Improvements on generators

If you use generators, there is some improvements:
- No more Ruby 1.9 hash syntax in file generated
- Scaffold generator generates request specs instead of 
controller spec
- New [generators][3] available (channel, generator, mailbox...)

### Choose which Active Job `queue_adapteur` in system specs

Some people want to run Active Job with a specific queue. In system
specs you can now choose your desired queue:

```ruby
before do
  ActiveJob::Base.queue_adapter = :inline
end
```

### Silent log with Puma

By default Puma will not print starting logs anymore when you are
running system specs.

### Ability to disable Active Record

Some people use Rails without database connection. They do not need
`ActiveRecord`. You can now choose to disable it in your RSpec config:
`config.use_active_record = false`

### Version sync between RSpec gems

`rspec-rails` no longer follow the version of other RSpec gems, that
means that `rspec-rails` will ask at least rspec-core, 
rspec-expectations, rspec-mocks and rspec-support at version 3.9.0.

## Stats:

* **Total Commits**: 258
* **Merged pull requests**: 56
* **27 contributors**: Andrew White, Anton Rieder, Benoit Tigeot, Jon Rowe,
David Revelo, Giovanni Kock Bonetti, Ignatius Reza, James Dabbs, Joel AZEMAR,
John Hawthorn, Jonathan Rochkind, Kieran O'Grady, Moshe Kamensky,
OKURA Masafumi, Olle Jonsson, Pedro Paiva, Phil Pirozhkov, Penelope Phippen,
Seb Jacobs, Tanbir Hasan, Viacheslav Bobrov, Vladimir Dementyev, Xavier Shay,
alpaca-tc, pavel, ta1kt0me

## Docs

### API Docs

* [rspec-rails](/documentation/4.0/rspec-rails/)

### Cucumber Features

* [rspec-rails](https://relishapp.com/rspec/rspec-rails/v/4-0/)

## Release Notes

### 4.0.0 / 2020-03-24
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.9.1...v4.0.0)

Enhancements:

* Adds support for Rails 6. (Penelope Phippen, Benoit Tigeot, Jon Rowe, #2071)
* Adds support for JRuby on Rails 5.2 and 6
* Add support for parameterised mailers (Ignatius Reza, #2125)
* Add ActionMailbox spec helpers and test type (James Dabbs, #2119)
* Add ActionCable spec helpers and test type (Vladimir Dementyev, #2113)
* Add support for partial args when using `have_enqueued_mail`
  (Ignatius Reza, #2118, #2125)
* Add support for time arguments for `have_enqueued_job` (@alpaca-tc, #2157)
* Improve path parsing in view specs render options. (John Hawthorn, #2115)
* Add routing spec template as an option for generating controller specs.
  (David Revelo, #2134)
* Add argument matcher support to `have_enqueued_*` matchers. (Phil Pirozhkov, #2206)
* Switch generated templates to use ruby 1.9 hash keys. (Tanbir Hasan, #2224)
* Add `have_been_performed`/`have_performed_job`/`perform_job` ActiveJob
  matchers (Isaac Seymour, #1785)
* Default to generating request specs rather than controller specs when
  generating a controller (Luka Lüdicke, #2222)
* Allow `ActiveJob` matchers `#on_queue` modifier to take symbolic queue names. (Nils Sommer, #2283)
* The scaffold generator now generates request specs in preference to controller specs.
  (Luka Lüdicke, #2288)
* Add configuration option to disable ActiveRecord. (Jon Rowe, Phil Pirozhkov, Hermann Mayer, #2266)
*  Set `ActionDispatch::SystemTesting::Server.silence_puma = true` when running system specs.
  (ta1kt0me, Benoit Tigeot, #2289)

Bug Fixes:

* `EmptyTemplateHandler.call` now needs to support an additional argument in
  Rails 6. (Pavel Rosický, #2089)
* Suppress warning from `SQLite3Adapter.represent_boolean_as_integer` which is
  deprecated. (Pavel Rosický, #2092)
* `ActionView::Template#formats` has been deprecated and replaced by
  `ActionView::Template#format`(Seb Jacobs, #2100)
* Replace `before_teardown` as well as `after_teardown` to ensure screenshots
  are generated correctly. (Jon Rowe, #2164)
* `ActionView::FixtureResolver#hash` has been renamed to `ActionView::FixtureResolver#data`.
  (Penelope Phippen, #2076)
* Prevent `driven_by(:selenium)` being called due to hook precedence.
  (Takumi Shotoku, #2188)
* Prevent a `WrongScopeError` being thrown during loading fixtures on Rails
  6.1 development version. (Edouard Chin, #2215)
* Fix Mocha mocking support with `should`. (Phil Pirozhkov, #2256)
* Restore previous conditional check for setting `default_url_options` in feature
  specs, prevents a `NoMethodError` in some scenarios. (Eugene Kenny, #2277)
* Allow changing `ActiveJob::Base.queue_adapter` inside a system spec.
  (Jonathan Rochkind, #2242)
* `rails generate generator` command now creates related spec file (Joel Azemar, #2217)
* Relax upper `capybara` version constraint to allow for Capybara 3.x (Phil Pirozhkov, #2281)
* Clear ActionMailer test mailbox after each example (Benoit Tigeot, #2293)

Breaking Changes:

* Drops support for Rails below 5.0
* Drops support for Ruby below 2.3

[1]: https://relishapp.com/rspec/rspec-rails/v/4-0/docs/channel-specs
[2]: https://edgeguides.rubyonrails.org/action_mailbox_basics.html
[3]: https://relishapp.com/rspec/rspec-rails/v/4-0/docs/generators
