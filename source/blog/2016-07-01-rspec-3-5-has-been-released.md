---
title: RSpec 3.5 has been released!
author: Sam Phippen, Myron Marston and Jon Rowe
---

RSpec 3.5 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over 600 commits and 150
merged pull requests from over 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: `config.when_first_matching_example_defined`

We generally advise that you avoid putting setup logic in `spec_helper.rb` that is
needed by only some of your specs--that way, you can minimize the boot time to
run isolated unit specs. Instead, that kind of setup logic can go in a file in
`spec/support`. Spec files that need it can then require the support file and tag the
example group to opt-in to any associated hooks and module inclusions, e.g.:

~~~ ruby
require 'support/db'

RSpec.describe SomeClassThatUsesTheDB, :db do
  # ...
end
~~~

This works, but it's always felt sub-optimal that both the require and the `:db` tag
are necessary to make this work. It's duplication that happens in every spec file that
uses the DB. If I forget to put the `require 'support/db'` line in a spec file that uses
the DB, I can get in a situation where the spec file fails when run individually, but
passes when run with the entire suite (because other spec files load the support file).

RSpec 3.5 includes a new hook that works nicely in this situation. Instead of requiring
`support/db` in each spec file that needs it, you can configure RSpec to load it if
any examples tagged with `:db` are defined:

~~~ ruby
RSpec.configure do |config|
  config.when_first_matching_example_defined(:db) do
    require 'support/db'
  end
end
~~~

This new `when_first_matching_example_defined` hook fires as soon as the first
example with matching metadata is defined, allowing you to configure things to
be loaded as needed based on metadata.  Of course, this new hook isn't limited to
just this use case, but it's one of the main ways we expect to see it used.

### Core: `config.filter_run_when_matching`

One of the common uses for RSpec's metadata system is focus filtering. Before RSpec 3.5,
you'd configure it like this:

~~~ ruby
RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
~~~

Then you can tag an example or group with `:focus` to have RSpec run just what you've tagged.
When nothing is tagged with `:focus` you want RSpec to ignore this filter, so the
`run_all_when_everything_filtered = true` option makes it do that.

