---
title: RSpec Rails 4.0 has been released!
author: Benoit Tigeot, Jon Rowe and Phil Pirozhkov
---

RSpec Rails 4.0 has been released! Given our commitment to
[semantic versioning](http://semver.org/), we've been delaying the
breaking changes until this update. One notable change is that
we've dropped support for Rails below 4.2.

As usual, if you notice any newly introduced bugs, please let us
know, and we'll release a fix for it ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 258 commits and 56
merged pull requests from 27 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

Support for Rails 6, support for testing ActionCable, ActiveMailbox.

### Breaking changes

RSpec Rails 4 supports only Rails 5 and 6. This is in line with our
new versioning policy which keeps major versions of RSpec Rails in
lock step with versions of Rails.

This means that we no longer support versions of Ruby below 2.2
in line with the supported Ruby versions of Rails 5.

We have only restricted the version of Rails for this version
allow a "soft support" for Rails 4.2 during this transitionary
period but we strongly urge you to upgrade Rails to use 4.0.0.

### Removed version lock with RSpec gems

The `rspec-rails` gem is no longer locked with the versioning of the other RSpec gems, we will now be releasing `rspec-rails` with each new major Rails release, keeping in lock step with their supported major versions.


### Improved JRuby support

We have improved JRuby support and RSpec Rails 4 fully supports JRuby on Rails 5 and 6.
### Support for Action Cable

We now support [channel specs][1] in order to easily test your Action Cable channels.  A `channel spec` pulls in `ActionCable::Channel::TestCase`, including all of the behavior and assertions that it provides, in addition to RSpec's own behavior and expectations.

### Support for Action Mailbox

Rails 6 came with [Action Mailbox][2]. We can now test them using
`:mailbox` flag.

```ruby
```

TODO: We do no have feature test for this...

### Improvements to generators

If you use generators, there is some improvements:
- The default hash syntax is now the Ruby 1.9 style in generated files to match Rails.
- Request specs are generated instead of controller specs by default
- New [generators][3] available (channel, generator, mailbox...)

### Allow configuring Active Job `queue_adapter` in system specs

Some people want to run Active Job with a specific queue adapter. In system
specs you can now choose your desired queue adapter:

```ruby
before do
  ActiveJob::Base.queue_adapter = :inline
end
```

### Silence log output with Puma

By default Puma will no longer print logs when running system specs.

### Ability to manually turn off Active Record support

When using Rails without ActiveRecord or using an alternative ORM
or a database of choice, e.g. Sequel, ROM, Mongoid etc. We can
mistakenly detect ActiveRecord as being used due to other gems
autoloading the constants, we now support manually turning off
Active Record support when not configured with:
`config.use_active_record = false`

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
* Drops support for Ruby below 2.2

[1]: https://relishapp.com/rspec/rspec-rails/v/4-0/docs/channel-specs
[2]: https://guides.rubyonrails.org/action_mailbox_basics.html
[3]: https://relishapp.com/rspec/rspec-rails/v/4-0/docs/generators