Unfortunately, `run_all_when_everything_filtered` applies globally to _all_ filtering
(not just `:focus` filtering), and it creates some surprising behavior in some situations.
(See [this issue](https://github.com/rspec/rspec-core/issues/1920) for one example).
We realized that it would make a lot more sense to be able to setup `:focus` as a
_conditional_ filter, so in RSpec 3.5 you can do that:

~~~ ruby
RSpec.configure do |config|
  config.filter_run_when_matching :focus
end
~~~

With this configuration, the `:focus` filtering will only apply if any examples
or groups are tagged with `:focus`. It also makes for shorter, simpler configuration!

### Core: Load spec files in order specified at command line

RSpec 3.5 now loads spec files and directories in the order of your
command line arguments. This provides a simple way to order things in a
one-off manner. For example, for a particular spec run if you want your fast
unit specs to run before your slow acceptance specs, you can run RSpec like so:

~~~
$ rspec spec/unit spec/acceptance --order defined
~~~

The `--order defined` bit is only needed if you've configured RSpec to normally
order things randomly (which we recommend as your default).

### Core: Shared example group inclusion changes

RSpec has supported the idea of a _shared context_--a shared example group defined
for the purpose of sharing contextual helpers and hooks--for a long time. You define
a shared context like this:

~~~ ruby
RSpec.shared_context "DB support" do
  let(:db) { MyORM.database }

  # Wrap each example in a transaction...
  around do |ex|
    db.transaction(:rollback => :always, &ex)
  end

  # Interleave example begin/end messages in DB logs so it
  # is clear which SQL statements come from which examples.
  before do |ex|
    db.logger.info "Beginning example: #{ex.metadata[:full_description}"
  end
  after do |ex|
    db.logger.info "Ending example: #{ex.metadata[:full_description}"
  end
end
~~~

To use this shared context, you can explicitly include it in a group with `include_context`:

~~~ ruby
RSpec.describe MyModel do
  include_context "DB support"
end
~~~

We also supported a way of _implicitly_ including the shared context in a group using matching metadata:

~~~ ruby
RSpec.shared_context "DB support", :db do
  # ...
end

# ...

RSpec.describe MyModel, :db do
  # ...
end
~~~

This approach worked OK, but had several significant problems:

* The first argument to `shared_context` (`"DB support"`) doesn't serve a purpose
  beyond labelling what the group is for (which a comment could achieve just as well).
* Some users have expressed surprised that the metadata is treated "special" here and
  isn't simply applied to the shared example group like it is applied to a normal example group.
* It makes it impossible to attach some metadata to a shared example group that will be
  automatically applied to including example groups. For example, maybe you want to temporarily
  add `:skip` or `:focus` metadata to all including groups. There was no way to do this.
* There's no obvious way to make a shared example group get auto-included in every
  example group (e.g. for a global `before` hook or a `let` you want to make available everywhere...).
* It's inconsistent with how module inclusion works (e.g. `config.include DBSupport, :db`).

In RSpec 3.5 we've rectified these problems with a couple of changes.

#### New API: `config.include_context`

You can now define shared context inclusions in your `RSpec.configure` block:

~~~ ruby
RSpec.configure do |config|
  config.include_context "DB support", :db
end
~~~

This aligns with the existing `config.include` API for module inclusions, provides
a way to include shared contexts based on metadata that is less surprising, and
makes it simple to include a shared context in all example groups (just don't
pass a metadata argument).

#### New config option: `config.shared_context_metadata_behavior`

We've also added a config option that lets you determine how shared context
metadata is treated:

~~~ ruby
RSpec.configure do |config|
  config.shared_context_metadata_behavior = :trigger_inclusion
  # or
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
~~~

The former value (`:trigger_inclusion`) is the default and exists only for backwards
compatibility. It treats metadata passed to `RSpec.shared_context` exactly how it was
treated in RSpec 3.4 and before: it triggers inclusion in groups with matching metadata.
We plan to remove support for it in RSpec 4.

The latter value (`:apply_to_host_groups`) opts-in to the new behavior. Instead of
triggering inclusion in groups with matching metadata, it applies the metadata to host
groups.  For example, you could focus on all groups that use the DB by tagging your
shared context:

~~~ ruby
RSpec.shared_context "DB support", :focus do
  # ...
end
~~~

### Expectations: Keyword argument support for the `respond_to` matcher.

Keyword arguments have been a stable language feature for some time now but RSpec
has lacked support for placing expectations upon keyword arguments in a variety of our matchers.

In rspec-expectations 3.5 we add support for checking whether an object responds to a method
using keyword arguments. You'll now be able to check a method's response signature for particular
keyword(s) as well as a count of traditional arguments.

~~~ ruby
expect(my_object).to respond_to(:find).with_keywords(:limit, :offset) }
expect(my_object).to respond_to(:find).with(1).argument.and_keywords(:limit, :offset)
~~~

 We're also expanding the matchers existing capabilities, adding the ability
 to check for a range of arguments, or unlimited arguments in addition to a specific
 number. e.g:

~~~ ruby
expect(my_object).to respond_to(:build).with(2..3).arguments
expect(my_object).to respond_to(:build).with_unlimited_arguments
~~~

A big thank you to Rob Smith for the work you put into making this a part of RSpec.

### Expectations: Minitest integration now works with Minitest 5.6+

While rspec-expectations is normally used with rspec-core, you can easily use it
with other test frameworks.  We provide integration with Minitest.  Simply load
our Minitest support after loading Minitest itself:

~~~ ruby
require 'rspec/expectations/minitest_integration'
~~~

Unfortunately, Minitest 5.6 introduced its own `expect` method which conflicted with
the `expect` method we provide and broke this integration. There's a fix for this in
rspec-expectations 3.5.

### Mocks: Add Minitest integration

While we've long provided Minitest integration for rspec-expectations, we've never
provided the same level of simple integration with rspec-mocks. Instead, users had
to integrate rspec-mocks with Minitest themselves using the lifecycle hooks we provide.
This worked pretty well until the aforementioned `expect` method was added to Minitest 5.6
and broke things for users trying to use rspec-mocks with minitest. In rspec-mocks 3.5,
we now provide first-class support for usage with Minitest.  Just require our integration
file:

~~~ ruby
require 'rspec/mocks/minitest_integration'
~~~

### Rails: Support for Rails 5

The headline here is that RSpec 3.5.0 is compatible with Rails 5. As Rails 5
betas and release candidates have been released, we've been releasing betas of
3.5.0 to keep up alongside Rails. Due to this being a major release of Rails
some APIs that we consume have been deprecated. RSpec is not doing a major
release and so  this only gets exposed to you, our users, in one place:
controller testing.

In [Rails 5](https://github.com/rails/rails/issues/18950) `assigns` and
`assert_template` are "soft deprecated". Controller tests themselves *are not*,
and adding `:type => :controller` to your specs is still 100% supported.
Through Rails 3 and 4 it was both prevalent and idiomatic to use `assigns` in
controller specs. As this is a minor release of RSpec our commitment to SemVer
means that we are not going to break your existing controller specs. For
existing Rails applications that make heavy use of `assigns` adding the
[`rails-controller-testing`](https://github.com/rails/rails-controller-testing)
to your Gemfile will restore `assigns` and `assert_template`. RSpec integrates
with this gem seamlessly, so your controller specs should just continue to work.

For new Rails apps: we don't recommend adding the `rails-controller-testing` gem
to your application. The official recommendation of the Rails team and the RSpec
core team is to write  [request
specs](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec)
instead. Request specs allow you to focus on a single controller action, but
unlike controller tests involve the router, the middleware stack, and both rack
requests and responses. This adds realism to the test that you are writing, and
helps avoid many of the issues that are common in controller specs. In Rails 5,
request specs are significantly faster than either request or controller specs
were in rails 4, thanks to the work by [Eileen Uchitelle](https://twitter.com/eileencodes?lang=en-gb)[^foot_1] of the Rails Committer Team.

The other important feature of Rails 5 we wanted to discuss is ActionCable.
Unfortunately RSpec is not able to provide a clean way of testing
ActionCable at this time. Rails is working on a testing type for ActionCable
slated for release as part of Rails 5.1. We'll be watching that closely and work
something up when it's ready. In the mean time, we suggest you test ActionCable
through a browser, in an integrated fashion.

The work on Rails 5 represented a significant investment by a number of RSpec
Core Team members, and we received significant help from members of the Rails
Commiter and Core teams. We offer kind thanks to everyone that was involved with
making this possible.

## Stats


### Combined:

* **Total Commits**: 625
* **Merged pull requests**: 192
* **62 contributors**: Aaron Stone, Ahmed AbouElhamayed, Al Snow, Alex Altair,
  Alexander Skiba, Alireza Bashiri, Andrew Kozin (aka nepalez), Andrew White,
Anton Rieder, Ben Saunders, Benjamin Quorning, Bradley Schaefer, Bruno Bonamin,
DarthSim, David Rodríguez, Diogo Benicá, Eliot Sykes, Fernando Seror, Gautam
Sawhney, Isaac Betesh, James Coleman, Joe Rafaniello, John Schroeder, Jon Moss,
Jon Rowe, Jun Aruga, Kilian Cirera Sant, Koen Punt, Liss McCabe, Marc Ignacio,
Martin Emde, Matt Jones, Michele Piccirillo, Miklos Fazekas, Myron Marston,
Patrik Wenger, Perry Smith, Peter Swan, Prem Sichanugrist, Rob, Rob Smith, Ryan
Beckman, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev, Simon
Coffey, Thomas Hart II, Timo Schilling, Tobias Bühlmann, Travis Grathwell,
William Jeffries, Wojciech Wnętrzak, Xavier Shay, Yoshihiro Ashida, Yuji
Nakayama, Zshawn Syed, chrisarcand, liam-m, mrageh, sleepingkingstudios, yui-knk

### rspec-core:

* **Total Commits**: 194
* **Merged pull requests**: 66
* **18 contributors**: Alexander Skiba, Alireza Bashiri, Benjamin Quorning,
  Bradley Schaefer, Jon Moss, Jon Rowe, Matt Jones, Michele Piccirillo, Myron
Marston, Patrik Wenger, Perry Smith, Sam Phippen, Simon Coffey, Thomas Hart II,
Travis Grathwell, Yuji Nakayama, mrageh, yui-knk

### rspec-expectations:

* **Total Commits**: 83
* **Merged pull requests**: 25
* **14 contributors**: Alex Altair, Ben Saunders, Benjamin Quorning, Bradley
  Schaefer, James Coleman, Jon Rowe, Myron Marston, Rob Smith, Sam Phippen,
William Jeffries, Yuji Nakayama, Zshawn Syed, chrisarcand, sleepingkingstudios

### rspec-mocks:

* **Total Commits**: 82
* **Merged pull requests**: 28
* **17 contributors**: Andrew Kozin (aka nepalez), Benjamin Quorning, Bradley
  Schaefer, Bruno Bonamin, David Rodríguez, Isaac Betesh, Joe Rafaniello, Jon
Rowe, Kilian Cirera Sant, Marc Ignacio, Martin Emde, Myron Marston, Patrik
Wenger, Ryan Beckman, Sam Phippen, Tobias Bühlmann, Yuji Nakayama

### rspec-rails:

* **Total Commits**: 185
* **Merged pull requests**: 47
* **31 contributors**: Ahmed AbouElhamayed, Al Snow, Andrew White, Anton Rieder,
  Benjamin Quorning, Bradley Schaefer, DarthSim, David Rodríguez, Diogo Benicá,
Eliot Sykes, Fernando Seror, Gautam Sawhney, John Schroeder, Jon Rowe, Jun
Aruga, Koen Punt, Liss McCabe, Miklos Fazekas, Myron Marston, Peter Swan, Prem
Sichanugrist, Rob, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev,
Timo Schilling, Wojciech Wnętrzak, Xavier Shay, Yoshihiro Ashida, Yuji Nakayama

### rspec-support:

* **Total Commits**: 81
* **Merged pull requests**: 26
* **8 contributors**: Aaron Stone, Bradley Schaefer, Jon Rowe, Myron Marston,
  Sam Phippen, Yuji Nakayama, liam-m, sleepingkingstudios

## Docs

### API Docs

* [rspec-core](/documentation/3.5/rspec-core/)
* [rspec-expectations](/documentation/3.5/rspec-expectations/)
* [rspec-mocks](/documentation/3.5/rspec-mocks/)
* [rspec-rails](/documentation/3.5/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### RSpec Core (combining all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta4...v3.5.0)

Enhancements:

* Include any `SPEC_OPTS` in reproduction command printed at the end of
  a bisect run. (Simon Coffey, #2274)

Bug Fixes:

* Handle `--bisect` in `SPEC_OPTS` environment variable correctly so as
  to avoid infinite recursion. (Simon Coffey, #2271)

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:

* Filter out bundler stackframes from backtraces by default, since
  Bundler 1.12 now includes its own frames in stack traces produced
  by using `bundle exec`. (Myron Marston, #2240)
* HTML Formatter uses exception presenter to get failure message
  for consistency with other formatters. (@mrageh, #2222)
* Load spec files in the order of the directories or files passed
  at the command line, making it easy to make some specs run before
  others in a one-off manner.  For example, `rspec spec/unit
  spec/acceptance --order defined` will run unit specs before acceptance
  specs. (Myron Marston, #2253)
* Add new `config.include_context` API for configuring global or
  filtered inclusion of shared contexts in example groups.
  (Myron Marston, #2256)
* Add new `config.shared_context_metadata_behavior = :apply_to_host_groups`
  option, which causes shared context metadata to be inherited by the
  metadata hash of all host groups and examples instead of configuring
  implicit auto-inclusion based on the passed metadata. (Myron Marston, #2256)

Bug Fixes:

* Fix `--bisect` so it works on large spec suites that were previously triggering
  "Argument list too long errors" due to all the spec locations being passed as
  CLI args. (Matt Jones, #2223).
* Fix deprecated `:example_group`-based filtering so that it properly
  applies to matching example groups. (Myron Marston, #2234)
* Fix `NoMethodError` caused by Java backtraces on JRuby. (Michele Piccirillo, #2244)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Add new `config.filter_run_when_matching` API, intended to replace
  the combination of `config.filter_run` and
  `config.run_all_when_everything_filtered` (Myron Marston, #2206)

Bug Fixes:

* Use the encoded string logic for source extraction. (Jon Rowe, #2183)
* Fix rounding issue in duration formatting helper. (Fabersky, Jon Rowe, #2208)
* Fix failure snippet extraction so that `def-end` snippets
  ending with `end`-only line can be extracted properly.
  (Yuji Nakayama, #2215)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Remove unneeded `:execution_result` example group metadata, saving a
  bit of memory. (Myron Marston, #2172)
* Apply hooks registered with `config` to previously defined groups.
  (Myron Marston, #2189)
* `RSpec::Core::Configuration#reporter` is now public API under SemVer.
  (Jon Rowe, #2193)
* Add new `config.when_first_matching_example_defined` hook. (Myron
  Marston, #2175)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.4.4...v3.5.0.beta1)

Enhancements:

* Add `RSpec::Core::ExampleGroup.currently_executing_a_context_hook?`,
  primarily for use by rspec-rails. (Sam Phippen, #2131)

Bug Fixes:

* Ensure `MultipleExceptionError` does not contain a recursive reference
  to itself. (Sam Phippen, #2133)


### RSpec Expectations (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta4...v3.5.0)

**No user facing changes since beta4**

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta3...v3.5.0.beta4)

Bug Fixes:

* Fix `include` matcher so that it provides a valid diff for hashes. (Yuji Nakayama, #916)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Make `rspec/expectations/minitest_integration` work on Minitest::Spec
  5.6+. (Myron Marston, #904)
* Add an alias `having_attributes` for `have_attributes` matcher.
  (Yuji Nakayama, #905)
* Improve `change` matcher error message when block is mis-used.
  (Alex Altair, #908)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Add the ability to raise an error on encountering false positives via
  `RSpec::Configuration#on_potential_false_positives = :raise`. (Jon Rowe, #900)
* When using the custom matcher DSL, support new
  `notify_expectation_failures: true` option for the `match` method to
  allow expectation failures to be raised as normal instead of being
  converted into a `false` return value for `matches?`. (Jon Rowe, #892)

Bug Fixes:

* Allow `should` deprecation check to work on `BasicObject`s. (James Coleman, #898)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.4.0...v3.5.0.beta1)

Enhancements:

* Make `match_when_negated` in custom matcher DSL support use of
  expectations within the match logic. (Chris Arcand, #789)

Bug Fixes:

* Return `true` as expected from passing negated expectations
  (such as `expect("foo").not_to eq "bar"`), so they work
  properly when used within a `match` or `match_when_negated`
  block. (Chris Arcand, #789)

### RSpec Mocks (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta4...v3.5.0)

Enhancements:

* Provides a nice string representation of
  `RSpec::Mocks::MessageExpectation` (Myron Marston, #1095)

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:

* Add `and_throw` to any instance handling. (Tobias Bühlmann, #1068)

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Issue warning when attempting to use unsupported
  `allow(...).to receive(...).ordered`. (Jon Rowe, #1000)
* Add `rspec/mocks/minitest_integration`, to properly integrate rspec-mocks
  with minitest. (Myron Marston, #1065)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Improve error message displayed when using `and_wrap_original` on pure test
  doubles. (betesh, #1063)

Bug Fixes:

* Fix issue that prevented `receive_message_chain(...).with(...)` working
  correctly on "any instance" mocks. (Jon Rowe, #1061)

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.4.1...v3.5.0.beta1)

Bug Fixes:

* Allow `any_instance_of(...).to receive(...)` to use `and_yield` multiple
  times. (Kilian Cirera Sant, #1054)
* Allow matchers which inherit from `rspec-mocks` matchers to be used for
  `allow`. (Andrew Kozin, #1056)
* Prevent stubbing `respond_to?` on partial doubles from causing infinite
  recursion. (Jon Rowe, #1013)
* Prevent aliased methods from disapearing after being mocked with
  `any_instance` (regression from #1043). (Joe Rafaniello, #1060)

### RSpec Support (including all betas of RSpec 3.5.0)

#### 3.5.0 / 2016-07-01
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta4...v3.5.0)

**No user facing changes since beat4**

#### 3.5.0.beta4 / 2016-06-05
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:
* Improve `MethodSignature` to better support keyword arguments. (#250, Rob Smith).

#### 3.5.0.beta3 / 2016-04-02
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta2...v3.5.0.beta3)

Bug Fixes:

* Fix `EncodedString` to properly handle the behavior of `String#split`
  on JRuby when the string contains invalid bytes. (Jon Rowe, #268)
* Fix `ObjectFormatter` so that formatting objects that don't respond to
  `#inspect` (such as `BasicObject`) does not cause `NoMethodError`.
  (Yuji Nakayama, #269)
* Fix `ObjectFormatter` so that formatting recursive array or hash does not
  cause `SystemStackError`. (Yuji Nakayama, #270, #272)

#### 3.5.0.beta2 / 2016-03-10
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0.beta1...v3.5.0.beta2)

No user-facing changes.

#### 3.5.0.beta1 / 2016-02-06
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.4.1...v3.5.0.beta1)


## Footnotes

[^foot_1]: See also Eileen's [talk about request spec performance](https://www.youtube.com/watch?v=oT74HLvDo_A)
